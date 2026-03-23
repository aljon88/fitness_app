import 'package:flutter/material.dart';
import 'onboarding_wizard_screen.dart';
import 'dashboard_screen.dart';
import '../services/firebase_auth_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isSignUp = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0E21),
              Color(0xFF1A1B3A),
              Color(0xFF2D3561),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: isSmallScreen ? 20 : 60),
                
                // App Logo and Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: isSmallScreen ? 80 : 100,
                          height: isSmallScreen ? 80 : 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6C5CE7).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.smart_toy_rounded,
                            size: isSmallScreen ? 40 : 50,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 24),
                        
                        Text(
                          'AI FITNESS',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'TRAINER',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 32,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 4,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Text(
                            'Smart Movement Detection • Real-time Rep Counting',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 30 : 50),
                
                // Login/Sign Up Form
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Toggle between Login and Sign Up
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = false),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isSignUp ? Color(0xFF6C5CE7) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Login',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: !_isSignUp ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = true),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isSignUp ? Color(0xFF6C5CE7) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Create Account',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: _isSignUp ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        
                        // Form Fields
                        if (_isSignUp) ...[
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline_rounded,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 20),
                        ],
                        
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        
                        if (_isSignUp) ...[
                          SizedBox(height: isSmallScreen ? 16 : 20),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            isPasswordVisible: _isConfirmPasswordVisible,
                            onTogglePassword: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                          ),
                        ],
                        
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        
                        // Login/Sign Up Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _handleEmailAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6C5CE7),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: Color(0xFF6C5CE7).withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              _isSignUp ? 'Create Account' : 'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        if (!_isSignUp) ...[
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              _showForgotPasswordDialog();
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF6C5CE7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 20 : 32),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                  ],
                ),
                
                SizedBox(height: isSmallScreen ? 20 : 32),
                
                // Google Sign In Button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 20 : 32),
                
                // Terms and Privacy
                Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 20 : 40),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDebugInfo,
        backgroundColor: Colors.orange,
        child: Icon(Icons.info_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && !isPasswordVisible,
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: Color(0xFF6C5CE7), size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white60,
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  void _handleEmailAuth() async {
    if (_isSignUp) {
      // Validate sign up form
      if (_nameController.text.isEmpty) {
        _showError('Please enter your full name');
        return;
      }
      if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
        _showError('Please enter a valid email address');
        return;
      }
      if (_passwordController.text.length < 6) {
        _showError('Password must be at least 6 characters');
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('Passwords do not match');
        return;
      }
      
      // Show loading
      _showLoading('Creating account...');
      
      // Create account
      final authService = FirebaseAuthService();
      final result = await authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      
      Navigator.of(context).pop(); // Close loading
      
      if (result.success) {
        _showSuccess(result.message);
        if (result.needsOnboarding) {
          _navigateToOnboarding(_emailController.text.trim());
        } else {
          _navigateToDashboard(_emailController.text.trim());
        }
      } else {
        _showError('Sign-up failed: ${result.message}');
      }
    } else {
      // Validate login form
      if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
        _showError('Please enter a valid email address');
        return;
      }
      if (_passwordController.text.isEmpty) {
        _showError('Please enter your password');
        return;
      }
      
      // Show loading
      _showLoading('Signing in...');
      
      // Sign in
      final authService = FirebaseAuthService();
      final result = await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      Navigator.of(context).pop(); // Close loading
      
      if (result.success) {
        _showSuccess(result.message);
        if (result.needsOnboarding) {
          _navigateToOnboarding(_emailController.text.trim());
        } else {
          _navigateToDashboard(_emailController.text.trim());
        }
      } else {
        _showError('Login failed: ${result.message}');
        print('Login error details: ${result.message}');
      }
    }
  }

  void _signInWithGoogle() async {
    // Show loading dialog
    _showLoading('Signing in with Google...');
    
    // Use the Firebase authentication service
    final authService = FirebaseAuthService();
    final result = await authService.signInWithGoogle();
    
    Navigator.of(context).pop(); // Close loading dialog
    
    if (result.success) {
      _showSuccess(result.message);
      if (result.needsOnboarding) {
        _navigateToOnboardingWithGoogleData(authService);
      } else {
        _navigateToDashboard(authService.userEmail!);
      }
    } else {
      _showError(result.message);
    }
  }

  void _navigateToOnboardingWithGoogleData(FirebaseAuthService authService) {
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => OnboardingWizardScreen(
            initialUserData: {
              'name': authService.currentUser?.displayName ?? '',
              'email': authService.userEmail ?? '',
            },
            onCompleted: (profile) async {
              // Save profile using Firebase
              await authService.completeOnboarding(profile);
              
              // Navigate to dashboard
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(profile: profile),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  Future<bool> _checkIfUserExists() async {
    // This method is no longer needed since we're using Firebase
    // Always return false to go through proper Firebase auth flow
    return false;
  }

  void _navigateToOnboarding(String userEmail) {
    // Get the user's name from the form if available
    String userName = _nameController.text.trim();
    
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => OnboardingWizardScreen(
            initialUserData: {
              'name': userName,
              'email': userEmail,
            },
            onCompleted: (profile) async {
              // Save profile using Firebase
              final authService = FirebaseAuthService();
              await authService.completeOnboarding(profile);
              
              // Navigate to dashboard
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(profile: profile),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  void _navigateToDashboard(String userEmail) async {
    Future.delayed(Duration(milliseconds: 500), () async {
      // Get existing user profile from Firebase
      final authService = FirebaseAuthService();
      Map<String, dynamic>? existingProfile = await authService.getUserProfile();
      
      // If no profile exists, create a default one (shouldn't happen in normal flow)
      existingProfile ??= {
        'name': 'User',
        'age': '25',
        'height': '170',
        'weight': '65',
        'gender': 'prefer_not_to_say',
        'fitnessLevel': 'beginner',
        'allergies': [],
        'motivation': 'Stay Fit',
        'goals': ['Stay Fit'],
        'workoutLocation': 'Floor',
      };
      
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(profile: existingProfile!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  void _navigateToProfile() {
    // For email auth, always go to onboarding since we can't easily check Firebase state here
    _navigateToOnboarding("email_user");
  }
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isEmpty || !emailController.text.contains('@')) {
                Navigator.of(context).pop();
                _showError('Please enter a valid email address');
                return;
              }
              
              final authService = FirebaseAuthService();
              bool success = await authService.resetPassword(emailController.text.trim());
              
              Navigator.of(context).pop();
              if (success) {
                _showSuccess('Password reset link sent to your email!');
              } else {
                _showError('Failed to send reset email. Please check the email address.');
              }
            },
            child: Text(
              'Send Link',
              style: TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showLoading(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: 120,
          height: 80,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF1A1B3A),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF6C5CE7),
                  strokeWidth: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDebugInfo() async {
    final authService = FirebaseAuthService();
    final allUsers = await authService.getAllUsers();
    final currentUser = authService.currentUser;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.bug_report, color: Colors.orange, size: 24),
            SizedBox(width: 12),
            Text(
              'Debug Info',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current User:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              Text(
                currentUser?.email ?? 'None (not logged in)',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'Registered Users (${allUsers.length}):',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              if (allUsers.isEmpty)
                Text(
                  'No users registered yet',
                  style: TextStyle(color: Colors.white70),
                )
              else
                ...allUsers.map((user) => Padding(
                  padding: EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    '• ${user['email']} (${user['authMethod']})',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                )),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firebase Authentication:',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• New users: Sign up → Onboarding → Dashboard\n'
                      '• Existing users: Sign in → Dashboard (skip onboarding)\n'
                      '• Google users: First time → Onboarding, Return → Dashboard\n'
                      '• Only registered users can access the app\n'
                      '• All data stored in Firebase Cloud Firestore',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await authService.signOut();
              Navigator.of(context).pop();
              _showSuccess('Signed out successfully!');
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: Color(0xFF6C5CE7)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}