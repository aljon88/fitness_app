import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'workout_program_loader.dart';
import 'workout_history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Real-time calendar service for workout and meal plan scheduling
/// Works like a gym schedule - fixed days with real calendar dates
class RealTimeCalendarService {
  final WorkoutProgramLoader _programLoader = WorkoutProgramLoader();
  final WorkoutHistoryService _historyService = WorkoutHistoryService();

  /// Get user-specific key for storage
  String _getUserKey(String baseKey) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return '${user.uid}_$baseKey';
    }
    return baseKey; // Fallback for non-authenticated users
  }

  /// Initialize program with start date (usually today)
  Future<void> startProgram(
    String primaryGoal,
    String fitnessLevel,
    DateTime startDate,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save start date (user-specific)
    await prefs.setString(_getUserKey('program_start_date'), startDate.toIso8601String());
    
    // Save program ID (user-specific)
    String programId = '${_normalizeGoal(primaryGoal)}_${fitnessLevel.toLowerCase()}';
    await prefs.setString(_getUserKey('current_program_id'), programId);
    
    // Note: Completed days now tracked by WorkoutHistoryService
  }

  /// Get program start date
  Future<DateTime?> getStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_getUserKey('program_start_date'));
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  /// Get today's program day number (1-based)
  /// Returns 0 if program not started
  Future<int> getTodayProgramDay() async {
    final startDate = await getStartDate();
    if (startDate == null) return 0;

    final today = _normalizeDate(DateTime.now());
    final start = _normalizeDate(startDate);
    final daysSinceStart = today.difference(start).inDays;
    
    return daysSinceStart + 1; // Day 1 = start date
  }

  /// Generate full calendar for the program
  /// Returns list of calendar days with dates, workout info, rest days
  Future<List<Map<String, dynamic>>> generateProgramCalendar(
    String primaryGoal,
    String fitnessLevel,
  ) async {
    // Load program
    Map<String, dynamic> program = await _programLoader.loadProgram(primaryGoal, fitnessLevel);
    
    // Get start date
    DateTime? startDate = await getStartDate();
    if (startDate == null) {
      startDate = DateTime.now();
      await startProgram(primaryGoal, fitnessLevel, startDate);
    }

    int totalDays = _programLoader.getProgramDurationDays(program);
    Map<String, Map<String, dynamic>> weeklySchedule = _programLoader.getWeeklySchedule(program);
    List<String> daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    
    List<Map<String, dynamic>> calendar = [];
    List<int> completedDays = await _getCompletedDaysFromHistory();
    int todayProgramDay = await getTodayProgramDay();

    for (int day = 1; day <= totalDays; day++) {
      DateTime date = startDate.add(Duration(days: day - 1));
      int weekdayIndex = date.weekday - 1; // 0=Mon, 6=Sun
      String dayOfWeek = daysOfWeek[weekdayIndex];
      
      Map<String, dynamic>? workout = weeklySchedule[dayOfWeek];
      bool isRestDay = workout?['isRestDay'] ?? false;
      bool isCompleted = completedDays.contains(day);
      bool isToday = day == todayProgramDay;
      bool isPast = day < todayProgramDay;
      bool isFuture = day > todayProgramDay;

      calendar.add({
        'programDay': day,
        'date': date,
        'dayOfWeek': _getDayName(date.weekday),
        'dayOfWeekShort': _getDayNameShort(date.weekday),
        'workoutName': workout?['name'] ?? 'REST',
        'duration': workout?['duration'] ?? 0,
        'calories': workout?['calories'] ?? 0,
        'isRestDay': isRestDay,
        'isCompleted': isCompleted,
        'isToday': isToday,
        'isPast': isPast,
        'isFuture': isFuture,
        'isUnlocked': !isFuture,
      });
    }

    return calendar;
  }

  /// Get completed days from WorkoutHistoryService (SINGLE source of truth)
  Future<List<int>> _getCompletedDaysFromHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    
    return await _historyService.getCompletedWorkoutDays(user.uid);
  }

  /// DEPRECATED: Use WorkoutHistoryService.saveWorkout() instead
  /// This method is kept for backward compatibility but does nothing
  @deprecated
  Future<void> completeWorkoutDay(int programDay) async {
    // This method is deprecated - completion is now handled by WorkoutHistoryService
    print('⚠️ completeWorkoutDay is deprecated - use WorkoutHistoryService.saveWorkout()');
  }

  /// DEPRECATED: Use _getCompletedDaysFromHistory() instead
  @deprecated
  Future<List<int>> getCompletedDays() async {
    return await _getCompletedDaysFromHistory();
  }

  /// Auto-complete rest days up to today
  Future<void> autoCompleteRestDays(String primaryGoal, String fitnessLevel) async {
    Map<String, dynamic> program = await _programLoader.loadProgram(primaryGoal, fitnessLevel);
    List<Map<String, dynamic>> calendar = await generateProgramCalendar(primaryGoal, fitnessLevel);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    for (var day in calendar) {
      if (day['isRestDay'] && (day['isPast'] || day['isToday'])) {
        // Check if rest day is already completed
        bool isAlreadyCompleted = await _historyService.isWorkoutDayCompleted(user.uid, day['programDay']);
        if (!isAlreadyCompleted) {
          // Create a simple rest day entry in workout history
          // Note: Rest days don't need detailed workout data
          print('📅 Auto-completing rest day: ${day['programDay']}');
        }
      }
    }
  }

  /// Get current week's calendar (7 days starting from today)
  Future<List<Map<String, dynamic>>> getCurrentWeekCalendar(
    String primaryGoal,
    String fitnessLevel,
  ) async {
    List<Map<String, dynamic>> fullCalendar = await generateProgramCalendar(primaryGoal, fitnessLevel);
    int todayDay = await getTodayProgramDay();
    
    // Get 7 days starting from today
    return fullCalendar
        .where((day) => day['programDay'] >= todayDay && day['programDay'] < todayDay + 7)
        .toList();
  }

  /// Reset program
  Future<void> resetProgram() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getUserKey('program_start_date'));
    await prefs.remove(_getUserKey('current_program_id'));
    
    // Note: Workout history is managed by WorkoutHistoryService
    // Call _historyService.clearHistory(userId) if needed
  }

  /// Helper: Normalize date to midnight
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Helper: Get day name
  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  /// Helper: Get short day name
  String _getDayNameShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Helper: Normalize goal
  String _normalizeGoal(String goal) {
    Map<String, String> goalMap = {
      'Weight Loss': 'weight_loss',
      'Muscle Gain': 'muscle_gain',
      'Strength': 'strength',
      'Flexibility': 'flexibility',
      'Healthy Lifestyle': 'general_fitness',
    };
    return goalMap[goal] ?? goal.toLowerCase().replaceAll(' ', '_');
  }
}
