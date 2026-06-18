import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../services/user_storage_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/mock_auth_service.dart';
import '../services/unified_auth_service.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';
import '../widgets/navigation_widgets.dart';
import '../models/navigation_state.dart';
import 'auth_screen.dart';
import 'quick_profile_setup.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final NavigationService _navigationService = NavigationService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    
    // Listen for navigation service changes (which includes auth state changes)
    _navigationService.addListener(_onNavigationStateChanged);
  }

  @override
  void dispose() {
    _navigationService.removeListener(_onNavigationStateChanged);
    super.dispose();
  }

  void _onNavigationStateChanged() {
    // When auth state changes, reload profile data
    if (mounted) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    // Use unified auth service
    final authService = UnifiedAuthService();
    authService.printAuthStatus();
    
    if (!authService.isLoggedIn) {
      print('⚠️ Profile screen: No user logged in');
      setState(() {
        _profile = null;
        _isLoading = false;
      });
      return;
    }
    
    final userEmail = authService.getCurrentUserEmail()!;
    
    UserProfile? profile;
    
    // First try UserProfileService (standardized way)
    print('🔍 Trying UserProfileService...');
    profile = await _profileService.getUserProfile();
    
    if (profile != null) {
      print('✅ Profile screen: Loaded profile from UserProfileService for ${profile.name}');
    } else {
      // Fallback: Try UserStorageService (onboarding data)
      print('🔍 Trying UserStorageService fallback...');
      final localProfile = await UserStorageService.getUserProfile(userEmail);
      if (localProfile != null && localProfile.isNotEmpty) {
        try {
          profile = UserProfile.fromOnboarding(localProfile);
          print('✅ Profile screen: Loaded local profile for ${profile.name}');
          
          // Save to UserProfileService for future use
          await _profileService.saveUserProfile(profile);
          print('✅ Profile migrated to UserProfileService');
        } catch (e) {
          print('❌ Profile screen: Error converting local profile: $e');
        }
      }
    }
    
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Log Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear all user data
      await UserStorageService.clearCurrentUser();
      _profileService.clearCache();
      
      // Navigate to auth screen (login/signup)
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthScreen()),
          (route) => false, // Remove all previous routes
        );
        
        // Show logout message after navigation
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logged out successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1A1B3A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: _handleLogout,
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? _buildNoProfileView()
              : _buildProfileView(),
      bottomNavigationBar: MainNavigationBar(currentScreen: NavigationScreen.profile),
    );
  }

  Widget _buildNoProfileView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6C5CE7).withOpacity(0.2),
                    Color(0xFF74B9FF).withOpacity(0.2)
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF6C5CE7).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_outline, 
                size: 60, 
                color: Color(0xFF6C5CE7),
              ),
            ),
            SizedBox(height: 24),
            
            // Title
            Text(
              'No profile found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            
            // Description
            Text(
              'Create your fitness profile to get personalized workouts and track your progress!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            SizedBox(height: 40),
            
            // Create Profile Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QuickProfileSetup(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Create My Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Alternative: Reset onboarding button
            TextButton(
              onPressed: () async {
                // Clear onboarding and restart
                final authService = FirebaseAuthService();
                final user = authService.currentUser;
                if (user?.email != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('${user!.uid}_onboarding_complete');
                  await prefs.remove('${user.uid}_profile');
                  
                  // Show restart message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile cleared. Restart the app to go through setup again.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Text(
                'Clear Profile Data',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 16),
          _buildPersonalInfoSection(),
          const SizedBox(height: 16),
          _buildFitnessInfoSection(),
          const SizedBox(height: 16),
          _buildHealthSection(),
          const SizedBox(height: 16),
          _buildMotivationSection(),
          const SizedBox(height: 100), // Extra space for bottom nav
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6C5CE7),
            Color(0xFF5B4FD8),
            Color(0xFF4A3FC7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Animated background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _ProfileBackgroundPainter(),
            ),
          ),
          
          // Blur overlay for depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              children: [
                // Avatar with glow effect
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      _profile!.name.isNotEmpty ? _profile!.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Name with shadow
                Text(
                  _profile!.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Member badge with glassmorphism
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Member since ${_formatDate(_profile!.createdAt)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow('Age', '${_profile!.age} years old'),
        _buildInfoRow('Gender', _formatGender(_profile!.gender)),
        _buildInfoRow('Height', '${_profile!.height} cm'),
        _buildInfoRow('Weight', '${_profile!.weight} kg'),
        if (_profile!.bmi != null)
          _buildInfoRow(
            'BMI',
            '${_profile!.bmi!.toStringAsFixed(1)} (${_profile!.bmiCategory})',
          ),
      ],
    );
  }

  Widget _buildFitnessInfoSection() {
    return _buildSection(
      title: 'Fitness Profile',
      icon: Icons.fitness_center,
      children: [
        _buildInfoRow('Fitness Level', _formatFitnessLevel(_profile!.fitnessLevel)),
        _buildInfoRow('Primary Goal', _profile!.primaryGoal),
      ],
    );
  }

  Widget _buildHealthSection() {
    return _buildSection(
      title: 'Health & Dietary',
      icon: Icons.health_and_safety_outlined,
      children: [
        _buildInfoRow(
          'Allergies',
          _profile!.allergies.isEmpty ? 'None' : _profile!.allergies.join(', '),
        ),
      ],
    );
  }

  Widget _buildMotivationSection() {
    return _buildSection(
      title: 'Motivation',
      icon: Icons.auto_awesome_rounded,
      children: [
        _buildInfoRow('What Drives You', _profile!.motivation),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C5CE7).withOpacity(0.2),
                const Color(0xFF74B9FF).withOpacity(0.2)
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF6C5CE7),
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                _profile!.selectedAdvice,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    if (children.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF6C5CE7), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.year}';
  }

  String _formatGender(String gender) {
    return gender[0].toUpperCase() + gender.substring(1);
  }

  String _formatFitnessLevel(String level) {
    return level[0].toUpperCase() + level.substring(1);
  }
}


// Custom painter for animated background pattern
class _ProfileBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw floating circles with blur effect
    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      80,
      paint,
    );
    
    paint.color = Colors.white.withOpacity(0.03);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.6),
      120,
      paint,
    );
    
    paint.color = Colors.white.withOpacity(0.04);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.8),
      60,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
