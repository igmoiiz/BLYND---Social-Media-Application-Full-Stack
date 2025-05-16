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
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
            _supabase.auth
                .signInWithPassword(email: email, password: password)
                .then((value) {
                  final fileName = "user_${_supabase.auth.currentUser!.id}";
                  final bytes = profileImage!.readAsBytesSync();
                  _supabase.storage.from('users').uploadBinary(fileName, bytes);
                  imageUrl = _supabase.storage
                      .from('users')
                      .getPublicUrl(fileName);
                });

            final UserModel user = UserModel(
              name: name,
              email: email,
              password: password,
              phone: int.parse(phone),
              userName: username,
              age: int.parse(age),
              profileImage: imageUrl!,
            );

            // Save the user data in Firestore
            _fireStore
                .collection('users')
                .doc(value.user!.uid)
                .set(user.toJson());
          })
          .onError((error, stackTrace) {
            log(error.toString());
          });
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
