import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/workout_history.dart';
import '../services/workout_history_service.dart';
import '../services/sound_service.dart';
import 'time_based_workout_screen.dart';
import 'workout_summary_screen.dart';

class ImprovedActiveWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic> workout;
  final Map<String, dynamic> profile;
  final Function? onWorkoutCompleted;

  const ImprovedActiveWorkoutScreen({
    Key? key,
    required this.workout,
    required this.profile,
    this.onWorkoutCompleted,
  }) : super(key: key);

  @override
  State<ImprovedActiveWorkoutScreen> createState() => _ImprovedActiveWorkoutScreenState();
}

class _ImprovedActiveWorkoutScreenState extends State<ImprovedActiveWorkoutScreen> {
  final SoundService _soundService = SoundService();
  
  int currentExerciseIndex = 0;
  int currentSet = 1;
  bool isResting = false;
  int restTimeRemaining = 0;
  Timer? restTimer;
  DateTime? workoutStartTime;
  
  Map<String, List<SetResult>> completedSets = {};
  int totalRepsCompleted = 0;

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
  void dispose() {
    restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.workout['exercises'] as List;
    final currentExercise = exercises[currentExerciseIndex];
    final totalExercises = exercises.length;

    return Scaffold(
      backgroundColor: Color(0xFF0D0E21),
      body: SafeArea(
        child: isResting
            ? _buildRestScreen(exercises)
            : _buildExerciseExecutionScreen(currentExercise, totalExercises),
      ),
    );
  }

