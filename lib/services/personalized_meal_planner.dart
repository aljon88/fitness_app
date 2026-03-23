import 'dart:math';
import '../models/meal_models.dart';
import 'meal_database_service.dart';

// Intelligent meal planning with personalization
class PersonalizedMealPlanner {
  static final PersonalizedMealPlanner _instance = PersonalizedMealPlanner._internal();
  factory PersonalizedMealPlanner() => _instance;
  PersonalizedMealPlanner._internal();

  final MealDatabaseService _database = MealDatabaseService();
  final Random _random = Random();

  // Generate personalized weekly meal plan
  Future<WeeklyMealPlan> generateWeeklyPlan({
    required UserNutritionProfile profile,
    DateTime? startDate,
    int days = 7,
  }) async {
    startDate ??= DateTime.now();
    
    final dailyPlans = <DailyMealPlan>[];
    final allMeals = <Recipe>[];
    
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dailyPlan = await _generateDailyPlan(profile, date, allMeals);
      dailyPlans.add(dailyPlan);
      allMeals.addAll(dailyPlan.allMeals);
    }
    
    final weeklyNutrition = _calculateWeeklyNutrition(dailyPlans, profile);
    final totalCost = dailyPlans.fold(0.0, (sum, plan) => sum + plan.dailyCost);
    final varietyScore = _calculateVarietyScore(allMeals);
    
