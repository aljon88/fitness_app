import 'dart:convert';
import 'package:flutter/services.dart';

/// Service to load exercise demo data from a single database file
/// All exercises stored in: assets/data/exercises/exercise_database.json
class ExerciseDemoLoader {
  static final ExerciseDemoLoader _instance = ExerciseDemoLoader._internal();
  factory ExerciseDemoLoader() => _instance;
  ExerciseDemoLoader._internal();

  // Cache for the exercise database
  Map<String, dynamic>? _exerciseDatabase;
  Map<String, Map<String, dynamic>> _exerciseMap = {};
  bool _isInitialized = false;

  /// Initialize by loading the exercise database
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/exercises/exercise_database.json');
      _exerciseDatabase = json.decode(jsonString);
      
      // Build a map for quick lookup by exerciseId
      List<dynamic> exercises = _exerciseDatabase!['exercises'] ?? [];
      for (var exercise in exercises) {
        String exerciseId = exercise['exerciseId'] ?? '';
        if (exerciseId.isNotEmpty) {
          _exerciseMap[exerciseId] = Map<String, dynamic>.from(exercise as Map);
        }
      }
      
      _isInitialized = true;
      print('✅ Exercise database loaded: ${exercises.length} exercises with demo data');
    } catch (e) {
      print('❌ Error loading exercise database: $e');
      _exerciseDatabase = {'exercises': []};
      _isInitialized = true;
    }
  }

  /// Get exercise demo data by ID
  Map<String, dynamic>? getExerciseDemoData(String exerciseId) {
    if (!_isInitialized) {
      print('⚠️ Exercise database not initialized');
      return null;
    }
    
    return _exerciseMap[exerciseId];
  }

  /// Merge program exercise data with demo data from database
  /// 
  /// Takes exercise from workout program (has sets, reps, rest)
  /// Adds demo data from database (instructions, tips, GIF, muscles)
  /// Returns complete exercise object for workout screens
  List<Map<String, dynamic>> mergeWorkoutExercises(
    String goal,
    String level,
    List<dynamic> programExercises
  ) {
    return programExercises.map((exercise) {
      final exerciseMap = Map<String, dynamic>.from(exercise as Map);
      final String exerciseId = exerciseMap['exerciseId'] ?? '';
      
      // Get demo data from database
      final demoData = getExerciseDemoData(exerciseId);
      
      if (demoData == null) {
        // No demo data found, use program data with defaults
        print('⚠️ No demo data for: $exerciseId, using defaults');
        return Map<String, dynamic>.from({
          ...exerciseMap,
          'instructions': ['Perform the exercise as demonstrated'],
          'tips': ['Focus on proper form', 'Control your breathing', 'Maintain good posture'],
          'commonMistakes': ['Rushing through reps', 'Poor form', 'Not breathing properly'],
          'primaryMuscles': exerciseMap['targetMuscles'] ?? [],
          'secondaryMuscles': [],
          'gifUrl': 'https://via.placeholder.com/400x300?text=${Uri.encodeComponent(exerciseMap['name'] ?? 'Exercise')}',
          'category': 'general',
          'difficulty': level,
          'equipment': 'none',
        });
      }
      
      // Merge program data (sets, reps, rest) with demo data (instructions, GIF, etc.)
      final merged = Map<String, dynamic>.from({
        ...demoData,  // Demo data: instructions, tips, GIF, muscles
        ...exerciseMap,  // Program data: sets, reps, rest, notes (overwrites demo if conflicts)
      });
      
      // Debug: Check if gifUrl is present
      if (merged['gifUrl'] == null || merged['gifUrl'].toString().isEmpty) {
        print('⚠️ Missing gifUrl for ${exerciseMap['name']} (ID: $exerciseId)');
        print('   Demo data has gifUrl: ${demoData['gifUrl']}');
        print('   Program data keys: ${exerciseMap.keys.toList()}');
      } else {
        print('✅ GIF URL found for ${exerciseMap['name']}: ${merged['gifUrl']}');
      }
      
      return merged;
    }).toList();
  }

  /// Pre-load exercises for a workout (call before merging)
  /// With single database, this just ensures initialization
  Future<void> preloadWorkoutExercises(
    String goal,
    String level,
    List<dynamic> programExercises
  ) async {
    await initialize();
  }

  /// Check if demo data exists for an exercise
  bool hasDemoData(String exerciseId) {
    return _exerciseMap.containsKey(exerciseId);
  }

  /// Get list of all available exercise IDs
  List<String> getAvailableExerciseIds() {
    if (!_isInitialized) return [];
    return _exerciseMap.keys.toList();
  }

  /// Get all exercises by category
  List<Map<String, dynamic>> getExercisesByCategory(String category) {
    if (!_isInitialized) return [];
    
    return _exerciseMap.values
        .where((exercise) => exercise['category'] == category)
        .toList();
  }

  /// Get all exercises by difficulty
  List<Map<String, dynamic>> getExercisesByDifficulty(String difficulty) {
    if (!_isInitialized) return [];
    
    return _exerciseMap.values
        .where((exercise) => exercise['difficulty'] == difficulty)
        .toList();
  }

  /// Get all exercises by primary muscle
  List<Map<String, dynamic>> getExercisesByMuscle(String muscle) {
    if (!_isInitialized) return [];
    
    return _exerciseMap.values
        .where((exercise) {
          List<dynamic> muscles = exercise['primaryMuscles'] ?? [];
          return muscles.contains(muscle);
        })
        .toList();
  }

  /// Search exercises by name
  List<Map<String, dynamic>> searchExercises(String query) {
    if (!_isInitialized || query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _exerciseMap.values
        .where((exercise) {
          String name = (exercise['name'] ?? '').toLowerCase();
          return name.contains(lowerQuery);
        })
        .toList();
  }

  /// Get total number of exercises
  int getTotalExercises() {
    return _exerciseMap.length;
  }

  /// Get database statistics
  Map<String, dynamic> getStats() {
    if (!_isInitialized) {
      return {'initialized': false, 'totalExercises': 0};
    }

    return {
      'initialized': true,
      'totalExercises': _exerciseMap.length,
      'version': _exerciseDatabase?['version'] ?? 'unknown',
      'lastUpdated': _exerciseDatabase?['lastUpdated'] ?? 'unknown',
    };
  }

  /// Clear cache (useful for testing)
  void clearCache() {
    _exerciseMap.clear();
    _exerciseDatabase = null;
    _isInitialized = false;
  }
}
