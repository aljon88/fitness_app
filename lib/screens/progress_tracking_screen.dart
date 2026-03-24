import 'package:flutter/material.dart';
import 'dart:math';

class ProgressTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const ProgressTrackingScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _ProgressTrackingScreenState createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  String _selectedPeriod = 'Week';
  
  // Mock data - in a real app, this would come from a database
  final List<Map<String, dynamic>> _workoutHistory = [
    {'date': 'Mon', 'workouts': 1, 'duration': 35},
    {'date': 'Tue', 'workouts': 1, 'duration': 42},
    {'date': 'Wed', 'workouts': 0, 'duration': 0},
    {'date': 'Thu', 'workouts': 1, 'duration': 38},
    {'date': 'Fri', 'workouts': 1, 'duration': 45},
    {'date': 'Sat', 'workouts': 0, 'duration': 0},
    {'date': 'Sun', 'workouts': 1, 'duration': 40},
  ];

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
              onTap: () => setState(() => _selectedPeriod = period),
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
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Workouts',
            '5',
            'This week',
            Icons.fitness_center_rounded,
            Color(0xFF6C5CE7),
            isSmallScreen,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Duration',
            '200',
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
            '7',
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
            children: _workoutHistory.map((day) {
              final maxDuration = _workoutHistory.map((d) => d['duration'] as int).reduce(max);
              final height = day['duration'] == 0 ? 20.0 : (day['duration'] / maxDuration * 100).toDouble();
              
              return Column(
                children: [
                  Container(
                    width: isSmallScreen ? 28 : 32,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: day['workouts'] > 0
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

  Widget _buildRecentActivity(bool isSmallScreen) {
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
          _buildActivityItem('Upper Body Workout', 'Today, 35 min', Icons.fitness_center_rounded, isSmallScreen),
          SizedBox(height: 12),
          _buildActivityItem('Cardio Session', 'Yesterday, 42 min', Icons.directions_run_rounded, isSmallScreen),
          SizedBox(height: 12),
          _buildActivityItem('Core Training', '2 days ago, 38 min', Icons.self_improvement_rounded, isSmallScreen),
        ],
      ),
    );
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
          _buildGoalItem('Weekly Workouts', 5, 7, isSmallScreen),
          SizedBox(height: 12),
          _buildGoalItem('Active Days', 5, 7, isSmallScreen),
          SizedBox(height: 12),
          _buildGoalItem('Total Minutes', 200, 300, isSmallScreen),
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