  Widget _buildExerciseExecutionScreen(Map<String, dynamic> exercise, int totalExercises) {
    final exerciseName = exercise['name'];
    final gifUrl = exercise['gifUrl'] as String?;
    final duration = exercise['duration'] ?? 30;

    return Stack(
      children: [
        // Full-screen exercise demo placeholder
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E88E5).withOpacity(0.2),
                  Color(0xFF00BFA5).withOpacity(0.2),
                ],
              ),
            ),
            child: Center(
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
                      Icons.fitness_center,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Exercise Demo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Top bar with progress
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopBar(totalExercises),
        ),
        
        // Bottom exercise info
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomExerciseInfo(exercise, 1, 0),
        ),
      ],
    );
  }

  Widget _buildTopBar(int totalExercises) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _showQuitDialog(),
                icon: Icon(Icons.close, color: Colors.white, size: 28),
              ),
              Spacer(),
              Text(
                'Exercises ${currentExerciseIndex + 1}/$totalExercises',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.music_note, color: Colors.white, size: 24),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalExercises > 12 ? 12 : totalExercises,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                width: index == currentExerciseIndex ? 24 : 8,
                height: 4,
                decoration: BoxDecoration(
                  color: index <= currentExerciseIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomExerciseInfo(Map<String, dynamic> exercise, int sets, int completedSets) {
    final instructions = exercise['instructions'] as List? ?? ['Perform the exercise with proper form'];
    final tips = exercise['tips'] as List? ?? ['Focus on controlled movements'];
    final targetMuscles = exercise['targetMuscles'] as List? ?? ['Full Body'];
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                exercise['name'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: () => _showExerciseInfo(exercise, instructions, tips, targetMuscles),
                icon: Icon(Icons.info_outline, color: Colors.white60, size: 20),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Target muscles chips
          Wrap(
            spacing: 8,
            children: targetMuscles.take(3).map((muscle) => Chip(
              label: Text(
                muscle.toString(),
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: Color(0xFF1E88E5).withOpacity(0.3),
              side: BorderSide.none,
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          ),
          SizedBox(height: 16),
          Text(
            '${exercise['duration'] ?? 30}s',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous exercise
              IconButton(
                onPressed: currentExerciseIndex > 0 ? _previousExercise : null,
                icon: Icon(
                  Icons.skip_previous,
                  color: currentExerciseIndex > 0 ? Colors.white : Colors.white30,
                  size: 32,
                ),
              ),
              // Start/Pause button
              GestureDetector(
                onTap: () => _startExercise(exercise),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E88E5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              // Next exercise
              IconButton(
                onPressed: _nextExercise,
                icon: Icon(Icons.skip_next, color: Colors.white, size: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExerciseInfo(Map<String, dynamic> exercise, List instructions, List tips, List targetMuscles) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            // Title
            Text(
              exercise['name'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            // Target muscles
            Wrap(
              spacing: 8,
              children: targetMuscles.map((muscle) => Chip(
                label: Text(
                  muscle.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: Color(0xFF1E88E5),
                side: BorderSide.none,
              )).toList(),
            ),
            SizedBox(height: 16),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructions
                    Text(
                      'How to Perform',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...instructions.asMap().entries.map((entry) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(0xFF1E88E5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    SizedBox(height: 24),
                    // Tips
                    Text(
                      'Pro Tips',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...tips.map((tip) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, color: Color(0xFF00BFA5), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestScreen(List exercises) {
    final nextExercise = currentExerciseIndex < exercises.length - 1
        ? exercises[currentExerciseIndex + 1]
        : null;

    return Container(
      color: Color(0xFF007AFF),
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showQuitDialog(),
                  icon: Icon(Icons.close, color: Colors.white, size: 28),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.menu, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          
          Spacer(),
          
          // REST title and timer
          Text(
            'REST',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 16),
          Text(
            _formatRestTime(restTimeRemaining),
            style: TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _addRestTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text('+20s', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: _skipRest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF007AFF),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text('SKIP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          
          Spacer(),
          
          // Next exercise preview
          if (nextExercise != null) ...[
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Text(
                    'NEXT ${currentExerciseIndex + 2}/${exercises.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            nextExercise['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.help_outline, color: Colors.white, size: 18),
                        ],
                      ),
                      Text(
                        '${nextExercise['duration'] ?? 30}s',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _startExercise(Map<String, dynamic> exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimeBasedWorkoutScreen(
          exercise: exercise,
          currentSet: currentExerciseIndex + 1,
          totalSets: (widget.workout['exercises'] as List).length,
          duration: exercise['duration'] ?? 30,
          fitnessLevel: widget.profile['fitnessLevel'] ?? 'intermediate',
          onSetComplete: () {
            _completeSet(exercise);
          },
        ),
      ),
    );
  }

  void _completeSet(Map<String, dynamic> exercise) {
    final exerciseName = exercise['name'];
    
    // For time-based workouts, we just mark it as complete
    completedSets[exerciseName]!.add(SetResult(
      setNumber: 1,
      reps: 1, // Time-based, so we just mark as 1 "rep" (completed)
      completedAt: DateTime.now(),
    ));
    
    totalRepsCompleted += 1;
    
    setState(() {
      _moveToNextExercise();
    });
  }

  void _moveToNextExercise() {
    final exercises = widget.workout['exercises'] as List;
    
    if (currentExerciseIndex < exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        currentSet = 1;
        isResting = true;
        restTimeRemaining = 10; // 10 seconds rest between exercises
      });
      
      _soundService.playSound(SoundService.restStart);
      
      restTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          restTimeRemaining--;
          if (restTimeRemaining <= 0) {
            _skipRest();
          }
        });
      });
    } else {
      _completeWorkout();
    }
  }

  void _previousExercise() {
    if (currentExerciseIndex > 0) {
      setState(() {
        currentExerciseIndex--;
        currentSet = 1;
        isResting = false;
      });
    }
  }

  void _nextExercise() {
    _moveToNextExercise();
  }

  void _addRestTime() {
    setState(() {
      restTimeRemaining += 20;
    });
  }

  void _skipRest() {
    restTimer?.cancel();
    setState(() {
      isResting = false;
      restTimeRemaining = 0;
    });
  }

  Future<void> _completeWorkout() async {
    final workoutDuration = DateTime.now().difference(workoutStartTime!).inMinutes;
    
    int totalSets = 0;
    List<ExerciseResult> results = [];
    
    final exercises = widget.workout['exercises'] as List;
    for (var exercise in exercises) {
      final exerciseName = exercise['name'];
      final sets = completedSets[exerciseName] ?? [];
      
      totalSets += sets.length;
      
      results.add(ExerciseResult(
        exerciseId: exercise['name'].toLowerCase().replaceAll(' ', '_'),
        exerciseName: exerciseName,
        targetReps: exercise['duration'] ?? 30, // Store duration as "target reps"
        actualReps: exercise['duration'] ?? 30, // Store duration as "actual reps"
        targetSets: 1,
        completedSets: sets.length,
        completed: sets.length >= 1,
        setResults: sets,
      ));
    }
    
    final history = WorkoutHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.profile['uid'] ?? 'user_001',
      workoutId: widget.workout['title'],
      workoutTitle: widget.workout['title'],
      dayNumber: widget.workout['day'] ?? 1,
      completedAt: DateTime.now(),
      durationMinutes: workoutDuration,
      exercises: results,
      totalReps: totalRepsCompleted,
      totalSets: totalSets,
      caloriesBurned: (totalRepsCompleted * 5).round(), // Estimate based on exercises completed
      difficulty: widget.profile['fitnessLevel'] ?? 'beginner',
    );
    
    await WorkoutHistoryService().saveWorkout(history);
    
    _soundService.playSound(SoundService.workoutComplete);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutSummaryScreen(workoutHistory: history),
        ),
      );
    }
  }

  void _showQuitDialog() {
    final exercises = widget.workout['exercises'] as List;
    final totalExercises = exercises.length;
    final completedExercises = currentExerciseIndex;
    final progressPercent = ((completedExercises / totalExercises) * 100).round();
    final remainingExercises = totalExercises - completedExercises;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, size: 80, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                'Why give up?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
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
              _buildQuitOption('Don\'t know how to do it'),
              _buildQuitOption('Too easy'),
              _buildQuitOption('Too hard'),
              _buildQuitOption('Just take a look'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Quit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Feedback', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    ).then((value) {
      if (value == 'quit') {
        Navigator.of(context).pop();
      }
    });
  }

  Widget _buildQuitOption(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop('quit'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black,
          minimumSize: Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  String _formatRestTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
