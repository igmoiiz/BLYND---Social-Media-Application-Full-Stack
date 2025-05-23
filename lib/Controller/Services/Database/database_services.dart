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
  final StreamController<List<PostModel>> _postsController =
      StreamController<List<PostModel>>.broadcast();

  // Add cache maps for followers and following
  final Map<String, bool> _followingStatusCache = {};
  final Map<String, List<Map<String, dynamic>>> _followersListCache = {};
  final Map<String, List<Map<String, dynamic>>> _followingListCache = {};
  final Map<String, int> _followersCountCache = {};
  final Map<String, int> _followingCountCache = {};

  // Add getters for cache
  bool isFollowingCached(String userId) =>
      _followingStatusCache.containsKey(userId);
  bool getFollowingStatus(String userId) =>
      _followingStatusCache[userId] ?? false;

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

        //  organizing the data with explicit timestamp
        final post = PostModel(
          postId: postId,
          userEmail: _auth.currentUser!.email ?? '',
          userId: _auth.currentUser!.uid,
          userName: userName,
          userProfileImage: userProfileImage,
          caption: caption,
          postImage: _imageUrl!,
          likeCount: 0,
          createdAt: DateTime.now().toUtc(), // Use UTC time for consistency
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

      // Create a batch write
      final batch = _fireStore.batch();

      if (likedBy.contains(userId)) {
        // Unlike
        batch.update(postRef, {
          'likedBy': FieldValue.arrayRemove([userId]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // Like
        batch.update(postRef, {
          'likedBy': FieldValue.arrayUnion([userId]),
          'likeCount': FieldValue.increment(1),
        });
      }

      // Commit the batch
      await batch.commit();
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

      // Create a batch write
      final batch = _fireStore.batch();
      final postRef = _fireStore.collection("Posts").doc(postId);

      batch.update(postRef, {
        'comments': FieldValue.arrayUnion([commentData]),
      });

      // Commit the batch
      await batch.commit();
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

  // Method to get real-time updates for a post
  Stream<PostModel> getPostStream(String postId) {
    return _fireStore
        .collection("Posts")
        .doc(postId)
        .snapshots()
        .map((doc) => PostModel.fromJson(doc.data()!));
  }

  // Method to get real-time updates for all posts
  Stream<List<PostModel>> getPostsStream() {
    // Listen to posts collection
    _fireStore
        .collection("Posts")
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final posts =
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['postId'] = doc.id;
                return PostModel.fromJson(data);
              }).toList();
          _postsController.add(posts);
        });

    return _postsController.stream;
  }

  // Add this method to refresh posts
  Future<void> refreshPosts() async {
    try {
      // Force a refresh by getting the latest posts
      final posts =
          await _fireStore
              .collection("Posts")
              .orderBy('createdAt', descending: true)
              .get();

      // Convert to PostModel list
      final postList =
          posts.docs.map((doc) {
            final data = doc.data();
            data['postId'] = doc.id;
            return PostModel.fromJson(data);
          }).toList();

      // Update the stream
      _postsController.add(postList);
    } catch (e) {
      _postsController.addError(e);
    }
  }

  // Method to get user profile data with followers/following counts
  Future<Map<String, dynamic>> getUserProfile({String? userId}) async {
    try {
      final targetUserId = userId ?? _auth.currentUser?.uid;
      if (targetUserId == null) throw Exception('User not authenticated');

      final userDoc =
          await _fireStore.collection("users").doc(targetUserId).get();

      if (!userDoc.exists) throw Exception('User profile not found');

      final userData = userDoc.data() ?? {};

      // Get followers and following counts
      final followersCount =
          await _fireStore
              .collection("followers")
              .doc(targetUserId)
              .collection("userFollowers")
              .count()
              .get();

      final followingCount =
          await _fireStore
              .collection("following")
              .doc(targetUserId)
              .collection("userFollowing")
              .count()
              .get();

      // Get posts count
      final postsCount =
          await _fireStore
              .collection("Posts")
              .where('userId', isEqualTo: targetUserId)
              .count()
              .get();

      return {
        ...userData,
        'followersCount': followersCount.count,
        'followingCount': followingCount.count,
        'postsCount': postsCount.count,
        'isFollowing': await isFollowingUser(targetUserId),
      };
    } catch (e) {
      log("Error getting user profile: $e");
      rethrow;
    }
  }

  // Method to get user posts
  Stream<List<PostModel>> getUserPosts({String? userId}) {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId == null) return Stream.value([]);

    return _fireStore
        .collection("Posts")
        .where('userId', isEqualTo: targetUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['postId'] = doc.id;
                return PostModel.fromJson(data);
              }).toList(),
        );
  }

  // Method to follow/unfollow a user with caching
  Future<void> toggleFollow(String targetUserId) async {
    try {
      if (_auth.currentUser == null) throw Exception('User not authenticated');
      if (_auth.currentUser!.uid == targetUserId) return;

      final batch = _fireStore.batch();
      final currentUserId = _auth.currentUser!.uid;

      // Check if already following
      final isFollowing = await isFollowingUser(targetUserId);

      if (isFollowing) {
        // Unfollow
        batch.delete(
          _fireStore
              .collection("following")
              .doc(currentUserId)
              .collection("userFollowing")
              .doc(targetUserId),
        );
        batch.delete(
          _fireStore
              .collection("followers")
              .doc(targetUserId)
              .collection("userFollowers")
              .doc(currentUserId),
        );

        // Update cache
        _followingStatusCache[targetUserId] = false;
        _followersCountCache[targetUserId] =
            (_followersCountCache[targetUserId] ?? 1) - 1;
        _followingCountCache[currentUserId] =
            (_followingCountCache[currentUserId] ?? 1) - 1;
      } else {
        // Follow
        batch.set(
          _fireStore
              .collection("following")
              .doc(currentUserId)
              .collection("userFollowing")
              .doc(targetUserId),
          {'timestamp': FieldValue.serverTimestamp()},
        );
        batch.set(
          _fireStore
              .collection("followers")
              .doc(targetUserId)
              .collection("userFollowers")
              .doc(currentUserId),
          {'timestamp': FieldValue.serverTimestamp()},
        );

        // Update cache
        _followingStatusCache[targetUserId] = true;
        _followersCountCache[targetUserId] =
            (_followersCountCache[targetUserId] ?? 0) + 1;
        _followingCountCache[currentUserId] =
            (_followingCountCache[currentUserId] ?? 0) + 1;
      }

      await batch.commit();
      notifyListeners();
    } catch (e) {
      log("Error toggling follow: $e");
      rethrow;
    }
  }

  // Helper method to check if current user is following a user with caching
  Future<bool> isFollowingUser(String targetUserId) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return false;

    // Check cache first
    if (_followingStatusCache.containsKey(targetUserId)) {
      return _followingStatusCache[targetUserId]!;
    }

    final followingDoc =
        await fireStore
            .collection("following")
            .doc(currentUser.uid)
            .collection("userFollowing")
            .doc(targetUserId)
            .get();

    // Update cache
    _followingStatusCache[targetUserId] = followingDoc.exists;
    return followingDoc.exists;
  }

  // Method to get user followers with caching
  Stream<List<Map<String, dynamic>>> getUserFollowers(String userId) {
    return _fireStore
        .collection("followers")
        .doc(userId)
        .collection("userFollowers")
        .snapshots()
        .asyncMap((snapshot) async {
          final followers = <Map<String, dynamic>>[];
          for (var doc in snapshot.docs) {
            // Check cache first
            if (_followersListCache.containsKey(userId)) {
              final cachedFollowers = _followersListCache[userId]!;
              final cachedFollower = cachedFollowers.firstWhere(
                (f) => f['userId'] == doc.id,
                orElse: () => {},
              );
              if (cachedFollower.isNotEmpty) {
                followers.add(cachedFollower);
                continue;
              }
            }

            final userDoc =
                await _fireStore.collection("users").doc(doc.id).get();
            if (userDoc.exists) {
              final userData = {...userDoc.data()!, 'userId': doc.id};
              followers.add(userData);
            }
          }

          // Update cache
          _followersListCache[userId] = followers;
          _followersCountCache[userId] = followers.length;
          return followers;
        });
  }

  // Method to get user following with caching
  Stream<List<Map<String, dynamic>>> getUserFollowing(String userId) {
    return _fireStore
        .collection("following")
        .doc(userId)
        .collection("userFollowing")
        .snapshots()
        .asyncMap((snapshot) async {
          final following = <Map<String, dynamic>>[];
          for (var doc in snapshot.docs) {
            // Check cache first
            if (_followingListCache.containsKey(userId)) {
              final cachedFollowing = _followingListCache[userId]!;
              final cachedUser = cachedFollowing.firstWhere(
                (f) => f['userId'] == doc.id,
                orElse: () => {},
              );
              if (cachedUser.isNotEmpty) {
                following.add(cachedUser);
                continue;
              }
            }

            final userDoc =
                await _fireStore.collection("users").doc(doc.id).get();
            if (userDoc.exists) {
              final userData = {...userDoc.data()!, 'userId': doc.id};
              following.add(userData);
            }
          }

          // Update cache
          _followingListCache[userId] = following;
          _followingCountCache[userId] = following.length;
          return following;
        });
  }

  // Method to update user profile
  Future<void> updateUserProfile({
    String? name,
    String? bio,
    File? profileImage,
  }) async {
    try {
      if (_auth.currentUser == null) throw Exception('User not authenticated');

      final userRef = _fireStore
          .collection("users")
          .doc(_auth.currentUser!.uid);
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;

      if (profileImage != null) {
        try {
          // Generate a unique filename using timestamp
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'profile_${_auth.currentUser!.uid}_$timestamp.jpg';

          // Upload new profile image to Supabase
          final bytes = await profileImage.readAsBytes();
          await _supabase.storage.from("users").uploadBinary(fileName, bytes);

          // Get public URL
          final imageUrl = _supabase.storage
              .from("users")
              .getPublicUrl(fileName);
          updates['profileImage'] = imageUrl;

          // Delete old profile image if it exists
          final oldUserDoc = await userRef.get();
          if (oldUserDoc.exists) {
            final oldData = oldUserDoc.data() as Map<String, dynamic>;
            final oldImageUrl = oldData['profileImage'] as String?;
            if (oldImageUrl != null) {
              try {
                final oldFileName = oldImageUrl.split('/').last;
                await _supabase.storage.from("users").remove([oldFileName]);
              } catch (e) {
                log("Error deleting old profile image: $e");
              }
            }
          }
        } catch (e) {
          log("Error handling profile image: $e");
          rethrow;
        }
      }

      await userRef.update(updates);
      notifyListeners();
    } catch (e) {
      log("Error updating user profile: $e");
      rethrow;
    }
  }

  // Method to sign out
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      _eventHandler.sucessSnackBar(context, "Signed out successfully");
    } catch (e) {
      log("Error signing out: $e");
      _eventHandler.errorSnackBar(context, "Error signing out");
      rethrow;
    }
  }

  // Method to clear cache for a specific user
  void clearUserCache(String userId) {
    _followingStatusCache.remove(userId);
    _followersListCache.remove(userId);
    _followingListCache.remove(userId);
    _followersCountCache.remove(userId);
    _followingCountCache.remove(userId);
  }

  // Method to clear all cache
  void clearAllCache() {
    _followingStatusCache.clear();
    _followersListCache.clear();
    _followingListCache.clear();
    _followersCountCache.clear();
    _followingCountCache.clear();
  }

  @override
  void dispose() {
    clearAllCache();
    _postsController.close();
    super.dispose();
  }
}
