import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/meal_plan.dart';

class MealDatabase {
  static Map<String, Map<String, Map<String, List<Meal>>>> _mealCache = {};
  static bool _isInitialized = false;

  /// Initialize meal database by loading all JSON files
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Load all 15 meal plan files
    final goals = ['weight_loss', 'muscle_gain', 'strength', 'flexibility', 'general_fitness'];
    final levels = ['beginner', 'intermediate', 'advanced'];
    
    for (final goal in goals) {
      _mealCache[goal] = {};
      for (final level in levels) {
        try {
          final jsonString = await rootBundle.loadString('assets/data/meals/${goal}_$level.json');
          final jsonData = json.decode(jsonString);
          
          _mealCache[goal]![level] = {
            'breakfast': (jsonData['breakfastOptions'] as List).map((m) => Meal.fromJson(m)).toList(),
            'lunch': (jsonData['lunchOptions'] as List).map((m) => Meal.fromJson(m)).toList(),
            'dinner': (jsonData['dinnerOptions'] as List).map((m) => Meal.fromJson(m)).toList(),
            'snack': (jsonData['snackOptions'] as List).map((m) => Meal.fromJson(m)).toList(),
          };
        } catch (e) {
          print('Error loading meal data for $goal $level: $e');
        }
      }
    }
    
