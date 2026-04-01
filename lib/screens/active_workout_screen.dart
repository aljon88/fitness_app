import 'package:flutter/material.dart';
import 'dart:async';
import '../models/exercise.dart';
import '../models/workout_history.dart';
import '../services/workout_history_service.dart';
import 'pre_workout_demo_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic> workout;
  final Map<String, dynamic> profile;
  final Function? onWorkoutCompleted;

  const ActiveWorkoutScreen({
    Key? key,
    required this.workout,
    required this.profile,
    this.onWorkoutCompleted,
  }) : super(key: key);

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int currentExerciseIndex = 0;
  int currentSet = 1;
  bool isResting = false;
  int restTimeRemaining = 0;
  Timer? restTimer;
  DateTime? workoutStartTime;
  
  List<ExerciseResult> exerciseResults = [];
  Map<String, List<SetResult>> completedSets = {};

  @override
  void initState() {
    super.initState();
    workoutStartTime = DateTime.now();
    _initializeExerciseResults();
  }

  void _initializeExerciseResults() {
    final exercises = widget.workout['exercises'] as List;
    for (var exercise in exercises) {
      completedSets[exercise['name']] = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.workout['exercises'] as List;
    final currentExercise = exercises[currentExerciseIndex];
    final totalExercises = exercises.length;
    final progress = (currentExerciseIndex + 1) / totalExercises;

    return Scaffold(
      backgroundColor: Color(0xFF0D0E21),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(progress, totalExercises),
            Expanded(
              child: isResting
                  ? _buildRestScreen()
                  : _buildExerciseScreen(currentExercise),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double progress, int totalExercises) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _showQuitDialog(),
                icon: Icon(Icons.close_rounded, color: Colors.white, size: 28),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.workout['name'] ?? 'Workout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Exercise ${currentExerciseIndex + 1} of $totalExercises',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 48),
            ],
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseScreen(Map<String, dynamic> exercise) {
    final sets = exercise['sets'] ?? 3;
    final reps = exercise['reps'] ?? 10;
    final exerciseName = exercise['name'];
    final completedSetsForExercise = completedSets[exerciseName]?.length ?? 0;
    final instructions = _getExerciseInstructions(exerciseName);
    final tips = _getExerciseTips(exerciseName);
    final safety = _getExerciseSafety(exerciseName);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Exercise name only
                Text(
                  exerciseName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Set $currentSet of $sets • $reps reps',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                
                // Exercise demonstration placeholder
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1B3A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFF6C5CE7).withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getExerciseIcon(exerciseName),
                        color: Color(0xFF6C5CE7),
                        size: 80,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Exercise Demo',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Instructions
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1B3A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_list_numbered,
                            color: Color(0xFF6C5CE7),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'How to Perform',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      ...instructions.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Color(0xFF6C5CE7),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                
                // Tips section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Pro Tips',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ...tips.map((tip) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                
                // Safety warnings
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Safety',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ...safety.map((warning) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚠ ',
                                style: TextStyle(fontSize: 14),
                              ),
                              Expanded(
                                child: Text(
                                  warning,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                
                // Completed sets
                if (completedSetsForExercise > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(sets, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < completedSetsForExercise
                              ? Colors.green
                              : Color(0xFF1A1B3A),
                        ),
                        child: Center(
                          child: index < completedSetsForExercise
                              ? Icon(Icons.check, color: Colors.white, size: 20)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
        
        // Bottom section with button
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF0D0E21),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Start button - solid, not blurry
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _startExerciseWithCamera(exercise),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Start Exercise',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Info text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, color: Color(0xFF6C5CE7), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Watch demo, then start timer workout',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.spa_rounded,
            color: Colors.green,
            size: 80,
          ),
          SizedBox(height: 24),
          Text(
            'Rest Time',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.2),
              border: Border.all(color: Colors.green, width: 4),
            ),
            child: Center(
              child: Text(
                '$restTimeRemaining',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: _skipRest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Skip Rest',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getExerciseInstructions(String exerciseName) {
    final instructionsMap = {
      'Push-ups': [
        'Start in plank position with hands shoulder-width apart',
        'Lower your body until chest nearly touches the floor',
        'Keep your core tight and back straight',
        'Push back up to starting position',
      ],
      'Squats': [
        'Stand with feet shoulder-width apart',
        'Lower your body by bending knees and hips',
        'Keep chest up and knees behind toes',
        'Push through heels to return to start',
      ],
      'Lunges': [
        'Stand with feet hip-width apart',
        'Step forward with one leg and lower hips',
        'Keep front knee at 90 degrees',
        'Push back to starting position and alternate',
      ],
      'Plank': [
        'Start in forearm plank position',
        'Keep body in straight line from head to heels',
        'Engage core and hold position',
        'Breathe steadily throughout',
      ],
      'Jumping Jacks': [
        'Start with feet together, arms at sides',
        'Jump while spreading legs and raising arms',
        'Return to starting position',
        'Maintain steady rhythm',
      ],
    };
    
    return instructionsMap[exerciseName] ?? [
      'Position yourself properly',
      'Perform the movement with control',
      'Maintain proper form throughout',
      'Complete the target number of reps',
    ];
  }
  
  List<String> _getExerciseTips(String exerciseName) {
    final tipsMap = {
      'Push-ups': [
        'Keep elbows at 45-degree angle to body',
        'Engage your core throughout the movement',
        'Breathe in going down, breathe out pushing up',
        'Focus on controlled movement, not speed',
      ],
      'Squats': [
        'Keep your weight on your heels',
        'Don\'t let knees cave inward',
        'Chest up, eyes forward throughout',
        'Go as low as comfortable with good form',
      ],
      'Lunges': [
        'Keep torso upright throughout movement',
        'Front knee should not pass toes',
        'Push through front heel to return',
        'Maintain balance by engaging core',
      ],
      'Plank': [
        'Don\'t let hips sag or pike up',
        'Keep neck neutral, look at floor',
        'Squeeze glutes and core tight',
        'Breathe normally, don\'t hold breath',
      ],
      'Jumping Jacks': [
        'Land softly on balls of feet',
        'Keep movements smooth and controlled',
        'Maintain steady breathing rhythm',
        'Engage core for stability',
      ],
    };
    
    return tipsMap[exerciseName] ?? [
      'Focus on proper form over speed',
      'Breathe consistently throughout',
      'Engage your core muscles',
      'Move with control and intention',
    ];
  }
  
  List<String> _getExerciseSafety(String exerciseName) {
    final safetyMap = {
      'Push-ups': [
        'Stop if you feel sharp pain in shoulders or wrists',
        'Modify to knees if full push-ups are too difficult',
        'Warm up shoulders before starting',
      ],
      'Squats': [
        'Stop if you feel knee or lower back pain',
        'Don\'t squat deeper than comfortable',
        'Keep movements slow and controlled',
      ],
      'Lunges': [
        'Use wall for balance if needed',
        'Stop if you feel knee pain',
        'Start with shorter range of motion',
      ],
      'Plank': [
        'Stop if lower back hurts',
        'Modify to knees if needed',
        'Don\'t hold your breath',
      ],
      'Jumping Jacks': [
        'Land softly to protect joints',
        'Stop if you feel dizzy',
        'Modify to low-impact if needed',
      ],
    };
    
    return safetyMap[exerciseName] ?? [
      'Stop if you feel any sharp pain',
      'Modify exercises as needed',
      'Stay hydrated throughout workout',
    ];
  }
  
  IconData _getExerciseIcon(String exerciseName) {
    if (exerciseName.toLowerCase().contains('push')) {
      return Icons.fitness_center;
    } else if (exerciseName.toLowerCase().contains('squat') || 
               exerciseName.toLowerCase().contains('lunge')) {
      return Icons.accessibility_new;
    } else if (exerciseName.toLowerCase().contains('plank')) {
      return Icons.self_improvement;
    } else if (exerciseName.toLowerCase().contains('jump')) {
      return Icons.directions_run;
    }
    return Icons.sports_gymnastics;
  }

  void _startExerciseWithCamera(Map<String, dynamic> exercise) {
    // Navigate to pre-workout demo screen instead of camera
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreWorkoutDemoScreen(
          exercise: exercise,
          currentSet: currentSet,
          totalSets: exercise['sets'] ?? 3,
          targetReps: exercise['reps'] ?? 10,
          fitnessLevel: widget.profile['fitnessLevel'] ?? 'intermediate',
          onSetComplete: (int reps) {
            _completeSetWithAI(exercise, reps);
          },
        ),
      ),
    );
  }

  void _completeSetWithAI(Map<String, dynamic> exercise, int reps) {
    final exerciseName = exercise['name'];
    final sets = exercise['sets'] ?? 3;
    
    completedSets[exerciseName]!.add(SetResult(
      setNumber: currentSet,
      reps: reps,
      completedAt: DateTime.now(),
    ));
    
    setState(() {
      if (currentSet < sets) {
        currentSet++;
        _startRest(exercise['restTime'] ?? '60 seconds');
      } else {
        _moveToNextExercise();
      }
    });
  }

  void _startRest(String restTimeString) {
    final seconds = int.tryParse(restTimeString.split(' ').first) ?? 60;
    
    setState(() {
      isResting = true;
      restTimeRemaining = seconds;
    });
    
    restTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        restTimeRemaining--;
        if (restTimeRemaining <= 0) {
          _skipRest();
        }
      });
    });
  }

  void _skipRest() {
    restTimer?.cancel();
    setState(() {
      isResting = false;
      restTimeRemaining = 0;
    });
  }

  void _moveToNextExercise() {
    final exercises = widget.workout['exercises'] as List;
    
    if (currentExerciseIndex < exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        currentSet = 1;
      });
    } else {
      _completeWorkout();
    }
  }

  Future<void> _completeWorkout() async {
    final workoutDuration = DateTime.now().difference(workoutStartTime!).inMinutes;
    
    int totalReps = 0;
    int totalSets = 0;
    List<ExerciseResult> results = [];
    
    final exercises = widget.workout['exercises'] as List;
    for (var exercise in exercises) {
      final exerciseName = exercise['name'];
      final sets = completedSets[exerciseName] ?? [];
      final reps = sets.fold(0, (sum, set) => sum + set.reps);
      
      totalReps += reps;
      totalSets += sets.length;
      
      results.add(ExerciseResult(
        exerciseId: exercise['name'].toLowerCase().replaceAll(' ', '_'),
        exerciseName: exerciseName,
        targetReps: exercise['reps'] ?? 10,
        actualReps: reps,
        targetSets: exercise['sets'] ?? 3,
        completedSets: sets.length,
        completed: sets.length >= (exercise['sets'] ?? 3),
        setResults: sets,
      ));
    }
    
    final history = WorkoutHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.profile['uid'] ?? 'user_001',
      workoutId: widget.workout['name'] ?? 'workout',
      workoutTitle: widget.workout['name'] ?? 'Workout',
      dayNumber: widget.workout['day'] ?? 1,
      completedAt: DateTime.now(),
      durationMinutes: workoutDuration,
      exercises: results,
      totalReps: totalReps,
      totalSets: totalSets,
      caloriesBurned: (totalReps * 0.5).round(),
      difficulty: widget.profile['fitnessLevel'] ?? 'beginner',
    );
    
    await WorkoutHistoryService().saveWorkout(history);
    _showCompletionDialog(history);
  }

  void _showCompletionDialog(WorkoutHistory history) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              Icons.celebration_rounded,
              color: Colors.amber,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Workout Complete!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Duration', '${history.durationMinutes} min'),
            _buildStatRow('Total Reps', '${history.totalReps}'),
            _buildStatRow('Total Sets', '${history.totalSets}'),
            _buildStatRow('Calories', '${history.caloriesBurned} kcal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              if (widget.onWorkoutCompleted != null) {
                widget.onWorkoutCompleted!();
              }
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: Color(0xFF6C5CE7),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Quit Workout?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to quit? Your progress won\'t be saved.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Quit',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    restTimer?.cancel();
    super.dispose();
  }
}
