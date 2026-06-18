import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'unified_auth_service.dart';

/// Professional workout tracking with comprehensive data and analytics
class WorkoutSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String workoutType;
  final String workoutTitle;
  final List<CompletedExercise> exercises;
  final int totalDuration; // in seconds
  final int caloriesBurned;
  final double averageHeartRate;
  final String difficulty;
  final String notes;
  final Map<String, dynamic> metadata;

  WorkoutSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.workoutType,
    required this.workoutTitle,
    required this.exercises,
    required this.totalDuration,
    required this.caloriesBurned,
    required this.averageHeartRate,
    required this.difficulty,
    required this.notes,
    required this.metadata,
  });

  // Calculate derived metrics
  int get totalReps => exercises.fold(0, (sum, ex) => sum + ex.totalReps);
  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets);
  double get caloriesPerMinute => totalDuration > 0 ? (caloriesBurned / (totalDuration / 60)) : 0;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'workoutType': workoutType,
      'workoutTitle': workoutTitle,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'totalDuration': totalDuration,
      'caloriesBurned': caloriesBurned,
      'averageHeartRate': averageHeartRate,
      'difficulty': difficulty,
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      workoutType: json['workoutType'],
      workoutTitle: json['workoutTitle'],
      exercises: (json['exercises'] as List)
          .map((e) => CompletedExercise.fromJson(e))
          .toList(),
      totalDuration: json['totalDuration'],
      caloriesBurned: json['caloriesBurned'],
      averageHeartRate: (json['averageHeartRate'] ?? 0.0).toDouble(),
      difficulty: json['difficulty'] ?? 'moderate',
      notes: json['notes'] ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class CompletedExercise {
  final String name;
  final String type; // 'reps', 'time', 'distance'
  final int sets;
  final int repsPerSet;
  final int durationSeconds;
  final double weight;
  final String notes;

  CompletedExercise({
    required this.name,
    required this.type,
    required this.sets,
    required this.repsPerSet,
    required this.durationSeconds,
    required this.weight,
    required this.notes,
  });

  int get totalReps => sets * repsPerSet;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'sets': sets,
      'repsPerSet': repsPerSet,
      'durationSeconds': durationSeconds,
      'weight': weight,
      'notes': notes,
    };
  }

  factory CompletedExercise.fromJson(Map<String, dynamic> json) {
    return CompletedExercise(
      name: json['name'],
      type: json['type'],
      sets: json['sets'],
      repsPerSet: json['repsPerSet'],
      durationSeconds: json['durationSeconds'],
      weight: (json['weight'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
    );
  }
}

class ProfessionalWorkoutTracker {
  static final ProfessionalWorkoutTracker _instance = ProfessionalWorkoutTracker._internal();
  factory ProfessionalWorkoutTracker() => _instance;
  ProfessionalWorkoutTracker._internal();

  static const String _workoutHistoryKey = 'workout_history';
  static const String _streakKey = 'workout_streak';
  static const String _statsKey = 'workout_stats';

  final UnifiedAuthService _authService = UnifiedAuthService();

  /// Save completed workout session
  Future<bool> saveWorkoutSession(WorkoutSession session) async {
    try {
      if (!_authService.isLoggedIn) {
        print('❌ ProfessionalWorkoutTracker: No user logged in');
        return false;
      }

      _authService.printAuthStatus();

      final prefs = await SharedPreferences.getInstance();
      final historyKey = _authService.getUserKey(_workoutHistoryKey);
      
      // Get existing history
      final existingHistory = await getWorkoutHistory();
      
      // Add new session
      existingHistory.add(session);
      
      // Sort by date (newest first)
      existingHistory.sort((a, b) => b.startTime.compareTo(a.startTime));
      
      // Keep only last 100 workouts to prevent storage bloat
      if (existingHistory.length > 100) {
        existingHistory.removeRange(100, existingHistory.length);
      }
      
      // Save to storage
      final jsonList = existingHistory.map((w) => w.toJson()).toList();
      await prefs.setString(historyKey, jsonEncode(jsonList));
      
      // Update analytics
      await _updateWorkoutStats(session);
      await _updateStreak();
      
      print('✅ ProfessionalWorkoutTracker: Workout saved successfully');
      print('   Workout: ${session.workoutTitle}');
      print('   Duration: ${(session.totalDuration / 60).round()} minutes');
      print('   Calories: ${session.caloriesBurned}');
      print('   Exercises: ${session.exercises.length}');
      
      return true;
    } catch (e) {
      print('❌ ProfessionalWorkoutTracker: Error saving workout: $e');
      return false;
    }
  }

  /// Get all workout history for current user
  Future<List<WorkoutSession>> getWorkoutHistory() async {
    try {
      if (!_authService.isLoggedIn) {
        return [];
      }

      final prefs = await SharedPreferences.getInstance();
      final historyKey = _authService.getUserKey(_workoutHistoryKey);
      final jsonString = prefs.getString(historyKey);
      
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => WorkoutSession.fromJson(json)).toList();
    } catch (e) {
      print('❌ ProfessionalWorkoutTracker: Error loading history: $e');
      return [];
    }
  }

  /// Get workout history for specific date range
  Future<List<WorkoutSession>> getWorkoutHistoryInRange(DateTime start, DateTime end) async {
    final allHistory = await getWorkoutHistory();
    return allHistory.where((session) {
      return session.startTime.isAfter(start.subtract(Duration(days: 1))) &&
             session.startTime.isBefore(end.add(Duration(days: 1)));
    }).toList();
  }

  /// Get current workout streak
  Future<int> getCurrentStreak() async {
    try {
      if (!_authService.isLoggedIn) return 0;

      final prefs = await SharedPreferences.getInstance();
      final streakKey = _authService.getUserKey(_streakKey);
      return prefs.getInt(streakKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Update workout streak
  Future<void> _updateStreak() async {
    try {
      final history = await getWorkoutHistory();
      if (history.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final streakKey = _authService.getUserKey(_streakKey);
      
      final today = DateTime.now();
      int streak = 0;

      // Check consecutive days from today backwards
      for (int i = 0; i < 365; i++) {
        final checkDate = today.subtract(Duration(days: i));
        final hasWorkout = history.any((session) {
          final sessionDate = session.startTime;
          return sessionDate.year == checkDate.year &&
                 sessionDate.month == checkDate.month &&
                 sessionDate.day == checkDate.day;
        });

        if (hasWorkout) {
          streak++;
        } else {
          break; // Streak broken
        }
      }

      await prefs.setInt(streakKey, streak);
      print('🔥 Workout streak updated: $streak days');
    } catch (e) {
      print('❌ Error updating streak: $e');
    }
  }

  /// Update workout statistics
  Future<void> _updateWorkoutStats(WorkoutSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsKey = _authService.getUserKey(_statsKey);
      
      // Get existing stats
      final existingStatsJson = prefs.getString(statsKey);
      Map<String, dynamic> stats = existingStatsJson != null 
          ? jsonDecode(existingStatsJson) 
          : _getInitialStats();
      
      // Update stats
      stats['totalWorkouts'] = (stats['totalWorkouts'] ?? 0) + 1;
      stats['totalMinutes'] = (stats['totalMinutes'] ?? 0) + (session.totalDuration / 60).round();
      stats['totalCalories'] = (stats['totalCalories'] ?? 0) + session.caloriesBurned;
      stats['totalReps'] = (stats['totalReps'] ?? 0) + session.totalReps;
      stats['lastWorkoutDate'] = session.startTime.toIso8601String();
      
      // Update workout type frequency
      final workoutTypes = Map<String, int>.from(stats['workoutTypeFrequency'] ?? {});
      workoutTypes[session.workoutType] = (workoutTypes[session.workoutType] ?? 0) + 1;
      stats['workoutTypeFrequency'] = workoutTypes;
      
      // Calculate averages
      stats['averageWorkoutDuration'] = (stats['totalMinutes'] / stats['totalWorkouts']).round();
      stats['averageCaloriesPerWorkout'] = (stats['totalCalories'] / stats['totalWorkouts']).round();
      
      await prefs.setString(statsKey, jsonEncode(stats));
    } catch (e) {
      print('❌ Error updating workout stats: $e');
    }
  }

  /// Get comprehensive workout statistics
  Future<Map<String, dynamic>> getWorkoutStats() async {
    try {
      if (!_authService.isLoggedIn) return _getInitialStats();

      final prefs = await SharedPreferences.getInstance();
      final statsKey = _authService.getUserKey(_statsKey);
      final statsJson = prefs.getString(statsKey);
      
      if (statsJson == null) return _getInitialStats();
      
      final stats = jsonDecode(statsJson);
      
      // Add current streak
      stats['currentStreak'] = await getCurrentStreak();
      
      return Map<String, dynamic>.from(stats);
    } catch (e) {
      return _getInitialStats();
    }
  }

  /// Get weekly workout summary
  Future<Map<String, dynamic>> getWeeklySummary() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    
    final weeklyHistory = await getWorkoutHistoryInRange(startOfWeek, endOfWeek);
    
    return {
      'workoutsThisWeek': weeklyHistory.length,
      'minutesThisWeek': weeklyHistory.fold(0, (sum, w) => sum + (w.totalDuration / 60).round()),
      'caloriesThisWeek': weeklyHistory.fold(0, (sum, w) => sum + w.caloriesBurned),
      'averageDifficulty': _calculateAverageDifficulty(weeklyHistory),
      'mostFrequentWorkoutType': _getMostFrequentWorkoutType(weeklyHistory),
    };
  }

  Map<String, dynamic> _getInitialStats() {
    return {
      'totalWorkouts': 0,
      'totalMinutes': 0,
      'totalCalories': 0,
      'totalReps': 0,
      'currentStreak': 0,
      'averageWorkoutDuration': 0,
      'averageCaloriesPerWorkout': 0,
      'workoutTypeFrequency': <String, int>{},
      'lastWorkoutDate': null,
    };
  }

  double _calculateAverageDifficulty(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0.0;
    
    final difficultyMap = {
      'easy': 1.0,
      'moderate': 2.0,
      'hard': 3.0,
      'very hard': 4.0,
    };
    
    final total = sessions.fold(0.0, (sum, session) {
      return sum + (difficultyMap[session.difficulty.toLowerCase()] ?? 2.0);
    });
    
    return total / sessions.length;
  }

  String _getMostFrequentWorkoutType(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 'None';
    
    final typeCount = <String, int>{};
    for (final session in sessions) {
      typeCount[session.workoutType] = (typeCount[session.workoutType] ?? 0) + 1;
    }
    
    return typeCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Convert from simple workout data to professional WorkoutSession
  static WorkoutSession createFromWorkoutData({
    required String workoutType,
    required String workoutTitle,
    required List<Map<String, dynamic>> exercises,
    required int durationMinutes,
    required int caloriesBurned,
    String difficulty = 'moderate',
    String notes = '',
  }) {
    final now = DateTime.now();
    final startTime = now.subtract(Duration(minutes: durationMinutes));
    
    final completedExercises = exercises.map((ex) {
      return CompletedExercise(
        name: ex['name'] ?? 'Unknown Exercise',
        type: ex['type'] ?? 'reps',
        sets: ex['sets'] ?? 1,
        repsPerSet: ex['reps'] ?? 0,
        durationSeconds: ex['duration'] ?? 30,
        weight: (ex['weight'] ?? 0.0).toDouble(),
        notes: ex['notes'] ?? '',
      );
    }).toList();
    
    return WorkoutSession(
      id: 'workout_${now.millisecondsSinceEpoch}',
      startTime: startTime,
      endTime: now,
      workoutType: workoutType,
      workoutTitle: workoutTitle,
      exercises: completedExercises,
      totalDuration: durationMinutes * 60,
      caloriesBurned: caloriesBurned,
      averageHeartRate: 0.0, // Can be enhanced later
      difficulty: difficulty,
      notes: notes,
      metadata: {
        'version': '1.0',
        'source': 'mobile_app',
        'completedAt': now.toIso8601String(),
      },
    );
  }
}