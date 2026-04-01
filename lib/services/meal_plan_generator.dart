import 'dart:math';
import '../models/meal_plan.dart';
import 'meal_database.dart';
import 'workout_program_loader.dart';

class MealPlanGenerator {
  static final Random _random = Random();
  static final WorkoutProgramLoader _programLoader = WorkoutProgramLoader();

  /// Generate a complete 7-day meal plan based on goal, fitness level, and allergies
  /// Aligned with workout calendar - uses program days instead of calendar days
  /// Reads workout schedule from actual workout program JSON
  static Future<MealPlan> generateMealPlan(
    String goal,
    String fitnessLevel,
    List<String> userAllergies,
    String userId,
    {int startProgramDay = 1, List<bool>? workoutDays}
  ) async {
    // Ensure meal database is initialized
    await MealDatabase.initialize();
    
    // Load workout schedule from actual program if not provided
    if (workoutDays == null) {
      workoutDays = await _getWorkoutScheduleFromProgram(goal, fitnessLevel);
    }
    
    // Generate 7-day meal plan
    List<DailyMealPlan> weeklyMeals = await _generateWeeklyMeals(
      goal,
      fitnessLevel,
      userAllergies,
      startProgramDay,
      workoutDays,
    );
    
    // Calculate average daily calories and macros
    int avgCalories = (weeklyMeals.fold(0, (sum, day) => sum + day.totalCalories) / 7).round();
    MacroNutrients avgMacros = _calculateAverageMacros(weeklyMeals);
    
    return MealPlan(
      id: '${userId}_mealplan_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      fitnessLevel: fitnessLevel,
      dailyCalories: avgCalories,
      macros: avgMacros,
      weeklyMeals: weeklyMeals,
      createdAt: DateTime.now(),
    );
  }

  /// Get workout schedule from actual workout program JSON
  /// Returns 7-day array: true = workout day, false = rest day
  /// Reads from weeklyPattern in program JSON (Monday-Sunday)
  static Future<List<bool>> _getWorkoutScheduleFromProgram(
    String goal,
    String fitnessLevel,
  ) async {
    try {
      // Map goal display name to goal key
      String goalKey = _mapGoalToKey(goal);
      
      // Load the workout program
      Map<String, dynamic> program = await _programLoader.loadProgram(goalKey, fitnessLevel);
      
      // Extract weeklyPattern
      Map<String, dynamic> weeklyPattern = program['weeklyPattern'] ?? {};
      
      // Days in order: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
      List<String> daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
      
      // Build workout schedule array
      List<bool> schedule = [];
      for (String day in daysOfWeek) {
        Map<String, dynamic>? dayWorkout = weeklyPattern[day];
        bool isWorkoutDay = dayWorkout != null && dayWorkout['name'] != 'REST';
        schedule.add(isWorkoutDay);
      }
      
      return schedule;
    } catch (e) {
      print('Error loading workout schedule from program: $e');
      // Fallback to beginner schedule if loading fails
      return [true, false, true, false, true, true, false];
    }
  }

  /// Map goal display name to goal key for program loading
  static String _mapGoalToKey(String goal) {
    Map<String, String> goalMap = {
      'Weight Loss': 'Weight Loss',
      'Muscle Gain': 'Muscle Gain',
      'Strength': 'Strength',
      'Flexibility': 'Flexibility',
      'Healthy Lifestyle': 'Healthy Lifestyle',
      'weight_loss': 'Weight Loss',
      'muscle_gain': 'Muscle Gain',
      'strength': 'Strength',
      'flexibility': 'Flexibility',
      'general_fitness': 'Healthy Lifestyle',
    };
    return goalMap[goal] ?? goal;
  }

  /// Calculate daily calorie target based on workout day vs rest day
  static int _calculateCalories(String goal, String fitnessLevel, bool isWorkoutDay) {
    // Base calories by fitness level and goal
    Map<String, Map<String, Map<String, int>>> calorieMatrix = {
      'weight_loss': {
        'beginner': {'workout': 2100, 'rest': 1700},
        'intermediate': {'workout': 2300, 'rest': 1900},
        'advanced': {'workout': 2400, 'rest': 2000},
      },
      'muscle_gain': {
        'beginner': {'workout': 2400, 'rest': 2000},
        'intermediate': {'workout': 2700, 'rest': 2300},
        'advanced': {'workout': 3000, 'rest': 2600},
      },
      'strength': {
        'beginner': {'workout': 2300, 'rest': 1900},
        'intermediate': {'workout': 2600, 'rest': 2200},
        'advanced': {'workout': 2900, 'rest': 2500},
      },
      'flexibility': {
        'beginner': {'workout': 2000, 'rest': 1700},
        'intermediate': {'workout': 2200, 'rest': 1900},
        'advanced': {'workout': 2300, 'rest': 2000},
      },
      'general_fitness': {
        'beginner': {'workout': 2100, 'rest': 1800},
        'intermediate': {'workout': 2400, 'rest': 2000},
        'advanced': {'workout': 2600, 'rest': 2200},
      },
    };
    
    final goalKey = MealDatabase.normalizeGoal(goal);
    final levelKey = fitnessLevel.toLowerCase();
    final dayType = isWorkoutDay ? 'workout' : 'rest';
    
    return calorieMatrix[goalKey]?[levelKey]?[dayType] ?? 2000;
  }

