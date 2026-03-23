import '../models/meal_models.dart';

// Service for tracking meal completion and user feedback
class MealTrackingService {
  static final MealTrackingService _instance = MealTrackingService._internal();
  factory MealTrackingService() => _instance;
  MealTrackingService._internal();

  final List<MealFeedback> _feedbackHistory = [];
  final Map<String, List<MealFeedback>> _userFeedback = {};

  // Record meal completion feedback
  Future<void> recordMealFeedback(MealFeedback feedback) async {
    _feedbackHistory.add(feedback);
    
    // Organize by user
    if (!_userFeedback.containsKey(feedback.userId)) {
      _userFeedback[feedback.userId] = [];
    }
    _userFeedback[feedback.userId]!.add(feedback);

    // Update user preferences based on feedback
    await _updateUserPreferences(feedback);
  }

  // Get user's meal completion history
  Future<List<MealFeedback>> getUserFeedbackHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    var userHistory = _userFeedback[userId] ?? [];
    
    // Filter by date range
    if (startDate != null || endDate != null) {
      userHistory = userHistory.where((feedback) {
        final date = feedback.date;
        if (startDate != null && date.isBefore(startDate)) return false;
        if (endDate != null && date.isAfter(endDate)) return false;
        return true;
      }).toList();
    }
    
    // Sort by date (most recent first)
    userHistory.sort((a, b) => b.date.compareTo(a.date));
    
    // Apply limit
    if (limit != null && userHistory.length > limit) {
      userHistory = userHistory.take(limit).toList();
    }
    
    return userHistory;
  }

  // Calculate user's meal plan adherence rate
  Future<double> calculateAdherenceRate(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final feedback = await getUserFeedbackHistory(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
    
    if (feedback.isEmpty) return 0.0;
    
    final completedMeals = feedback.where((f) => f.completed).length;
    return completedMeals / feedback.length;
  }

  // Get meal completion insights
  Future<MealInsights> generateMealInsights(
    String userId, {
    int daysBack = 30,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: daysBack));
    
    final feedback = await getUserFeedbackHistory(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
    
    return MealInsights.fromFeedback(feedback);
  }

  // Get popular recipes based on user ratings
  Future<List<String>> getPopularRecipes({
    double minRating = 4.0,
    int limit = 10,
  }) async {
    final recipeRatings = <String, List<int>>{};
    
    // Collect all ratings by recipe
    for (final feedback in _feedbackHistory) {
      if (feedback.rating != null) {
        if (!recipeRatings.containsKey(feedback.recipeId)) {
          recipeRatings[feedback.recipeId] = [];
        }
        recipeRatings[feedback.recipeId]!.add(feedback.rating!);
      }
    }
    
    // Calculate average ratings
    final averageRatings = recipeRatings.entries.map((entry) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return MapEntry(entry.key, average);
    }).where((entry) => entry.value >= minRating).toList();
    
    // Sort by rating
    averageRatings.sort((a, b) => b.value.compareTo(a.value));
    
    return averageRatings.take(limit).map((entry) => entry.key).toList();
  }

  // Track ingredient substitutions
  Future<void> recordSubstitution(
    String userId,
    String recipeId,
    String originalIngredient,
    String substitute,
  ) async {
    final feedback = MealFeedback(
      userId: userId,
      recipeId: recipeId,
      date: DateTime.now(),
      completed: true,
      substitutions: [substitute],
      notes: 'Substituted $originalIngredient with $substitute',
    );
    
    await recordMealFeedback(feedback);
  }

  // Get common substitutions for an ingredient
  Future<List<String>> getCommonSubstitutions(String ingredient) async {
    final substitutions = <String, int>{};
    
    for (final feedback in _feedbackHistory) {
      if (feedback.substitutions != null && feedback.notes != null) {
        final notes = feedback.notes!.toLowerCase();
        if (notes.contains(ingredient.toLowerCase())) {
          for (final sub in feedback.substitutions!) {
            substitutions[sub] = (substitutions[sub] ?? 0) + 1;
          }
        }
      }
    }
    
    // Sort by frequency
    final sortedSubs = substitutions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedSubs.take(5).map((entry) => entry.key).toList();
  }

  // Update user preferences based on feedback
  Future<void> _updateUserPreferences(MealFeedback feedback) async {
    // This would typically update the user's profile in a database
    // For now, we'll simulate the preference learning
    
    if (feedback.rating != null) {
      final rating = feedback.rating!;
      
      // Positive feedback (4-5 stars) increases preferences
      // Negative feedback (1-2 stars) decreases preferences
      final preferenceChange = (rating - 3) * 0.1; // -0.2 to +0.2
      
      // In a real implementation, you would:
      // 1. Get the recipe details
      // 2. Update ingredient preferences
      // 3. Update cuisine preferences
      // 4. Adjust cooking time preferences
      // 5. Learn from difficulty feedback
      
      print('Learning from feedback: Recipe ${feedback.recipeId} rated $rating stars');
      print('Preference adjustment: ${preferenceChange > 0 ? '+' : ''}${preferenceChange.toStringAsFixed(2)}');
    }
  }

  // Get meal timing patterns
  Future<Map<String, double>> getMealTimingPatterns(String userId) async {
    final feedback = await getUserFeedbackHistory(userId, limit: 100);
    final timingPatterns = <String, List<int>>{};
    
    for (final f in feedback) {
      final hour = f.date.hour;
      String mealTime;
      
      if (hour >= 6 && hour < 11) {
        mealTime = 'breakfast';
      } else if (hour >= 11 && hour < 16) {
        mealTime = 'lunch';
      } else if (hour >= 16 && hour < 22) {
        mealTime = 'dinner';
      } else {
        mealTime = 'snack';
      }
      
      if (!timingPatterns.containsKey(mealTime)) {
        timingPatterns[mealTime] = [];
      }
      timingPatterns[mealTime]!.add(hour);
    }
    
    // Calculate average timing for each meal
    final averageTiming = <String, double>{};
    for (final entry in timingPatterns.entries) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      averageTiming[entry.key] = average;
    }
    
    return averageTiming;
  }

  // Clear user data (for privacy/GDPR compliance)
  Future<void> clearUserData(String userId) async {
    _userFeedback.remove(userId);
    _feedbackHistory.removeWhere((feedback) => feedback.userId == userId);
  }
}

