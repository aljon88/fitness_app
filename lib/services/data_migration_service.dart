import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workout_history_service.dart';
import 'workout_journal_service.dart';
import '../models/workout_history.dart';

/// Enterprise data migration service for seamless transition
/// Migrates data from WorkoutJournalService to WorkoutHistoryService
class DataMigrationService {
  static final DataMigrationService _instance = DataMigrationService._internal();
  factory DataMigrationService() => _instance;
  DataMigrationService._internal();

  static const String _migrationKey = 'data_migration_completed';
  
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  final WorkoutJournalService _journalService = WorkoutJournalService();

  /// Execute complete data migration if not already done
  Future<void> executeMigrationIfNeeded() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('🔄 [MIGRATION] No user logged in, skipping migration');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final migrationKey = '${_migrationKey}_${user.uid}';
      final migrationCompleted = prefs.getBool(migrationKey) ?? false;

      if (migrationCompleted) {
        print('✅ [MIGRATION] Data migration already completed for user ${user.uid}');
        return;
      }

      print('🔄 [MIGRATION] Starting data migration for user ${user.uid}');
      await _migrateJournalToHistory(user.uid);
      
      // Mark migration as completed
      await prefs.setBool(migrationKey, true);
      print('✅ [MIGRATION] Data migration completed successfully');

    } catch (e) {
      print('❌ [MIGRATION] Migration failed: $e');
      // Don't throw - allow app to continue with new system
    }
  }

  /// Migrate journal entries to workout history format
  Future<void> _migrateJournalToHistory(String userId) async {
    try {
      // Get existing journal entries
      final journalEntries = await _journalService.getJournalEntries();
      
      if (journalEntries.isEmpty) {
        print('📭 [MIGRATION] No journal entries to migrate');
        return;
      }

      print('🔄 [MIGRATION] Migrating ${journalEntries.length} journal entries');

      int migratedCount = 0;
      for (final entry in journalEntries) {
        try {
          // Convert journal entry to workout history format
          final workoutHistory = _convertJournalToHistory(entry, userId);
          
          // Save to new system
          await _historyService.saveWorkout(workoutHistory);
          migratedCount++;
          
          print('✅ [MIGRATION] Migrated: ${entry.workoutType} (${entry.date})');
        } catch (e) {
          print('⚠️ [MIGRATION] Failed to migrate entry ${entry.id}: $e');
          // Continue with other entries
        }
      }

      print('✅ [MIGRATION] Successfully migrated $migratedCount/${journalEntries.length} entries');

    } catch (e) {
      print('❌ [MIGRATION] Journal migration failed: $e');
      rethrow;
    }
  }

  /// Convert WorkoutJournalEntry to WorkoutHistory format
  WorkoutHistory _convertJournalToHistory(dynamic entry, String userId) {
    // Extract program day from workout type or date
    int programDay = _extractProgramDay(entry.workoutType, entry.date);
    
    // Create exercise results from journal data
    List<ExerciseResult> exerciseResults = [];
    
    if (entry.exercisesCompleted != null) {
      for (int i = 0; i < entry.exercisesCompleted.length; i++) {
        final exerciseName = entry.exercisesCompleted[i];
        
        // Create basic exercise result
        exerciseResults.add(ExerciseResult(
          exerciseId: 'migrated_${i + 1}',
          exerciseName: exerciseName,
          targetReps: 10, // Default values for migrated data
          actualReps: 10,
          targetSets: 3,
          completedSets: 3,
          completed: true,
          setResults: [
            SetResult(setNumber: 1, reps: 10, completedAt: entry.date),
            SetResult(setNumber: 2, reps: 10, completedAt: entry.date),
            SetResult(setNumber: 3, reps: 10, completedAt: entry.date),
          ],
        ));
      }
    }

    // Estimate calories based on duration and exercises
    int estimatedCalories = _estimateCalories(entry.duration, entry.totalExercises);

    return WorkoutHistory(
      id: 'migrated_${entry.id}',
      userId: userId,
      workoutId: 'migrated_program_day_$programDay',
      workoutTitle: entry.workoutType,
      dayNumber: programDay,
      completedAt: entry.date,
      durationMinutes: entry.duration,
      exercises: exerciseResults,
      totalReps: exerciseResults.length * 30, // Estimate: 3 sets × 10 reps per exercise
      totalSets: exerciseResults.length * 3,
      caloriesBurned: estimatedCalories,
      difficulty: _mapEnergyToDifficulty(entry.energyRating),
    );
  }

  /// Extract program day from workout type or date
  int _extractProgramDay(String workoutType, DateTime date) {
    // Try to extract day number from workout type
    final dayMatch = RegExp(r'Day (\d+)').firstMatch(workoutType);
    if (dayMatch != null) {
      return int.parse(dayMatch.group(1)!);
    }

    // Fallback: calculate based on date (assuming program started recently)
    final now = DateTime.now();
    final daysSinceWorkout = now.difference(date).inDays;
    
    // Estimate program day (this is approximate for migrated data)
    return math.max(1, daysSinceWorkout + 1);
  }

  /// Estimate calories burned based on duration and exercise count
  int _estimateCalories(int durationMinutes, int exerciseCount) {
    // Basic estimation: ~5-8 calories per minute for strength training
    final baseCalories = durationMinutes * 6;
    
    // Adjust based on exercise count (more exercises = higher intensity)
    final exerciseMultiplier = 1.0 + (exerciseCount * 0.1);
    
    return (baseCalories * exerciseMultiplier).round();
  }

  /// Map energy rating to difficulty level
  String _mapEnergyToDifficulty(int energyRating) {
    switch (energyRating) {
      case 1:
      case 2:
        return 'easy';
      case 3:
        return 'moderate';
      case 4:
      case 5:
        return 'hard';
      default:
        return 'moderate';
    }
  }

  /// Check if migration is needed for current user
  Future<bool> isMigrationNeeded() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final migrationKey = '${_migrationKey}_${user.uid}';
      final migrationCompleted = prefs.getBool(migrationKey) ?? false;

      return !migrationCompleted;
    } catch (e) {
      print('❌ [MIGRATION] Error checking migration status: $e');
      return false;
    }
  }

  /// Force re-migration (admin function)
  Future<void> forceMigration() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      final migrationKey = '${_migrationKey}_${user.uid}';
      await prefs.remove(migrationKey);
      
      await executeMigrationIfNeeded();
    } catch (e) {
      print('❌ [MIGRATION] Force migration failed: $e');
    }
  }
}