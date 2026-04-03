import 'package:flutter/material.dart';
import 'ready_to_go_screen.dart';
import 'exercise_timer_screen.dart';
import 'rest_screen.dart';

class WorkoutSessionController extends StatefulWidget {
  final Map<String, dynamic> workout;
  final Map<String, dynamic> profile;
  final VoidCallback onWorkoutCompleted;

  const WorkoutSessionController({
    Key? key,
    required this.workout,
    required this.profile,
    required this.onWorkoutCompleted,
  }) : super(key: key);

  @override
  State<WorkoutSessionController> createState() => _WorkoutSessionControllerState();
}

class _WorkoutSessionControllerState extends State<WorkoutSessionController> {
  int _currentExerciseIndex = 0;
  WorkoutPhase _currentPhase = WorkoutPhase.ready;
  List<Map<String, dynamic>> _exercises = [];
  int _completedExercises = 0;

  @override
  void initState() {
    super.initState();
    _exercises = (widget.workout['exercises'] as List).cast<Map<String, dynamic>>();
  }

  void _moveToNextPhase() {
    setState(() {
      switch (_currentPhase) {
        case WorkoutPhase.ready:
          _currentPhase = WorkoutPhase.exercise;
          break;
        case WorkoutPhase.exercise:
          _completedExercises++;
          if (_currentExerciseIndex < _exercises.length - 1) {
            _currentPhase = WorkoutPhase.rest;
          } else {
            _completeWorkout();
          }
          break;
        case WorkoutPhase.rest:
          _currentExerciseIndex++;
          _currentPhase = WorkoutPhase.ready;
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
      barrierColor: Colors.black.withOpacity(0.8), // Solid overlay instead of blur
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
      barrierColor: Colors.black.withOpacity(0.8), // Solid overlay instead of blur
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
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Feedback',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
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
    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8), // Solid overlay instead of blur
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 24,
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded, 
                  color: Colors.green, 
                  size: 64
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Workout Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Great job! You completed all exercises.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.onWorkoutCompleted();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          nextExercise: nextExercise,
          nextExerciseIndex: _currentExerciseIndex + 1,
          totalExercises: _exercises.length,
          restDuration: currentExercise['rest'] ?? 30,
          onRestComplete: _moveToNextPhase,
          onSkip: _skipRest,
        );
    }
  }
}

enum WorkoutPhase {
  ready,
  exercise,
  rest,
}
