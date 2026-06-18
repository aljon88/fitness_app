import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'workout_history_screen.dart';
import '../services/navigation_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/real_time_calendar_service.dart';
import '../services/workout_history_service.dart';
import '../services/workout_program_loader.dart';
import '../models/navigation_state.dart';
import '../widgets/navigation_widgets.dart';
import '../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  
  Map<String, dynamic> _currentProfile = {};

  @override
  void initState() {
    super.initState();
    
    _currentProfile = widget.profile;
    
    // Initialize navigation service with user profile
    NavigationService().initialize(widget.profile);
    
    // Listen for navigation service changes (includes auth state changes)
    NavigationService().addListener(_onNavigationStateChanged);
    
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
  void dispose() {
    NavigationService().removeListener(_onNavigationStateChanged);
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onNavigationStateChanged() {
    // When auth state changes, reload dashboard with fresh data
    if (mounted) {
      setState(() {
        // Clear current profile to force fresh load
        _currentProfile = {};
      });
      // Load fresh profile data
      _loadFreshProfile();
    }
  }

  Future<void> _loadFreshProfile() async {
    final authService = FirebaseAuthService();
    final freshProfile = await authService.getUserProfile();
    
    if (freshProfile != null && freshProfile.isNotEmpty && mounted) {
      setState(() {
        _currentProfile = Map<String, dynamic>.from(freshProfile);
        _currentProfile['uid'] = authService.currentUser?.uid ?? 'unknown';
      });
      print('🔄 Dashboard: Loaded fresh profile for ${_currentProfile['name']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug logging
    print('🏠 Dashboard build() called');
    print('   Profile is null: ${_currentProfile == null}');
    print('   Profile is empty: ${_currentProfile.isEmpty}');
    print('   Profile keys: ${_currentProfile.keys.toList()}');
    print('   Profile has name: ${_currentProfile.containsKey("name")}');
    print('   Profile name value: ${_currentProfile['name']}');
    
    // Check if profile is empty or invalid
    if (_currentProfile.isEmpty || _currentProfile['name'] == null) {
      print('❌ Dashboard showing "No profile found" error');
      print('   Reason: ${_currentProfile.isEmpty ? "Profile is empty" : "Profile name is null"}');
      
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
                    title: 'Hello, ${_currentProfile['name'] ?? 'User'}!',
                    subtitle: 'Ready for your workout?',
                    showBackButton: false,
                    actions: [
                      // History Icon
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutHistoryScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                      // Profile Icon
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

    return RefreshIndicator(
      onRefresh: () async {
        // Trigger a rebuild to refresh stats
        if (mounted) {
          setState(() {});
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24),
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: dashboardWidgets.length,
        itemBuilder: (context, index) {
          return dashboardWidgets[index];
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    String fitnessLevel = _currentProfile['fitnessLevel'] ?? 'beginner';
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
                  'Home Fitness Journey',
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
    String fitnessLevel = _currentProfile['fitnessLevel'] ?? 'beginner';
    String primaryGoal = _currentProfile['primaryGoal'] ?? 'Healthy Lifestyle';
    
    return FutureBuilder<Map<String, dynamic>>(
      future: _calculateRealTimeStats(primaryGoal, fitnessLevel),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingStats();
        }
        
        final stats = snapshot.data!;
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today_rounded,
                title: 'Day',
                value: '${stats['currentDay']}',
                subtitle: 'of ${stats['totalDays']}',
                color: Color(0xFF6C5CE7),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.date_range_rounded,
                title: 'This Week',
                value: '${stats['weeklyCompleted']}/${stats['weeklyGoal']}',
                subtitle: 'workouts',
                color: Color(0xFF4ECDC4),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.fitness_center_rounded,
                title: 'Total',
                value: '${stats['totalCompleted']}',
                subtitle: 'completed',
                color: Color(0xFFFF6B6B),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_rounded,
            title: 'Day',
            value: '-',
            subtitle: 'of -',
            color: Color(0xFF6C5CE7),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.date_range_rounded,
            title: 'This Week',
            value: '-/-',
            subtitle: 'workouts',
            color: Color(0xFF4ECDC4),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.fitness_center_rounded,
            title: 'Total',
            value: '-',
            subtitle: 'completed',
            color: Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _calculateRealTimeStats(String primaryGoal, String fitnessLevel) async {
    final calendarService = RealTimeCalendarService();
    final historyService = WorkoutHistoryService();
    final programLoader = WorkoutProgramLoader();
    
    try {
      // Get current program day from real-time calendar
      final currentDay = await calendarService.getTodayProgramDay();
      
      // Get program info for total days and weekly goal
      final program = await programLoader.loadProgram(primaryGoal, fitnessLevel);
      final totalDays = programLoader.getProgramDurationDays(program);
      final weeklyGoal = program['schedule']['workoutsPerWeek'] ?? 4;
      
      // Get completed workout days (excludes rest days)
      final user = FirebaseAuth.instance.currentUser;
      final completedDays = user != null 
          ? await historyService.getCompletedWorkoutDays(user.uid)
          : <int>[];
      
      // Calculate current week number and weekly progress
      final currentWeek = ((currentDay - 1) ~/ 7) + 1;
      final weekStartDay = ((currentWeek - 1) * 7) + 1;
      final weekEndDay = currentWeek * 7;
      
      // Count completed workouts in current week (exclude rest days)
      final calendar = await calendarService.generateProgramCalendar(primaryGoal, fitnessLevel);
      final currentWeekDays = calendar.where((day) => 
          day['programDay'] >= weekStartDay && 
          day['programDay'] <= weekEndDay &&
          !day['isRestDay']
      ).toList();
      
      final weeklyCompleted = currentWeekDays.where((day) => 
          completedDays.contains(day['programDay'])
      ).length;
      
      // Total completed workouts (exclude rest days)
      final totalCompleted = calendar.where((day) => 
          completedDays.contains(day['programDay']) && !day['isRestDay']
      ).length;
      
      return {
        'currentDay': currentDay,
        'totalDays': totalDays,
        'weeklyCompleted': weeklyCompleted,
        'weeklyGoal': weeklyGoal,
        'totalCompleted': totalCompleted,
        'currentWeek': currentWeek,
      };
    } catch (e) {
      print('Error calculating stats: $e');
      return {
        'currentDay': 1,
        'totalDays': 90,
        'weeklyCompleted': 0,
        'weeklyGoal': 4,
        'totalCompleted': 0,
        'currentWeek': 1,
      };
    }
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
              fontSize: title == 'This Week' ? 24 : 28,
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
    String fitnessLevel = _currentProfile['fitnessLevel'] ?? 'beginner';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next Workout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        
        // Next Workout Card
        _buildNextWorkoutCard(fitnessLevel),
      ],
    );
  }
  
  Widget _buildNextWorkoutCard(String fitnessLevel) {
    String primaryGoal = _currentProfile['primaryGoal'] ?? 'Healthy Lifestyle';
    
    return FutureBuilder<Map<String, dynamic>>(
      future: _getNextWorkoutFromCalendar(primaryGoal, fitnessLevel),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingNextWorkoutCard();
        }
        
        final nextWorkout = snapshot.data!;
        
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
                      color: nextWorkout['isRestDay'] ? Color(0xFF4ECDC4) : Color(0xFF6C5CE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      nextWorkout['isRestDay'] ? 'REST DAY' : 'NEXT UP',
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
                    nextWorkout['isRestDay'] ? Icons.self_improvement_rounded : Icons.arrow_forward_rounded,
                    color: nextWorkout['isRestDay'] ? Color(0xFF4ECDC4) : Color(0xFF6C5CE7),
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
              if (!nextWorkout['isRestDay']) ...[
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingNextWorkoutCard() {
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
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Spacer(),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: 200,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
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

  Future<Map<String, dynamic>> _getNextWorkoutFromCalendar(String primaryGoal, String fitnessLevel) async {
    try {
      print('🏠 Dashboard: Getting next workout for $primaryGoal - $fitnessLevel');
      
      final calendarService = RealTimeCalendarService();
      final historyService = WorkoutHistoryService();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        print('❌ Dashboard: No user logged in, using fallback');
        return _getFallbackNextWorkout(fitnessLevel);
      }
      
      // Get current program day and completed days
      final currentDay = await calendarService.getTodayProgramDay();
      final completedDays = await historyService.getCompletedWorkoutDays(user.uid);
      
      print('📅 Dashboard: Current day = $currentDay, Completed days = $completedDays');
      
      // Generate calendar to find next workout
      final calendar = await calendarService.generateProgramCalendar(primaryGoal, fitnessLevel);
      
      print('📋 Dashboard: Generated calendar with ${calendar.length} days');
      
      // Find the next uncompleted workout
      Map<String, dynamic>? nextWorkout;
      
      // First, check if today's workout is not completed
      final todayWorkout = calendar.firstWhere(
        (day) => day['programDay'] == currentDay,
        orElse: () => {},
      );
      
      if (todayWorkout.isNotEmpty && !completedDays.contains(currentDay)) {
        nextWorkout = todayWorkout;
        print('✅ Dashboard: Today\'s workout (Day $currentDay) is next');
      } else {
        // Find next uncompleted workout after today
        for (final day in calendar) {
          if (day['programDay'] > currentDay && !completedDays.contains(day['programDay'])) {
            nextWorkout = day;
            print('⏭️ Dashboard: Next workout is Day ${day['programDay']}');
            break;
          }
        }
      }
      
      if (nextWorkout == null || nextWorkout.isEmpty) {
        print('❌ Dashboard: No next workout found, using fallback');
        return _getFallbackNextWorkout(fitnessLevel);
      }
      
      // Format the workout data for display
      if (nextWorkout['isRestDay'] == true) {
        print('😴 Dashboard: Next is rest day');
        return {
          'title': 'Rest Day',
          'description': 'Recovery and muscle repair time',
          'exercises': 0,
          'duration': 0,
          'isRestDay': true,
          'programDay': nextWorkout['programDay'],
        };
      } else {
        final workoutData = nextWorkout['workoutData'] ?? {};
        final exercises = workoutData['exercises'] as List<dynamic>? ?? [];
        
        final result = {
          'title': 'Day ${nextWorkout['programDay']}: ${workoutData['name'] ?? 'Workout'}',
          'description': _getWorkoutDescription(workoutData['name'] ?? 'Workout', fitnessLevel),
          'exercises': exercises.length,
          'duration': workoutData['duration'] ?? 30,
          'isRestDay': false,
          'programDay': nextWorkout['programDay'],
        };
        
        print('💪 Dashboard: Next workout = ${result['title']}');
        return result;
      }
    } catch (e) {
      print('❌ Dashboard: Error getting next workout from calendar: $e');
      return _getFallbackNextWorkout(fitnessLevel);
    }
  }

  Map<String, dynamic> _getFallbackNextWorkout(String fitnessLevel) {
    // Fallback to static data if calendar service fails
    // Use generic workout that works for all goals
    switch (fitnessLevel.toLowerCase()) {
      case 'beginner':
        return {
          'title': 'Day 1: Workout',
          'description': 'Foundation building with proper form',
          'exercises': 5,
          'duration': 25,
          'isRestDay': false,
          'programDay': 1,
        };
      case 'intermediate':
        return {
          'title': 'Day 1: Workout',
          'description': 'Strength and power development',
          'exercises': 5,
          'duration': 30,
          'isRestDay': false,
          'programDay': 1,
        };
      case 'advanced':
        return {
          'title': 'Day 1: Workout',
          'description': 'Elite performance training',
          'exercises': 5,
          'duration': 35,
          'isRestDay': false,
          'programDay': 1,
        };
      default:
        return {
          'title': 'Day 1: Workout',
          'description': 'Foundation building',
          'exercises': 5,
          'duration': 25,
          'isRestDay': false,
          'programDay': 1,
        };
    }
  }

  String _getWorkoutDescription(String workoutName, String fitnessLevel) {
    final name = workoutName.toLowerCase();
    
    if (name.contains('full body') || name.contains('strength')) {
      switch (fitnessLevel.toLowerCase()) {
        case 'beginner':
          return 'Foundation building with proper form';
        case 'intermediate':
          return 'Strength and power development';
        case 'advanced':
          return 'Elite performance training';
        default:
          return 'Full body strength training';
      }
    } else if (name.contains('hiit') || name.contains('cardio')) {
      return 'High-intensity cardiovascular training';
    } else if (name.contains('upper body')) {
      return 'Upper body strength and conditioning';
    } else if (name.contains('lower body')) {
      return 'Lower body power and endurance';
    } else if (name.contains('flexibility') || name.contains('recovery')) {
      return 'Active recovery and flexibility';
    } else {
      return 'Targeted workout session';
    }
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
    String fitnessLevel = _currentProfile['fitnessLevel'] ?? 'beginner';
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
    String fitnessLevel = _currentProfile['fitnessLevel'] ?? 'beginner';
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
    // Navigate to workout history instead
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutHistoryScreen(),
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

}