    _isInitialized = true;
  }

  /// Get breakfast options filtered by goal, fitness level, and allergies
  static List<Meal> getBreakfastOptions(String goal, String fitnessLevel, List<String> userAllergies) {
    final goalKey = normalizeGoal(goal);
    final levelKey = fitnessLevel.toLowerCase();
    
    if (!_mealCache.containsKey(goalKey) || !_mealCache[goalKey]!.containsKey(levelKey)) {
      return [];
    }
    
    final allMeals = _mealCache[goalKey]![levelKey]!['breakfast'] ?? [];
    return _filterByAllergies(allMeals, userAllergies);
  }

  /// Get lunch options filtered by goal, fitness level, and allergies
  static List<Meal> getLunchOptions(String goal, String fitnessLevel, List<String> userAllergies) {
    final goalKey = normalizeGoal(goal);
    final levelKey = fitnessLevel.toLowerCase();
    
    if (!_mealCache.containsKey(goalKey) || !_mealCache[goalKey]!.containsKey(levelKey)) {
      return [];
    }
    
    final allMeals = _mealCache[goalKey]![levelKey]!['lunch'] ?? [];
    return _filterByAllergies(allMeals, userAllergies);
  }

  /// Get dinner options filtered by goal, fitness level, and allergies
  static List<Meal> getDinnerOptions(String goal, String fitnessLevel, List<String> userAllergies) {
    final goalKey = normalizeGoal(goal);
    final levelKey = fitnessLevel.toLowerCase();
    
    if (!_mealCache.containsKey(goalKey) || !_mealCache[goalKey]!.containsKey(levelKey)) {
      return [];
    }
    
    final allMeals = _mealCache[goalKey]![levelKey]!['dinner'] ?? [];
    return _filterByAllergies(allMeals, userAllergies);
  }

  /// Get snack options filtered by goal, fitness level, and allergies
  static List<Meal> getSnackOptions(String goal, String fitnessLevel, List<String> userAllergies) {
    final goalKey = normalizeGoal(goal);
    final levelKey = fitnessLevel.toLowerCase();
    
    if (!_mealCache.containsKey(goalKey) || !_mealCache[goalKey]!.containsKey(levelKey)) {
      return [];
    }
    
    final allMeals = _mealCache[goalKey]![levelKey]!['snack'] ?? [];
    return _filterByAllergies(allMeals, userAllergies);
  }

  /// Filter meals by removing those containing user's allergens
  static List<Meal> _filterByAllergies(List<Meal> meals, List<String> userAllergies) {
    if (userAllergies.isEmpty) return meals;
    return meals.where((meal) => meal.isSafeFor(userAllergies)).toList();
  }

  /// Normalize goal from UI format to file format (PUBLIC for use by MealPlanGenerator)
  /// "Weight Loss" -> "weight_loss", "Muscle Gain" -> "muscle_gain", etc.
  static String normalizeGoal(String goal) {
    final goalMap = {
      'Weight Loss': 'weight_loss',
      'Muscle Gain': 'muscle_gain',
      'Strength': 'strength',
      'Flexibility': 'flexibility',
      'Healthy Lifestyle': 'general_fitness',
    };
    return goalMap[goal] ?? goal.toLowerCase().replaceAll(' ', '_');
  }

  // ==================== DEPRECATED: OLD HARDCODED MEALS ====================
  // Keeping for backward compatibility during migration
  
  static List<Meal> beginnerBreakfast = [
    Meal(
      name: 'Oatmeal with Banana & Almonds',
      description: 'Hearty oats topped with fresh banana and crunchy almonds',
      calories: 380,
      protein: 12,
      carbs: 62,
      fats: 10,
      ingredients: ['1 cup oats', '1 banana', '10 almonds', '1 tbsp honey', 'Cinnamon'],
      prepTime: 10,
      mealType: 'breakfast',
    ),
    Meal(
      name: 'Scrambled Eggs & Whole Wheat Toast',
      description: 'Protein-packed eggs with fiber-rich toast',
      calories: 400,
      protein: 22,
      carbs: 38,
      fats: 16,
      ingredients: ['3 eggs', '2 slices whole wheat bread', '1 tbsp butter', '1 tomato', 'Salt & pepper'],
      prepTime: 15,
      mealType: 'breakfast',
    ),
    Meal(
      name: 'Greek Yogurt Parfait',
      description: 'Creamy yogurt layered with granola and berries',
      calories: 350,
      protein: 20,
      carbs: 50,
      fats: 8,
      ingredients: ['1 cup Greek yogurt', '1/2 cup granola', '1 cup mixed berries', '1 tbsp honey'],
      prepTime: 5,
      mealType: 'breakfast',
    ),
  ];

  static List<Meal> beginnerLunch = [
    Meal(
      name: 'Grilled Chicken Rice Bowl',
      description: 'Lean chicken breast with brown rice and steamed vegetables',
      calories: 550,
      protein: 40,
      carbs: 65,
      fats: 12,
      ingredients: ['150g chicken breast', '1 cup brown rice', '1 cup mixed vegetables', '1 tbsp olive oil', 'Soy sauce'],
      prepTime: 25,
      mealType: 'lunch',
    ),
    Meal(
      name: 'Tuna Sandwich with Salad',
      description: 'Protein-rich tuna on whole grain bread with fresh salad',
      calories: 500,
      protein: 35,
      carbs: 55,
      fats: 14,
      ingredients: ['1 can tuna', '2 slices whole grain bread', 'Lettuce', 'Tomato', 'Cucumber', 'Light mayo'],
      prepTime: 10,
      mealType: 'lunch',
    ),
    Meal(
      name: 'Vegetable Stir-Fry with Tofu',
      description: 'Colorful veggies and tofu in savory sauce',
      calories: 480,
      protein: 25,
      carbs: 60,
      fats: 15,
      ingredients: ['200g tofu', 'Mixed vegetables', '1 cup rice', 'Soy sauce', 'Garlic', 'Ginger'],
      prepTime: 20,
      mealType: 'lunch',
    ),
  ];

  static List<Meal> beginnerDinner = [
    Meal(
      name: 'Baked Salmon with Sweet Potato',
      description: 'Omega-3 rich salmon with roasted sweet potato and broccoli',
      calories: 520,
      protein: 42,
      carbs: 48,
      fats: 18,
      ingredients: ['150g salmon fillet', '1 medium sweet potato', '1 cup broccoli', 'Lemon', 'Olive oil'],
      prepTime: 30,
      mealType: 'dinner',
    ),
    Meal(
      name: 'Turkey Meatballs with Pasta',
      description: 'Lean turkey meatballs in tomato sauce with whole wheat pasta',
      calories: 540,
      protein: 38,
      carbs: 62,
      fats: 14,
      ingredients: ['150g ground turkey', '1 cup whole wheat pasta', 'Tomato sauce', 'Garlic', 'Herbs'],
      prepTime: 35,
      mealType: 'dinner',
    ),
    Meal(
      name: 'Chicken Breast with Quinoa',
      description: 'Grilled chicken with protein-rich quinoa and green beans',
      calories: 500,
      protein: 45,
      carbs: 50,
      fats: 12,
      ingredients: ['150g chicken breast', '1 cup quinoa', '1 cup green beans', 'Olive oil', 'Herbs'],
      prepTime: 25,
      mealType: 'dinner',
    ),
  ];

  static List<Meal> beginnerSnacks = [
    Meal(
      name: 'Apple with Peanut Butter',
      description: 'Crisp apple slices with natural peanut butter',
      calories: 200,
      protein: 8,
      carbs: 28,
      fats: 8,
      ingredients: ['1 apple', '2 tbsp peanut butter'],
      prepTime: 2,
      mealType: 'snack',
    ),
    Meal(
      name: 'Protein Smoothie',
      description: 'Refreshing blend of banana, berries, and protein',
      calories: 250,
      protein: 20,
      carbs: 35,
      fats: 4,
      ingredients: ['1 scoop protein powder', '1 banana', '1/2 cup berries', '1 cup almond milk'],
      prepTime: 5,
      mealType: 'snack',
    ),
    Meal(
      name: 'Mixed Nuts & Dried Fruit',
      description: 'Energy-boosting trail mix',
      calories: 220,
      protein: 6,
      carbs: 24,
      fats: 12,
      ingredients: ['1/4 cup mixed nuts', '2 tbsp dried cranberries', '2 tbsp raisins'],
      prepTime: 1,
      mealType: 'snack',
    ),
  ];

  // ==================== INTERMEDIATE MEALS (2300 calories/day) ====================
  
  static List<Meal> intermediateBreakfast = [
    Meal(
      name: 'Protein Pancakes with Berries',
      description: 'High-protein pancakes topped with fresh berries and Greek yogurt',
      calories: 480,
      protein: 30,
      carbs: 60,
      fats: 12,
      ingredients: ['1 cup oats', '2 eggs', '1 scoop protein powder', '1 cup berries', '2 tbsp Greek yogurt'],
      prepTime: 15,
      mealType: 'breakfast',
    ),
    Meal(
      name: 'Egg White Omelet with Avocado',
      description: 'Fluffy egg white omelet with creamy avocado and vegetables',
      calories: 450,
      protein: 28,
      carbs: 42,
      fats: 18,
      ingredients: ['5 egg whites', '1/2 avocado', 'Spinach', 'Mushrooms', '2 slices whole grain toast'],
      prepTime: 12,
      mealType: 'breakfast',
    ),
    Meal(
      name: 'Breakfast Burrito',
      description: 'Protein-packed burrito with eggs, beans, and cheese',
      calories: 500,
      protein: 32,
      carbs: 55,
      fats: 16,
      ingredients: ['3 eggs', '1/2 cup black beans', '1 whole wheat tortilla', '1/4 cup cheese', 'Salsa'],
      prepTime: 10,
      mealType: 'breakfast',
    ),
  ];

  static List<Meal> intermediateLunch = [
    Meal(
      name: 'Chicken & Quinoa Power Bowl',
      description: 'Grilled chicken with quinoa, avocado, and roasted vegetables',
      calories: 650,
      protein: 48,
      carbs: 68,
      fats: 18,
      ingredients: ['180g chicken breast', '1.5 cups quinoa', '1/2 avocado', 'Mixed vegetables', 'Olive oil'],
      prepTime: 30,
      mealType: 'lunch',
    ),
    Meal(
      name: 'Beef Stir-Fry with Brown Rice',
      description: 'Lean beef strips with colorful vegetables and brown rice',
      calories: 620,
      protein: 45,
      carbs: 70,
      fats: 16,
      ingredients: ['150g lean beef', '1.5 cups brown rice', 'Bell peppers', 'Broccoli', 'Soy sauce'],
      prepTime: 25,
      mealType: 'lunch',
    ),
    Meal(
      name: 'Salmon Poke Bowl',
      description: 'Fresh salmon with rice, edamame, and Asian-inspired toppings',
      calories: 640,
      protein: 42,
      carbs: 72,
      fats: 20,
      ingredients: ['150g salmon', '1.5 cups rice', '1/2 cup edamame', 'Cucumber', 'Seaweed', 'Sesame seeds'],
      prepTime: 20,
      mealType: 'lunch',
    ),
  ];

  static List<Meal> intermediateDinner = [
    Meal(
      name: 'Grilled Steak with Baked Potato',
      description: 'Juicy steak with loaded baked potato and asparagus',
      calories: 680,
      protein: 52,
      carbs: 65,
      fats: 22,
      ingredients: ['180g sirloin steak', '1 large potato', '1 cup asparagus', 'Sour cream', 'Butter'],
      prepTime: 35,
      mealType: 'dinner',
    ),
    Meal(
      name: 'Chicken Pasta Primavera',
      description: 'Grilled chicken with whole wheat pasta and garden vegetables',
      calories: 650,
      protein: 48,
      carbs: 75,
      fats: 18,
      ingredients: ['180g chicken', '1.5 cups pasta', 'Mixed vegetables', 'Olive oil', 'Parmesan'],
      prepTime: 30,
      mealType: 'dinner',
    ),
    Meal(
      name: 'Turkey Chili with Cornbread',
      description: 'Hearty turkey chili with a side of cornbread',
      calories: 620,
      protein: 45,
      carbs: 68,
      fats: 16,
      ingredients: ['180g ground turkey', 'Kidney beans', 'Tomatoes', 'Spices', '1 piece cornbread'],
      prepTime: 40,
      mealType: 'dinner',
    ),
  ];

  static List<Meal> intermediateSnacks = [
    Meal(
      name: 'Protein Bar & Banana',
      description: 'Convenient protein bar with fresh banana',
      calories: 280,
      protein: 20,
      carbs: 38,
      fats: 6,
      ingredients: ['1 protein bar', '1 banana'],
      prepTime: 1,
      mealType: 'snack',
    ),
    Meal(
      name: 'Cottage Cheese with Fruit',
      description: 'High-protein cottage cheese with pineapple',
      calories: 250,
      protein: 24,
      carbs: 30,
      fats: 4,
      ingredients: ['1 cup cottage cheese', '1 cup pineapple chunks'],
      prepTime: 2,
      mealType: 'snack',
    ),
    Meal(
      name: 'Turkey Roll-Ups',
      description: 'Deli turkey wrapped with cheese and veggies',
      calories: 220,
      protein: 22,
      carbs: 12,
      fats: 10,
      ingredients: ['4 slices turkey breast', '2 cheese sticks', 'Lettuce', 'Mustard'],
      prepTime: 5,
      mealType: 'snack',
    ),
  ];

  // ==================== ADVANCED MEALS (2500 calories/day) ====================
  
  static List<Meal> advancedBreakfast = [
    Meal(
      name: 'Muscle-Building Breakfast Bowl',
      description: 'Eggs, turkey sausage, sweet potato hash, and avocado',
      calories: 620,
      protein: 42,
      carbs: 58,
      fats: 24,
      ingredients: ['4 eggs', '2 turkey sausages', '1 sweet potato', '1/2 avocado', 'Peppers', 'Onions'],
      prepTime: 20,
      mealType: 'breakfast',
    ),
    Meal(
      name: 'High-Protein French Toast',
      description: 'Protein-enriched French toast with berries and nut butter',
      calories: 580,
      protein: 38,
      carbs: 68,
      fats: 18,
      ingredients: ['3 slices bread', '3 eggs', '1 scoop protein powder', '1 cup berries', '2 tbsp almond butter'],
      prepTime: 15,
      mealType: 'breakfast',
    ),
    Meal(
      name: 'Steak & Eggs with Hash Browns',
      description: 'Classic bodybuilder breakfast with lean steak and eggs',
      calories: 640,
      protein: 48,
      carbs: 52,
      fats: 26,
      ingredients: ['150g lean steak', '3 eggs', '1 cup hash browns', 'Vegetables'],
      prepTime: 25,
      mealType: 'breakfast',
    ),
  ];

  static List<Meal> advancedLunch = [
    Meal(
      name: 'Double Chicken Rice Bowl',
      description: 'Extra chicken with jasmine rice and stir-fried vegetables',
      calories: 750,
      protein: 62,
      carbs: 85,
      fats: 16,
      ingredients: ['250g chicken breast', '2 cups jasmine rice', 'Mixed vegetables', 'Teriyaki sauce'],
      prepTime: 30,
      mealType: 'lunch',
    ),
    Meal(
      name: 'Beef & Sweet Potato Power Meal',
      description: 'Lean ground beef with sweet potatoes and green beans',
      calories: 720,
      protein: 58,
      carbs: 78,
      fats: 20,
      ingredients: ['200g lean ground beef', '2 sweet potatoes', '1.5 cups green beans', 'Olive oil'],
      prepTime: 35,
      mealType: 'lunch',
    ),
    Meal(
      name: 'Tuna Pasta with Vegetables',
      description: 'High-protein tuna pasta with extra vegetables',
      calories: 700,
      protein: 52,
      carbs: 88,
      fats: 14,
      ingredients: ['2 cans tuna', '2 cups pasta', 'Broccoli', 'Tomatoes', 'Olive oil', 'Garlic'],
      prepTime: 20,
      mealType: 'lunch',
    ),
  ];

  static List<Meal> advancedDinner = [
    Meal(
      name: 'Grilled Salmon with Quinoa & Asparagus',
      description: 'Large salmon portion with quinoa and roasted asparagus',
      calories: 780,
      protein: 58,
      carbs: 72,
      fats: 28,
      ingredients: ['200g salmon', '2 cups quinoa', '1.5 cups asparagus', 'Lemon', 'Olive oil'],
      prepTime: 30,
      mealType: 'dinner',
    ),
    Meal(
      name: 'Chicken Fajita Bowl',
      description: 'Seasoned chicken with rice, beans, and all the toppings',
      calories: 760,
      protein: 62,
      carbs: 82,
      fats: 20,
      ingredients: ['220g chicken', '1.5 cups rice', '1 cup black beans', 'Peppers', 'Onions', 'Guacamole'],
      prepTime: 25,
      mealType: 'dinner',
    ),
    Meal(
      name: 'Beef Stir-Fry with Noodles',
      description: 'Tender beef strips with rice noodles and vegetables',
      calories: 740,
      protein: 56,
      carbs: 80,
      fats: 22,
      ingredients: ['200g beef', '2 cups rice noodles', 'Mixed vegetables', 'Soy sauce', 'Sesame oil'],
      prepTime: 30,
      mealType: 'dinner',
    ),
  ];

  static List<Meal> advancedSnacks = [
    Meal(
      name: 'Mass Gainer Shake',
      description: 'High-calorie protein shake with oats and peanut butter',
      calories: 420,
      protein: 35,
      carbs: 48,
      fats: 12,
      ingredients: ['2 scoops protein powder', '1/2 cup oats', '2 tbsp peanut butter', '1 banana', 'Milk'],
      prepTime: 5,
      mealType: 'snack',
    ),
    Meal(
      name: 'Chicken Breast with Rice Cakes',
      description: 'Lean protein with quick carbs',
      calories: 320,
      protein: 38,
      carbs: 32,
      fats: 4,
      ingredients: ['150g chicken breast', '4 rice cakes', 'Hot sauce'],
      prepTime: 10,
      mealType: 'snack',
    ),
    Meal(
      name: 'Greek Yogurt with Granola & Honey',
      description: 'Protein-rich yogurt with crunchy granola',
      calories: 380,
      protein: 28,
      carbs: 52,
      fats: 8,
      ingredients: ['1.5 cups Greek yogurt', '3/4 cup granola', '2 tbsp honey', 'Berries'],
      prepTime: 3,
      mealType: 'snack',
    ),
  ];
}
