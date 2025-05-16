import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/Model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices extends ChangeNotifier {
  //  Instance for firebase firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //  Supabase Instance
  final SupabaseClient _supabase = Supabase.instance.client;
  //  Other Variables
  File? _profileImage;
  String? imageUrl = '';

  //  Instance for Firebase Authentication Services
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //  Instance for Image Picker
  final ImagePicker _picker = ImagePicker();

  //  Getters
  File? get profileImage => _profileImage;
  ImagePicker get picker => _picker;
  FirebaseAuth get auth => _auth;

  // Methods for handling profile image

  /// Take profile photo from camera
  Future<void> takeProfilePicture() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (pickedImage != null) {
      _profileImage = File(pickedImage.path);
      notifyListeners();
    }
  }

  /// Pick profile photo from gallery
  Future<void> pickProfileImageFromGallery() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedImage != null) {
      _profileImage = File(pickedImage.path);
      notifyListeners();
    }
  }

  /// Clear selected profile image
  void clearProfileImage() {
    _profileImage = null;
    notifyListeners();
  }

  /// Handle user registration
  Future<bool> registerUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String age,
    required String phone,
  }) async {
    try {
      // Step 1: Create user with Firebase Auth
      final UserCredential authResult = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Step 2: Sign in to Supabase and upload profile image if available
      if (profileImage != null) {
        try {
          // Sign in to Supabase
          final response = await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (response.user != null) {
            // Generate a unique filename
            final fileName = "user_${response.user!.id}";

            // Read image bytes
            final bytes = profileImage!.readAsBytesSync();

            // Upload image to Supabase storage
            await _supabase.storage
                .from('users')
                .uploadBinary(
                  fileName,
                  bytes,
                  fileOptions: const FileOptions(
                    cacheControl: '3600',
                    upsert: true,
                  ),
                );

            // Get the public URL
            imageUrl = _supabase.storage.from('users').getPublicUrl(fileName);
            log('Image uploaded successfully: $imageUrl');
          }
        } catch (e) {
          log('Error uploading image to Supabase: $e');
          // If image upload fails, we'll continue with a default image or empty string
          imageUrl = '';
        }
      } else {
        log('No profile image selected');
        imageUrl = '';
      }

      // Step 3: Create user model
      final UserModel user = UserModel(
        name: name,
        email: email,
        password: password,
        phone: int.parse(phone),
        userName: username,
        age: int.parse(age),
        profileImage: imageUrl!,
      );

      // Step 4: Save user data to Firestore
      await _fireStore
          .collection('users')
          .doc(authResult.user!.uid)
          .set(user.toJson());

      log('User registered successfully');
      return true;
    } catch (e) {
      log('Registration error: ${e.toString()}');
      return false;
    }
  }
}
