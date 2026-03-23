import 'package:flutter/material.dart';
import 'workout_program_screen.dart';
import 'enhanced_meal_plan_screen.dart';
import 'camera_screen.dart';
import 'auth_screen.dart';
import '../services/navigation_service.dart';
import '../services/firebase_auth_service.dart';
import '../models/navigation_state.dart';
import '../widgets/navigation_widgets.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const DashboardScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize navigation service with user profile
    NavigationService().initialize(widget.profile);
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
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
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header with navigation integration
                  NavigationHeader(
                    title: 'Hello, ${widget.profile['name'] ?? 'User'}!',
                    subtitle: 'Ready for your workout?',
                    showBackButton: false,
                    actions: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 12),
                      GestureDetector(
                        onTap: _showLogoutDialog,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Full-screen scrollable content
                  Expanded(
                    child: _buildDashboardContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: MainNavigationBar(currentScreen: NavigationScreen.dashboard),
      floatingActionButton: WorkoutCameraFAB(),
    );
  }

  Widget _buildDashboardContent() {
    // Create list of all dashboard widgets
    List<Widget> dashboardWidgets = [];
    
    // Add all sections
    dashboardWidgets.add(SizedBox(height: 20));
    dashboardWidgets.add(_buildWelcomeSection());
    dashboardWidgets.add(SizedBox(height: 30));
    dashboardWidgets.add(_buildQuickStats());
    dashboardWidgets.add(SizedBox(height: 30));
    dashboardWidgets.add(_buildMainFeatures());
    dashboardWidgets.add(SizedBox(height: 30));
    dashboardWidgets.add(_buildTodayProgress());
    dashboardWidgets.add(SizedBox(height: 100)); // Extra bottom spacing for FAB

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24),
      itemCount: dashboardWidgets.length,
      itemBuilder: (context, index) {
        return dashboardWidgets[index];
      },
    );
  }

  Widget _buildWelcomeSection() {
    String fitnessLevel = widget.profile['fitnessLevel'] ?? 'beginner';
    Map<String, dynamic> programInfo = _getProgramInfo(fitnessLevel);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6C5CE7).withOpacity(0.2),
            Color(0xFFA29BFE).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF6C5CE7),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'AI Fitness Journey',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            programInfo['description'],
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getProgramInfo(String fitnessLevel) {
    switch (fitnessLevel.toLowerCase()) {
      case 'beginner':
        return {
          'duration': '60-day',
          'description': 'Your personalized 60-day beginner program is ready. Start with Day 1 and build your foundation with gentle, progressive exercises!',
          'workoutTitle': '60-Day Beginner Program',
          'workoutSubtitle': 'Gentle introduction to fitness',
          'todayMessage': 'Ready to start your fitness journey? Begin with Day 1 of your beginner-friendly workout program.',
          'buttonText': 'Start Day 1 Workout',
        };
      case 'intermediate':
        return {
          'duration': '45-day',
          'description': 'Your personalized 45-day intermediate program is ready. Challenge yourself with varied exercises and build strength!',
          'workoutTitle': '45-Day Intermediate Program',
          'workoutSubtitle': 'Balanced strength and cardio training',
          'todayMessage': 'Ready to level up? Begin with Day 1 of your intermediate workout program.',
          'buttonText': 'Start Day 1 Challenge',
        };
      case 'advanced':
        return {
          'duration': '30-day',
          'description': 'Your personalized 30-day advanced program is ready. Push your limits with intense, high-performance workouts!',
          'workoutTitle': '30-Day Advanced Program',
          'workoutSubtitle': 'High-intensity performance training',
          'todayMessage': 'Ready to dominate? Begin with Day 1 of your advanced training program.',
          'buttonText': 'Start Day 1 Beast Mode',
        };
      default:
        return {
          'duration': '60-day',
          'description': 'Your personalized fitness program is ready. Start your journey today!',
          'workoutTitle': 'Fitness Program',
          'workoutSubtitle': 'Personalized training',
          'todayMessage': 'Ready to start? Begin with Day 1 of your workout program.',
          'buttonText': 'Start Day 1 Workout',
        };
    }
  }

  Widget _buildQuickStats() {
    String fitnessLevel = widget.profile['fitnessLevel'] ?? 'beginner';
    Map<String, int> programDays = {
      'beginner': 60,
      'intermediate': 45,
      'advanced': 30,
    };
    int totalDays = programDays[fitnessLevel.toLowerCase()] ?? 60;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_rounded,
            title: 'Day',
            value: '1',
            subtitle: 'of $totalDays',
            color: Color(0xFF6C5CE7),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            title: 'Streak',
            value: '0',
            subtitle: 'days',
            color: Color(0xFFFF6B6B),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.fitness_center_rounded,
            title: 'Workouts',
            value: '0',
            subtitle: 'completed',
            color: Color(0xFF4ECDC4),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatures() {
    final navigationService = NavigationService();
    String fitnessLevel = widget.profile['fitnessLevel'] ?? 'beginner';
    Map<String, dynamic> programInfo = _getProgramInfo(fitnessLevel);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        
        // Fitness Level-Specific Workout Program
        _buildFeatureCard(
          icon: Icons.fitness_center_rounded,
          title: programInfo['workoutTitle'],
          subtitle: programInfo['workoutSubtitle'],
          gradient: _getGradientForLevel(fitnessLevel),
          onTap: () => navigationService.navigateToWorkoutProgram(),
        ),
        SizedBox(height: 16),
        
        // AI Camera Trainer
        _buildFeatureCard(
          icon: Icons.camera_alt_rounded,
          title: 'AI Camera Trainer',
          subtitle: 'Real-time movement detection & rep counting',
          gradient: [Color(0xFF74B9FF), Color(0xFF0984E3)],
          onTap: () => navigationService.navigateToCamera(),
        ),
        SizedBox(height: 16),
        
        // Meal Plans
        _buildFeatureCard(
          icon: Icons.restaurant_rounded,
          title: 'Nutrition Plans',
          subtitle: 'Personalized meal recommendations',
          gradient: [Color(0xFF00B894), Color(0xFF00CEC9)],
          onTap: () => navigationService.navigateToMealPlan(),
        ),
      ],
    );
  }

  List<Color> _getGradientForLevel(String fitnessLevel) {
    switch (fitnessLevel.toLowerCase()) {
      case 'beginner':
        return [Color(0xFF6C5CE7), Color(0xFFA29BFE)]; // Purple - gentle
      case 'intermediate':
        return [Color(0xFFFF7675), Color(0xFFE17055)]; // Orange - moderate
      case 'advanced':
        return [Color(0xFFE84393), Color(0xFFD63031)]; // Red - intense
      default:
        return [Color(0xFF6C5CE7), Color(0xFFA29BFE)];
    }
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient.map((c) => c.withOpacity(0.2)).toList()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white60,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayProgress() {
    String fitnessLevel = widget.profile['fitnessLevel'] ?? 'beginner';
    Map<String, dynamic> programInfo = _getProgramInfo(fitnessLevel);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today_rounded,
                color: Color(0xFF6C5CE7),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Today\'s Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          Text(
            programInfo['todayMessage'],
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => NavigationService().navigateToWorkoutProgram(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColorForLevel(fitnessLevel),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                programInfo['buttonText'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getButtonColorForLevel(String fitnessLevel) {
    switch (fitnessLevel.toLowerCase()) {
      case 'beginner':
        return Color(0xFF6C5CE7); // Purple - gentle
      case 'intermediate':
        return Color(0xFFFF7675); // Orange - moderate
      case 'advanced':
        return Color(0xFFE84393); // Red - intense
      default:
        return Color(0xFF6C5CE7);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 24),
            SizedBox(width: 12),
            Text(
              'Sign Out',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out? You\'ll need to sign in again to access your workouts.',
          style: TextStyle(color: Colors.white70),
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
              Navigator.of(context).pop();
              
              // Simple direct logout without loading dialog for testing
              try {
                final authService = FirebaseAuthService();
                await authService.signOut();
                
                // Navigate to auth screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthScreen()),
                  (route) => false,
                );
              } catch (e) {
                print('Simple logout error: $e');
                // Force navigation even if Firebase fails
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1A1B3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                SizedBox(height: 16),
                Text(
                  'Signing out...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );

      // Sign out using Firebase
      final authService = FirebaseAuthService();
      await authService.signOut();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Navigate to auth screen and clear all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthScreen()),
        (route) => false,
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed out successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      print('Logout error: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}