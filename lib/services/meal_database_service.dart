import 'dart:convert';
import 'dart:math';
import '../models/meal_models.dart';

// Core meal database with curated recipes
class MealDatabaseService {
  static final MealDatabaseService _instance = MealDatabaseService._internal();
  factory MealDatabaseService() => _instance;
  MealDatabaseService._internal();

  final List<Recipe> _coreRecipes = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    await _loadCoreRecipes();
    _initialized = true;
  }

  Future<void> _loadCoreRecipes() async {
    // Load curated recipe database
    _coreRecipes.addAll(_getBreakfastRecipes());
    _coreRecipes.addAll(_getLunchRecipes());
    _coreRecipes.addAll(_getDinnerRecipes());
    _coreRecipes.addAll(_getSnackRecipes());
  }

  // Search recipes with filters
  Future<List<Recipe>> searchRecipes({
    String? query,
    List<String>? mealTypes,
    List<String>? cuisines,
    List<String>? dietaryTags,
    List<String>? excludeAllergens,
    int? maxPrepTime,
    String? difficulty,
    double? maxCost,
    int limit = 50,
  }) async {
    await initialize();
    
    var results = _coreRecipes.where((recipe) {
      // Text search
      if (query != null && query.isNotEmpty) {
        final searchText = '${recipe.title} ${recipe.description} ${recipe.ingredients.map((i) => i.name).join(' ')}'.toLowerCase();
        if (!searchText.contains(query.toLowerCase())) return false;
      }
      
      // Meal type filter
      if (mealTypes != null && !mealTypes.contains(recipe.mealType)) return false;
      
      // Cuisine filter
      if (cuisines != null && !cuisines.contains(recipe.cuisine)) return false;
      
      // Dietary tags filter
      if (dietaryTags != null && !recipe.matchesDietaryRestrictions(dietaryTags)) return false;
      
      // Allergen exclusion
      if (excludeAllergens != null && recipe.containsAllergens(excludeAllergens)) return false;
      
      // Prep time filter
      if (maxPrepTime != null && recipe.prepTimeMinutes > maxPrepTime) return false;
      
      // Difficulty filter
      if (difficulty != null && recipe.difficulty != difficulty) return false;
      
      // Cost filter
      if (maxCost != null && recipe.estimatedCost > maxCost) return false;
      
      return true;
    }).toList();
    
    // Limit results
    if (results.length > limit) {
      results = results.take(limit).toList();
    }
    
    return results;
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    await initialize();
    try {
      return _coreRecipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get recipes by meal type
  Future<List<Recipe>> getRecipesByMealType(String mealType) async {
    return await searchRecipes(mealTypes: [mealType]);
  }

  // Get popular recipes
  Future<List<Recipe>> getPopularRecipes({int limit = 20}) async {
    await initialize();
    var popular = _coreRecipes.where((recipe) => recipe.rating >= 4.0).toList();
    popular.sort((a, b) => b.rating.compareTo(a.rating));
    return popular.take(limit).toList();
  }

  // Get seasonal recipes
  Future<List<Recipe>> getSeasonalRecipes({int limit = 30}) async {
    await initialize();
    return _coreRecipes.where((recipe) => recipe.hasSeasonalIngredients()).take(limit).toList();
  }

  // Get all available cuisines
  List<String> getAvailableCuisines() {
    return _coreRecipes.map((recipe) => recipe.cuisine).toSet().toList()..sort();
  }

  // Get all dietary tags
  List<String> getAvailableDietaryTags() {
    return _coreRecipes
        .expand((recipe) => recipe.dietaryTags)
        .toSet()
        .toList()..sort();
  }

  // CURATED RECIPE DATA
  List<Recipe> _getBreakfastRecipes() {
    return [
      Recipe(
        id: 'breakfast_001',
        title: 'Protein Power Smoothie Bowl',
        description: 'High-protein smoothie bowl with berries and nuts',
        ingredients: [
          Ingredient(name: 'Greek yogurt', amount: 1, unit: 'cup', isOptional: false, caloriesPerUnit: 130, seasonalMonths: []),
          Ingredient(name: 'Banana', amount: 1, unit: 'medium', isOptional: false, caloriesPerUnit: 105, seasonalMonths: []),
          Ingredient(name: 'Blueberries', amount: 0.5, unit: 'cup', isOptional: false, caloriesPerUnit: 40, seasonalMonths: [6, 7, 8]),
          Ingredient(name: 'Protein powder', amount: 1, unit: 'scoop', isOptional: false, caloriesPerUnit: 120, seasonalMonths: []),
          Ingredient(name: 'Almonds', amount: 2, unit: 'tbsp', isOptional: true, caloriesPerUnit: 35, seasonalMonths: []),
        ],
        instructions: [
          'Blend Greek yogurt, banana, and protein powder until smooth',
          'Pour into bowl and top with blueberries and almonds',
          'Serve immediately'
        ],
        nutrition: NutritionInfo(
          calories: 430,
          protein: 35,
          carbs: 45,
          fat: 12,
          fiber: 8,
          sugar: 30,
          sodium: 150,
          vitamins: {'C': 15, 'B6': 0.5},
          minerals: {'Calcium': 300, 'Potassium': 600},
        ),
        dietaryTags: ['high-protein', 'gluten-free', 'vegetarian'],
        allergens: ['dairy', 'nuts'],
        prepTimeMinutes: 5,
        cookTimeMinutes: 0,
        servings: 1,
        difficulty: 'easy',
        cuisine: 'American',
        imageUrl: 'https://example.com/smoothie-bowl.jpg',
        rating: 4.5,
        mealType: 'breakfast',
        estimatedCost: 3.50,
        dataSource: 'curated',
        lastUpdated: DateTime.now(),
      ),
      Recipe(
        id: 'breakfast_002',
        title: 'Avocado Toast with Eggs',
        description: 'Whole grain toast topped with avocado and poached eggs',
        ingredients: [
          Ingredient(name: 'Whole grain bread', amount: 2, unit: 'slices', isOptional: false, caloriesPerUnit: 80, seasonalMonths: []),
          Ingredient(name: 'Avocado', amount: 1, unit: 'medium', isOptional: false, caloriesPerUnit: 234, seasonalMonths: []),
          Ingredient(name: 'Eggs', amount: 2, unit: 'large', isOptional: false, caloriesPerUnit: 70, seasonalMonths: []),
          Ingredient(name: 'Lemon juice', amount: 1, unit: 'tsp', isOptional: false, caloriesPerUnit: 1, seasonalMonths: []),
          Ingredient(name: 'Salt', amount: 0.25, unit: 'tsp', isOptional: false, caloriesPerUnit: 0, seasonalMonths: []),
          Ingredient(name: 'Black pepper', amount: 0.125, unit: 'tsp', isOptional: true, caloriesPerUnit: 0, seasonalMonths: []),
        ],
        instructions: [
          'Toast bread slices until golden brown',
          'Mash avocado with lemon juice, salt, and pepper',
          'Poach eggs in simmering water for 3-4 minutes',
          'Spread avocado mixture on toast and top with poached eggs'
        ],
        nutrition: NutritionInfo(
          calories: 474,
          protein: 18,
          carbs: 32,
          fat: 32,
          fiber: 14,
          sugar: 4,
          sodium: 420,
          vitamins: {'K': 26, 'Folate': 163},
          minerals: {'Potassium': 690, 'Magnesium': 58},
        ),
        dietaryTags: ['vegetarian', 'high-fiber'],
        allergens: ['gluten', 'eggs'],
        prepTimeMinutes: 10,
        cookTimeMinutes: 5,
        servings: 1,
        difficulty: 'easy',
        cuisine: 'American',
        rating: 4.7,
        mealType: 'breakfast',
        estimatedCost: 2.75,
        dataSource: 'curated',
        lastUpdated: DateTime.now(),
      ),
      Recipe(
        id: 'breakfast_003',
        title: 'Overnight Oats with Berries',
        description: 'Make-ahead oats with mixed berries and chia seeds',
        ingredients: [
          Ingredient(name: 'Rolled oats', amount: 0.5, unit: 'cup', isOptional: false, caloriesPerUnit: 150, seasonalMonths: []),
          Ingredient(name: 'Almond milk', amount: 0.5, unit: 'cup', isOptional: false, caloriesPerUnit: 20, seasonalMonths: []),
          Ingredient(name: 'Chia seeds', amount: 1, unit: 'tbsp', isOptional: false, caloriesPerUnit: 60, seasonalMonths: []),
          Ingredient(name: 'Mixed berries', amount: 0.5, unit: 'cup', isOptional: false, caloriesPerUnit: 40, seasonalMonths: [6, 7, 8, 9]),
          Ingredient(name: 'Honey', amount: 1, unit: 'tsp', isOptional: true, caloriesPerUnit: 21, seasonalMonths: []),
          Ingredient(name: 'Vanilla extract', amount: 0.25, unit: 'tsp', isOptional: true, caloriesPerUnit: 1, seasonalMonths: []),
        ],
        instructions: [
          'Mix oats, almond milk, chia seeds, honey, and vanilla in a jar',
          'Refrigerate overnight or at least 4 hours',
          'Top with mixed berries before serving',
          'Enjoy cold or at room temperature'
        ],
        nutrition: NutritionInfo(
          calories: 292,
          protein: 8,
          carbs: 52,
          fat: 7,
          fiber: 12,
          sugar: 18,
          sodium: 85,
          vitamins: {'C': 12, 'E': 2},
          minerals: {'Manganese': 1.5, 'Phosphorus': 180},
        ),
        dietaryTags: ['vegan', 'gluten-free', 'high-fiber'],
        allergens: ['nuts'],
        prepTimeMinutes: 5,
        cookTimeMinutes: 0,
        servings: 1,
        difficulty: 'easy',
        cuisine: 'American',
        rating: 4.3,
        mealType: 'breakfast',
        estimatedCost: 2.25,
        dataSource: 'curated',
        lastUpdated: DateTime.now(),
      ),
    ];
  }

  List<Recipe> _getLunchRecipes() {
    return [
      Recipe(
        id: 'lunch_001',
        title: 'Mediterranean Quinoa Bowl',
        description: 'Nutritious quinoa bowl with Mediterranean vegetables and feta',
        ingredients: [
          Ingredient(name: 'Quinoa', amount: 0.75, unit: 'cup', isOptional: false, caloriesPerUnit: 170, seasonalMonths: []),
          Ingredient(name: 'Cherry tomatoes', amount: 1, unit: 'cup', isOptional: false, caloriesPerUnit: 30, seasonalMonths: [6, 7, 8, 9]),
          Ingredient(name: 'Cucumber', amount: 0.5, unit: 'cup', isOptional: false, caloriesPerUnit: 8, seasonalMonths: [6, 7, 8]),
          Ingredient(name: 'Red onion', amount: 0.25, unit: 'cup', isOptional: false, caloriesPerUnit: 16, seasonalMonths: []),
          Ingredient(name: 'Feta cheese', amount: 2, unit: 'oz', isOptional: false, caloriesPerUnit: 75, seasonalMonths: []),
          Ingredient(name: 'Olive oil', amount: 2, unit: 'tbsp', isOptional: false, caloriesPerUnit: 120, seasonalMonths: []),
          Ingredient(name: 'Lemon juice', amount: 1, unit: 'tbsp', isOptional: false, caloriesPerUnit: 4, seasonalMonths: []),
          Ingredient(name: 'Oregano', amount: 1, unit: 'tsp', isOptional: true, caloriesPerUnit: 1, seasonalMonths: []),
        ],
        instructions: [
          'Cook quinoa according to package directions and let cool',
          'Dice tomatoes, cucumber, and red onion',
          'Whisk olive oil, lemon juice, and oregano for dressing',
          'Combine quinoa with vegetables and feta',
          'Drizzle with dressing and toss gently'
        ],
        nutrition: NutritionInfo(
          calories: 520,
          protein: 18,
          carbs: 45,
          fat: 32,
          fiber: 6,
          sugar: 8,
          sodium: 580,
          vitamins: {'C': 25, 'K': 15},
          minerals: {'Iron': 4, 'Magnesium': 120},
        ),
        dietaryTags: ['vegetarian', 'gluten-free', 'mediterranean'],
        allergens: ['dairy'],
        prepTimeMinutes: 15,
        cookTimeMinutes: 15,
        servings: 2,
        difficulty: 'easy',
        cuisine: 'Mediterranean',
        rating: 4.6,
        mealType: 'lunch',
        estimatedCost: 4.50,
        dataSource: 'curated',
        lastUpdated: DateTime.now(),
      ),
      Recipe(
        id: 'lunch_002',
        title: 'Grilled Chicken Caesar Salad',
        description: 'Classic Caesar salad with grilled chicken breast',
        ingredients: [
          Ingredient(name: 'Chicken breast', amount: 6, unit: 'oz', isOptional: false, caloriesPerUnit: 185, seasonalMonths: []),
          Ingredient(name: 'Romaine lettuce', amount: 4, unit: 'cups', isOptional: false, caloriesPerUnit: 8, seasonalMonths: []),
          Ingredient(name: 'Parmesan cheese', amount: 0.25, unit: 'cup', isOptional: false, caloriesPerUnit: 108, seasonalMonths: []),
          Ingredient(name: 'Caesar dressing', amount: 2, unit: 'tbsp', isOptional: false, caloriesPerUnit: 80, seasonalMonths: []),
          Ingredient(name: 'Croutons', amount: 0.25, unit: 'cup', isOptional: true, caloriesPerUnit: 30, seasonalMonths: []),
          Ingredient(name: 'Lemon wedge', amount: 1, unit: 'piece', isOptional: true, caloriesPerUnit: 2, seasonalMonths: []),
        ],
        instructions: [
          'Season chicken breast with salt and pepper',
          'Grill chicken for 6-7 minutes per side until cooked through',
          'Let chicken rest for 5 minutes, then slice',
          'Toss romaine lettuce with Caesar dressing',
          'Top with sliced chicken, Parmesan, and croutons',
          'Serve with lemon wedge'
        ],
        nutrition: NutritionInfo(
          calories: 425,
          protein: 42,
          carbs: 8,
          fat: 24,
          fiber: 3,
          sugar: 3,
          sodium: 720,
          vitamins: {'A': 148, 'C': 8},
          minerals: {'Calcium': 180, 'Iron': 2},
        ),
        dietaryTags: ['high-protein', 'low-carb'],
        allergens: ['dairy', 'gluten'],
        prepTimeMinutes: 10,
        cookTimeMinutes: 15,
        servings: 1,
        difficulty: 'medium',
        cuisine: 'American',
        rating: 4.4,
        mealType: 'lunch',
        estimatedCost: 5.25,
        dataSource: 'curated',
        lastUpdated: DateTime.now(),
      ),
    ];
  }

  List<Recipe> _getDinnerRecipes() {
    return [
      Recipe(
        id: 'dinner_001',
        title: 'Baked Salmon with Roasted Vegetables',
        description: 'Omega-3 rich salmon with colorful roasted vegetables',
        ingredients: [
          Ingredient(name: 'Salmon fillet', amount: 6, unit: 'oz', isOptional: false, caloriesPerUnit: 206, seasonalMonths: []),
          Ingredient(name: 'Broccoli', amount: 1, unit: 'cup', isOptional: false, caloriesPerUnit: 25, seasonalMonths: [10, 11, 12, 1, 2, 3]),
          Ingredient(name: 'Bell peppers', amount: 1, unit: 'cup', isOptional: false, caloriesPerUnit: 30, seasonalMonths: [7, 8, 9]),
          Ingredient(name: 'Sweet potato', amount: 1, unit: 'medium', isOptional: false, caloriesPerUnit: 112, seasonalMonths: [9, 10, 11]),
          Ingredient(name: 'Olive oil', amount: 2, unit: 'tbsp', isOptional: false, caloriesPerUnit: 120, seasonalMonths: []),
          Ingredient(name: 'Garlic', amount: 2, unit: 'cloves', isOptional: false, caloriesPerUnit: 4, seasonalMonths: []),
          Ingredient(name: 'Lemon', amount: 0.5, unit: 'piece', isOptional: false, caloriesPerUnit: 8, seasonalMonths: []),
          Ingredient(name: 'Herbs', amount: 1, unit: 'tsp', isOptional: true, caloriesPerUnit: 1, seasonalMonths: []),
        ],
        instructions: [
          'Preheat oven to 425°F (220°C)',
          'Cut vegetables into uniform pieces',
          'Toss vegetables with olive oil, minced garlic, salt, and pepper',
          'Roast vegetables for 20 minutes',
          'Season salmon with salt, pepper, and herbs',
          'Add salmon to the pan with vegetables',
          'Bake for 12-15 minutes until salmon flakes easily',
          'Serve with lemon wedges'
        ],
        nutrition: NutritionInfo(
          calories: 506,
          protein: 35,
          carbs: 32,
          fat: 28,
          fiber: 8,
          sugar: 12,
          sodium: 320,
          vitamins: {'C': 120, 'A': 184},
          minerals: {'Potassium': 1200, 'Omega-3': 1800},
        ),
        dietaryTags: ['high-protein', 'omega-3', 'gluten-free', 'paleo'],
        allergens: ['fish'],
        prepTimeMinutes: 15,
        cookTimeMinutes: 35,
        servings: 1,
        difficulty: 'medium',
        cuisine: 'American',
        rating: 4.8,
        mealType: 'dinner',
        estimatedCost: 8.50,
        dataSource: 'curated',
        lastUpdated: DateTime.now(),
      ),
      Recipe(
        id: 'dinner_002',
        title: 'Vegetarian Stir-Fry with Tofu',
        description: 'Colorful vegetable stir-fry with crispy tofu and brown rice',
        ingredients: [
          Ingredient(name: 'Extra-firm tofu', amount: 6, unit: 'oz', isOptional: false, caloriesPerUnit: 94, seasonalMonths: []),
          Ingredient(name: 'Brown rice', amount: 0.75, unit: 'cup', isOptional: false, caloriesPerUnit: 170, seasonalMonths: []),
          Ingredient(name: 'Mixed vegetables', amount: 2, unit: 'cups', isOptional: false, caloriesPerUnit: 35, seasonalMonths: []),
          Ingredient(name: 'Soy sauce', amount: 2, unit: 'tbsp', isOptional: false, caloriesPerUnit: 10, seasonalMonths: []),
          Ingredient(name: 'Sesame oil', amount: 1, unit: 'tbsp', isOptional: false, caloriesPerUnit: 120, seasonalMonths: []),
          Ingredient(name: 'Ginger', amount: 1, unit: 'tsp', isOptional: false, caloriesPerUnit: 1, seasonalMonths: []),
          Ingredient(name: 'Garlic', amount: 2, unit: 'cloves', isOptional: false, caloriesPerUnit: 4, seasonalMonths: []),
          Ingredient(name: 'Green onions', amount: 2, unit: 'stalks', isOptional: true, caloriesPerUnit: 5, seasonalMonths: []),
        ],
        instructions: [
          'Cook brown rice according to package directions',
          'Press tofu to remove excess water, then cube',
          'Heat sesame oil in a large pan or wok',
          'Stir-fry tofu until golden brown, remove and set aside',
          'Stir-fry vegetables with garlic and ginger for 3-4 minutes',
          'Add tofu back to pan with soy sauce',
          'Serve over brown rice and garnish with green onions'
        ],
        nutrition: NutritionInfo(
          calories: 434,
          protein: 20,
          carbs: 58,
          fat: 16,
          fiber: 6,
          sugar: 8,
          sodium: 680,
          vitamins: {'C': 45, 'K': 25},
          minerals: {'Iron': 3, 'Calcium': 150},
        ),
        dietaryTags: ['vegetarian', 'vegan', 'high-fiber'],
        allergens: ['soy'],
        prepTimeMinutes: 15,
        cookTimeMinutes: 20,
        servings: 2,
        difficulty: 'medium',
        cuisine: 'Asian',
        rating: 4.2,
        mealType: 'dinner',
        estimatedCost: 4.75,
        dataSource: 'curated',
        lastUpdated: DateTime.now(),
      ),
    ];
  }

  List<Recipe> _getSnackRecipes() {
    return [
      Recipe(
        id: 'snack_001',
        title: 'Apple Slices with Almond Butter',
        description: 'Fresh apple slices with natural almond butter',
        ingredients: [
          Ingredient(name: 'Apple', amount: 1, unit: 'medium', isOptional: false, caloriesPerUnit: 95, seasonalMonths: [9, 10, 11]),
          Ingredient(name: 'Almond butter', amount: 2, unit: 'tbsp', isOptional: false, caloriesPerUnit: 190, seasonalMonths: []),
          Ingredient(name: 'Cinnamon', amount: 0.25, unit: 'tsp', isOptional: true, caloriesPerUnit: 1, seasonalMonths: []),
        ],
        instructions: [
          'Wash and core the apple',
          'Slice apple into wedges',
          'Serve with almond butter for dipping',
          'Sprinkle with cinnamon if desired'
        ],
        nutrition: NutritionInfo(
          calories: 285,
          protein: 7,
          carbs: 25,
          fat: 18,
          fiber: 7,
          sugar: 19,
          sodium: 2,
          vitamins: {'C': 8, 'E': 7},
          minerals: {'Magnesium': 76, 'Potassium': 194},
        ),
        dietaryTags: ['vegan', 'gluten-free', 'high-fiber'],
        allergens: ['nuts'],
        prepTimeMinutes: 3,
        cookTimeMinutes: 0,
        servings: 1,
        difficulty: 'easy',
        cuisine: 'American',
        rating: 4.1,
        mealType: 'snack',
        estimatedCost: 1.50,
        dataSource: 'curated',
        lastUpdated: DateTime.now(),
      ),
    ];
  }
}