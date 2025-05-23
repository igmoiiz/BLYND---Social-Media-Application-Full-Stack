import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/Model/user_model.dart';
import 'package:social_media/View/Authentication/login.dart';
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
  FirebaseFirestore get fireStore => _fireStore;

  // Method to encrypt password using SHA-256
  String encryptPassword(String password) {
    final bytes = utf8.encode(password); // Convert to bytes
    final digest = sha256.convert(bytes); // Apply SHA-256 hashing
    return digest.toString(); // Return the hash as a string
  }

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

  /// Ensure the Supabase bucket exists
  Future<void> _ensureSupabaseBucketExists() async {
    try {
      log('Checking if users bucket exists in Supabase...');

      // Get list of buckets
      final buckets = await _supabase.storage.listBuckets();
      log('Available buckets: ${buckets.map((b) => b.name).join(', ')}');

      final bucketExists = buckets.any((bucket) => bucket.name == 'users');

      if (!bucketExists) {
        log('Creating users bucket in Supabase');
        try {
          await _supabase.storage.createBucket(
            'users',
            BucketOptions(
              public: true, // Make bucket public so we can access images
              fileSizeLimit: '5242880', // 5MB limit
            ),
          );
          log('Users bucket created successfully');
          // Set public access policy for the bucket
          await _supabase.storage.createBucket(
            'users',
            BucketOptions(
              public: true, // Make bucket public so we can access images
              fileSizeLimit: '5242880', // 5MB limit
            ),
          );
          log('Public access policy set for users bucket');
        } catch (e) {
          log('Error creating bucket: $e');
          if (e is StorageException) {
            log('Storage error details: ${e.message}');
          }
        }
      } else {
        log('Users bucket already exists');

        // Note: Bucket permissions are managed through Supabase dashboard
        // or when creating the bucket with BucketOptions(public: true)
        log('Make sure the bucket is set to public in the Supabase dashboard');
      }
    } catch (e) {
      log('Error checking/creating bucket: $e');
      if (e is StorageException) {
        log('Storage error details: ${e.message}');
      }
    }
  }

  /// Upload profile image to Supabase storage
  Future<String> _uploadProfileImageToSupabase() async {
    if (_profileImage == null) {
      log('No profile image to upload');
      return '';
    }

    try {
      // Ensure bucket exists
      await _ensureSupabaseBucketExists();

      // Generate a unique filename using timestamp to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'user_$timestamp.jpg'; // Add extension for proper MIME type

      log('Uploading image: $fileName');

      // Read image bytes
      final bytes = await _profileImage!.readAsBytes();
      log('Image size: ${bytes.length} bytes');

      // Check if we have a session
      final hasSession = _supabase.auth.currentSession != null;
      log('Supabase session available: $hasSession');

      try {
        // Upload image to Supabase storage
        log('Attempting to upload image to Supabase storage...');
        await _supabase.storage
            .from('users')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
                contentType: 'image/jpeg', // Specify content type
              ),
            );

        // Get the public URL
        final publicUrl = _supabase.storage
            .from('users')
            .getPublicUrl(fileName);
        log('Image uploaded successfully. Public URL: $publicUrl');

        return publicUrl;
      } catch (uploadError) {
        log('First upload attempt failed: $uploadError');

        // If we're here, the upload failed. Let's try a different approach.
        // Some Supabase configurations require a specific setup for unauthenticated uploads.

        // Try with a different file name (sometimes helps with caching issues)
        final newFileName = 'user_${timestamp + 1}.jpg';
        log('Trying again with different filename: $newFileName');

        await _supabase.storage
            .from('users')
            .uploadBinary(
              newFileName,
              bytes,
              fileOptions: const FileOptions(
                cacheControl: '0', // No caching
                upsert: true,
                contentType: 'image/jpeg',
              ),
            );

        final publicUrl = _supabase.storage
            .from('users')
            .getPublicUrl(newFileName);
        log('Second attempt successful. Public URL: $publicUrl');

        return publicUrl;
      }
    } catch (e) {
      log('Error uploading image to Supabase: $e');
      // Print detailed error information
      if (e is StorageException) {
        log('Storage error code: ${e.statusCode}');
        log('Storage error message: ${e.message}');
        log('Storage error details: ${e.error}');
      } else if (e is AuthException) {
        log('Auth error: ${e.message}');
      }
      return '';
    }
  }

  /// Handle user login
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      log('Starting user login process');

      // Step 1: Sign in with Firebase Auth
      log('Step 1: Authenticating with Firebase');
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authResult.user == null) {
        log('Authentication failed: No user returned');
        return null;
      }

      log(
        'Firebase authentication successful for user: ${authResult.user!.uid}',
      );

      // Step 2: Fetch user data from Firestore
      log('Step 2: Fetching user data from Firestore');
      final DocumentSnapshot userDoc =
          await _fireStore.collection('users').doc(authResult.user!.uid).get();

      if (!userDoc.exists) {
        log('User document not found in Firestore');
        return null;
      }

      log('User data retrieved successfully');

      // Step 3: Convert document to UserModel
      final userData = userDoc.data() as Map<String, dynamic>;
      final UserModel user = UserModel.fromJson(userData);

      // Step 4: Verify password (optional additional security)
      final encryptedPassword = encryptPassword(password);
      if (user.password != encryptedPassword) {
        log('Password verification failed');
        // Sign out from Firebase as the password doesn't match
        await _auth.signOut();
        return null;
      }

      log('Login successful');
      return user;
    } catch (e) {
      log('Login error: ${e.toString()}');
      return null;
    }
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
      log('Starting user registration process');

      // Step 1: Create user with Firebase Auth
      log('Step 1: Creating Firebase Auth user');
      final UserCredential authResult = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      log('Firebase Auth user created: ${authResult.user?.uid}');

      // Step 2: Upload profile image to Supabase (if available)
      String profileImageUrl = '';

      if (_profileImage != null) {
        log('Step 2: Preparing to upload profile image');

        // First, try to create a Supabase account with the same credentials
        // This is optional and we'll proceed even if it fails
        try {
          log('Attempting to create Supabase account');
          await _supabase.auth.signUp(email: email, password: password);
          log('Supabase account created successfully');
        } catch (authError) {
          // If account already exists, try to sign in
          log('Could not create Supabase account: $authError');
          try {
            log('Attempting to sign in to existing Supabase account');
            await _supabase.auth.signInWithPassword(
              email: email,
              password: password,
            );
            log('Signed in to Supabase successfully');
          } catch (signInError) {
            // If sign-in fails, we'll continue without authentication
            log('Could not sign in to Supabase: $signInError');
            log('Will attempt to upload without authentication');
          }
        }

        // Now try to upload the image
        try {
          log('Uploading profile image');
          profileImageUrl = await _uploadProfileImageToSupabase();
          log('Profile image uploaded: $profileImageUrl');
        } catch (uploadError) {
          log('Failed to upload profile image: $uploadError');
          profileImageUrl = '';
        }
      } else {
        log('No profile image selected');
      }

      // Step 3: Create user model with encrypted password
      log('Step 3: Creating user model');
      final UserModel user = UserModel(
        name: name,
        email: email,
        password: encryptPassword(password), // Store encrypted password
        phone: int.parse(phone),
        userName: username,
        age: int.parse(age),
        profileImage: profileImageUrl,
      );

      // Step 4: Save user data to Firestore
      log('Step 4: Saving user data to Firestore');
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

  // Method to sign the user out of the software
  Future<bool> signUserOut(BuildContext context) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signing out...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Clear any cached data
      _profileImage = null;
      imageUrl = '';
      notifyListeners();

      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Supabase if there's an active session
      if (_supabase.auth.currentSession != null) {
        await _supabase.auth.signOut();
      }

      // Clear any stored tokens or credentials
      await _fireStore.terminate();

      if (context.mounted) {
        // Navigate to login page
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => LoginPage()),
          (route) => false, // Remove all previous routes
        );
      }

      return true;
    } catch (error) {
      log("Error Signing Out: $error");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}
