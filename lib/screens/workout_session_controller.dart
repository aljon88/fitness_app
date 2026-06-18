import 'package:flutter/material.dart';
import 'ready_to_go_screen.dart';
import 'exercise_timer_screen.dart';
import 'rest_screen.dart';
import 'workout_celebration_screen.dart';
import '../services/sound_service.dart';
import '../services/workout_journal_service.dart';

class WorkoutSessionController extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final Map<String, dynamic> workoutData; // Add workout data
  final VoidCallback onWorkoutCompleted;

  const WorkoutSessionController({
    Key? key,
    required this.exercises,
    required this.workoutData, // Add workout data
    required this.onWorkoutCompleted,
  }) : super(key: key);

  @override
  State<WorkoutSessionController> createState() => _WorkoutSessionControllerState();
}

enum WorkoutPhase { ready, exercise, rest, celebration, completed }

class _WorkoutSessionControllerState extends State<WorkoutSessionController> {
  WorkoutPhase _currentPhase = WorkoutPhase.ready;
  int _currentExerciseIndex = 0;
  int _completedExercises = 0;

  List<Map<String, dynamic>> get _exercises => widget.exercises;

  void _moveToNextPhase() {
    print('🎬 WORKOUT SESSION: Moving to next phase from $_currentPhase');
    setState(() {
      switch (_currentPhase) {
        case WorkoutPhase.ready:
          _currentPhase = WorkoutPhase.exercise;
          print('🎬 WORKOUT SESSION: Now in EXERCISE phase');
          break;
        case WorkoutPhase.exercise:
          _completedExercises++;
          if (_currentExerciseIndex < _exercises.length - 1) {
            _currentPhase = WorkoutPhase.rest;
            print('🎬 WORKOUT SESSION: Now in REST phase');
          } else {
            _currentPhase = WorkoutPhase.celebration;
            print('🎬 WORKOUT SESSION: Now in CELEBRATION phase - should show celebration screen!');
            // Don't call _completeWorkout() here - let celebration screen handle completion
          }
          break;
        case WorkoutPhase.rest:
          _currentExerciseIndex++;
          _currentPhase = WorkoutPhase.ready;
          print('🎬 WORKOUT SESSION: Now in READY phase for next exercise');
          break;
        case WorkoutPhase.celebration:
          print('🎬 WORKOUT SESSION: Celebration completed, completing workout');
          // Celebration completed, now complete the workout and go back to calendar
          _completeWorkout();
          break;
        case WorkoutPhase.completed:
          print('🎬 WORKOUT SESSION: Calling onWorkoutCompleted callback');
          widget.onWorkoutCompleted();
          break;
      }
    });
  }

  void _skipRest() {
    setState(() {
      _currentExerciseIndex++;
      _currentPhase = WorkoutPhase.ready;
    });
  }

  void _showPauseDialog() {
    final progress = (_completedExercises / _exercises.length * 100).toInt();
    final remaining = _exercises.length - _completedExercises;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 24,
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hold on!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You can do it!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'You have finished $progress%',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                'Only $remaining exercises left',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF007AFF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Resume',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentPhase = WorkoutPhase.ready;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text(
                  'Restart this exercise',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showQuitDialog(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text(
                  'Quit',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
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

  void _showQuitDialog() {
    Navigator.pop(context); // Close pause dialog
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 24,
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Why give up?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This helps us know you better and\nimprove the workout to better suit you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              _buildFeedbackButton('Don\'t know how to do it'),
              _buildFeedbackButton('Too easy'),
              _buildFeedbackButton('Too hard'),
              _buildFeedbackButton('Just take a look'),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text(
                  'Quit',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text(
                  'Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF007AFF),
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

  Widget _buildFeedbackButton(String text) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        onPressed: () {
          // Save feedback
          print('Feedback: $text');
          Navigator.pop(context);
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
          backgroundColor: Colors.grey[50],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _completeWorkout() {
    // Professional workout completion sequence
    SoundService().playWorkoutCompleteSequence();
    
    // Call the existing callback - this maintains the proper UI flow
    widget.onWorkoutCompleted();
  }

  String _getWorkoutTypeName() {
    // Try to determine workout type from exercises or use generic name
    if (_exercises.isNotEmpty) {
      final firstExercise = _exercises.first;
      if (firstExercise.containsKey('workoutType')) {
        return firstExercise['workoutType'];
      }
    }
    return 'Workout';
  }

  int _getTotalWorkoutDuration() {
    // Calculate total workout duration in seconds
    // This is a simple estimation - you might want to track actual time
    int totalDuration = 0;
    
    for (var exercise in _exercises) {
      final int sets = exercise['sets'] ?? 1;
      final num duration = exercise['duration'] ?? 30;
      final num rest = exercise['rest'] ?? 30;
      
      totalDuration += ((duration * sets) + (rest * (sets - 1))).round();
    }
    
    return totalDuration;
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = _exercises[_currentExerciseIndex];
    final nextExercise = _currentExerciseIndex < _exercises.length - 1
        ? _exercises[_currentExerciseIndex + 1]
        : null;

    switch (_currentPhase) {
      case WorkoutPhase.ready:
        return ReadyToGoScreen(
          exercise: currentExercise,
          currentExerciseIndex: _currentExerciseIndex,
          totalExercises: _exercises.length,
          onStart: _moveToNextPhase,
        );
      case WorkoutPhase.exercise:
        return ExerciseTimerScreen(
          exercise: currentExercise,
          currentExerciseIndex: _currentExerciseIndex,
          totalExercises: _exercises.length,
          onComplete: _moveToNextPhase,
          onPause: _showPauseDialog,
        );
      case WorkoutPhase.rest:
        return RestScreen(
          nextExercise: nextExercise!,
          nextExerciseIndex: _currentExerciseIndex + 1,
          totalExercises: _exercises.length,
          restDuration: currentExercise['rest'] ?? 30,
          onRestComplete: _moveToNextPhase,
          onSkip: _skipRest,
        );
      case WorkoutPhase.celebration:
        print('🎬 WORKOUT SESSION CONTROLLER: Showing celebration screen');
        return WorkoutCelebrationScreen(
          exercises: _exercises,
          workoutType: _getWorkoutTypeName(),
          duration: (_getTotalWorkoutDuration() / 60).round(),
          calories: widget.workoutData['calories'] ?? 0, // Pass actual calories
          onComplete: _moveToNextPhase,
        );
      case WorkoutPhase.completed:
        return Container(); // This shouldn't be reached as we call onWorkoutCompleted
    }
  }
}