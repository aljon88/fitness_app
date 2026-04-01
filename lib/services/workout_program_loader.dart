import 'dart:convert';
import 'package:flutter/services.dart';

/// Service to load workout programs from JSON files based on user profile
class WorkoutProgramLoader {
  /// Load a workout program based on user's goal and fitness level
  Future<Map<String, dynamic>> loadProgram(
    String primaryGoal,
    String fitnessLevel,
  ) async {
    try {
      // Get the program file path
      String filePath = _getProgramFilePath(primaryGoal, fitnessLevel);
      
      // Load the JSON file
      String jsonString = await rootBundle.loadString(filePath);
      
      // Parse and return the program data
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading workout program: $e');
      // Return a default program if loading fails
      return _getDefaultProgram();
    }
  }

  /// Get the file path for a specific program
  String _getProgramFilePath(String primaryGoal, String fitnessLevel) {
    // Map user's primary goal to program file prefix
    Map<String, String> goalMap = {
      'Weight Loss': 'weight_loss',
      'Muscle Gain': 'muscle_gain',
      'Strength': 'strength',
      'Flexibility': 'flexibility',
      'Healthy Lifestyle': 'general_fitness',
    };

    // Get goal key (default to general_fitness if not found)
    String goalKey = goalMap[primaryGoal] ?? 'general_fitness';
    
    // Convert fitness level to lowercase
    String levelKey = fitnessLevel.toLowerCase();
    
    // Build and return file path
    return 'assets/data/programs/${goalKey}_${levelKey}.json';
  }

  /// Parse program data and extract key information
  Map<String, dynamic> parseProgramData(Map<String, dynamic> program) {
    return {
      'programId': program['programId'] ?? '',
      'programName': program['programName'] ?? '',
      'goal': program['goal'] ?? '',
      'fitnessLevel': program['fitnessLevel'] ?? '',
      'duration': program['duration'] ?? {},
      'schedule': program['schedule'] ?? {},
      'overview': program['overview'] ?? {},
      'weeklyPattern': program['weeklyPattern'] ?? {},
      'phases': program['phases'] ?? [],
      'expectedResults': program['expectedResults'] ?? {},
      'nutrition': program['nutrition'] ?? {},
    };
  }

  /// Get weekly workout schedule from program
  Map<String, Map<String, dynamic>> getWeeklySchedule(
    Map<String, dynamic> program,
  ) {
    Map<String, dynamic> weeklyPattern = program['weeklyPattern'] ?? {};
    Map<String, Map<String, dynamic>> schedule = {};

    weeklyPattern.forEach((day, workout) {
      schedule[day] = {
        'name': workout['name'] ?? 'REST',
        'duration': workout['duration'] ?? 0,
        'calories': workout['calories'] ?? 0,
        'isRestDay': workout['name'] == 'REST',
      };
    });

    return schedule;
  }

  /// Get rest days from program
  List<String> getRestDays(Map<String, dynamic> program) {
    Map<String, dynamic> schedule = program['schedule'] ?? {};
    List<dynamic> restDays = schedule['restDays'] ?? [];
    return restDays.map((day) => day.toString()).toList();
  }

  /// Get workouts per week
  int getWorkoutsPerWeek(Map<String, dynamic> program) {
    Map<String, dynamic> schedule = program['schedule'] ?? {};
    return schedule['workoutsPerWeek'] ?? 4;
  }

  /// Get program duration in days
  int getProgramDurationDays(Map<String, dynamic> program) {
    Map<String, dynamic> duration = program['duration'] ?? {};
    return duration['days'] ?? 90;
  }

  /// Get program duration in weeks
  int getProgramDurationWeeks(Map<String, dynamic> program) {
    Map<String, dynamic> duration = program['duration'] ?? {};
    return duration['weeks'] ?? 13;
  }

  /// Get nutrition guidelines
  Map<String, dynamic> getNutritionGuidelines(Map<String, dynamic> program) {
    return program['nutrition'] ?? {};
  }

  /// Get expected results
  Map<String, dynamic> getExpectedResults(Map<String, dynamic> program) {
    return program['expectedResults'] ?? {};
  }

