import '../models/exercise.dart';

/// Factory to create Exercise objects from ExerciseDB data
class ExerciseFactory {
  static Exercise createFromExerciseDB(
    Map<String, dynamic> data,
    String difficulty,
    int duration,
  ) {
    return Exercise(
      id: data['id'] ?? 'unknown',
      name: _formatName(data['name'] ?? 'Exercise'),
      description: '${_formatName(data['name'] ?? 'Exercise')} - ${data['category'] ?? 'Strength'}',
      instructions: List<String>.from(data['instructions'] ?? ['Perform the exercise with proper form']),
      category: _formatCategory(data['category'] ?? 'strength'),
      difficulty: difficulty,
      duration: duration,
      reps: _getRepsForDifficulty(difficulty),
      sets: _getSetsForDifficulty(difficulty),
      restTime: _getRestTimeForDifficulty(difficulty),
      targetMuscles: _formatMuscles(data['primaryMuscles'] ?? []),
      equipment: [_formatEquipment(data['equipment'] ?? 'body weight')],
      tips: _generateTips(data),
      commonMistakes: _generateCommonMistakes(data),
      caloriesBurned: _estimateCalories(duration),
      gifUrl: _getGifUrl(data),
    );
  }
  
  static String _getGifUrl(Map<String, dynamic> data) {
    final images = data['images'] as List?;
    if (images != null && images.isNotEmpty) {
      // Use first image as GIF
      return images[0];
    }
    return '';
  }
  
  static String _formatName(String name) {
    // Capitalize first letter of each word
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  static String _formatCategory(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return 'Strength';
      case 'cardio':
        return 'Cardio';
      case 'stretching':
        return 'Flexibility';
      case 'plyometrics':
        return 'Cardio';
      default:
        return 'Strength';
    }
  }
  
  static List<String> _formatMuscles(List muscles) {
    return muscles.map((m) {
      final muscle = m.toString();
      // Capitalize first letter
      return muscle[0].toUpperCase() + muscle.substring(1).toLowerCase();
    }).toList();
  }
  
  static String _formatEquipment(String equipment) {
    if (equipment.toLowerCase().contains('body') || equipment.toLowerCase().contains('bodyweight')) {
      return 'None';
    }
    return equipment;
  }
  
  static int _getRepsForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'beginner': return 8;
      case 'intermediate': return 12;
      case 'advanced': return 20;
      default: return 10;
    }
  }
  
  static int _getSetsForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'beginner': return 2;
      case 'intermediate': return 3;
      case 'advanced': return 4;
      default: return 3;
    }
  }
  
  static String _getRestTimeForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'beginner': return '45 seconds';
      case 'intermediate': return '60 seconds';
      case 'advanced': return '90 seconds';
      default: return '60 seconds';
    }
  }
  
  static List<String> _generateTips(Map<String, dynamic> data) {
    return [
      'Focus on proper form',
      'Breathe steadily throughout',
      'Control the movement',
    ];
  }
  
  static List<String> _generateCommonMistakes(Map<String, dynamic> data) {
    return [
      'Rushing through reps',
      'Poor form',
      'Not breathing properly',
    ];
  }
  
  static int _estimateCalories(int duration) {
    return (duration * 0.15).round(); // Rough estimate
  }
}
