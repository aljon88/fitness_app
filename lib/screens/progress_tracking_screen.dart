import 'package:flutter/material.dart';
import 'dart:math';
import '../services/workout_history_service.dart';
import '../models/workout_history.dart';

class ProgressTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const ProgressTrackingScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _ProgressTrackingScreenState createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  String _selectedPeriod = 'Week';
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  
  // Real data
  List<WorkoutHistory> _workoutHistory = [];
  int _totalWorkouts = 0;
  int _totalMinutes = 0;
  int _totalCalories = 0;
  int _currentStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }
  
  Future<void> _loadRealData() async {
    setState(() => _isLoading = true);
    
    String userId = widget.profile['uid'] ?? 'user_001';
    
    try {
      // Load based on selected period
      if (_selectedPeriod == 'Week') {
        _workoutHistory = await _historyService.getWorkoutsThisWeek(userId);
      } else if (_selectedPeriod == 'Month') {
        _workoutHistory = await _historyService.getWorkoutsThisMonth(userId);
      } else {
        _workoutHistory = await _historyService.getWorkoutHistory(userId);
      }
      
      // Calculate stats
      _totalWorkouts = _workoutHistory.length;
      _totalMinutes = _workoutHistory.fold(0, (int sum, w) => sum + w.durationMinutes);
      _totalCalories = _workoutHistory.fold(0, (int sum, w) => sum + w.caloriesBurned);
      _currentStreak = await _historyService.getCurrentStreak(userId);
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading progress data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Text(
                        'Progress Tracking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Period Selector
                  _buildPeriodSelector(isSmallScreen),
                  
                  SizedBox(height: 24),
                  
                  // Stats Overview
                  _buildStatsOverview(isSmallScreen),
                  
                  SizedBox(height: 24),
                  
                  // Workout Chart
                  _buildWorkoutChart(isSmallScreen),
                  
                  SizedBox(height: 24),
                  
                  // Recent Activity
                  _buildRecentActivity(isSmallScreen),
                  
                  SizedBox(height: 24),
                  
                  // Goals Progress
                  _buildGoalsProgress(isSmallScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Week', 'Month', 'Year'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPeriod = period);
                _loadRealData();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF6C5CE7) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsOverview(bool isSmallScreen) {
    if (_isLoading) {
      return Container(
        height: 100,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
      );
    }
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Workouts',
            '$_totalWorkouts',
            'This ${_selectedPeriod.toLowerCase()}',
            Icons.fitness_center_rounded,
            Color(0xFF6C5CE7),
            isSmallScreen,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Duration',
            '$_totalMinutes',
            'Minutes',
            Icons.timer_rounded,
            Color(0xFF00B894),
            isSmallScreen,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Streak',
            '$_currentStreak',
            'Days',
            Icons.local_fire_department_rounded,
            Color(0xFFFF7675),
            isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color, bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isSmall ? 24 : 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 20 : 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: isSmall ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutChart(bool isSmallScreen) {
    if (_isLoading) {
      return Container(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
      );
    }
    
    if (_workoutHistory.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(
            'No workout data for this period',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      );
    }
    
    // Group workouts by day for chart
    Map<String, int> dailyDurations = {};
    for (var workout in _workoutHistory) {
      String dayKey = _getDayKey(workout.completedAt);
      dailyDurations[dayKey] = (dailyDurations[dayKey] ?? 0) + workout.durationMinutes;
    }
    
    // Get last 7 days for weekly view
    List<Map<String, dynamic>> chartData = [];
    DateTime now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String dayKey = _getDayKey(date);
      chartData.add({
        'date': _getDayName(date),
        'duration': dailyDurations[dayKey] ?? 0,
      });
    }
    
    int maxDuration = chartData.map((d) => d['duration'] as int).reduce(max);
    if (maxDuration == 0) maxDuration = 1; // Avoid division by zero
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: chartData.map((day) {
              final duration = day['duration'] as int;
              final height = duration == 0 ? 20.0 : (duration / maxDuration * 100).toDouble();
              
              return Column(
                children: [
                  Container(
                    width: isSmallScreen ? 28 : 32,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: duration > 0
                            ? [Color(0xFF6C5CE7), Color(0xFF74B9FF)]
                            : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    day['date'],
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 10 : 11,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
  
  String _getDayName(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Widget _buildRecentActivity(bool isSmallScreen) {
    if (_isLoading) {
      return Container(
        height: 150,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
      );
    }
    
    if (_workoutHistory.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(
            'No recent activity',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          ..._workoutHistory.take(5).map((workout) {
            return Column(
              children: [
                _buildActivityItem(
                  workout.workoutTitle,
                  _formatWorkoutDate(workout.completedAt, workout.durationMinutes),
                  _getIconForWorkout(workout.workoutTitle),
                  isSmallScreen,
                ),
                if (workout != _workoutHistory.take(5).last)
                  SizedBox(height: 12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
  
  String _formatWorkoutDate(DateTime date, int duration) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    String dateStr;
    if (difference == 0) {
      dateStr = 'Today';
    } else if (difference == 1) {
      dateStr = 'Yesterday';
    } else if (difference < 7) {
      dateStr = '$difference days ago';
    } else {
      dateStr = '${date.month}/${date.day}';
    }
    
    return '$dateStr, $duration min';
  }
  
  IconData _getIconForWorkout(String title) {
    if (title.contains('Push')) return Icons.fitness_center_rounded;
    if (title.contains('Pull')) return Icons.self_improvement_rounded;
    if (title.contains('Leg')) return Icons.directions_run_rounded;
    if (title.contains('Core')) return Icons.accessibility_new_rounded;
    return Icons.fitness_center_rounded;
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, bool isSmall) {
    return Row(
      children: [
        Container(
          width: isSmall ? 40 : 48,
          height: isSmall ? 40 : 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: isSmall ? 20 : 24),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 14 : 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: isSmall ? 12 : 13,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildGoalsProgress(bool isSmallScreen) {
    if (_isLoading) {
      return Container(
        height: 150,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
      );
    }
    
    // Calculate goals based on fitness level
    String fitnessLevel = widget.profile['fitnessLevel'] ?? 'beginner';
    int weeklyWorkoutGoal = fitnessLevel == 'beginner' ? 4 : fitnessLevel == 'intermediate' ? 5 : 6;
    int weeklyMinutesGoal = fitnessLevel == 'beginner' ? 100 : fitnessLevel == 'intermediate' ? 150 : 200;
    
    // Get this week's data
    int weeklyWorkouts = _selectedPeriod == 'Week' ? _totalWorkouts : 0;
    int weeklyMinutes = _selectedPeriod == 'Week' ? _totalMinutes : 0;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goals Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _buildGoalItem('Weekly Workouts', weeklyWorkouts, weeklyWorkoutGoal, isSmallScreen),
          SizedBox(height: 12),
          _buildGoalItem('Active Days', _currentStreak, 7, isSmallScreen),
          SizedBox(height: 12),
          _buildGoalItem('Total Minutes', weeklyMinutes, weeklyMinutesGoal, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String title, int current, int target, bool isSmall) {
    final progress = current / target;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmall ? 13 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$current / $target',
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmall ? 12 : 13,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Color(0xFF00B894) : Color(0xFF6C5CE7),
            ),
          ),
        ),
      ],
    );
  }
}