    return WeeklyMealPlan(
      id: _generateId(),
      userId: profile.userId,
      startDate: startDate,
      dailyPlans: dailyPlans,
      weeklyNutrition: weeklyNutrition,
      totalEstimatedCost: totalCost,
      varietyScore: varietyScore,
      createdAt: DateTime.now(),
    );
  }

  // Generate single day meal plan
  Future<DailyMealPlan> _generateDailyPlan(
    UserNutritionProfile profile,
    DateTime date,
    List<Recipe> recentMeals,
  ) async {
    // Get candidate recipes for each meal type
    final breakfastCandidates = await _getPersonalizedRecipes(
      profile, 'breakfast', recentMeals);
    final lunchCandidates = await _getPersonalizedRecipes(
      profile, 'lunch', recentMeals);
    final dinnerCandidates = await _getPersonalizedRecipes(
      profile, 'dinner', recentMeals);
    final snackCandidates = await _getPersonalizedRecipes(
      profile, 'snack', recentMeals);

    // Select optimal combination
    final breakfast = _selectOptimalMeal(breakfastCandidates, profile, 'breakfast');
    final lunch = _selectOptimalMeal(lunchCandidates, profile, 'lunch');
    final dinner = _selectOptimalMeal(dinnerCandidates, profile, 'dinner');
    
    // Select snacks to meet remaining calorie needs
    final selectedSnacks = _selectSnacks(snackCandidates, profile, 
        [breakfast, lunch, dinner].where((m) => m != null).cast<Recipe>().toList());

    final allDayMeals = [
      if (breakfast != null) breakfast,
      if (lunch != null) lunch,
      if (dinner != null) dinner,
      ...selectedSnacks,
    ];

    final dailyNutrition = _calculateDailyNutrition(allDayMeals);
    final dailyCost = allDayMeals.fold(0.0, (sum, meal) => sum + meal.estimatedCost);

    return DailyMealPlan(
      date: date,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snacks: selectedSnacks,
      dailyNutrition: dailyNutrition,
      dailyCost: dailyCost,
    );
  }
  // Get personalized recipe recommendations
  Future<List<Recipe>> _getPersonalizedRecipes(
    UserNutritionProfile profile,
    String mealType,
    List<Recipe> recentMeals,
  ) async {
    // Get base candidates
    var candidates = await _database.searchRecipes(
      mealTypes: [mealType],
      excludeAllergens: profile.allergies,
      maxPrepTime: profile.maxPrepTime,
      maxCost: profile.weeklyBudget / 21, // Rough per-meal budget
    );

    // Filter by dietary restrictions
    candidates = candidates.where((recipe) => 
        recipe.matchesDietaryRestrictions(profile.dietaryRestrictions)).toList();

    // Remove recently used meals for variety
    final recentIds = recentMeals.map((m) => m.id).toSet();
    candidates = candidates.where((recipe) => !recentIds.contains(recipe.id)).toList();

    // Score and sort by personalization
    candidates = _scoreRecipesByPersonalization(candidates, profile);

    return candidates.take(10).toList(); // Return top 10 candidates
  }

  // Score recipes based on user preferences
  List<Recipe> _scoreRecipesByPersonalization(
    List<Recipe> recipes,
    UserNutritionProfile profile,
  ) {
    final scoredRecipes = recipes.map((recipe) {
      double score = 0.0;

      // Cuisine preference (30%)
      if (profile.preferredCuisines.contains(recipe.cuisine)) {
        score += 0.3;
      }
      if (profile.cuisineAffinities.containsKey(recipe.cuisine)) {
        score += profile.cuisineAffinities[recipe.cuisine]! * 0.3;
      }

      // Ingredient preferences (25%)
      for (final ingredient in recipe.ingredients) {
        if (profile.ingredientPreferences.containsKey(ingredient.name)) {
          score += profile.ingredientPreferences[ingredient.name]! * 0.25 / recipe.ingredients.length;
        }
      }

      // Nutrition alignment (25%)
      score += _calculateNutritionAlignment(recipe, profile) * 0.25;

      // Practical factors (20%)
      score += _calculatePracticalScore(recipe, profile) * 0.20;

      return MapEntry(recipe, score);
    }).toList();

    // Sort by score descending
    scoredRecipes.sort((a, b) => b.value.compareTo(a.value));
    return scoredRecipes.map((entry) => entry.key).toList();
  }

  // Calculate how well recipe aligns with nutrition goals
  double _calculateNutritionAlignment(Recipe recipe, UserNutritionProfile profile) {
    double alignment = 0.0;
    final nutrition = recipe.nutrition;
    final targets = profile.macroTargets;

    // Check protein alignment for muscle gain
    if (profile.fitnessGoal == 'muscle_gain' && nutrition.protein > 20) {
      alignment += 0.4;
    }

    // Check calorie alignment
    final targetCaloriesPerMeal = profile.dailyCalorieTarget / 4; // 3 meals + snacks
    final calorieRatio = nutrition.calories / targetCaloriesPerMeal;
    if (calorieRatio >= 0.8 && calorieRatio <= 1.2) {
      alignment += 0.3;
    }

    // Check macro ratios
    if (targets.containsKey('protein')) {
      final proteinRatio = nutrition.proteinPercentage / (targets['protein']! * 100 / profile.dailyCalorieTarget * 4);
      alignment += (1.0 - (proteinRatio - 1.0).abs()).clamp(0.0, 0.3);
    }

    return alignment.clamp(0.0, 1.0);
  }

  // Calculate practical score (prep time, difficulty, cost)
  double _calculatePracticalScore(Recipe recipe, UserNutritionProfile profile) {
    double score = 0.0;

    // Prep time preference
    if (recipe.prepTimeMinutes <= profile.maxPrepTime * 0.7) {
      score += 0.4; // Prefer quicker meals
    }

    // Difficulty alignment
    final skillLevels = ['beginner', 'intermediate', 'advanced'];
    final userSkillIndex = skillLevels.indexOf(profile.cookingSkillLevel);
    final recipeSkillIndex = skillLevels.indexOf(recipe.difficulty);
    
    if (recipeSkillIndex <= userSkillIndex) {
      score += 0.3; // Recipe is within skill level
    }

    // Cost consideration
    final budgetPerMeal = profile.weeklyBudget / 21;
    if (recipe.estimatedCost <= budgetPerMeal) {
      score += 0.3;
    }

    return score.clamp(0.0, 1.0);
  }

  // Select optimal meal from candidates
  Recipe? _selectOptimalMeal(
    List<Recipe> candidates,
    UserNutritionProfile profile,
    String mealType,
  ) {
    if (candidates.isEmpty) return null;

    // Add some randomness to avoid repetition
    final topCandidates = candidates.take(3).toList();
    return topCandidates[_random.nextInt(topCandidates.length)];
  }

  // Select snacks to meet remaining nutritional needs
  List<Recipe> _selectSnacks(
    List<Recipe> snackCandidates,
    UserNutritionProfile profile,
    List<Recipe> mainMeals,
  ) {
    final selectedSnacks = <Recipe>[];
    
    // Calculate remaining calorie needs
    final mainMealCalories = mainMeals.fold(0.0, (sum, meal) => sum + meal.nutrition.calories);
    final remainingCalories = profile.dailyCalorieTarget - mainMealCalories;
    
    // Select snacks to fill remaining calories (aim for 10-20% of daily calories)
    final targetSnackCalories = (profile.dailyCalorieTarget * 0.15).clamp(100.0, remainingCalories);
    
    double currentSnackCalories = 0.0;
    for (final snack in snackCandidates) {
      if (currentSnackCalories + snack.nutrition.calories <= targetSnackCalories) {
        selectedSnacks.add(snack);
        currentSnackCalories += snack.nutrition.calories;
      }
      
      if (selectedSnacks.length >= 2) break; // Max 2 snacks per day
    }
    
    return selectedSnacks;
  }

  // Calculate daily nutrition totals
  NutritionInfo _calculateDailyNutrition(List<Recipe> meals) {
    if (meals.isEmpty) {
      return NutritionInfo(
        calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0,
        sugar: 0, sodium: 0, vitamins: {}, minerals: {},
      );
    }

    return NutritionInfo(
      calories: meals.fold(0.0, (sum, meal) => sum + meal.nutrition.calories),
      protein: meals.fold(0.0, (sum, meal) => sum + meal.nutrition.protein),
      carbs: meals.fold(0.0, (sum, meal) => sum + meal.nutrition.carbs),
      fat: meals.fold(0.0, (sum, meal) => sum + meal.nutrition.fat),
      fiber: meals.fold(0.0, (sum, meal) => sum + meal.nutrition.fiber),
      sugar: meals.fold(0.0, (sum, meal) => sum + meal.nutrition.sugar),
      sodium: meals.fold(0.0, (sum, meal) => sum + meal.nutrition.sodium),
      vitamins: _combineNutrientMaps(meals.map((m) => m.nutrition.vitamins).toList()),
      minerals: _combineNutrientMaps(meals.map((m) => m.nutrition.minerals).toList()),
    );
  }

  // Combine nutrient maps from multiple meals
  Map<String, double> _combineNutrientMaps(List<Map<String, double>> maps) {
    final combined = <String, double>{};
    for (final map in maps) {
      for (final entry in map.entries) {
        combined[entry.key] = (combined[entry.key] ?? 0.0) + entry.value;
      }
    }
    return combined;
  }

  // Calculate weekly nutrition summary
  NutritionSummary _calculateWeeklyNutrition(
    List<DailyMealPlan> dailyPlans,
    UserNutritionProfile profile,
  ) {
    if (dailyPlans.isEmpty) {
      return NutritionSummary(
        averageCalories: 0, averageProtein: 0, averageCarbs: 0,
        averageFat: 0, averageFiber: 0, targetCalories: profile.dailyCalorieTarget.toDouble(),
        targetMacros: profile.macroTargets,
      );
    }

    final totalDays = dailyPlans.length;
    return NutritionSummary(
      averageCalories: dailyPlans.fold(0.0, (sum, plan) => sum + plan.dailyNutrition.calories) / totalDays,
      averageProtein: dailyPlans.fold(0.0, (sum, plan) => sum + plan.dailyNutrition.protein) / totalDays,
      averageCarbs: dailyPlans.fold(0.0, (sum, plan) => sum + plan.dailyNutrition.carbs) / totalDays,
      averageFat: dailyPlans.fold(0.0, (sum, plan) => sum + plan.dailyNutrition.fat) / totalDays,
      averageFiber: dailyPlans.fold(0.0, (sum, plan) => sum + plan.dailyNutrition.fiber) / totalDays,
      targetCalories: profile.dailyCalorieTarget.toDouble(),
      targetMacros: profile.macroTargets,
    );
  }

  // Calculate variety score for meal selection
  double _calculateVarietyScore(List<Recipe> meals) {
    if (meals.isEmpty) return 0.0;

    // Count unique cuisines
    final uniqueCuisines = meals.map((m) => m.cuisine).toSet().length;
    final cuisineVariety = uniqueCuisines / meals.length;

    // Count unique ingredients
    final allIngredients = meals.expand((m) => m.ingredients.map((i) => i.name)).toList();
    final uniqueIngredients = allIngredients.toSet().length;
    final ingredientVariety = uniqueIngredients / allIngredients.length;

    // Count cooking methods variety (based on prep/cook time)
    final cookingMethods = meals.map((m) => m.cookTimeMinutes > 0 ? 'cooked' : 'raw').toSet().length;
    final methodVariety = cookingMethods / 2; // Max 2 methods

    return (cuisineVariety * 0.4 + ingredientVariety * 0.4 + methodVariety * 0.2).clamp(0.0, 1.0);
  }

  // Generate unique ID
  String _generateId() {
    return 'meal_plan_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
  }

  // Update user preferences based on feedback
  Future<void> updateUserPreferences(
    String userId,
    MealFeedback feedback,
  ) async {
    // This would typically update the user's preference scores in a database
    // For now, we'll just log the feedback
    print('Updating preferences for user $userId based on feedback for recipe ${feedback.recipeId}');
    
    // In a real implementation, you would:
    // 1. Get the recipe details
    // 2. Update ingredient preferences based on rating
    // 3. Update cuisine preferences
    // 4. Adjust difficulty tolerance
    // 5. Learn from substitutions made
  }

  // Get meal suggestions based on available ingredients
  Future<List<Recipe>> suggestMealsWithIngredients(
    List<String> availableIngredients,
    UserNutritionProfile profile,
  ) async {
    final allRecipes = await _database.searchRecipes(
      excludeAllergens: profile.allergies,
      maxPrepTime: profile.maxPrepTime,
    );

    // Score recipes by ingredient availability
    final scoredRecipes = allRecipes.map((recipe) {
      final recipeIngredients = recipe.ingredients.map((i) => i.name.toLowerCase()).toSet();
      final availableSet = availableIngredients.map((i) => i.toLowerCase()).toSet();
      final matchCount = recipeIngredients.intersection(availableSet).length;
      final matchRatio = matchCount / recipeIngredients.length;
      
      return MapEntry(recipe, matchRatio);
    }).where((entry) => entry.value > 0.5).toList(); // At least 50% ingredients available

    scoredRecipes.sort((a, b) => b.value.compareTo(a.value));
    return scoredRecipes.take(10).map((entry) => entry.key).toList();
  }
}