import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_history.dart';

class WorkoutHistoryService {
  static final WorkoutHistoryService _instance = WorkoutHistoryService._internal();
  factory WorkoutHistoryService() => _instance;
  WorkoutHistoryService._internal();

  static const String _historyKey = 'workout_history';
  static const String _streakKey = 'workout_streak';
  static const String _lastWorkoutKey = 'last_workout_date';

  // Save completed workout
  Future<void> saveWorkout(WorkoutHistory workout) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing history
    List<WorkoutHistory> history = await getWorkoutHistory(workout.userId);
    
    // Add new workout
    history.insert(0, workout); // Most recent first
    
    // Save to storage
    final historyJson = history.map((w) => w.toJson()).toList();
    await prefs.setString('${_historyKey}_${workout.userId}', jsonEncode(historyJson));
    
    // Update streak
    await _updateStreak(workout.userId, workout.completedAt);
  }

  // Get workout history for user
  Future<List<WorkoutHistory>> getWorkoutHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('${_historyKey}_$userId');
    
    if (historyString == null) return [];
    
    final List<dynamic> historyJson = jsonDecode(historyString);
    return historyJson.map((json) => WorkoutHistory.fromJson(json)).toList();
  }

  // Get workout history for specific date range
  Future<List<WorkoutHistory>> getWorkoutHistoryByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allHistory = await getWorkoutHistory(userId);
    return allHistory.where((workout) {
      return workout.completedAt.isAfter(startDate) &&
             workout.completedAt.isBefore(endDate);
    }).toList();
  }

  // Get total workouts completed
  Future<int> getTotalWorkoutsCompleted(String userId) async {
    final history = await getWorkoutHistory(userId);
    return history.length;
  }

  // Get current streak
  Future<int> getCurrentStreak(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_streakKey}_$userId') ?? 0;
  }

  // Get last workout date
  Future<DateTime?> getLastWorkoutDate(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('${_lastWorkoutKey}_$userId');
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  // Update streak
  Future<void> _updateStreak(String userId, DateTime workoutDate) async {
    final prefs = await SharedPreferences.getInstance();
    final lastWorkoutDate = await getLastWorkoutDate(userId);
    int currentStreak = await getCurrentStreak(userId);
    
    if (lastWorkoutDate == null) {
      // First workout
      currentStreak = 1;
    } else {
      final daysSinceLastWorkout = workoutDate.difference(lastWorkoutDate).inDays;
      
      if (daysSinceLastWorkout == 0) {
        // Same day, don't change streak
      } else if (daysSinceLastWorkout == 1) {
        // Consecutive day, increment streak
        currentStreak++;
      } else {
        // Streak broken, reset to 1
        currentStreak = 1;
      }
    }
    
    await prefs.setInt('${_streakKey}_$userId', currentStreak);
    await prefs.setString('${_lastWorkoutKey}_$userId', workoutDate.toIso8601String());
  }

  // Get total reps completed (all time)
  Future<int> getTotalReps(String userId) async {
    final history = await getWorkoutHistory(userId);
    return history.fold<int>(0, (sum, workout) => sum + workout.totalReps);
  }

  // Get total calories burned (all time)
  Future<int> getTotalCaloriesBurned(String userId) async {
    final history = await getWorkoutHistory(userId);
    return history.fold<int>(0, (sum, workout) => sum + workout.caloriesBurned);
  }

  // Get total workout time (all time)
  Future<int> getTotalWorkoutMinutes(String userId) async {
    final history = await getWorkoutHistory(userId);
    return history.fold<int>(0, (sum, workout) => sum + workout.durationMinutes);
  }

  // Get workouts this week
  Future<List<WorkoutHistory>> getWorkoutsThisWeek(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 7));
    
    return getWorkoutHistoryByDateRange(userId, startOfWeek, endOfWeek);
  }

  // Get workouts this month
  Future<List<WorkoutHistory>> getWorkoutsThisMonth(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return getWorkoutHistoryByDateRange(userId, startOfMonth, endOfMonth);
  }

  // Check if workout day is completed
  Future<bool> isWorkoutDayCompleted(String userId, int dayNumber) async {
    final history = await getWorkoutHistory(userId);
    return history.any((workout) => workout.dayNumber == dayNumber);
  }

  // Get completed workout days
  Future<List<int>> getCompletedWorkoutDays(String userId) async {
    final history = await getWorkoutHistory(userId);
    return history.map((workout) => workout.dayNumber).toList();
  }

  // Clear all history (for testing)
  Future<void> clearHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_historyKey}_$userId');
    await prefs.remove('${_streakKey}_$userId');
    await prefs.remove('${_lastWorkoutKey}_$userId');
  }
}
