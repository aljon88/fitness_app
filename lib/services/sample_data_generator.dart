import 'dart:math';
import '../models/workout_history.dart';
import 'workout_history_service.dart';

/// Generates realistic sample workout data for testing and demonstration
class SampleDataGenerator {
  static final Random _random = Random();
  
  /// Generate 30 days of realistic workout history
  static Future<void> generate30DayHistory({
    required String userId,
    required String difficulty,
  }) async {
    List<WorkoutHistory> history = [];
    DateTime now = DateTime.now();
    
    // Generate 30 days back
    int workoutDayNumber = 1;
    for (int i = 29; i >= 0; i--) {
      DateTime workoutDate = now.subtract(Duration(days: i));
      
      // Realistic rest day pattern based on difficulty
      bool isRestDay = _shouldBeRestDay(i, difficulty);
      if (isRestDay) continue;
      
      // Generate workout with progressive overload
      WorkoutHistory workout = _generateRealisticWorkout(
        userId: userId,
        date: workoutDate,
        difficulty: difficulty,
        workoutDayNumber: workoutDayNumber,
        daysSinceStart: 30 - i,
      );
      
      history.add(workout);
      workoutDayNumber++;
    }
    
    // Save all workouts
    final historyService = WorkoutHistoryService();
    for (var workout in history) {
      await historyService.saveWorkout(workout);
    }
  }
  
