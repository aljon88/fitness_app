import 'dart:convert';
import 'package:flutter/services.dart';

/// Service to filter exercises based on user's physical restrictions
class ExerciseRestrictionService {
  static Map<String, List<String>> _exerciseContraindications = {};
  static Map<String, Map<String, List<String>>> _exerciseAlternatives = {};
  static bool _initialized = false;

  /// Initialize the service by loading exercise contraindications
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Load exercise database
      String jsonString = await rootBundle.loadString('assets/data/exercises/exercise_database.json');
      Map<String, dynamic> data = json.decode(jsonString);
      
      List<dynamic> exercises = data['exercises'] ?? [];
      
      // Build contraindications and alternatives maps
      for (var exercise in exercises) {
        String exerciseId = exercise['exerciseId'] ?? '';
        
        // Load contraindications (if exists)
        if (exercise['contraindications'] != null) {
          _exerciseContraindications[exerciseId] = List<String>.from(exercise['contraindications']);
        }
        
        // Load alternatives (if exists)
        if (exercise['alternatives'] != null) {
          _exerciseAlternatives[exerciseId] = {};
          Map<String, dynamic> alternatives = exercise['alternatives'];
          alternatives.forEach((restriction, altList) {
            _exerciseAlternatives[exerciseId]![restriction] = List<String>.from(altList);
          });
        }
      }
      
      _initialized = true;
      print('✅ Exercise restriction service initialized');
      print('📋 Loaded contraindications for ${_exerciseContraindications.length} exercises');
    } catch (e) {
      print('❌ Error initializing exercise restriction service: $e');
    }
  }

  /// Filter exercises to remove those contraindicated for user's restrictions
  static List<Map<String, dynamic>> filterSafeExercises(
    List<Map<String, dynamic>> exercises,
    List<String> userRestrictions,
  ) {
    if (!_initialized) {
      print('⚠️ Exercise restriction service not initialized, returning all exercises');
      return exercises;
    }

    if (userRestrictions.isEmpty || userRestrictions.contains('none')) {
      return exercises; // No restrictions, return all exercises
    }

    List<Map<String, dynamic>> safeExercises = [];
    List<Map<String, dynamic>> unsafeExercises = [];

    for (var exercise in exercises) {
      String exerciseId = exercise['exerciseId'] ?? '';
      List<String> contraindications = _exerciseContraindications[exerciseId] ?? [];
      
      // Check if exercise has any contraindications matching user restrictions
      bool isSafe = true;
      for (String restriction in userRestrictions) {
        if (contraindications.contains(restriction)) {
          isSafe = false;
          break;
        }
      }
      
      if (isSafe) {
        safeExercises.add(exercise);
      } else {
        unsafeExercises.add(exercise);
        
        // Try to find alternatives
        List<String> alternatives = getAlternativeExercises(exerciseId, userRestrictions);
        if (alternatives.isNotEmpty) {
          print('🔄 Replacing ${exercise['name']} with alternatives: ${alternatives.join(', ')}');
        }
      }
    }

    print('✅ Filtered exercises: ${safeExercises.length} safe, ${unsafeExercises.length} restricted');
    return safeExercises;
  }

  /// Get alternative exercises for a restricted exercise
  static List<String> getAlternativeExercises(
    String exerciseId,
    List<String> userRestrictions,
  ) {
    if (!_initialized || !_exerciseAlternatives.containsKey(exerciseId)) {
      return [];
    }

    Set<String> alternatives = {};
    Map<String, List<String>> exerciseAlts = _exerciseAlternatives[exerciseId]!;

    for (String restriction in userRestrictions) {
      if (exerciseAlts.containsKey(restriction)) {
        alternatives.addAll(exerciseAlts[restriction]!);
      }
    }

    return alternatives.toList();
  }

  /// Check if an exercise is safe for user's restrictions
  static bool isExerciseSafe(String exerciseId, List<String> userRestrictions) {
    if (!_initialized) return true;
    
    if (userRestrictions.isEmpty || userRestrictions.contains('none')) {
      return true;
    }

    List<String> contraindications = _exerciseContraindications[exerciseId] ?? [];
    
    for (String restriction in userRestrictions) {
      if (contraindications.contains(restriction)) {
        return false;
      }
    }
    
    return true;
  }

  /// Get safety warnings for an exercise given user restrictions
  static List<String> getExerciseWarnings(String exerciseId, List<String> userRestrictions) {
    if (!_initialized) return [];
    
    if (userRestrictions.isEmpty || userRestrictions.contains('none')) {
      return [];
    }

    List<String> warnings = [];
    List<String> contraindications = _exerciseContraindications[exerciseId] ?? [];
    
    for (String restriction in userRestrictions) {
      if (contraindications.contains(restriction)) {
        warnings.add(_getWarningMessage(restriction));
      }
    }
    
    return warnings;
  }

  /// Get user-friendly warning message for a restriction
  static String _getWarningMessage(String restriction) {
    switch (restriction) {
      case 'knee_issues':
        return 'This exercise may strain your knees';
      case 'back_problems':
        return 'This exercise may put pressure on your back';
      case 'heart_conditions':
        return 'This exercise may be too intense for your heart';
      case 'shoulder_limitations':
        return 'This exercise may strain your shoulders';
      case 'high_impact_restrictions':
        return 'This exercise involves high-impact movements';
      case 'balance_concerns':
        return 'This exercise requires good balance';
      case 'wrist_problems':
        return 'This exercise may strain your wrists';
      case 'pregnancy':
        return 'This exercise may not be suitable during pregnancy';
      default:
        return 'This exercise may not be suitable for your condition';
    }
  }

  /// Get statistics about restriction filtering
  static Map<String, int> getFilteringStats(
    List<Map<String, dynamic>> originalExercises,
    List<Map<String, dynamic>> filteredExercises,
  ) {
    return {
      'original': originalExercises.length,
      'filtered': filteredExercises.length,
      'removed': originalExercises.length - filteredExercises.length,
    };
  }

  /// Reset the service (for testing)
  static void reset() {
    _initialized = false;
    _exerciseContraindications.clear();
    _exerciseAlternatives.clear();
  }
}