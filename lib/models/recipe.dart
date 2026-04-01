class Recipe {
  final String id;
  final String name;
  final String category; // breakfast, lunch, dinner, snack
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final NutritionInfo nutrition;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String? imageUrl;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.ingredients,
    required this.instructions,
    required this.nutrition,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    this.servings = 1,
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList(),
      instructions: List<String>.from(json['instructions']),
      nutrition: NutritionInfo.fromJson(json['nutrition']),
      prepTimeMinutes: json['prepTimeMinutes'] as int,
      cookTimeMinutes: json['cookTimeMinutes'] as int,
      servings: json['servings'] as int? ?? 1,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions,
      'nutrition': nutrition.toJson(),
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'imageUrl': imageUrl,
    };
  }

  bool isAllergyFree(List<String> allergies) {
    for (var ingredient in ingredients) {
      for (var allergen in ingredient.allergens) {
        if (allergies.contains(allergen)) {
          return false;
        }
      }
    }
    return true;
  }
}

class Ingredient {
  final String name;
  final double amount;
  final String unit;
  final List<String> allergens; // dairy, eggs, nuts, fish, wheat

  Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.allergens = const [],
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      allergens: List<String>.from(json['allergens'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'allergens': allergens,
    };
  }
}

class NutritionInfo {
  final int calories;
  final double protein; // grams
  final double carbs; // grams
  final double fats; // grams
  final double fiber; // grams

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber = 0,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
    };
  }
}
