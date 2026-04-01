class MealPlan {
  final String id;
  final String userId;
  final String fitnessLevel;
  final int dailyCalories;
  final MacroNutrients macros;
  final List<DailyMealPlan> weeklyMeals;
  final DateTime createdAt;

  MealPlan({
    required this.id,
    required this.userId,
    required this.fitnessLevel,
    required this.dailyCalories,
    required this.macros,
    required this.weeklyMeals,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fitnessLevel': fitnessLevel,
      'dailyCalories': dailyCalories,
      'macros': macros.toJson(),
      'weeklyMeals': weeklyMeals.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      userId: json['userId'],
      fitnessLevel: json['fitnessLevel'],
      dailyCalories: json['dailyCalories'],
      macros: MacroNutrients.fromJson(json['macros']),
      weeklyMeals: (json['weeklyMeals'] as List)
          .map((m) => DailyMealPlan.fromJson(m))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class DailyMealPlan {
  final int dayNumber;
  final String dayName;
  final Meal breakfast;
  final Meal lunch;
  final Meal dinner;
  final List<Meal> snacks;
  final int totalCalories;

  DailyMealPlan({
    required this.dayNumber,
    required this.dayName,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.totalCalories,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'dayName': dayName,
      'breakfast': breakfast.toJson(),
      'lunch': lunch.toJson(),
      'dinner': dinner.toJson(),
      'snacks': snacks.map((s) => s.toJson()).toList(),
      'totalCalories': totalCalories,
    };
  }

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      dayNumber: json['dayNumber'],
      dayName: json['dayName'],
      breakfast: Meal.fromJson(json['breakfast']),
      lunch: Meal.fromJson(json['lunch']),
      dinner: Meal.fromJson(json['dinner']),
      snacks: (json['snacks'] as List).map((s) => Meal.fromJson(s)).toList(),
      totalCalories: json['totalCalories'],
    );
  }
}

class Meal {
  final String name;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final List<String> ingredients;
  final int prepTime;
  final String mealType;
  final List<String> allergens; // NEW: dairy, eggs, nuts, seafood, gluten

  Meal({
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.ingredients,
    required this.prepTime,
    required this.mealType,
    this.allergens = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'ingredients': ingredients,
      'prepTime': prepTime,
      'mealType': mealType,
      'allergens': allergens,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'],
      description: json['description'],
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fats: json['fats'],
      ingredients: List<String>.from(json['ingredients']),
      prepTime: json['prepTime'],
      mealType: json['mealType'],
      allergens: List<String>.from(json['allergens'] ?? []),
    );
  }
  
  /// Check if meal is safe for user with given allergies
  bool isSafeFor(List<String> userAllergies) {
    if (userAllergies.isEmpty) return true;
    return !allergens.any((allergen) => userAllergies.contains(allergen));
  }
}

class MacroNutrients {
  final int protein;
  final int carbs;
  final int fats;
  final int calories;

  MacroNutrients({
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.calories,
  });

  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'calories': calories,
    };
  }

  factory MacroNutrients.fromJson(Map<String, dynamic> json) {
    return MacroNutrients(
      protein: json['protein'],
      carbs: json['carbs'],
      fats: json['fats'],
      calories: json['calories'],
    );
  }
}
