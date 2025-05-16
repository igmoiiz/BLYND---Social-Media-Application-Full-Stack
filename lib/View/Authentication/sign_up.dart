// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  // Form keys for each tab
  final _profileFormKey = GlobalKey<FormState>();
  final _accountFormKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();

  // State variables
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _privacyPolicyRead = false;
  int _currentStep = 0;
  late TabController _tabController;

  // Profile photo
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    _tabController.addListener(() {
      setState(() {
        _currentStep = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Take profile photo from camera
  Future<void> _takePicture() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  // Pick profile photo from gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  // Show image source selection dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Choose Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a picture'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _takePicture();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImageFromGallery();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _nextTab() {
    if (_currentStep == 0) {
      // Validate profile information
      if (_profileFormKey.currentState!.validate()) {
        _tabController.animateTo(_currentStep + 1);
      }
    } else if (_currentStep == 1) {
      // Validate account information
      if (_accountFormKey.currentState!.validate()) {
        _tabController.animateTo(_currentStep + 1);
      }
    }
  }

  void _previousTab() {
    if (_currentStep > 0) {
      _tabController.animateTo(_currentStep - 1);
    }
  }

  // Common validator
  String? _requiredFieldValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  // Username validator
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, dots, and underscores';
    }
    return null;
  }

  // Email validator
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validator
  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Confirm password validator
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Age validator
  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your age';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number';
    }
    if (age < 13) {
      return 'You must be at least 13 years old';
    }
    if (age > 120) {
      return 'Please enter a valid age';
    }
    return null;
  }

  // Phone number validator
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withOpacity(0.1),
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 16,
              left: 16,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: colorScheme.primary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Main content
            Container(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  // Header
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Row(
                      children: [
                        _buildStepIndicator(0, "Profile"),
                        _buildStepConnector(),
                        _buildStepIndicator(1, "Account"),
                        _buildStepConnector(),
                        _buildStepIndicator(2, "Privacy"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tabbed content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildProfileTab(colorScheme),
                        _buildAccountTab(colorScheme),
                        _buildPrivacyPolicyTab(colorScheme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isActive || isCompleted
                      ? colorScheme.secondary
                      : colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: colorScheme.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                      : null,
            ),
            child: Center(
              child:
                  isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                        '${step + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color:
                  isActive
                      ? colorScheme.secondary
                      : colorScheme.primary.withOpacity(0.7),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 3,
      color: colorScheme.primary.withOpacity(0.1),
    );
  }

  Widget _buildProfileTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text(
              'Tell us about yourself',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Profile photo
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.secondary.withOpacity(0.5),
                          width: 2,
                        ),
                        image:
                            _profileImage != null
                                ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          _profileImage == null
                              ? Icon(
                                Icons.person,
                                size: 60,
                                color: colorScheme.primary.withOpacity(0.4),
                              )
                              : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Optional text
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Optional: You can add a photo now or later',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.primary.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Full Name
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
              validator: (value) => _requiredFieldValidator(value, 'full name'),
            ),
            const SizedBox(height: 16),

            // Username
            _buildTextField(
              controller: _usernameController,
              label: 'Username',
              hint: 'Choose a unique username',
              icon: Icons.alternate_email,
              keyboardType: TextInputType.text,
              validator: _validateUsername,
            ),
            const SizedBox(height: 16),

            // Age
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              hint: 'Enter your age',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              validator: _validateAge,
            ),
            const SizedBox(height: 40),

            // Next button
            _buildActionButton(
              label: 'NEXT',
              onPressed: _nextTab,
              icon: Icons.arrow_forward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _accountFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text(
              'Set up your account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),

            // Phone
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),

            // Password
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Create a strong password',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscurePassword,
              validator: _validatePassword,
              onTogglePassword: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              validator: _validateConfirmPassword,
              onTogglePassword: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 40),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'BACK',
                    onPressed: _previousTab,
                    icon: Icons.arrow_back,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    label: 'NEXT',
                    onPressed: _nextTab,
                    icon: Icons.arrow_forward,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyTab(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Privacy Policy & Terms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Privacy policy content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _privacyPolicyText,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Terms of Service',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _termsOfServiceText,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Checkboxes
          Row(
            children: [
              Checkbox(
                value: _privacyPolicyRead,
                activeColor: colorScheme.secondary,
                onChanged: (value) {
                  setState(() {
                    _privacyPolicyRead = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  'I have read the Privacy Policy',
                  style: TextStyle(fontSize: 14, color: colorScheme.primary),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                activeColor: colorScheme.secondary,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  'I agree to the Terms of Service and Privacy Policy',
                  style: TextStyle(fontSize: 14, color: colorScheme.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'BACK',
                  onPressed: _previousTab,
                  icon: Icons.arrow_back,
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  label: 'REGISTER',
                  onPressed:
                      _agreeToTerms && _privacyPolicyRead
                          ? _handleRegistration
                          : null,
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sign in option
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(color: colorScheme.primary.withOpacity(0.7)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    String? Function(String?)? validator,
    VoidCallback? onTogglePassword,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: colorScheme.surface,
          errorMaxLines: 2,
          prefixIcon: Icon(icon, color: colorScheme.secondary),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: colorScheme.primary.withOpacity(0.7),
                    ),
                    onPressed: onTogglePassword,
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.secondary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required IconData icon,
    bool isOutlined = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 50,
      decoration:
          isOutlined
              ? null
              : BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.secondary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isOutlined ? Colors.transparent : colorScheme.secondary,
          foregroundColor: isOutlined ? colorScheme.secondary : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                isOutlined
                    ? BorderSide(color: colorScheme.secondary, width: 1.5)
                    : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isOutlined && icon == Icons.arrow_back) Icon(icon, size: 18),
            if (isOutlined && icon == Icons.arrow_back)
              const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            if (!isOutlined || icon != Icons.arrow_back)
              const SizedBox(width: 8),
            if (!isOutlined || icon != Icons.arrow_back) Icon(icon, size: 18),
          ],
        ),
      ),
    );
  }

  // Handle registration process
  void _handleRegistration() {
    // Here you would normally connect to your authentication service
    // and register the user with the provided information

    // For now we'll just show a success dialog
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Registration Successful'),
            content: const Text(
              'Your account has been created successfully! You can now log in with your credentials.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(); // Go back to login screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  final String _privacyPolicyText = '''
Our app is committed to protecting your privacy. We collect personal information such as your name, email address, and demographic information to provide you with a personalized experience.

We use this information to:
• Create and manage your account
• Provide you with personalized content and recommendations
• Improve our services and develop new features
• Communicate with you about updates and new features

We may share your information with third-party service providers who assist us in operating our app, conducting our business, or serving you. These providers have access to your personal information only to perform specific tasks on our behalf and are obligated to maintain its confidentiality.

We implement a variety of security measures to maintain the safety of your personal information. However, no method of transmission over the Internet or method of electronic storage is 100% secure.

You have the right to access, update, or delete your personal information at any time through your account settings.

By using our app, you consent to our privacy policy and agree to its terms.
''';

  final String _termsOfServiceText = '''
By accessing or using our app, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, you may not access the app.

CONTENT AND CONDUCT
• You are responsible for all content you post and activity that occurs under your account.
• You must not post content that is illegal, offensive, threatening, defamatory, or infringing on intellectual property rights.
• You must not use the app to engage in any illegal activities or to harass, bully, or harm others.

ACCOUNT TERMINATION
We reserve the right to terminate or suspend your account and access to the app at our sole discretion, without notice, for conduct that we believe violates these Terms of Service or is harmful to other users, us, or third parties, or for any other reason.

INTELLECTUAL PROPERTY
The app and all its original content, features, and functionality are owned by us and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.

DISCLAIMER OF WARRANTIES
The app is provided "as is" without warranties of any kind, either express or implied.

LIMITATION OF LIABILITY
In no event shall we be liable for any indirect, incidental, special, consequential, or punitive damages, including lost profit, lost revenue, or similar damages.

CHANGES TO TERMS
We reserve the right to modify or replace these terms at any time. It is your responsibility to check the terms periodically for changes.
''';
}