  /// Calculate macro nutrient split based on goal and fitness level
  static MacroNutrients _calculateMacros(int calories, String goal, String fitnessLevel) {
    double proteinPercent, carbsPercent, fatsPercent;
    
    final goalKey = MealDatabase.normalizeGoal(goal);
    
    // Macro split varies by goal
    switch (goalKey) {
      case 'weight_loss':
        // Higher protein, moderate carbs, lower fats
        proteinPercent = 0.35;
        carbsPercent = 0.40;
        fatsPercent = 0.25;
        break;
      case 'muscle_gain':
        // High protein, high carbs, moderate fats
        proteinPercent = 0.30;
        carbsPercent = 0.45;
        fatsPercent = 0.25;
        break;
      case 'strength':
        // Very high protein, moderate carbs
        proteinPercent = 0.35;
        carbsPercent = 0.40;
        fatsPercent = 0.25;
        break;
      case 'flexibility':
        // Balanced macros
        proteinPercent = 0.30;
        carbsPercent = 0.45;
        fatsPercent = 0.25;
        break;
      case 'general_fitness':
        // Balanced macros
        proteinPercent = 0.30;
        carbsPercent = 0.45;
        fatsPercent = 0.25;
        break;
      default:
        proteinPercent = 0.30;
        carbsPercent = 0.40;
        fatsPercent = 0.30;
    }
    
    // Calculate grams (protein & carbs = 4 cal/g, fats = 9 cal/g)
    int protein = ((calories * proteinPercent) / 4).round();
    int carbs = ((calories * carbsPercent) / 4).round();
    int fats = ((calories * fatsPercent) / 9).round();
    
    return MacroNutrients(
      protein: protein,
      carbs: carbs,
      fats: fats,
      calories: calories,
    );
  }

  /// Generate 7 days of varied meals aligned with workout schedule
  static Future<List<DailyMealPlan>> _generateWeeklyMeals(
    String goal,
    String fitnessLevel,
    List<String> userAllergies,
    int startProgramDay,
    List<bool> workoutDays,
  ) async {
    List<DailyMealPlan> weeklyMeals = [];
    List<String> dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    // Get meal options for this goal + fitness level + allergies
    List<Meal> breakfastOptions = MealDatabase.getBreakfastOptions(goal, fitnessLevel, userAllergies);
    List<Meal> lunchOptions = MealDatabase.getLunchOptions(goal, fitnessLevel, userAllergies);
    List<Meal> dinnerOptions = MealDatabase.getDinnerOptions(goal, fitnessLevel, userAllergies);
    List<Meal> snackOptions = MealDatabase.getSnackOptions(goal, fitnessLevel, userAllergies);
    
    // Track used meals to ensure variety
    Set<String> usedBreakfasts = {};
    Set<String> usedLunches = {};
    Set<String> usedDinners = {};
    
    for (int day = 0; day < 7; day++) {
      bool isWorkoutDay = workoutDays[day];
      int programDay = startProgramDay + day;
      
      // Calculate calorie target for this day
      int targetCalories = _calculateCalories(goal, fitnessLevel, isWorkoutDay);
      
      // Select unique meals for each day
      Meal breakfast = _selectUniqueMeal(breakfastOptions, usedBreakfasts);
      Meal lunch = _selectUniqueMeal(lunchOptions, usedLunches);
      Meal dinner = _selectUniqueMeal(dinnerOptions, usedDinners);
      
      // Select snacks to reach calorie target
      List<Meal> dailySnacks = _selectSnacks(snackOptions, breakfast, lunch, dinner, targetCalories);
      
      // Calculate total calories and macros for the day
      int totalCalories = breakfast.calories + 
                         lunch.calories + 
                         dinner.calories + 
                         dailySnacks.fold(0, (sum, snack) => sum + snack.calories);
      
      weeklyMeals.add(DailyMealPlan(
        dayNumber: programDay,
        dayName: dayNames[day],
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
        snacks: dailySnacks,
        totalCalories: totalCalories,
      ));
    }
    
    return weeklyMeals;
  }

