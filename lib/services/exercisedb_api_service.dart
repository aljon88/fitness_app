import 'dart:convert';
import 'package:http/http.dart' as http;

class ExerciseDBApiService {
  static final ExerciseDBApiService _instance = ExerciseDBApiService._internal();
  factory ExerciseDBApiService() => _instance;
  ExerciseDBApiService._internal();

  // ExerciseDB.dev free API endpoint
  static const String baseUrl = 'https://exercisedb.p.rapidapi.com';
  
  // For free tier, we'll use a fallback local database
  // You can sign up for RapidAPI key at: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb
  static const String apiKey = 'YOUR_API_KEY_HERE'; // Replace with actual key

  Future<List<Map<String, dynamic>>> getBodyweightExercises() async {
    // For now, return curated bodyweight exercises
    // Later, integrate with actual API when you get the key
    return _getLocalBodyweightExercises();
  }

  Future<Map<String, dynamic>> getExerciseById(String id) async {
    final exercises = await getBodyweightExercises();
    return exercises.firstWhere(
      (ex) => ex['id'] == id,
      orElse: () => exercises.first,
    );
  }

  List<Map<String, dynamic>> _getLocalBodyweightExercises() {
    return [
      // BEGINNER EXERCISES
      {
        'id': 'push_ups',
        'name': 'Push-ups',
        'difficulty': 'beginner',
        'equipment': 'bodyweight',
        'primaryMuscles': ['chest', 'triceps'],
        'secondaryMuscles': ['shoulders', 'core'],
        'instructions': [
          'Start in plank position with hands shoulder-width apart',
          'Lower your body until chest nearly touches the floor',
          'Keep your core tight and back straight throughout',
          'Push back up to starting position',
        ],
        'gifUrl': 'https://v2.exercisedb.io/image/FtlER-Wd7Aq8Uw',
        'tips': [
          'Keep elbows at 45-degree angle to body',
          'Engage your core throughout the movement',
          'Breathe in going down, breathe out pushing up',
        ],
      },
      {
        'id': 'knee_push_ups',
        'name': 'Knee Push-ups',
        'difficulty': 'beginner',
        'equipment': 'bodyweight',
        'primaryMuscles': ['chest', 'triceps'],
        'secondaryMuscles': ['shoulders'],
        'instructions': [
          'Start in plank position, then lower knees to ground',
          'Keep body straight from knees to head',
          'Lower chest to floor',
          'Push back up',
        ],
        'gifUrl': 'https://v2.exercisedb.io/image/GtlER-Wd7Aq8Uw',
        'tips': [
          'Great modification for beginners',
          'Focus on proper form',
          'Progress to regular push-ups when ready',
        ],
      },
      {
        'id': 'wall_push_ups',
        'name': 'Wall Push-ups',
        'difficulty': 'beginner',
        'equipment': 'bodyweight',
        'primaryMuscles': ['chest', 'triceps'],
        'secondaryMuscles': ['shoulders'],
        'instructions': [
          'Stand arm\'s length from wall',
          'Place hands on wall at shoulder height',
          'Lean forward, bending elbows',
          'Push back to start',
        ],
        'gifUrl': 'https://v2.exercisedb.io/image/HtlER-Wd7Aq8Uw',
        'tips': [
          'Perfect for absolute beginners',
          'Step further from wall to increase difficulty',
          'Keep body straight',
        ],
      },
      {
        'id': 'squats',
        'name': 'Squats',
        'difficulty': 'beginner',
        'equipment': 'bodyweight',
        'primaryMuscles': ['quadriceps', 'glutes'],
        'secondaryMuscles': ['hamstrings', 'calves'],
        'instructions': [
          'Stand with feet shoulder-width apart',
          'Lower your body by bending knees and hips',
          'Keep chest up and knees behind toes',
          'Push through heels to return to start',
        ],
        'gifUrl': 'https://v2.exercisedb.io/image/yB5ER-Wd7Aq8Uw',
        'tips': [
          'Keep your weight on your heels',
          'Don\'t let knees cave inward',
          'Go as low as comfortable with good form',
        ],
      },
      {
        'id': 'lunges',
        'name': 'Lunges',
        'difficulty': 'beginner',
        'equipment': 'bodyweight',
        'primaryMuscles': ['quadriceps', 'glutes'],
        'secondaryMuscles': ['hamstrings', 'calves'],
        'instructions': [
          'Stand with feet hip-width apart',
          'Step forward with one leg and lower hips',
          'Keep front knee at 90 degrees',
          'Push back to starting position and alternate',
        ],
        'gifUrl': 'https://v2.exercisedb.io/image/zB5ER-Wd7Aq8Uw',
        'tips': [
          'Keep torso upright throughout movement',
          'Front knee should not pass toes',
          'Push through front heel to return',
        ],
      },
      {
        'id': 'plank',
        'name': 'Plank',
        'difficulty': 'beginner',
        'equipment': 'bodyweight',
        'primaryMuscles': ['core', 'abs'],
        'secondaryMuscles': ['shoulders', 'back'],
        'instructions': [
          'Start in forearm plank position',
          'Keep body in straight line from head to heels',
          'Engage core and hold position',
          'Breathe steadily throughout',
        ],
        'gifUrl': 'https://v2.exercisedb.io/image/AB5ER-Wd7Aq8Uw',
        'tips': [
          'Don\'t let hips sag or pike up',
          'Keep neck neutral, look at floor',
          'Squeeze glutes and core tight',
        ],
      },
      {
        'id': 'mountain_climbers',
        'name': 'Mountain Climbers',
        'difficulty': 'intermediate',
        'equipment': 'bodyweight',
        'primaryMuscles': ['core', 'abs'],
        'secondaryMuscles': ['shoulders', 'legs'],
        'instructions': [
          'Start in plank position',
          'Bring one knee to chest',
          'Quickly switch legs',
          'Maintain fast pace',
        ],
        'gifUrl': 'https://v2.exercisedb.io/image/CB5ER-Wd7Aq8Uw',
        'tips': [
          'Keep hips level',
          'Maintain fast pace',
          'Breathe rhythmically',
        ],
      },
      {
        'id': 'burpees',
        'name': 'Burpees',
        'difficulty': 'advanced',
        'equipment': 'bodyweight',
        'primaryMuscles': ['full_body'],
        'secondaryMuscles': ['cardio'],
        'instructions': [
          'Start standing',
          'Drop to plank position',
          'Perform push-up',
          'Jump feet to hands',
          'Jump up explosively',
        ],
        'gifUrl': 'https://v2.exercisedb.io/image/DB5ER-Wd7Aq8Uw',
        'tips': [
          'Full push-up each rep',
          'Explosive jump at top',
          'Land softly',
        ],
      },
      {
        'id': 'jumping_jacks',
        'name': 'Jumping Jacks',
        'difficulty': 'beginner',
        'equipment': 'bodyweight',
        'primaryMuscles': ['full_body', 'cardio'],
        'secondaryMuscles': ['shoulders', 'legs'],
        'instructions': [
          'Start with feet together, arms at sides',
          'Jump while spreading legs and raising arms',
          'Return to starting position',
          'Maintain steady rhythm',
        ],
        'gifUrl': 'https://v2.exercisedb.io/image/EB5ER-Wd7Aq8Uw',
        'tips': [
          'Land softly on balls of feet',
          'Keep movements smooth',
          'Maintain steady breathing',
        ],
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getExercisesByDifficulty(String difficulty) async {
    final allExercises = await getBodyweightExercises();
    return allExercises.where((ex) => ex['difficulty'] == difficulty).toList();
  }

  Future<List<Map<String, dynamic>>> getExercisesByMuscle(String muscle) async {
    final allExercises = await getBodyweightExercises();
    return allExercises.where((ex) {
      final primary = ex['primaryMuscles'] as List;
      final secondary = ex['secondaryMuscles'] as List;
      return primary.contains(muscle) || secondary.contains(muscle);
    }).toList();
  }
}