  /// Get program phases
  List<Map<String, dynamic>> getProgramPhases(Map<String, dynamic> program) {
    List<dynamic> phases = program['phases'] ?? [];
    return phases.map((phase) => phase as Map<String, dynamic>).toList();
  }

  /// Get workout for a specific day
  Map<String, dynamic>? getWorkoutForDay(
    Map<String, dynamic> program,
    String dayOfWeek,
  ) {
    Map<String, dynamic> weeklyPattern = program['weeklyPattern'] ?? {};
    return weeklyPattern[dayOfWeek.toLowerCase()] as Map<String, dynamic>?;
  }

  /// Check if a day is a rest day
  bool isRestDay(Map<String, dynamic> program, String dayOfWeek) {
    List<String> restDays = getRestDays(program);
    return restDays.contains(dayOfWeek.toLowerCase());
  }

  /// Get program overview
  Map<String, dynamic> getProgramOverview(Map<String, dynamic> program) {
    return program['overview'] ?? {};
  }

  /// Default program (fallback)
  Map<String, dynamic> _getDefaultProgram() {
    return {
      'programId': 'general_fitness_beginner',
      'programName': 'General Fitness - Beginner Program',
      'goal': 'general_fitness',
      'fitnessLevel': 'beginner',
      'duration': {'days': 90, 'weeks': 13},
      'schedule': {
        'workoutsPerWeek': 4,
        'restDays': ['tuesday', 'thursday', 'sunday']
      },
      'overview': {
        'focus': 'Balanced Fitness',
        'intensity': 'Low to Moderate',
        'equipment': 'None',
        'description': 'General fitness program for beginners'
      },
      'weeklyPattern': {
        'monday': {'name': 'Full Body', 'duration': 30, 'calories': 150},
        'tuesday': {'name': 'REST', 'duration': 0, 'calories': 0},
        'wednesday': {'name': 'Cardio', 'duration': 25, 'calories': 140},
        'thursday': {'name': 'REST', 'duration': 0, 'calories': 0},
        'friday': {'name': 'Full Body', 'duration': 30, 'calories': 155},
        'saturday': {'name': 'Flexibility', 'duration': 20, 'calories': 80},
        'sunday': {'name': 'REST', 'duration': 0, 'calories': 0},
      },
      'phases': [],
      'expectedResults': {},
      'nutrition': {},
    };
  }

  /// Generate workout calendar for the entire program
  List<Map<String, dynamic>> generateProgramCalendar(
    Map<String, dynamic> program,
    DateTime startDate,
  ) {
    List<Map<String, dynamic>> calendar = [];
    int durationDays = getProgramDurationDays(program);
    Map<String, Map<String, dynamic>> weeklySchedule = getWeeklySchedule(program);

    // Days of week in order
    List<String> daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    for (int day = 0; day < durationDays; day++) {
      DateTime currentDate = startDate.add(Duration(days: day));
      int weekdayIndex = currentDate.weekday - 1; // 0 = Monday, 6 = Sunday
      String dayName = daysOfWeek[weekdayIndex];

      Map<String, dynamic>? workout = weeklySchedule[dayName];

      calendar.add({
        'date': currentDate.toIso8601String(),
        'day': day + 1,
        'dayOfWeek': dayName,
        'workoutName': workout?['name'] ?? 'REST',
        'duration': workout?['duration'] ?? 0,
        'calories': workout?['calories'] ?? 0,
        'isRestDay': workout?['isRestDay'] ?? true,
        'completed': false,
      });
    }

    return calendar;
  }

  /// Get current phase based on day number
  Map<String, dynamic>? getCurrentPhase(
    Map<String, dynamic> program,
    int currentDay,
  ) {
    List<Map<String, dynamic>> phases = getProgramPhases(program);
    int durationWeeks = getProgramDurationWeeks(program);
    int currentWeek = (currentDay / 7).ceil();

    for (var phase in phases) {
      String weeksRange = phase['weeks'] ?? '';
      List<String> parts = weeksRange.split('-');
      
      if (parts.length == 2) {
        int startWeek = int.tryParse(parts[0]) ?? 1;
        int endWeek = int.tryParse(parts[1]) ?? durationWeeks;
        
        if (currentWeek >= startWeek && currentWeek <= endWeek) {
          return phase;
        }
      }
    }

    return phases.isNotEmpty ? phases[0] : null;
  }
}