  /// Determine if a day should be a rest day based on difficulty
  static bool _shouldBeRestDay(int dayIndex, String difficulty) {
    int weekDay = dayIndex % 7;
    
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        // 4 workouts/week: rest on days 2, 4, 5 (Wed, Fri, Sat)
        return [2, 4, 5].contains(weekDay);
      case 'intermediate':
        // 5 workouts/week: rest on days 1, 5 (Tue, Sat)
        return [1, 5].contains(weekDay);
      case 'advanced':
        // 6 workouts/week: rest on day 3 (Thu)
        return [3].contains(weekDay);
      default:
        return [2, 4, 5].contains(weekDay);
    }
  }
  
  /// Generate a realistic workout with progressive overload
  static WorkoutHistory _generateRealisticWorkout({
    required String userId,
    required DateTime date,
    required String difficulty,
    required int workoutDayNumber,
    required int daysSinceStart,
  }) {
    // Progressive overload: performance improves over time
    double progressionFactor = 1.0 + (daysSinceStart / 150); // 20% improvement over 30 days
    
    // Workout type rotation (Push/Pull/Legs/Core)
    List<String> workoutTypes = ['Push', 'Pull', 'Legs', 'Core'];
    String workoutType = workoutTypes[(workoutDayNumber - 1) % workoutTypes.length];
    
    // Generate exercises with realistic performance
    List<ExerciseResult> exercises = _generateExercisesWithProgression(
      workoutType,
      difficulty,
      progressionFactor,
    );
    
    // Calculate totals
    int totalReps = exercises.fold(0, (sum, ex) => sum + ex.actualReps);
    int totalSets = exercises.fold(0, (sum, ex) => sum + ex.completedSets);
    int duration = _calculateDuration(difficulty, exercises.length);
    int calories = (totalReps * 5 * _getDifficultyMultiplier(difficulty)).round();
    
    return WorkoutHistory(
      id: '${userId}_${date.millisecondsSinceEpoch}',
      userId: userId,
      workoutId: 'workout_day_$workoutDayNumber',
      workoutTitle: 'Day $workoutDayNumber: $workoutType Day',
      dayNumber: workoutDayNumber,
      completedAt: date,
      durationMinutes: duration,
      exercises: exercises,
      totalReps: totalReps,
      totalSets: totalSets,
      caloriesBurned: calories,
      difficulty: difficulty,
    );
  }
  
  /// Generate exercises with progressive overload
  static List<ExerciseResult> _generateExercisesWithProgression(
    String workoutType,
    String difficulty,
    double progressionFactor,
  ) {
    List<ExerciseResult> exercises = [];
    List<Map<String, dynamic>> exerciseTemplates = _getExerciseTemplates(workoutType, difficulty);
    
    for (var template in exerciseTemplates) {
      int targetReps = (template['reps'] * progressionFactor).round();
      int targetSets = template['sets'];
      
      // Simulate realistic performance (90-105% of target)
      List<SetResult> setResults = [];
      int totalReps = 0;
      
      for (int set = 1; set <= targetSets; set++) {
        // Performance degrades slightly with each set
        double fatigueFactor = 1.0 - (set - 1) * 0.08;
        double performanceVariation = 0.90 + _random.nextDouble() * 0.15; // 90-105%
        
        int reps = (targetReps * fatigueFactor * performanceVariation).round();
        reps = reps.clamp(targetReps - 4, targetReps + 2); // Keep realistic
        
        setResults.add(SetResult(
          setNumber: set,
          reps: reps,
          completedAt: DateTime.now().subtract(Duration(minutes: (targetSets - set) * 2)),
        ));
        
        totalReps += reps;
      }
      
      exercises.add(ExerciseResult(
        exerciseId: template['id'],
        exerciseName: template['name'],
        targetReps: targetReps,
        actualReps: totalReps,
        targetSets: targetSets,
        completedSets: targetSets,
        completed: true,
        setResults: setResults,
      ));
    }
    
    return exercises;
  }
  
  /// Get exercise templates for workout type and difficulty
  static List<Map<String, dynamic>> _getExerciseTemplates(String workoutType, String difficulty) {
    // Base reps and sets by difficulty
    Map<String, Map<String, int>> difficultyParams = {
      'beginner': {'reps': 10, 'sets': 2},
      'intermediate': {'reps': 15, 'sets': 3},
      'advanced': {'reps': 20, 'sets': 4},
    };
    
    int baseReps = difficultyParams[difficulty]?['reps'] ?? 10;
    int baseSets = difficultyParams[difficulty]?['sets'] ?? 2;
    
    Map<String, List<Map<String, dynamic>>> templates = {
      'Push': [
        {'id': 'push_ups', 'name': 'Push-ups', 'reps': baseReps, 'sets': baseSets},
        {'id': 'diamond_push_ups', 'name': 'Diamond Push-ups', 'reps': (baseReps * 0.7).round(), 'sets': baseSets},
      ],
      'Pull': [
        {'id': 'plank', 'name': 'Plank Hold', 'reps': 1, 'sets': baseSets},
        {'id': 'side_plank', 'name': 'Side Plank', 'reps': 1, 'sets': baseSets},
      ],
      'Legs': [
        {'id': 'squats', 'name': 'Squats', 'reps': (baseReps * 1.5).round(), 'sets': baseSets},
        {'id': 'lunges', 'name': 'Lunges', 'reps': baseReps, 'sets': baseSets},
      ],
      'Core': [
        {'id': 'crunches', 'name': 'Crunches', 'reps': (baseReps * 1.2).round(), 'sets': baseSets},
        {'id': 'mountain_climbers', 'name': 'Mountain Climbers', 'reps': (baseReps * 1.5).round(), 'sets': baseSets},
      ],
    };
    
    return templates[workoutType] ?? templates['Push']!;
  }
  
  /// Calculate workout duration based on difficulty and exercise count
  static int _calculateDuration(String difficulty, int exerciseCount) {
    int baseTime = difficulty == 'beginner' ? 20 : difficulty == 'intermediate' ? 30 : 40;
    return baseTime + (exerciseCount * 5) + _random.nextInt(10);
  }
  
  /// Get calorie multiplier based on difficulty
  static double _getDifficultyMultiplier(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 1.0;
      case 'intermediate':
        return 1.3;
      case 'advanced':
        return 1.6;
      default:
        return 1.0;
    }
  }
  
  /// Legacy method for backward compatibility (generates 7 days)
  static List<WorkoutHistory> generateSampleHistory({
    required String userId,
    required String difficulty,
    int daysCompleted = 7,
  }) {
    List<WorkoutHistory> history = [];
    DateTime now = DateTime.now();
    
    int workoutDayNumber = 1;
    for (int i = daysCompleted - 1; i >= 0; i--) {
      DateTime workoutDate = now.subtract(Duration(days: i));
      
      // Skip some days randomly to simulate rest days
      if (_random.nextDouble() < 0.3) continue;
      
      WorkoutHistory workout = _generateRealisticWorkout(
        userId: userId,
        date: workoutDate,
        difficulty: difficulty,
        workoutDayNumber: workoutDayNumber,
        daysSinceStart: daysCompleted - i,
      );
      
      history.add(workout);
      workoutDayNumber++;
    }
    
    return history;
  }
}
