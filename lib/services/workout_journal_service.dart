import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class WorkoutJournalEntry {
  final String id;
  final DateTime date;
  final String workoutType;
  final int duration; // in minutes
  final List<String> exercisesCompleted;
  final int energyRating; // 1-5
  final String notes;
  final List<String> tags;
  final int totalExercises;

  WorkoutJournalEntry({
    required this.id,
    required this.date,
    required this.workoutType,
    required this.duration,
    required this.exercisesCompleted,
    required this.energyRating,
    required this.notes,
    required this.tags,
    required this.totalExercises,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'workoutType': workoutType,
      'duration': duration,
      'exercisesCompleted': exercisesCompleted,
      'energyRating': energyRating,
      'notes': notes,
      'tags': tags,
      'totalExercises': totalExercises,
    };
  }

  factory WorkoutJournalEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutJournalEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      workoutType: json['workoutType'],
      duration: json['duration'],
      exercisesCompleted: List<String>.from(json['exercisesCompleted']),
      energyRating: json['energyRating'],
      notes: json['notes'],
      tags: List<String>.from(json['tags']),
      totalExercises: json['totalExercises'],
    );
  }
}

class WorkoutJournalService {
  static final WorkoutJournalService _instance = WorkoutJournalService._internal();
  factory WorkoutJournalService() => _instance;
  WorkoutJournalService._internal();

  static const String _journalKey = 'workout_journal_entries';
  static const String _streakKey = 'workout_streak';

  // Save a new journal entry
  Future<void> saveJournalEntry(WorkoutJournalEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entries = await getJournalEntries();
      
      entries.add(entry);
      
      // Sort by date (newest first)
      entries.sort((a, b) => b.date.compareTo(a.date));
      
      final jsonList = entries.map((e) => e.toJson()).toList();
      await prefs.setString(_journalKey, jsonEncode(jsonList));
      
      // Update streak
      await _updateStreak();
      
      if (kDebugMode) {
        print('📝 Workout journal entry saved: ${entry.workoutType}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save journal entry: $e');
      }
    }
  }

  // Get all journal entries
  Future<List<WorkoutJournalEntry>> getJournalEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_journalKey);
      
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => WorkoutJournalEntry.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load journal entries: $e');
      }
      return [];
    }
  }

  // Get entries for a specific date
  Future<List<WorkoutJournalEntry>> getEntriesForDate(DateTime date) async {
    final entries = await getJournalEntries();
    return entries.where((entry) {
      return entry.date.year == date.year &&
             entry.date.month == date.month &&
             entry.date.day == date.day;
    }).toList();
  }

  // Get current workout streak
  Future<int> getCurrentStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_streakKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Update workout streak
  Future<void> _updateStreak() async {
    try {
      final entries = await getJournalEntries();
      if (entries.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      int streak = 0;

      // Check consecutive days from today backwards
      for (int i = 0; i < 365; i++) { // Max 365 days check
        final checkDate = today.subtract(Duration(days: i));
        final hasWorkout = entries.any((entry) =>
          entry.date.year == checkDate.year &&
          entry.date.month == checkDate.month &&
          entry.date.day == checkDate.day
        );

        if (hasWorkout) {
          streak++;
        } else {
          break; // Streak broken
        }
      }

      await prefs.setInt(_streakKey, streak);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update streak: $e');
      }
    }
  }

  // Get workout stats for the week
  Future<Map<String, dynamic>> getWeeklyStats() async {
    final entries = await getJournalEntries();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final weekEntries = entries.where((entry) {
      return entry.date.isAfter(weekStart.subtract(Duration(days: 1))) &&
             entry.date.isBefore(now.add(Duration(days: 1)));
    }).toList();

    final totalWorkouts = weekEntries.length;
    final totalMinutes = weekEntries.fold(0, (sum, entry) => sum + entry.duration);
    final avgEnergyRating = weekEntries.isEmpty ? 0.0 : 
      weekEntries.fold(0, (sum, entry) => sum + entry.energyRating) / weekEntries.length;

    return {
      'totalWorkouts': totalWorkouts,
      'totalMinutes': totalMinutes,
      'avgEnergyRating': avgEnergyRating,
      'streak': await getCurrentStreak(),
    };
  }

  // Get suggested tags based on workout type and previous entries
  List<String> getSuggestedTags(String workoutType) {
    final baseTags = [
      'Felt Strong',
      'Good Energy',
      'Challenging',
      'Too Easy',
      'Perfect Pace',
      'Need More Rest',
      'Great Form',
      'Struggled',
    ];

    // Add workout-specific tags
    if (workoutType.toLowerCase().contains('cardio')) {
      baseTags.addAll(['Heart Pumping', 'Good Sweat', 'Breathless']);
    } else if (workoutType.toLowerCase().contains('strength')) {
      baseTags.addAll(['Muscle Burn', 'Heavy Weights', 'Good Pump']);
    } else if (workoutType.toLowerCase().contains('flexibility')) {
      baseTags.addAll(['Relaxing', 'Good Stretch', 'Improved Range']);
    }

    return baseTags;
  }
}