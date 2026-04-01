import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'progress_tracking_screen.dart';
import '../services/navigation_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/sample_data_generator.dart';
import '../services/workout_history_service.dart';
import '../models/workout_history.dart';
import '../models/navigation_state.dart';
import '../widgets/navigation_widgets.dart';
import '../theme/app_colors.dart';

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
  
  // Real data from WorkoutHistoryService
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  int _totalWorkouts = 0;
  int _currentStreak = 0;
  int _currentDay = 1;
  List<WorkoutHistory> _recentWorkouts = [];
  bool _isLoadingData = true;

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
    
    // Load real workout data
    _loadRealData();
  }
  
  Future<void> _loadRealData() async {
    String userId = widget.profile['uid'] ?? 'user_001';
    
    try {
      // Load real data from WorkoutHistoryService
      _totalWorkouts = await _historyService.getTotalWorkoutsCompleted(userId);
      _currentStreak = await _historyService.getCurrentStreak(userId);
      _recentWorkouts = await _historyService.getWorkoutHistory(userId);
      
      // Calculate current day based on completed workouts
      List<int> completedDays = await _historyService.getCompletedWorkoutDays(userId);
      if (completedDays.isNotEmpty) {
        _currentDay = completedDays.last + 1;
      }
      
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('Error loading workout data: $e');
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug logging
    print('🏠 Dashboard build() called');
    print('   Profile is null: ${widget.profile == null}');
    print('   Profile is empty: ${widget.profile.isEmpty}');
    print('   Profile keys: ${widget.profile.keys.toList()}');
    print('   Profile has name: ${widget.profile.containsKey("name")}');
    print('   Profile name value: ${widget.profile['name']}');
    
    // Check if profile is empty or invalid
    if (widget.profile.isEmpty || widget.profile['name'] == null) {
      print('❌ Dashboard showing "No profile found" error');
      print('   Reason: ${widget.profile.isEmpty ? "Profile is empty" : "Profile name is null"}');
      
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 100,
                  color: Colors.white54,
                ),
                SizedBox(height: 24),
                Text(
                  'No profile found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Please complete the onboarding process',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => AuthScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C5CE7),
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Go to Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
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
                      GestureDetector(
                        onTap: () => NavigationService().navigateToUserProfile(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
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
    dashboardWidgets.add(_buildWorkoutHistory());
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
      padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C5CE7),
            Color(0xFF8B7FE8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'AI Fitness Journey',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            programInfo['description'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w400,
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
          'duration': '90-day',
          'description': 'Your personalized 90-day beginner program is ready. Build your foundation with 4 training days and 3 rest days per week. Master proper form and technique!',
          'workoutTitle': '90-Day Beginner Program',
          'workoutSubtitle': 'Foundation building with proper form',
          'todayMessage': 'Ready to start your fitness journey? Begin with Day 1 of your beginner-friendly workout program with built-in rest days.',
          'buttonText': 'Start Day 1 Workout',
        };
      case 'intermediate':
        return {
          'duration': '60-day',
          'description': 'Your personalized 60-day intermediate program is ready. Train 5 days per week with 2 rest days. Build strength, power, and endurance!',
          'workoutTitle': '60-Day Intermediate Program',
          'workoutSubtitle': 'Strength and power development',
          'todayMessage': 'Ready to level up? Begin with Day 1 of your intermediate workout program with strategic rest days.',
          'buttonText': 'Start Day 1 Challenge',
        };
      case 'advanced':
        return {
          'duration': '30-day',
          'description': 'Your personalized 30-day advanced program is ready. Elite training 5-6 days per week. Push your limits with high-intensity workouts!',
          'workoutTitle': '30-Day Advanced Program',
          'workoutSubtitle': 'Elite performance training',
          'todayMessage': 'Ready to dominate? Begin with Day 1 of your advanced training program designed for peak performance.',
          'buttonText': 'Start Day 1 Beast Mode',
        };
      default:
        return {
          'duration': '90-day',
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
      'beginner': 90,
      'intermediate': 60,
      'advanced': 30,
    };
    int totalDays = programDays[fitnessLevel.toLowerCase()] ?? 90;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_rounded,
            title: 'Day',
            value: _isLoadingData ? '-' : '$_currentDay',
            subtitle: 'of $totalDays',
            color: Color(0xFF6C5CE7),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            title: 'Streak',
            value: _isLoadingData ? '-' : '$_currentStreak',
            subtitle: 'days',
            color: Color(0xFFFF6B6B),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.fitness_center_rounded,
            title: 'Workouts',
            value: _isLoadingData ? '-' : '$_totalWorkouts',
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHistory() {
    String fitnessLevel = widget.profile['fitnessLevel'] ?? 'beginner';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Workout History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToProgressTracking(),
              child: Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        
        // Next Workout Card
        _buildNextWorkoutCard(fitnessLevel),
        SizedBox(height: 12),
        
        // Recent Workouts or Empty State
        if (_isLoadingData)
          _buildLoadingHistoryCard()
        else if (_recentWorkouts.isEmpty)
          _buildEmptyHistoryCard()
        else
          _buildRecentWorkoutsSection(),
      ],
    );
  }
  
  Widget _buildLoadingHistoryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1E1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6C5CE7),
          strokeWidth: 2,
        ),
      ),
    );
  }
  
  Widget _buildRecentWorkoutsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Workouts',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        ..._recentWorkouts.take(3).map((workout) => Column(
          children: [
            _buildWorkoutHistoryCard(workout),
            SizedBox(height: 12),
          ],
        )),
      ],
    );
  }
  
  Widget _buildWorkoutHistoryCard(WorkoutHistory workout) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.workoutTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_formatDate(workout.completedAt)} • ${workout.durationMinutes} min • ${workout.totalReps} reps',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${workout.caloriesBurned}',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'kcal',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';
    
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildNextWorkoutCard(String fitnessLevel) {
    Map<String, dynamic> nextWorkout = _getNextWorkout(fitnessLevel);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C5CE7).withOpacity(0.2),
            Color(0xFF8B7FE8).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF6C5CE7).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'NEXT UP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF6C5CE7),
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            nextWorkout['title'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            nextWorkout['description'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildWorkoutInfoChip(
                Icons.fitness_center_rounded,
                '${nextWorkout['exercises']} exercises',
              ),
              SizedBox(width: 12),
              _buildWorkoutInfoChip(
                Icons.timer_rounded,
                '${nextWorkout['duration']} min',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1E1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            color: Colors.white.withOpacity(0.3),
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'No workouts completed yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Start your first workout to track your progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkoutInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 16),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getNextWorkout(String fitnessLevel) {
    switch (fitnessLevel.toLowerCase()) {
      case 'beginner':
        return {
          'title': 'Day 1: Push Day',
          'description': 'Foundation - Chest, shoulders, triceps',
          'exercises': 2,
          'duration': 25,
        };
      case 'intermediate':
        return {
          'title': 'Day 1: Push Day',
          'description': 'Strength Building - Upper body power',
          'exercises': 2,
          'duration': 30,
        };
      case 'advanced':
        return {
          'title': 'Day 1: Push Power',
          'description': 'Intensity Ramp - Explosive upper body',
          'exercises': 3,
          'duration': 40,
        };
      default:
        return {
          'title': 'Day 1: Push Day',
          'description': 'Foundation building',
          'exercises': 2,
          'duration': 25,
        };
    }
  }

  Widget _buildMainFeatures_OLD() {
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
        SizedBox(height: 16),
        
        // Progress Tracking
        _buildFeatureCard(
          icon: Icons.trending_up_rounded,
          title: 'Progress Tracking',
          subtitle: 'Monitor your fitness journey',
          gradient: [Color(0xFFFD79A8), Color(0xFFE84393)],
          onTap: () => _navigateToProgressTracking(),
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
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(0xFF1E1F3A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1E1F3A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF6C5CE7).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.today_rounded,
                  color: Color(0xFF6C5CE7),
                  size: 24,
                ),
              ),
              SizedBox(width: 14),
              Text(
                'Today\'s Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          
          Text(
            programInfo['todayMessage'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20),
          
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _getButtonColorForLevel(fitnessLevel),
                  _getButtonColorForLevel(fitnessLevel).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(27),
              boxShadow: [
                BoxShadow(
                  color: _getButtonColorForLevel(fitnessLevel).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => NavigationService().navigateToWorkoutProgram(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
              child: Text(
                programInfo['buttonText'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
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

  void _navigateToProgressTracking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProgressTrackingScreen(profile: widget.profile),
      ),
    );
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