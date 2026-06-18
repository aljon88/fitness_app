import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/workout_history_service.dart';
import '../services/professional_workout_tracker.dart';
import '../services/unified_auth_service.dart';
import '../services/real_time_calendar_service.dart';
import '../services/workout_program_loader.dart';
import '../models/workout_history.dart';
import '../theme/app_colors.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  List<WorkoutSession> _professionalWorkouts = [];
  List<WorkoutHistory> _workoutHistory = [];
  bool _isLoading = true;
  int _currentStreak = 0;
  int _totalWorkouts = 0;
  String _currentProgramName = '';
  Map<String, List<dynamic>> _weeklyHistory = {};

  @override
  void initState() {
    super.initState();
    _loadWorkoutHistory();
  }

  Future<void> _loadWorkoutHistory() async {
    try {
      final authService = UnifiedAuthService();
      
      if (!authService.isLoggedIn) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      authService.printAuthStatus();

      // Load from professional workout tracker (new system)
      final professionalTracker = ProfessionalWorkoutTracker();
      final professionalWorkouts = await professionalTracker.getWorkoutHistory();
      final professionalStreak = await professionalTracker.getCurrentStreak();
      
      // Load from old workout history service (for backwards compatibility)
      List<WorkoutHistory> oldHistory = [];
      int oldStreak = 0;
      
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final historyService = WorkoutHistoryService();
          oldHistory = await historyService.getWorkoutHistory(user.uid);
          oldStreak = await historyService.getCurrentStreak(user.uid);
        }
      } catch (e) {
        print('⚠️ Could not load old workout history: $e');
      }
      
      // Combine both sources for total count
      final totalFromNew = professionalWorkouts.length;
      final totalFromOld = oldHistory.length;
      final combinedStreak = professionalStreak > oldStreak ? professionalStreak : oldStreak;
      
      // Get current program info
      String programName = 'Home Fitness Journey';
      
      // Group history by weeks (using professional workouts primarily)
      final weeklyHistory = _groupWorkoutsByWeeks(professionalWorkouts, oldHistory);
      
      setState(() {
        _professionalWorkouts = professionalWorkouts;
        _workoutHistory = oldHistory;
        _currentStreak = combinedStreak;
        _totalWorkouts = totalFromNew + totalFromOld;
        _currentProgramName = programName;
        _weeklyHistory = weeklyHistory;
        _isLoading = false;
      });
      
      print('✅ Workout history loaded:');
      print('   Professional workouts: $totalFromNew');
      print('   Legacy workouts: $totalFromOld');
      print('   Current streak: $combinedStreak days');
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Error loading workout history: $e');
    }
  }

  Map<String, List<dynamic>> _groupWorkoutsByWeeks(
    List<WorkoutSession> professionalWorkouts, 
    List<WorkoutHistory> legacyWorkouts
  ) {
    Map<String, List<dynamic>> grouped = {};
    
    // Add professional workouts
    for (var workout in professionalWorkouts) {
      final weekKey = _getWeekKey(workout.startTime);
      if (!grouped.containsKey(weekKey)) {
        grouped[weekKey] = [];
      }
      grouped[weekKey]!.add(workout);
    }
    
    // Add legacy workouts
    for (var workout in legacyWorkouts) {
      final weekKey = _getWeekKey(workout.completedAt);
      if (!grouped.containsKey(weekKey)) {
        grouped[weekKey] = [];
      }
      grouped[weekKey]!.add(workout);
    }
    
    // Sort each week's workouts by date (most recent first)
    grouped.forEach((key, workouts) {
      workouts.sort((a, b) {
        DateTime dateA = a is WorkoutSession ? a.startTime : (a as WorkoutHistory).completedAt;
        DateTime dateB = b is WorkoutSession ? b.startTime : (b as WorkoutHistory).completedAt;
        return dateB.compareTo(dateA);
      });
    });
    
    return grouped;
  }

  String _getWeekKey(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    
    return '${_formatDateShort(startOfWeek)} - ${_formatDateShort(endOfWeek)}';
  }

  String _formatDateShort(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}';
  }

  String _getPerformanceEmoji(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return '😊';
      case 'moderate': return '💪';
      case 'hard': return '🔥';
      case 'very hard': return '😤';
      default: return '💪';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final workoutDate = DateTime(date.year, date.month, date.day);

    if (workoutDate == today) {
      return 'Today';
    } else if (workoutDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
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
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workout History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _currentProgramName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : _buildHistoryContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryContent() {
    if (_workoutHistory.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Stats Header
        _buildStatsHeader(),
        
        // History List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24),
            itemCount: _weeklyHistory.keys.length,
            itemBuilder: (context, index) {
              final weekKey = _weeklyHistory.keys.elementAt(index);
              final weekWorkouts = _weeklyHistory[weekKey]!;
              return _buildWeekSection(weekKey, weekWorkouts);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.fitness_center_rounded,
              value: '$_totalWorkouts',
              label: 'Total Workouts',
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white.withOpacity(0.2),
            margin: EdgeInsets.symmetric(horizontal: 20),
          ),
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_fire_department_rounded,
              value: '$_currentStreak',
              label: 'Current Streak',
              color: Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSection(String weekKey, List<dynamic> weekWorkouts) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  weekKey,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${weekWorkouts.length} workout${weekWorkouts.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12),
          
          // Week's Workouts
          ...weekWorkouts.map((workout) {
            if (workout is WorkoutSession) {
              return _buildProfessionalWorkoutCard(workout);
            } else {
              return _buildWorkoutCard(workout as WorkoutHistory);
            }
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalWorkoutCard(WorkoutSession workout) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1F3A),
        borderRadius: BorderRadius.circular(16),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF4ECDC4).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        color: Color(0xFF4ECDC4),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _formatDate(workout.startTime),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Text(
                _getPerformanceEmoji(workout.difficulty),
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Workout Name
          Text(
            workout.workoutTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 12),
          
          // Stats Row
          Row(
            children: [
              _buildWorkoutStat(
                Icons.timer_rounded,
                '${(workout.totalDuration / 60).round()}m',
                Color(0xFF4ECDC4),
              ),
              SizedBox(width: 16),
              _buildWorkoutStat(
                Icons.fitness_center_rounded,
                '${workout.totalReps} reps',
                Color(0xFFFF6B6B),
              ),
              SizedBox(width: 16),
              _buildWorkoutStat(
                Icons.local_fire_department_rounded,
                '${workout.caloriesBurned} cal',
                Color(0xFFFFD93D),
              ),
            ],
          ),
          
          // Performance Rating
          if (workout.difficulty.isNotEmpty) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFFFFD93D),
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Difficulty: ${workout.difficulty}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          
          // Notes/Tags if available
          if (workout.notes.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              '💭 ${workout.notes}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutHistory workout) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1F3A),
        borderRadius: BorderRadius.circular(16),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Day ${workout.dayNumber}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _formatDate(workout.completedAt),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Text(
                _getPerformanceEmoji(workout.difficulty),
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Workout Name
          Text(
            workout.workoutTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 12),
          
          // Stats Row
          Row(
            children: [
              _buildWorkoutStat(
                Icons.timer_rounded,
                '${workout.durationMinutes}m',
                Color(0xFF4ECDC4),
              ),
              SizedBox(width: 16),
              _buildWorkoutStat(
                Icons.fitness_center_rounded,
                '${workout.totalReps} reps',
                Color(0xFFFF6B6B),
              ),
              SizedBox(width: 16),
              _buildWorkoutStat(
                Icons.local_fire_department_rounded,
                '${workout.caloriesBurned} cal',
                Color(0xFFFFD93D),
              ),
            ],
          ),
          
          // Performance Rating
          if (workout.difficulty.isNotEmpty) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFFFFD93D),
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Difficulty: ${workout.difficulty}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkoutStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No workouts completed yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete your first workout to see your\naccomplishments here!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              'Start Your First Workout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}