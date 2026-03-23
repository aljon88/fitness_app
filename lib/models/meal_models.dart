// Core meal planning data models
class Recipe {
  final String id;
  final String title;
  final String description;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final NutritionInfo nutrition;
  final List<String> dietaryTags;
  final List<String> allergens;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final String? imageUrl;
  final double rating;
  final String mealType; // breakfast, lunch, dinner, snack
  final double estimatedCost;
  final String dataSource;
  final DateTime lastUpdated;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.nutrition,
    required this.dietaryTags,
    required this.allergens,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    this.imageUrl,
    required this.rating,
    required this.mealType,
    required this.estimatedCost,
    required this.dataSource,
    required this.lastUpdated,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList(),
      instructions: List<String>.from(json['instructions']),
      nutrition: NutritionInfo.fromJson(json['nutrition']),
      dietaryTags: List<String>.from(json['dietaryTags']),
      allergens: List<String>.from(json['allergens']),
      prepTimeMinutes: json['prepTimeMinutes'],
      cookTimeMinutes: json['cookTimeMinutes'],
      servings: json['servings'],
      difficulty: json['difficulty'],
      cuisine: json['cuisine'],
      imageUrl: json['imageUrl'],
      rating: json['rating'].toDouble(),
      mealType: json['mealType'],
      estimatedCost: json['estimatedCost'].toDouble(),
      dataSource: json['dataSource'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions,
      'nutrition': nutrition.toJson(),
      'dietaryTags': dietaryTags,
      'allergens': allergens,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'cuisine': cuisine,
      'imageUrl': imageUrl,
      'rating': rating,
      'mealType': mealType,
      'estimatedCost': estimatedCost,
      'dataSource': dataSource,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  bool matchesDietaryRestrictions(List<String> restrictions) {
    return restrictions.every((restriction) => dietaryTags.contains(restriction));
  }

  bool containsAllergens(List<String> userAllergens) {
    return allergens.any((allergen) => userAllergens.contains(allergen));
  }

  bool hasSeasonalIngredients() {
    final currentMonth = DateTime.now().month;
    return ingredients.any((ingredient) => 
        ingredient.isSeasonalForMonth(currentMonth));
  }
}

class Ingredient {
  final String name;
  final double amount;
  final String unit;
  final String? substitute;
  final bool isOptional;
  final double caloriesPerUnit;
  final List<int> seasonalMonths; // Months when ingredient is in season

  Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.substitute,
    required this.isOptional,
    required this.caloriesPerUnit,
    required this.seasonalMonths,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      amount: json['amount'].toDouble(),
      unit: json['unit'],
      substitute: json['substitute'],
      isOptional: json['isOptional'],
      caloriesPerUnit: json['caloriesPerUnit'].toDouble(),
      seasonalMonths: List<int>.from(json['seasonalMonths'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'substitute': substitute,
      'isOptional': isOptional,
      'caloriesPerUnit': caloriesPerUnit,
      'seasonalMonths': seasonalMonths,
    };
  }

  bool isSeasonalForMonth(int month) {
    return seasonalMonths.isEmpty || seasonalMonths.contains(month);
  }
}

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final Map<String, double> vitamins;
  final Map<String, double> minerals;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.vitamins,
    required this.minerals,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber'].toDouble(),
      sugar: json['sugar'].toDouble(),
      sodium: json['sodium'].toDouble(),
      vitamins: Map<String, double>.from(json['vitamins'] ?? {}),
      minerals: Map<String, double>.from(json['minerals'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'vitamins': vitamins,
      'minerals': minerals,
    };
  }

  double get totalMacros => protein + carbs + fat;
  double get proteinPercentage => (protein * 4) / calories * 100;
  double get carbsPercentage => (carbs * 4) / calories * 100;
  double get fatPercentage => (fat * 9) / calories * 100;
}

