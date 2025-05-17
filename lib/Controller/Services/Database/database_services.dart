import 'dart:developer';
import 'dart:io';

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
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      log("Image Picked from Gaallery");
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        log('Image file path: ${_image!.path}');
      } else {
        log("No Image Picked");
      }
      notifyListeners();
    } catch (error) {
      log("Error While Picking Up the Image: $error");
    }
  }

  //  Methodd to Create a new Post
  Future<void> createPost(String? caaption, BuildContext context) async {
    //  Check if the imaage is selectedd or not
    if (_image == null) {
      _eventHandler.errorSnackBar(context, "Please Select a Image");
      notifyListeners();
      return;
    }

    //  Check if the captions are empty or not
    if (_inputControllers.descriptionController.text.isEmpty) {
      _eventHandler.errorSnackBar(
        context,
        "Please Write a caption for the post",
      );
    }

    String postId = DateTime.now().millisecondsSinceEpoch.toString();
    String fileName = 'post_$postId.jpg';
    try {
      _inputControllers.isLoading = true;
      notifyListeners();

      //  Upload the image to Supaabase Storaage Bucket
      final bytes = await _image!.readAsBytes();
      await _supabase.storage.from("posts").uploadBinary(fileName, bytes);

      //  Get the public url of the uploaded imaage
      _imageUrl = supabase.storage.from("posts").getPublicUrl(fileName);

      // First, fetch the user document
      DocumentSnapshot userDoc =
          await _fireStore
              .collection("users")
              .doc(_auth.currentUser!.uid)
              .get();

      // Extract the profile image URL from the document
      String userProfileImage = userDoc.get('profileImage') as String;

      //  organizing the data
      final post = PostModel(
        postId: postId,
        userEmail: _auth.currentUser!.email,
        userId: _auth.currentUser!.uid,
        userName: userDoc['name'],
        userProfileImage: userProfileImage,
        caption: caaption!,
        postImage: imageUrl!,
        likeCount: 0,
      );
      //  Upload Data to Firebase FireStore
      await _fireStore.collection("Posts").doc(postId).set(post.toJson()).then((
        value,
      ) {
        _inputControllers.isLoading = false;
        _inputControllers.descriptionController.clear();
        _image = null;
        notifyListeners();
      });
    } catch (error) {
      log("Error occured while creating post :$error");
    }
  }
}
