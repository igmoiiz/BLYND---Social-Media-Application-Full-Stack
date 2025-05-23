// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: theme.colorScheme.onBackground,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'v1.0.0',
                            style: GoogleFonts.poppins(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // App Logo and Name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Image.asset(
                                          'assets/icons/icon_blynd_dark.png',
                                          height: size.height * 0.4,
                                          width: size.width * 0.6,
                                        )
                                        : Image.asset(
                                          'assets/icons/icon_blynd_light.png',
                                          height: size.height * 0.4,
                                          width: size.width * 0.6,
                                        ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Social Media App',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // About Section
                    _buildSection(
                      theme,
                      'About',
                      'A modern social media application built with Flutter, featuring real-time interactions, beautiful UI, and seamless user experience.',
                      Iconsax.info_circle,
                    ),
                    const SizedBox(height: 24),

                    // Developer Section
                    _buildSection(
                      theme,
                      'Developer',
                      'Developed with ❤️ by Moaiz\nA passionate Flutter developer dedicated to creating beautiful and functional applications.',
                      Iconsax.user,
                    ),
                    const SizedBox(height: 24),

                    // Tech Stack Section
                    _buildSection(
                      theme,
                      'Tech Stack',
                      '• Flutter & Dart\n• Firebase (Authentication, Firestore)\n• Supabase (Storage)\n• Provider (State Management)\n• Google Fonts & Iconsax Icons\n• Lottie Animations',
                      Iconsax.code,
                    ),
                    const SizedBox(height: 24),

                    // Features Section
                    _buildSection(
                      theme,
                      'Features',
                      '• Real-time posts and interactions\n• User profiles and following system\n• Image upload and storage\n• Comments and likes\n• Beautiful UI with animations\n• Dark/Light theme support',
                      Iconsax.star,
                    ),
                    const SizedBox(height: 24),

                    // Contact Section
                    _buildSection(
                      theme,
                      'Contact',
                      'Feel free to reach out for any questions or suggestions!',
                      Iconsax.message,
                    ),
                    const SizedBox(height: 24),

                    // Social Media Links
                    _buildSocialLinks(theme),
                    const SizedBox(height: 40),

                    // Footer
                    Center(
                      child: Text(
                        '© 2025 Social Media App. All rights reserved.',
                        style: GoogleFonts.poppins(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.6,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    _buildAnimation(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    String title,
    String content,
    IconData icon,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLinks(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.link,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Connect With Me',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildSocialButton(
                    theme: theme,
                    label: 'Email',
                    icon: Iconsax.message,
                    url: 'mailto:moaiz3110@gmail.com',
                  ),
                  _buildSocialButton(
                    theme: theme,
                    label: 'GitHub',
                    icon: FontAwesomeIcons.github,
                    url: 'https://github.com/igmoiiz',
                  ),
                  _buildSocialButton(
                    theme: theme,
                    label: 'LinkedIn',
                    icon: FontAwesomeIcons.linkedinIn,
                    url: 'https://www.linkedin.com/in/moaiz-baloch-a615392b4',
                  ),
                  _buildSocialButton(
                    theme: theme,
                    label: 'Instagram',
                    icon: Iconsax.instagram,
                    url: 'https://www.instagram.com/ig_moiiz',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required String url,
  }) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    return Lottie.asset(
      "assets/animations/BLYND - Social Media.json",
      fit: BoxFit.cover,
    );
  }
}