class UserNutritionProfile {
  final String userId;
  final String fitnessGoal; // weight_loss, muscle_gain, maintenance
  final List<String> allergies;
  final List<String> dietaryRestrictions;
  final List<String> dislikedFoods;
  final List<String> preferredCuisines;
  final int dailyCalorieTarget;
  final Map<String, double> macroTargets;
  final double weeklyBudget;
  final String cookingSkillLevel; // beginner, intermediate, advanced
  final int maxPrepTime; // maximum prep time in minutes
  final Map<String, double> ingredientPreferences; // learned preferences
  final Map<String, double> cuisineAffinities; // learned affinities

  UserNutritionProfile({
    required this.userId,
    required this.fitnessGoal,
    required this.allergies,
    required this.dietaryRestrictions,
    required this.dislikedFoods,
    required this.preferredCuisines,
    required this.dailyCalorieTarget,
    required this.macroTargets,
    required this.weeklyBudget,
    required this.cookingSkillLevel,
    required this.maxPrepTime,
    required this.ingredientPreferences,
    required this.cuisineAffinities,
  });

  factory UserNutritionProfile.fromJson(Map<String, dynamic> json) {
    return UserNutritionProfile(
      userId: json['userId'],
      fitnessGoal: json['fitnessGoal'],
      allergies: List<String>.from(json['allergies']),
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions']),
      dislikedFoods: List<String>.from(json['dislikedFoods']),
      preferredCuisines: List<String>.from(json['preferredCuisines']),
      dailyCalorieTarget: json['dailyCalorieTarget'],
      macroTargets: Map<String, double>.from(json['macroTargets']),
      weeklyBudget: json['weeklyBudget'].toDouble(),
      cookingSkillLevel: json['cookingSkillLevel'],
      maxPrepTime: json['maxPrepTime'],
      ingredientPreferences: Map<String, double>.from(json['ingredientPreferences'] ?? {}),
      cuisineAffinities: Map<String, double>.from(json['cuisineAffinities'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fitnessGoal': fitnessGoal,
      'allergies': allergies,
      'dietaryRestrictions': dietaryRestrictions,
      'dislikedFoods': dislikedFoods,
      'preferredCuisines': preferredCuisines,
      'dailyCalorieTarget': dailyCalorieTarget,
      'macroTargets': macroTargets,
      'weeklyBudget': weeklyBudget,
      'cookingSkillLevel': cookingSkillLevel,
      'maxPrepTime': maxPrepTime,
      'ingredientPreferences': ingredientPreferences,
      'cuisineAffinities': cuisineAffinities,
    };
  }
}

class WeeklyMealPlan {
  final String id;
  final String userId;
  final DateTime startDate;
  final List<DailyMealPlan> dailyPlans;
  final NutritionSummary weeklyNutrition;
  final double totalEstimatedCost;
  final double varietyScore;
  final DateTime createdAt;

  WeeklyMealPlan({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.dailyPlans,
    required this.weeklyNutrition,
    required this.totalEstimatedCost,
    required this.varietyScore,
    required this.createdAt,
  });

  factory WeeklyMealPlan.fromJson(Map<String, dynamic> json) {
    return WeeklyMealPlan(
      id: json['id'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      dailyPlans: (json['dailyPlans'] as List)
          .map((d) => DailyMealPlan.fromJson(d))
          .toList(),
      weeklyNutrition: NutritionSummary.fromJson(json['weeklyNutrition']),
      totalEstimatedCost: json['totalEstimatedCost'].toDouble(),
      varietyScore: json['varietyScore'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'dailyPlans': dailyPlans.map((d) => d.toJson()).toList(),
      'weeklyNutrition': weeklyNutrition.toJson(),
      'totalEstimatedCost': totalEstimatedCost,
      'varietyScore': varietyScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class DailyMealPlan {
  final DateTime date;
  final Recipe? breakfast;
  final Recipe? lunch;
  final Recipe? dinner;
  final List<Recipe> snacks;
  final NutritionInfo dailyNutrition;
  final double dailyCost;

  DailyMealPlan({
    required this.date,
    this.breakfast,
    this.lunch,
    this.dinner,
    required this.snacks,
    required this.dailyNutrition,
    required this.dailyCost,
  });

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      date: DateTime.parse(json['date']),
      breakfast: json['breakfast'] != null ? Recipe.fromJson(json['breakfast']) : null,
      lunch: json['lunch'] != null ? Recipe.fromJson(json['lunch']) : null,
      dinner: json['dinner'] != null ? Recipe.fromJson(json['dinner']) : null,
      snacks: (json['snacks'] as List)
          .map((s) => Recipe.fromJson(s))
          .toList(),
      dailyNutrition: NutritionInfo.fromJson(json['dailyNutrition']),
      dailyCost: json['dailyCost'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'breakfast': breakfast?.toJson(),
      'lunch': lunch?.toJson(),
      'dinner': dinner?.toJson(),
      'snacks': snacks.map((s) => s.toJson()).toList(),
      'dailyNutrition': dailyNutrition.toJson(),
      'dailyCost': dailyCost,
    };
  }

  List<Recipe> get allMeals {
    List<Recipe> meals = [];
    if (breakfast != null) meals.add(breakfast!);
    if (lunch != null) meals.add(lunch!);
    if (dinner != null) meals.add(dinner!);
    meals.addAll(snacks);
    return meals;
  }
}

class NutritionSummary {
  final double averageCalories;
  final double averageProtein;
  final double averageCarbs;
  final double averageFat;
  final double averageFiber;
  final double targetCalories;
  final Map<String, double> targetMacros;

  NutritionSummary({
    required this.averageCalories,
    required this.averageProtein,
    required this.averageCarbs,
    required this.averageFat,
    required this.averageFiber,
    required this.targetCalories,
    required this.targetMacros,
  });

  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    return NutritionSummary(
      averageCalories: json['averageCalories'].toDouble(),
      averageProtein: json['averageProtein'].toDouble(),
      averageCarbs: json['averageCarbs'].toDouble(),
      averageFat: json['averageFat'].toDouble(),
      averageFiber: json['averageFiber'].toDouble(),
      targetCalories: json['targetCalories'].toDouble(),
      targetMacros: Map<String, double>.from(json['targetMacros']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageCalories': averageCalories,
      'averageProtein': averageProtein,
      'averageCarbs': averageCarbs,
      'averageFat': averageFat,
      'averageFiber': averageFiber,
      'targetCalories': targetCalories,
      'targetMacros': targetMacros,
    };
  }

  double get calorieAccuracy => (averageCalories / targetCalories).clamp(0.0, 2.0);
  double get proteinAccuracy => (averageProtein / targetMacros['protein']!).clamp(0.0, 2.0);
  double get carbsAccuracy => (averageCarbs / targetMacros['carbs']!).clamp(0.0, 2.0);
  double get fatAccuracy => (averageFat / targetMacros['fat']!).clamp(0.0, 2.0);
}

class MealFeedback {
  final String userId;
  final String recipeId;
  final DateTime date;
  final bool completed;
  final int? rating; // 1-5 stars
  final String? notes;
  final List<String>? substitutions;
  final int? actualPrepTime;

  MealFeedback({
    required this.userId,
    required this.recipeId,
    required this.date,
    required this.completed,
    this.rating,
    this.notes,
    this.substitutions,
    this.actualPrepTime,
  });

  factory MealFeedback.fromJson(Map<String, dynamic> json) {
    return MealFeedback(
      userId: json['userId'],
      recipeId: json['recipeId'],
      date: DateTime.parse(json['date']),
      completed: json['completed'],
      rating: json['rating'],
      notes: json['notes'],
      substitutions: json['substitutions'] != null 
          ? List<String>.from(json['substitutions']) 
          : null,
      actualPrepTime: json['actualPrepTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'date': date.toIso8601String(),
      'completed': completed,
      'rating': rating,
      'notes': notes,
      'substitutions': substitutions,
      'actualPrepTime': actualPrepTime,
    };
  }
}