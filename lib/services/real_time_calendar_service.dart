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
  /// Takes into account completed workouts to determine the next available day
  Future<int> getTodayProgramDay() async {
    final startDate = await getStartDate();
    if (startDate == null) return 0;

    final today = _normalizeDate(DateTime.now());
    final start = _normalizeDate(startDate);
    final daysSinceStart = today.difference(start).inDays;
    final calendarBasedDay = daysSinceStart + 1; // Day 1 = start date
    
    // Get completed workout days to determine actual progression
    final completedDays = await _getCompletedDaysFromHistory();
    
    // Find the next uncompleted day that should be available
    // Start from the calendar-based day and work forward
    for (int day = calendarBasedDay; day <= calendarBasedDay + 7; day++) {
      if (!completedDays.contains(day)) {
        // Check if this day's date has arrived (not in future)
        DateTime dayDate = startDate.add(Duration(days: day - 1));
        if (!dayDate.isAfter(_normalizeDate(DateTime.now()))) {
          return day;
        }
      }
    }
    
    // Fallback to calendar-based calculation
    return calendarBasedDay;
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
    
    // Create ordered workout sequence (excluding rest days)
    List<Map<String, dynamic>> workoutSequence = [];
    List<String> workoutDays = [];
    List<String> restDays = List<String>.from(program['schedule']['restDays'] ?? []);
    
    // Build workout sequence in weekly order
    List<String> daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    for (String dayOfWeek in daysOfWeek) {
      if (!restDays.contains(dayOfWeek)) {
        Map<String, dynamic>? workout = weeklySchedule[dayOfWeek];
        if (workout != null) {
          workoutSequence.add(workout);
          workoutDays.add(dayOfWeek);
        }
      }
    }
    
    List<Map<String, dynamic>> calendar = [];
    List<int> completedDays = await _getCompletedDaysFromHistory();
    int todayProgramDay = await getTodayProgramDay();
    
    // Pre-load unlocked workouts for this user
    List<int> unlockedEarlyWorkouts = await _getUnlockedEarlyWorkouts();
    
    int workoutCounter = 0;
    
    for (int day = 1; day <= totalDays; day++) {
      DateTime date = startDate.add(Duration(days: day - 1));
      
      // Determine if this program day should be a workout or rest day
      // Use the weekly pattern but cycle through workouts sequentially
      int weekPosition = (day - 1) % 7; // 0-6 position in week
      String weekDayName = daysOfWeek[weekPosition];
      
      bool isRestDay = restDays.contains(weekDayName);
      Map<String, dynamic> workoutData;
      
      if (isRestDay) {
        workoutData = {
          'name': 'REST',
          'duration': 0,
          'calories': 0,
          'isRestDay': true,
          'exercises': [],
        };
      } else {
        // Get next workout from sequence
        if (workoutSequence.isNotEmpty) {
          int workoutIndex = workoutCounter % workoutSequence.length;
          workoutData = Map<String, dynamic>.from(workoutSequence[workoutIndex]);
          workoutData['isRestDay'] = false;
          
          // Ensure exercises are included from the program phases
          if (!workoutData.containsKey('exercises') || workoutData['exercises'] == null) {
            // Get exercises from the first phase for this workout
            try {
              Map<String, dynamic> firstPhase = program['phases'][0];
              Map<String, dynamic> phaseWorkouts = Map<String, dynamic>.from(firstPhase['workouts']);
              
              // Find matching workout in phase by name
              String workoutName = workoutData['name'];
              for (String dayKey in phaseWorkouts.keys) {
                Map<String, dynamic> phaseWorkout = phaseWorkouts[dayKey];
                if (phaseWorkout['name'] == workoutName) {
                  workoutData['exercises'] = phaseWorkout['exercises'] ?? [];
                  break;
                }
              }
            } catch (e) {
              print('Warning: Could not load exercises for workout: $e');
              workoutData['exercises'] = [];
            }
          }
          
          workoutCounter++;
        } else {
          workoutData = {
            'name': 'Workout ${workoutCounter + 1}',
            'duration': 30,
            'calories': 150,
            'isRestDay': false,
            'exercises': [],
          };
          workoutCounter++;
        }
      }
      
      bool isCompleted = completedDays.contains(day);
      bool isToday = day == todayProgramDay;
      bool isPast = day < todayProgramDay && !isCompleted; // Past but not completed
      bool isFuture = day > todayProgramDay || (day > todayProgramDay && date.isAfter(_normalizeDate(DateTime.now())));

      // Check if this workout was unlocked early
      bool isUnlockedEarly = unlockedEarlyWorkouts.contains(day);

      // A day is unlocked if:
      // 1. It's not in the future (date-wise)
      // 2. It's the current "today" day
      // 3. It's already completed
      // 4. It was unlocked early after completing previous workout
      bool isUnlocked = !date.isAfter(_normalizeDate(DateTime.now())) || 
                       isToday || 
                       isCompleted || 
                       (day < todayProgramDay) ||
                       isUnlockedEarly;

      calendar.add({
        'programDay': day,
        'date': date,
        'dayOfWeek': _getDayName(date.weekday),
        'dayOfWeekShort': _getDayNameShort(date.weekday),
        'workoutName': workoutData['name'] ?? 'Workout',
        'duration': workoutData['duration'] ?? 0,
        'calories': workoutData['calories'] ?? 0,
        'isRestDay': isRestDay,
        'isCompleted': isCompleted,
        'isToday': isToday,
        'isPast': isPast,
        'isFuture': isFuture,
        'isUnlocked': isUnlocked,
        'exercises': workoutData['exercises'] ?? [],
        'workoutData': workoutData, // Include full workout data
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

  /// Get next available workout that can be rescheduled (helper for UI)
  Future<Map<String, dynamic>?> getNextAvailableWorkout(
    String primaryGoal,
    String fitnessLevel,
    int afterProgramDay,
  ) async {
    List<Map<String, dynamic>> calendar = await generateProgramCalendar(primaryGoal, fitnessLevel);
    List<int> completedDays = await _getCompletedDaysFromHistory();
    
    for (var day in calendar) {
      int programDay = day['programDay'];
      bool isRestDay = day['isRestDay'] ?? false;
      bool isCompleted = completedDays.contains(programDay);
      
      if (programDay > afterProgramDay && !isRestDay && !isCompleted) {
        return day;
      }
    }
    return null;
  }

  /// Check if a workout was unlocked early after completing previous workouts
  Future<bool> _isWorkoutUnlockedEarly(int programDay) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      String unlockedKey = '${user.uid}_unlocked_workouts';
      List<String> unlockedWorkouts = prefs.getStringList(unlockedKey) ?? [];
      
      return unlockedWorkouts.contains('day_$programDay');
    } catch (e) {
      print('❌ Error checking unlocked workouts: $e');
      return false;
    }
  }

  /// Get all workouts that were unlocked early (for batch processing)
  Future<List<int>> _getUnlockedEarlyWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      String unlockedKey = '${user.uid}_unlocked_workouts';
      List<String> unlockedWorkouts = prefs.getStringList(unlockedKey) ?? [];
      
      // Convert from 'day_X' format to int list
      List<int> unlockedDays = [];
      for (String workoutKey in unlockedWorkouts) {
        if (workoutKey.startsWith('day_')) {
          int? dayNum = int.tryParse(workoutKey.substring(4));
          if (dayNum != null) {
            unlockedDays.add(dayNum);
          }
        }
      }
      
      return unlockedDays;
    } catch (e) {
      print('❌ Error getting unlocked workouts: $e');
      return [];
    }
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