  /// Calculate average macros across the week
  static MacroNutrients _calculateAverageMacros(List<DailyMealPlan> weeklyMeals) {
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFats = 0;
    int totalCalories = 0;
    
    for (final day in weeklyMeals) {
      totalProtein += day.breakfast.protein + day.lunch.protein + day.dinner.protein +
                     day.snacks.fold(0, (sum, s) => sum + s.protein);
      totalCarbs += day.breakfast.carbs + day.lunch.carbs + day.dinner.carbs +
                   day.snacks.fold(0, (sum, s) => sum + s.carbs);
      totalFats += day.breakfast.fats + day.lunch.fats + day.dinner.fats +
                  day.snacks.fold(0, (sum, s) => sum + s.fats);
      totalCalories += day.totalCalories;
    }
    
    return MacroNutrients(
      protein: (totalProtein / 7).round(),
      carbs: (totalCarbs / 7).round(),
      fats: (totalFats / 7).round(),
      calories: (totalCalories / 7).round(),
    );
  }

  /// Select a unique meal that hasn't been used recently
  static Meal _selectUniqueMeal(List<Meal> options, Set<String> usedMeals) {
    if (options.isEmpty) {
      throw Exception('No meal options available - check allergen filtering');
    }
    
    // If we've used all options, reset
    if (usedMeals.length >= options.length) {
      usedMeals.clear();
    }
    
    // Find available meals
    List<Meal> availableMeals = options.where((meal) => !usedMeals.contains(meal.name)).toList();
    
    // If no available meals, reset and try again
    if (availableMeals.isEmpty) {
      usedMeals.clear();
      availableMeals = options;
    }
    
    // Select random meal from available
    Meal selectedMeal = availableMeals[_random.nextInt(availableMeals.length)];
    usedMeals.add(selectedMeal.name);
    
    return selectedMeal;
  }

  /// Select snacks to reach daily calorie target
  static List<Meal> _selectSnacks(
    List<Meal> snackOptions,
    Meal breakfast,
    Meal lunch,
    Meal dinner,
    int targetCalories,
  ) {
    if (snackOptions.isEmpty) return [];
    
    int currentCalories = breakfast.calories + lunch.calories + dinner.calories;
    int remainingCalories = targetCalories - currentCalories;
    
    List<Meal> selectedSnacks = [];
    
    // Add snacks until we're close to target (within 100 calories)
    while (remainingCalories > 100 && selectedSnacks.length < 3) {
      // Find snacks that fit within remaining calories
      List<Meal> fittingSnacks = snackOptions
          .where((snack) => snack.calories <= remainingCalories + 50)
          .toList();
      
      if (fittingSnacks.isEmpty) break;
      
      Meal snack = fittingSnacks[_random.nextInt(fittingSnacks.length)];
      selectedSnacks.add(snack);
      remainingCalories -= snack.calories;
    }
    
    // Ensure at least one snack
    if (selectedSnacks.isEmpty) {
      selectedSnacks.add(snackOptions[_random.nextInt(snackOptions.length)]);
    }
    
    return selectedSnacks;
  }

  /// Get meal plan recommendations based on goal and fitness level
  static String getMealPlanGuidance(String goal, String fitnessLevel) {
    final goalKey = MealDatabase.normalizeGoal(goal);
    
    switch (goalKey) {
      case 'weight_loss':
        return 'Focus on portion control and nutrient-dense foods. Higher protein helps preserve muscle while losing fat. Stay hydrated and avoid skipping meals.';
      case 'muscle_gain':
        return 'Eat in a calorie surplus with high protein intake. Time your carbs around workouts for energy and recovery. Consistency is key for muscle growth.';
      case 'strength':
        return 'Fuel your training with adequate protein and carbs. Eat more on workout days to support performance. Recovery nutrition is crucial.';
      case 'flexibility':
        return 'Maintain balanced nutrition to support recovery and joint health. Stay hydrated and include anti-inflammatory foods.';
      case 'general_fitness':
        return 'Eat balanced meals with variety. Focus on whole foods and consistent meal timing. Adjust portions based on activity level.';
      default:
        return 'Eat balanced meals and stay consistent with your nutrition.';
    }
  }

  /// Get hydration recommendations
  static String getHydrationGuidance(String fitnessLevel) {
    switch (fitnessLevel.toLowerCase()) {
      case 'beginner':
        return 'Drink 8-10 glasses of water daily. Increase intake on workout days.';
      case 'intermediate':
        return 'Aim for 10-12 glasses daily. Drink water before, during, and after workouts.';
      case 'advanced':
        return 'Drink 12-15 glasses daily. Consider electrolyte drinks during intense sessions.';
      default:
        return 'Stay hydrated throughout the day.';
    }
  }
}