// Meal insights data class
class MealInsights {
  final double completionRate;
  final double averageRating;
  final Map<String, int> mealTypeCompletions;
  final Map<String, int> cuisinePreferences;
  final List<String> mostCompletedRecipes;
  final List<String> leastCompletedRecipes;
  final Map<String, double> averagePrepTimes;
  final int totalMealsTracked;

  MealInsights({
    required this.completionRate,
    required this.averageRating,
    required this.mealTypeCompletions,
    required this.cuisinePreferences,
    required this.mostCompletedRecipes,
    required this.leastCompletedRecipes,
    required this.averagePrepTimes,
    required this.totalMealsTracked,
  });

  factory MealInsights.fromFeedback(List<MealFeedback> feedback) {
    if (feedback.isEmpty) {
      return MealInsights(
        completionRate: 0.0,
        averageRating: 0.0,
        mealTypeCompletions: {},
        cuisinePreferences: {},
        mostCompletedRecipes: [],
        leastCompletedRecipes: [],
        averagePrepTimes: {},
        totalMealsTracked: 0,
      );
    }

    // Calculate completion rate
    final completedCount = feedback.where((f) => f.completed).length;
    final completionRate = completedCount / feedback.length;

    // Calculate average rating
    final ratingsOnly = feedback.where((f) => f.rating != null).map((f) => f.rating!).toList();
    final averageRating = ratingsOnly.isEmpty ? 0.0 : 
        ratingsOnly.reduce((a, b) => a + b) / ratingsOnly.length;

    // Analyze meal type completions (would need recipe data for this)
    final mealTypeCompletions = <String, int>{};
    
    // Analyze cuisine preferences (would need recipe data for this)
    final cuisinePreferences = <String, int>{};

    // Find most/least completed recipes
    final recipeCompletions = <String, int>{};
    for (final f in feedback) {
      if (f.completed) {
        recipeCompletions[f.recipeId] = (recipeCompletions[f.recipeId] ?? 0) + 1;
      }
    }
    
    final sortedRecipes = recipeCompletions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final mostCompleted = sortedRecipes.take(5).map((e) => e.key).toList();
    final leastCompleted = sortedRecipes.reversed.take(5).map((e) => e.key).toList();

    // Calculate average prep times
    final prepTimes = <String, List<int>>{};
    for (final f in feedback) {
      if (f.actualPrepTime != null) {
        prepTimes[f.recipeId] = (prepTimes[f.recipeId] ?? [])..add(f.actualPrepTime!);
      }
    }
    
    final averagePrepTimes = <String, double>{};
    for (final entry in prepTimes.entries) {
      averagePrepTimes[entry.key] = entry.value.reduce((a, b) => a + b) / entry.value.length;
    }

    return MealInsights(
      completionRate: completionRate,
      averageRating: averageRating,
      mealTypeCompletions: mealTypeCompletions,
      cuisinePreferences: cuisinePreferences,
      mostCompletedRecipes: mostCompleted,
      leastCompletedRecipes: leastCompleted,
      averagePrepTimes: averagePrepTimes,
      totalMealsTracked: feedback.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completionRate': completionRate,
      'averageRating': averageRating,
      'mealTypeCompletions': mealTypeCompletions,
      'cuisinePreferences': cuisinePreferences,
      'mostCompletedRecipes': mostCompletedRecipes,
      'leastCompletedRecipes': leastCompletedRecipes,
      'averagePrepTimes': averagePrepTimes,
      'totalMealsTracked': totalMealsTracked,
    };
  }
}