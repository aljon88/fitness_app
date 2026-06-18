import '../services/user_storage_service.dart';

/// Enhanced personalization service for better fitness level and goal alignment
class PersonalizationService {
  
  /// Get personalized workout intensity based on user profile
  static double getWorkoutIntensity(Map<String, dynamic> userProfile) {
    String fitnessLevel = userProfile['fitnessLevel'] ?? 'beginner';
    String goal = userProfile['primaryGoal'] ?? 'general_fitness';
    int age = int.tryParse(userProfile['age'] ?? '25') ?? 25;
    List<String> restrictions = List<String>.from(userProfile['physicalRestrictions'] ?? []);
    
    double baseIntensity = 1.0;
    
    // Adjust based on fitness level
    switch (fitnessLevel) {
      case 'beginner':
        baseIntensity = 0.6;
        break;
      case 'intermediate': 
        baseIntensity = 0.8;
        break;
      case 'advanced':
        baseIntensity = 1.0;
        break;
    }
    
    // Adjust based on goal
    switch (goal) {
      case 'weight_loss':
        baseIntensity += 0.1; // Slightly higher intensity for cardio
        break;
      case 'muscle_gain':
        baseIntensity += 0.05; // Moderate increase for strength
        break;
      case 'strength':
        baseIntensity += 0.15; // Highest intensity for strength goals
        break;
      case 'flexibility':
        baseIntensity -= 0.1; // Lower intensity, focus on form
        break;
    }
    
    // Adjust based on age
    if (age > 50) {
      baseIntensity -= 0.1;
    } else if (age > 65) {
      baseIntensity -= 0.2;
    }
    
    // Adjust based on restrictions
    if (restrictions.contains('heart_conditions')) {
      baseIntensity -= 0.2;
    }
    if (restrictions.contains('back_problems')) {
      baseIntensity -= 0.1;
    }
    
    // Ensure intensity stays within bounds
    return baseIntensity.clamp(0.3, 1.2);
  }
  
  /// Get recommended rest time between sets
  static int getRestTime(Map<String, dynamic> userProfile, String exerciseType) {
    String fitnessLevel = userProfile['fitnessLevel'] ?? 'beginner';
    String goal = userProfile['primaryGoal'] ?? 'general_fitness';
    
    int baseRestTime = 60; // seconds
    
    // Adjust based on fitness level
    switch (fitnessLevel) {
      case 'beginner':
        baseRestTime = 90;
        break;
      case 'intermediate':
        baseRestTime = 60;
        break;
      case 'advanced':
        baseRestTime = 45;
        break;
    }
    
    // Adjust based on exercise type and goal
    if (exerciseType == 'strength') {
      if (goal == 'strength') {
        baseRestTime += 30; // Longer rest for strength training
      } else if (goal == 'muscle_gain') {
        baseRestTime += 15; 
      }
    } else if (exerciseType == 'cardio') {
      if (goal == 'weight_loss') {
        baseRestTime -= 15; // Shorter rest for fat burning
      }
    }
    
    return baseRestTime;
  }
  
  /// Get personalized rep ranges
  static Map<String, int> getRepRange(Map<String, dynamic> userProfile, String exerciseType) {
    String fitnessLevel = userProfile['fitnessLevel'] ?? 'beginner';
    String goal = userProfile['primaryGoal'] ?? 'general_fitness';
    
    Map<String, int> repRange = {'min': 8, 'max': 12};
    
    // Base ranges by fitness level
    switch (fitnessLevel) {
      case 'beginner':
        repRange = {'min': 8, 'max': 12};
        break;
      case 'intermediate':
        repRange = {'min': 10, 'max': 15};
        break;
      case 'advanced':
        repRange = {'min': 12, 'max': 20};
        break;
    }
    
    // Adjust based on goal
    switch (goal) {
      case 'strength':
        repRange = {'min': repRange['min']! - 2, 'max': repRange['max']! - 3};
        break;
      case 'muscle_gain':
        // Keep standard ranges
        break;
      case 'weight_loss':
        repRange = {'min': repRange['min']! + 2, 'max': repRange['max']! + 5};
        break;
      case 'flexibility':
        repRange = {'min': 5, 'max': 8}; // Lower reps, focus on holds
        break;
    }
    
    // Ensure minimum bounds
    repRange['min'] = repRange['min']!.clamp(3, 15);
    repRange['max'] = repRange['max']!.clamp(5, 25);
    
    return repRange;
  }
  
