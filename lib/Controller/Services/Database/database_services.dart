// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/Controller/input_controllers.dart';
import 'package:social_media/Model/post_model.dart';
import 'package:social_media/Utils/event_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseServices extends ChangeNotifier {
  //  Firebase FireStore Instance
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  //  Supabase Instance
  final SupabaseClient _supabase = Supabase.instance.client;
  //  Firebase Authenticaation Instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //  image Picker Instnces
  final ImagePicker _picker = ImagePicker();
  //  Other Variables
  String? _imageUrl;
  File? _image;
  //  input Controller Instance
  final InputControllers _inputControllers = InputControllers();
  //  Instance for event handler functions
  final EventHandler _eventHandler = EventHandler();
  //  getters
  FirebaseFirestore get fireStore => _fireStore;
  FirebaseAuth get auth => _auth;
  SupabaseClient get supabase => _supabase;
  ImagePicker get picker => _picker;
  String? get imageUrl => _imageUrl;
  File? get image => _image;
  InputControllers get inputControllers => _inputControllers;

  //  Method to pick an image from the gallery
  Future<void> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Optimize image quality
      );
      log("Image Picked from Gallery");
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        log('Image file path: ${_image!.path}');
      } else {
        log("No Image Picked");
      }
      notifyListeners();
    } catch (error) {
      log("Error While Picking Up the Image: $error", error: error);
      rethrow;
    }
  }

  //  Method to Create a new Post
  Future<void> createPost(String? caption, BuildContext context) async {
    try {
      // Validate user authentication
      if (_auth.currentUser == null) {
        _eventHandler.errorSnackBar(context, "User not authenticated");
        return;
      }

      // Validate image
      if (_image == null) {
        _eventHandler.errorSnackBar(context, "Please Select an Image");
        notifyListeners();
        return;
      }

      // Validate caption
      if (caption == null || caption.trim().isEmpty) {
        _eventHandler.errorSnackBar(
          context,
          "Please Write a caption for the post",
        );
        return;
      }

      // Validate image file
      if (!await _image!.exists()) {
        _eventHandler.errorSnackBar(context, "Selected image file is invalid");
        return;
      }

      // Check image file size (max 5MB)
      final imageSize = await _image!.length();
      if (imageSize > 5 * 1024 * 1024) {
        _eventHandler.errorSnackBar(
          context,
          "Image size should be less than 5MB",
        );
        return;
      }

      String postId = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = 'post_$postId.jpg';

      _inputControllers.isLoading = true;
      notifyListeners();

      try {
        //  Upload the image to Supabase Storage Bucket
        final bytes = await _image!.readAsBytes();
        await _supabase.storage.from("posts").uploadBinary(fileName, bytes);

        //  Get the public url of the uploaded image
        _imageUrl = supabase.storage.from("posts").getPublicUrl(fileName);

        // Fetch user document with timeout
        DocumentSnapshot userDoc = await _fireStore
            .collection("users")
            .doc(_auth.currentUser!.uid)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw TimeoutException('Failed to fetch user data');
              },
            );

        // Validate user document
        if (!userDoc.exists) {
          throw Exception('User profile not found');
        }

        // Extract and validate user data
        final userData = userDoc.data() as Map<String, dynamic>;
        final userName = userData['name'] as String?;
        final userProfileImage = userData['profileImage'] as String?;

        if (userName == null || userProfileImage == null) {
          throw Exception('Invalid user profile data');
        }

        //  organizing the data
        final post = PostModel(
          postId: postId,
          userEmail: _auth.currentUser!.email ?? '',
          userId: _auth.currentUser!.uid,
          userName: userName,
          userProfileImage: userProfileImage,
          caption: caption,
          postImage: _imageUrl!,
          likeCount: 0,
          createdAt: DateTime.now(),
        );

        //  Upload Data to Firebase FireStore with timeout
        await _fireStore
            .collection("Posts")
            .doc(postId)
            .set(post.toJson())
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw TimeoutException('Failed to save post data');
              },
            );

        // Success handling
        _inputControllers.isLoading = false;
        _inputControllers.descriptionController.clear();
        _image = null;
        _imageUrl = null;
        notifyListeners();

        _eventHandler.sucessSnackBar(context, "Post created successfully!");
      } catch (error) {
        // Cleanup on error
        if (_imageUrl != null) {
          try {
            await _supabase.storage.from("posts").remove([fileName]);
          } catch (e) {
            log("Error cleaning up uploaded image: $e");
          }
        }
        rethrow;
      }
    } on TimeoutException catch (error) {
      _eventHandler.errorSnackBar(
        context,
        "Operation timed out. Please try again.",
      );
      log("Timeout error: $error");
    } on FirebaseException catch (error) {
      _eventHandler.errorSnackBar(context, "Firebase error: ${error.message}");
      log("Firebase error: $error");
    } on Exception catch (error) {
      _eventHandler.errorSnackBar(
        context,
        "An error occurred: ${error.toString()}",
      );
      log("Error occurred while creating post: $error");
    } finally {
      _inputControllers.isLoading = false;
      notifyListeners();
    }
  }

  // Method to like/unlike a post
  Future<void> toggleLike(String postId) async {
    try {
      if (_auth.currentUser == null) return;

      final postRef = _fireStore.collection("Posts").doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) return;

      final post = PostModel.fromJson(postDoc.data()!);
      final likedBy = post.likedBy ?? [];
      final userId = _auth.currentUser!.uid;

      if (likedBy.contains(userId)) {
        // Unlike
        await postRef.update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // Like
        await postRef.update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (error) {
      log("Error toggling like: $error");
      rethrow;
    }
  }

  // Method to add a comment
  Future<void> addComment(String postId, String comment) async {
    try {
      if (_auth.currentUser == null) return;

      final userDoc =
          await _fireStore
              .collection("users")
              .doc(_auth.currentUser!.uid)
              .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final commentData = {
        'userId': _auth.currentUser!.uid,
        'userName': userData['name'] as String,
        'userProfileImage': userData['profileImage'] as String,
        'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _fireStore.collection("Posts").doc(postId).update({
        'comments': FieldValue.arrayUnion([commentData]),
      });
    } catch (error) {
      log("Error adding comment: $error");
      rethrow;
    }
  }

  // Method to check if current user has liked a post
  bool hasUserLikedPost(List<String>? likedBy) {
    if (_auth.currentUser == null || likedBy == null) return false;
    return likedBy.contains(_auth.currentUser!.uid);
  }
}
