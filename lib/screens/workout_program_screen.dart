import 'package:flutter/material.dart';
import '../widgets/ai_coach_character.dart';
import '../services/navigation_service.dart';
import '../models/navigation_state.dart';
import '../widgets/navigation_widgets.dart';
import '../models/exercise.dart';
import '../services/workout_program_generator.dart';

class WorkoutProgramScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  
  const WorkoutProgramScreen({super.key, required this.userProfile});

  @override
  State<WorkoutProgramScreen> createState() => _WorkoutProgramScreenState();
}

class _WorkoutProgramScreenState extends State<WorkoutProgramScreen> with TickerProviderStateMixin {
  int currentDay = 1;
  List<bool> completedDays = [];
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late WorkoutProgram workoutProgram;

  @override
  void initState() {
    super.initState();
    
    // Generate workout program based on user's fitness level
    String fitnessLevel = widget.userProfile['fitnessLevel'] ?? 'beginner';
    workoutProgram = WorkoutProgramGenerator.getProgramByDifficulty(fitnessLevel);
    
    // Initialize completed days list based on program length
    completedDays = List.filled(workoutProgram.totalDays, false);
    
    _progressController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: (currentDay - 1) / workoutProgram.totalDays,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.forward();
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
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header
                NavigationHeader(
                  title: workoutProgram.name,
                  subtitle: workoutProgram.description,
                ),
                
                // AI Coach Message
                AICoachCharacter(
                  message: _getCoachMessage(),
                  mood: AICoachMood.motivating,
                ),
                
                // Progress Section
                _buildProgressSection(),
                
                // All workout days
                _buildAllWorkoutDays(),
                
                // Bottom spacing for FAB
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MainNavigationBar(currentScreen: NavigationScreen.workoutProgram),
      floatingActionButton: WorkoutCameraFAB(),
    );
  }

  Widget _buildProgressSection() {
    int completedCount = completedDays.where((completed) => completed).length;
    double progressPercentage = completedCount / workoutProgram.totalDays;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6C5CE7),
            Color(0xFF74B9FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day $currentDay of ${workoutProgram.totalDays}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$completedCount days completed',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progressPercentage,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progressPercentage * 100).round()}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllWorkoutDays() {
    return Column(
      children: List.generate(workoutProgram.totalDays, (index) {
        final day = index + 1;
        final isUnlocked = day <= currentDay;
        final isCompleted = completedDays[index];
        final isToday = day == currentDay && !isCompleted;
        
        // Get workout day info
        WorkoutDay? workoutDay = workoutProgram.workoutDays
            .where((wd) => wd.day == day)
            .firstOrNull;
        
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          decoration: BoxDecoration(
            gradient: isToday 
                ? LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                  )
                : null,
            color: isToday ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isToday 
                  ? Colors.transparent 
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : isUnlocked
                        ? (isToday ? Colors.white : Color(0xFF6C5CE7))
                        : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
              ),
              child: isCompleted
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 24)
                  : isUnlocked
                      ? Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isToday ? Color(0xFF6C5CE7) : Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : Icon(Icons.lock_rounded, color: Colors.white54, size: 20),
            ),
            title: Text(
              workoutDay?.title ?? 'Day $day Workout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  workoutDay?.description ?? 'Fitness development workout',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.white60, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${workoutDay?.estimatedDuration ?? 15} min',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.fitness_center_outlined, color: Colors.white60, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${workoutDay?.exercises.length ?? 3} exercises',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: isUnlocked
                ? Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      isToday ? Icons.play_arrow_rounded : Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: isToday ? 24 : 16,
                    ),
                  )
                : null,
            onTap: isUnlocked
                ? () => _startWorkout(day)
                : () => _showLockedMessage(),
          ),
        );
      }),
    );
  }

  void _startWorkout(int day) {
    // Get the actual workout day from our program
    WorkoutDay? workoutDay = workoutProgram.workoutDays
        .where((wd) => wd.day == day)
        .firstOrNull;
    
    if (workoutDay == null) {
      _showError('Workout for day $day not available yet');
      return;
    }

    final workout = {
      'title': workoutDay.title,
      'day': day,
      'duration': '${workoutDay.estimatedDuration} min',
      'exercises': workoutDay.exercises.map((exercise) => {
        'name': exercise.name,
        'reps': exercise.reps,
        'sets': exercise.sets,
        'restTime': exercise.restTime,
        'instructions': exercise.instructions.join('\n'),
        'tips': exercise.tips.join('\n'),
        'difficulty': exercise.difficulty,
        'targetMuscles': exercise.targetMuscles.join(', '),
      }).toList(),
    };

    NavigationService().navigateTo(
      NavigationScreen.workoutDetail,
      arguments: {
        'workout': workout,
        'profile': widget.userProfile,
        'onWorkoutCompleted': () => _completeDay(day),
      },
      transition: NavigationTransition.slide,
    );
  }

  String _getCoachMessage() {
    int completedCount = completedDays.where((completed) => completed).length;
    double progressPercentage = completedCount / workoutProgram.totalDays;
    String level = widget.userProfile['fitnessLevel'] ?? 'beginner';
    
    if (completedCount == 0) {
      return "Welcome to your ${workoutProgram.totalDays}-day ${level} transformation! Let's start with Day 1 and build momentum! 🚀";
    }
    
    if (progressPercentage >= 0.5) {
      return "You're over halfway there! Your ${level}-level dedication is incredible - keep pushing forward! 💪";
    }
    
    if (completedCount >= 7) {
      return "Amazing! You've completed $completedCount days! You're building an unstoppable ${level} habit! 🔥";
    }
    
    if (completedCount >= 3) {
      return "Great progress! $completedCount days completed. You're proving your ${level} potential! ⭐";
    }
    
    return "Day $currentDay is ready for you! Every ${level} workout makes you stronger than yesterday! 💯";
  }

  void _completeDay(int day) {
    setState(() {
      completedDays[day - 1] = true;
      if (day == currentDay && currentDay < workoutProgram.totalDays) {
        currentDay++;
      }
    });
    
    _showCompletionDialog(day);
  }

  void _showCompletionDialog(int day) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.celebration_rounded, color: Color(0xFF6C5CE7), size: 28),
            SizedBox(width: 12),
            Text(
              'Day $day Complete!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations! You\'ve completed Day $day of your fitness journey.',
              style: TextStyle(color: Colors.white70),
            ),
            if (day < workoutProgram.totalDays) ...[
              SizedBox(height: 16),
              Text(
                'Day ${day + 1} is now unlocked!',
                style: TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              SizedBox(height: 16),
              Text(
                '🎉 You\'ve completed the entire ${workoutProgram.totalDays}-day program! Amazing work!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continue',
              style: TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.lock_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Complete the previous day to unlock this workout!'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }
}