  /// Get personalized workout duration
  static int getWorkoutDuration(Map<String, dynamic> userProfile) {
    String fitnessLevel = userProfile['fitnessLevel'] ?? 'beginner';
    String goal = userProfile['primaryGoal'] ?? 'general_fitness';
    List<String> restrictions = List<String>.from(userProfile['physicalRestrictions'] ?? []);
    
    int baseDuration = 30; // minutes
    
    // Adjust based on fitness level
    switch (fitnessLevel) {
      case 'beginner':
        baseDuration = 25;
        break;
      case 'intermediate':
        baseDuration = 35;
        break;
      case 'advanced':
        baseDuration = 45;
        break;
    }
    
    // Adjust based on goal
    switch (goal) {
      case 'weight_loss':
        baseDuration += 10; // Longer cardio sessions
        break;
      case 'strength':
        baseDuration += 5; // Longer rest between sets
        break;
      case 'flexibility':
        baseDuration -= 5; // Shorter, focused sessions
        break;
    }
    
    // Adjust for restrictions
    if (restrictions.contains('heart_conditions')) {
      baseDuration -= 10;
    }
    if (restrictions.contains('low_impact_only')) {
      baseDuration -= 5;
    }
    
    return baseDuration.clamp(15, 60);
  }
  
  /// Get personalized weekly workout frequency
  static int getWeeklyFrequency(Map<String, dynamic> userProfile) {
    String fitnessLevel = userProfile['fitnessLevel'] ?? 'beginner';
    List<String> restrictions = List<String>.from(userProfile['physicalRestrictions'] ?? []);
    
    int frequency = 4; // base frequency
    
    switch (fitnessLevel) {
      case 'beginner':
        frequency = 3;
        break;
      case 'intermediate':
        frequency = 4;
        break;
      case 'advanced':
        frequency = 5;
        break;
    }
    
    // Reduce frequency for certain restrictions
    if (restrictions.contains('heart_conditions') || 
        restrictions.contains('balance_support')) {
      frequency = (frequency - 1).clamp(2, 5);
    }
    
    return frequency;
  }
  
  /// Get motivational messages based on user profile
  static List<String> getPersonalizedMotivation(Map<String, dynamic> userProfile) {
    String goal = userProfile['primaryGoal'] ?? 'general_fitness';
    String fitnessLevel = userProfile['fitnessLevel'] ?? 'beginner';
    
    List<String> messages = [];
    
    switch (goal) {
      case 'weight_loss':
        messages = [
          'Every workout burns calories and builds confidence!',
          'You\'re one step closer to your weight loss goal!',
          'Consistency beats perfection - keep moving!',
        ];
        break;
      case 'muscle_gain':
        messages = [
          'Your muscles grow stronger with every rep!',
          'Building muscle takes time - trust the process!',
          'Progressive overload is your path to gains!',
        ];
        break;
      case 'strength':
        messages = [
          'Strength isn\'t just physical - you\'re building mental toughness!',
          'Every set makes you more powerful!',
          'Your future self will thank you for today\'s effort!',
        ];
        break;
      case 'flexibility':
        messages = [
          'Flexibility is freedom of movement!',
          'Your body is becoming more mobile every day!',
          'Breathe deep and stretch further!',
        ];
        break;
      default:
        messages = [
          'Every workout is an investment in your health!',
          'You\'re building a healthier, stronger you!',
          'Progress happens one workout at a time!',
        ];
    }
    
    // Add level-specific encouragement
    if (fitnessLevel == 'beginner') {
      messages.add('Remember, everyone started where you are now!');
    }
    
    return messages;
  }
}