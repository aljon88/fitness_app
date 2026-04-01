import 'dart:convert';
import 'package:flutter/services.dart';

class ExerciseDBLoader {
  static List<Map<String, dynamic>>? _exercises;
  
  /// Load exercises from JSON file
  static Future<void> loadExercises() async {
    if (_exercises != null) return; // Already loaded
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _exercises = jsonData.cast<Map<String, dynamic>>();
      
      print('✅ Loaded ${_exercises!.length} exercises from ExerciseDB');
    } catch (e) {
      print('❌ Error loading exercises: $e');
      _exercises = [];
    }
  }
  
  /// Get exercise by name (case-insensitive)
  static Map<String, dynamic>? getExerciseByName(String name) {
    if (_exercises == null || _exercises!.isEmpty) return null;
    
    final lowerName = name.toLowerCase().trim();
    
    try {
      return _exercises!.firstWhere(
        (ex) => ex['name'].toString().toLowerCase() == lowerName,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Get exercises by body part
  static List<Map<String, dynamic>> getExercisesByBodyPart(String bodyPart) {
    if (_exercises == null) return [];
    
    return _exercises!.where((ex) {
      final parts = ex['primaryMuscles'] as List?;
      return parts?.any((p) => 
        p.toString().toLowerCase().contains(bodyPart.toLowerCase())
      ) ?? false;
    }).toList();
  }
  
  /// Get bodyweight exercises only
  static List<Map<String, dynamic>> getBodyweightExercises() {
    if (_exercises == null) return [];
    
    return _exercises!.where((ex) {
      final equipment = ex['equipment']?.toString().toLowerCase() ?? '';
      return equipment.contains('body') || equipment.contains('bodyweight');
    }).toList();
  }
  
  /// Search exercises
  static List<Map<String, dynamic>> searchExercises(String query) {
    if (_exercises == null) return [];
    
    final lowerQuery = query.toLowerCase();
    return _exercises!.where((ex) {
      final name = ex['name'].toString().toLowerCase();
      final category = ex['category']?.toString().toLowerCase() ?? '';
      return name.contains(lowerQuery) || category.contains(lowerQuery);
    }).toList();
  }
}
