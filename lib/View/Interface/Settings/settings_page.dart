// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:social_media/Controller/Services/Database/database_services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;
  bool _isUpdatingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = await context.read<DatabaseServices>().getUserProfile();
      _nameController.text = userData['name'] as String? ?? '';
      _bioController.text = userData['bio'] as String? ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await context.read<DatabaseServices>().updateUserProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfileImage() async {
    try {
      setState(() => _isUpdatingProfile = true);
      await context.read<DatabaseServices>().pickImageFromGallery();
      final image = context.read<DatabaseServices>().image;
      if (image != null) {
        await context.read<DatabaseServices>().updateUserProfile(
          profileImage: image,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingProfile = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onBackground,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Settings",
              style: GoogleFonts.poppins(
                color: theme.colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: FutureBuilder<Map<String, dynamic>>(
            future: context.read<DatabaseServices>().getUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final userData = snapshot.data ?? {};
              final profileImage = userData['profileImage'] as String?;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image Section
                      Center(
                        child: Stack(
                          children: [
                            Hero(
                              tag: 'profile_image_own',
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        profileImage ??
                                        'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => Container(
                                          color: theme.colorScheme.surface,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    theme.colorScheme.primary,
                                                  ),
                                            ),
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          color: theme.colorScheme.surface,
                                          child: Icon(
                                            Iconsax.user,
                                            color: theme.colorScheme.primary,
                                            size: 40,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.photo_camera,
                                    color: theme.colorScheme.surface,
                                    size: 20,
                                  ),
                                  onPressed:
                                      _isUpdatingProfile
                                          ? null
                                          : _updateProfileImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name Field
                      Text(
                        'Name',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        enabled: !_isLoading && !_isUpdatingProfile,
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          hintStyle: GoogleFonts.poppins(
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Iconsax.user,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bio Field
                      Text(
                        'Bio',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _bioController,
                        enabled: !_isLoading && !_isUpdatingProfile,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Write something about yourself',
                          hintStyle: GoogleFonts.poppins(
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Iconsax.document_text,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (_isLoading || _isUpdatingProfile)
                                  ? null
                                  : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.surface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    'Save Changes',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed:
                              (_isLoading || _isUpdatingProfile)
                                  ? null
                                  : () => context
                                      .read<DatabaseServices>()
                                      .signOut(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: theme.colorScheme.error),
                          ),
                          child: Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_isUpdatingProfile)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Updating profile picture...',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
