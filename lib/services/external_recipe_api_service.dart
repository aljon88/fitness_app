import 'dart:convert';
import 'dart:math';
import '../models/meal_models.dart';

// Service to integrate with external recipe APIs
class ExternalRecipeAPIService {
  static final ExternalRecipeAPIService _instance = ExternalRecipeAPIService._internal();
  factory ExternalRecipeAPIService() => _instance;
  ExternalRecipeAPIService._internal();

  final Random _random = Random();
  
  // Simulate API calls with mock data for now
  // In production, replace with actual API calls to Spoonacular, Edamam, etc.
  
  Future<List<Recipe>> searchRecipesFromAPI({
    String? query,
    List<String>? dietaryRestrictions,
    List<String>? excludeIngredients,
    String? cuisine,
    int maxResults = 10,
  }) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Return mock recipes that would come from external APIs
    return _generateMockAPIRecipes(
      query: query,
      dietaryRestrictions: dietaryRestrictions,
      cuisine: cuisine,
      count: maxResults,
    );
  }

  Future<Recipe?> getRecipeDetailsFromAPI(String externalId) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 300));
    
    // Return detailed recipe from external API
    return _generateDetailedMockRecipe(externalId);
  }

  Future<List<Recipe>> getPopularRecipesFromAPI({
    String? mealType,
    int limit = 20,
  }) async {
    await Future.delayed(Duration(milliseconds: 400));
    
    return _generateMockAPIRecipes(
      mealType: mealType,
      count: limit,
      popular: true,
    );
  }

  Future<List<Recipe>> getSeasonalRecipesFromAPI({
    int month = 0,
    int limit = 15,
  }) async {
    await Future.delayed(Duration(milliseconds: 350));
    
    final currentMonth = month == 0 ? DateTime.now().month : month;
    return _generateSeasonalMockRecipes(currentMonth, limit);
  }

  Future<List<String>> getIngredientSubstitutions(String ingredient) async {
    await Future.delayed(Duration(milliseconds: 200));
    
    // Mock substitution data
    final substitutions = {
      'butter': ['coconut oil', 'olive oil', 'avocado oil', 'applesauce'],
      'milk': ['almond milk', 'oat milk', 'coconut milk', 'soy milk'],
      'eggs': ['flax eggs', 'chia eggs', 'applesauce', 'banana'],
      'flour': ['almond flour', 'coconut flour', 'oat flour', 'rice flour'],
      'sugar': ['honey', 'maple syrup', 'stevia', 'dates'],
    };
    
    return substitutions[ingredient.toLowerCase()] ?? [];
  }

  Future<NutritionInfo> calculateNutritionFromAPI(List<Ingredient> ingredients) async {
    await Future.delayed(Duration(milliseconds: 250));
    
    // Mock nutrition calculation
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    
    for (final ingredient in ingredients) {
      totalCalories += ingredient.caloriesPerUnit * ingredient.amount;
      // Estimate macros based on ingredient type
      if (_isProteinSource(ingredient.name)) {
        totalProtein += ingredient.amount * 6; // Rough estimate
      }
      if (_isCarbSource(ingredient.name)) {
        totalCarbs += ingredient.amount * 15;
      }
      if (_isFatSource(ingredient.name)) {
        totalFat += ingredient.amount * 8;
      }
    }
    
    return NutritionInfo(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      fiber: totalCarbs * 0.1, // Rough estimate
      sugar: totalCarbs * 0.3,
      sodium: totalCalories * 0.5,
      vitamins: {'C': 10, 'A': 5},
      minerals: {'Iron': 2, 'Calcium': 50},
    );
  }

  // Mock data generation methods
  List<Recipe> _generateMockAPIRecipes({
    String? query,
    List<String>? dietaryRestrictions,
    String? cuisine,
    String? mealType,
    int count = 10,
    bool popular = false,
  }) {
    final recipes = <Recipe>[];
    final cuisines = ['Italian', 'Mexican', 'Asian', 'Mediterranean', 'Indian', 'American'];
    final mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    
    for (int i = 0; i < count; i++) {
      final selectedCuisine = cuisine ?? cuisines[_random.nextInt(cuisines.length)];
      final selectedMealType = mealType ?? mealTypes[_random.nextInt(mealTypes.length)];
      
      recipes.add(Recipe(
        id: 'api_recipe_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: _generateRecipeTitle(selectedCuisine, selectedMealType),
        description: _generateRecipeDescription(selectedCuisine),
        ingredients: _generateMockIngredients(),
        instructions: _generateMockInstructions(),
        nutrition: _generateMockNutrition(),
        dietaryTags: _generateDietaryTags(dietaryRestrictions),
        allergens: _generateAllergens(),
        prepTimeMinutes: 15 + _random.nextInt(45),
        cookTimeMinutes: _random.nextInt(60),
        servings: 2 + _random.nextInt(4),
        difficulty: ['easy', 'medium', 'hard'][_random.nextInt(3)],
        cuisine: selectedCuisine,
        imageUrl: 'https://example.com/recipe_$i.jpg',
        rating: popular ? 4.0 + _random.nextDouble() : 3.0 + _random.nextDouble() * 2,
        mealType: selectedMealType,
        estimatedCost: 3.0 + _random.nextDouble() * 12.0,
        dataSource: 'external_api',
        lastUpdated: DateTime.now(),
      ));
    }
    
    return recipes;
  }

  Recipe _generateDetailedMockRecipe(String id) {
    return Recipe(
      id: id,
      title: 'Detailed API Recipe',
      description: 'A comprehensive recipe with full details from external API',
      ingredients: _generateDetailedIngredients(),
      instructions: _generateDetailedInstructions(),
      nutrition: _generateDetailedNutrition(),
      dietaryTags: ['healthy', 'balanced'],
      allergens: ['gluten'],
      prepTimeMinutes: 25,
      cookTimeMinutes: 35,
      servings: 4,
      difficulty: 'medium',
      cuisine: 'International',
      imageUrl: 'https://example.com/detailed_recipe.jpg',
      rating: 4.5,
      mealType: 'dinner',
      estimatedCost: 8.50,
      dataSource: 'external_api_detailed',
      lastUpdated: DateTime.now(),
    );
  }

  List<Recipe> _generateSeasonalMockRecipes(int month, int count) {
    final seasonalIngredients = _getSeasonalIngredients(month);
    final recipes = <Recipe>[];
    
    for (int i = 0; i < count; i++) {
      final ingredients = _generateSeasonalIngredients(seasonalIngredients);
      
      recipes.add(Recipe(
        id: 'seasonal_api_${month}_$i',
        title: _generateSeasonalRecipeTitle(month),
        description: 'Fresh seasonal recipe featuring ingredients at their peak',
        ingredients: ingredients,
        instructions: _generateMockInstructions(),
        nutrition: _generateMockNutrition(),
        dietaryTags: ['seasonal', 'fresh'],
        allergens: [],
        prepTimeMinutes: 20 + _random.nextInt(30),
        cookTimeMinutes: 15 + _random.nextInt(45),
        servings: 2 + _random.nextInt(3),
        difficulty: ['easy', 'medium'][_random.nextInt(2)],
        cuisine: 'Seasonal',
        rating: 4.2 + _random.nextDouble() * 0.8,
        mealType: ['lunch', 'dinner'][_random.nextInt(2)],
        estimatedCost: 4.0 + _random.nextDouble() * 8.0,
        dataSource: 'seasonal_api',
        lastUpdated: DateTime.now(),
      ));
    }
    
    return recipes;
  }

  // Helper methods for mock data generation
  String _generateRecipeTitle(String cuisine, String mealType) {
    final adjectives = ['Delicious', 'Healthy', 'Quick', 'Easy', 'Gourmet', 'Fresh'];
    final proteins = ['Chicken', 'Salmon', 'Tofu', 'Beef', 'Shrimp', 'Turkey'];
    final preparations = ['Grilled', 'Baked', 'Sautéed', 'Roasted', 'Steamed'];
    
    final adjective = adjectives[_random.nextInt(adjectives.length)];
    final protein = proteins[_random.nextInt(proteins.length)];
    final preparation = preparations[_random.nextInt(preparations.length)];
    
    return '$adjective $preparation $protein ($cuisine Style)';
  }

  String _generateRecipeDescription(String cuisine) {
    return 'A flavorful $cuisine dish that combines traditional techniques with modern nutrition science. Perfect for your fitness goals!';
  }

  List<Ingredient> _generateMockIngredients() {
    final ingredientNames = [
      'chicken breast', 'olive oil', 'garlic', 'onion', 'bell pepper',
      'tomatoes', 'spinach', 'quinoa', 'brown rice', 'broccoli'
    ];
    
    return ingredientNames.take(5 + _random.nextInt(3)).map((name) => 
      Ingredient(
        name: name,
        amount: 0.5 + _random.nextDouble() * 2,
        unit: ['cup', 'tbsp', 'oz', 'piece'][_random.nextInt(4)],
        isOptional: _random.nextBool(),
        caloriesPerUnit: 20 + _random.nextInt(100),
        seasonalMonths: [],
      )
    ).toList();
  }

  List<Ingredient> _generateDetailedIngredients() {
    return [
      Ingredient(name: 'chicken breast', amount: 1.5, unit: 'lbs', isOptional: false, caloriesPerUnit: 185, seasonalMonths: []),
      Ingredient(name: 'olive oil', amount: 2, unit: 'tbsp', isOptional: false, caloriesPerUnit: 120, seasonalMonths: []),
      Ingredient(name: 'garlic cloves', amount: 3, unit: 'pieces', isOptional: false, caloriesPerUnit: 4, seasonalMonths: []),
      Ingredient(name: 'mixed vegetables', amount: 2, unit: 'cups', isOptional: false, caloriesPerUnit: 25, seasonalMonths: []),
      Ingredient(name: 'herbs and spices', amount: 1, unit: 'tsp', isOptional: true, caloriesPerUnit: 1, seasonalMonths: []),
    ];
  }

  List<String> _generateMockInstructions() {
    return [
      'Prepare all ingredients by washing and chopping as needed',
      'Heat oil in a large pan over medium-high heat',
      'Add protein and cook until golden brown',
      'Add vegetables and seasonings, cook until tender',
      'Serve hot and enjoy your nutritious meal'
    ];
  }

  List<String> _generateDetailedInstructions() {
    return [
      'Preheat your oven to 375°F (190°C)',
      'Season the chicken breast with salt, pepper, and your favorite herbs',
      'Heat olive oil in an oven-safe skillet over medium-high heat',
      'Sear the chicken breast for 3-4 minutes on each side until golden',
      'Add minced garlic and cook for 30 seconds until fragrant',
      'Add mixed vegetables around the chicken in the skillet',
      'Transfer the skillet to the preheated oven',
      'Bake for 15-20 minutes until chicken reaches internal temperature of 165°F',
      'Let rest for 5 minutes before slicing and serving'
    ];
  }

  NutritionInfo _generateMockNutrition() {
    return NutritionInfo(
      calories: 300 + _random.nextInt(400),
      protein: 20 + _random.nextInt(30),
      carbs: 15 + _random.nextInt(40),
      fat: 8 + _random.nextInt(20),
      fiber: 3 + _random.nextInt(8),
      sugar: 2 + _random.nextInt(15),
      sodium: 200 + _random.nextInt(600),
      vitamins: {'C': _random.nextInt(50), 'A': _random.nextInt(30)},
      minerals: {'Iron': _random.nextInt(10), 'Calcium': _random.nextInt(200)},
    );
  }

  NutritionInfo _generateDetailedNutrition() {
    return NutritionInfo(
      calories: 425,
      protein: 35,
      carbs: 28,
      fat: 18,
      fiber: 6,
      sugar: 8,
      sodium: 380,
      vitamins: {'C': 45, 'A': 25, 'B6': 0.8, 'K': 15},
      minerals: {'Iron': 4, 'Calcium': 80, 'Potassium': 650, 'Magnesium': 45},
    );
  }

  List<String> _generateDietaryTags(List<String>? restrictions) {
    final allTags = ['healthy', 'high-protein', 'low-carb', 'gluten-free', 'dairy-free', 'vegan', 'vegetarian'];
    final selectedTags = <String>[];
    
    // Add restriction-based tags
    if (restrictions != null) {
      selectedTags.addAll(restrictions);
    }
    
    // Add random tags
    for (int i = 0; i < 2 + _random.nextInt(3); i++) {
      final tag = allTags[_random.nextInt(allTags.length)];
      if (!selectedTags.contains(tag)) {
        selectedTags.add(tag);
      }
    }
    
    return selectedTags;
  }

  List<String> _generateAllergens() {
    final possibleAllergens = ['dairy', 'eggs', 'nuts', 'soy', 'gluten', 'fish'];
    final allergens = <String>[];
    
    for (final allergen in possibleAllergens) {
      if (_random.nextDouble() < 0.3) { // 30% chance of containing each allergen
        allergens.add(allergen);
      }
    }
    
    return allergens;
  }

  List<String> _getSeasonalIngredients(int month) {
    final seasonalMap = {
      1: ['citrus', 'winter squash', 'kale', 'brussels sprouts'], // January
      2: ['citrus', 'winter squash', 'kale', 'brussels sprouts'], // February
      3: ['asparagus', 'artichokes', 'spring onions', 'peas'], // March
      4: ['asparagus', 'artichokes', 'spring onions', 'peas'], // April
      5: ['strawberries', 'asparagus', 'spring greens', 'radishes'], // May
      6: ['berries', 'tomatoes', 'zucchini', 'corn'], // June
      7: ['berries', 'tomatoes', 'zucchini', 'corn'], // July
      8: ['peaches', 'tomatoes', 'bell peppers', 'eggplant'], // August
      9: ['apples', 'pumpkin', 'sweet potatoes', 'squash'], // September
      10: ['apples', 'pumpkin', 'sweet potatoes', 'squash'], // October
      11: ['cranberries', 'winter squash', 'root vegetables'], // November
      12: ['citrus', 'winter squash', 'kale', 'brussels sprouts'], // December
    };
    
    return seasonalMap[month] ?? [];
  }

  List<Ingredient> _generateSeasonalIngredients(List<String> seasonalItems) {
    return seasonalItems.take(3).map((item) => 
      Ingredient(
        name: item,
        amount: 0.5 + _random.nextDouble() * 1.5,
        unit: 'cup',
        isOptional: false,
        caloriesPerUnit: 30 + _random.nextInt(70),
        seasonalMonths: [DateTime.now().month],
      )
    ).toList();
  }

  String _generateSeasonalRecipeTitle(int month) {
    final seasonNames = {
      12: 'Winter', 1: 'Winter', 2: 'Winter',
      3: 'Spring', 4: 'Spring', 5: 'Spring',
      6: 'Summer', 7: 'Summer', 8: 'Summer',
      9: 'Fall', 10: 'Fall', 11: 'Fall',
    };
    
    final season = seasonNames[month] ?? 'Seasonal';
    final dishes = ['Bowl', 'Salad', 'Soup', 'Stir-fry', 'Casserole'];
    final dish = dishes[_random.nextInt(dishes.length)];
    
    return 'Fresh $season $dish';
  }

  bool _isProteinSource(String ingredient) {
    final proteinSources = ['chicken', 'beef', 'fish', 'salmon', 'tofu', 'eggs', 'turkey'];
    return proteinSources.any((source) => ingredient.toLowerCase().contains(source));
  }

  bool _isCarbSource(String ingredient) {
    final carbSources = ['rice', 'quinoa', 'pasta', 'bread', 'potato', 'oats'];
    return carbSources.any((source) => ingredient.toLowerCase().contains(source));
  }

  bool _isFatSource(String ingredient) {
    final fatSources = ['oil', 'butter', 'nuts', 'avocado', 'cheese'];
    return fatSources.any((source) => ingredient.toLowerCase().contains(source));
  }
}