# Meal Plan System & Real Data Integration

## Overview
Complete the AI Home Workout Coach app by implementing the meal plan feature (capstone requirement) and integrating real workout data throughout the app to create a realistic, production-ready demonstration.

## Goals
1. Implement comprehensive meal plan system for all fitness levels
2. Connect dashboard and progress screens to real workout history data
3. Generate realistic sample datasets for demonstration
4. Ensure all capstone study requirements are met

---

## High-Level Design

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     AI HOME WORKOUT COACH                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Workout    │  │  Meal Plan   │  │   Progress   │      │
│  │   System     │  │   System     │  │   Tracking   │      │
│  │   (Done ✓)   │  │   (NEW)      │  │  (Upgrade)   │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │               │
│         └──────────────────┴──────────────────┘               │
│                            │                                  │
│                   ┌────────▼────────┐                        │
│                   │  Data Services  │                        │
│                   │  - Workout      │                        │
│                   │  - Meal Plan    │                        │
│                   │  - User Profile │                        │
│                   └─────────────────┘                        │
│                            │                                  │
│                   ┌────────▼────────┐                        │
│                   │ Local Storage   │                        │
│                   │ (SharedPrefs)   │                        │
│                   └─────────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

### Component Breakdown

#### 1. Meal Plan System (NEW)
- **MealPlanGenerator**: Creates personalized meal plans based on fitness level
- **MealPlanScreen**: Displays daily meal recommendations
- **NutritionCalculator**: Calculates calories, macros based on user profile
- **MealDatabase**: Stores meal options for each fitness level

#### 2. Data Integration (UPGRADE)
- **Dashboard**: Pull real stats from WorkoutHistoryService
- **ProgressTracking**: Display actual workout history with charts
- **SampleDataGenerator**: Enhanced to create realistic 30-day datasets

#### 3. Data Models

```
MealPlan
├── id: String
├── userId: String
├── fitnessLevel: String (beginner/intermediate/advanced)
├── dailyCalories: int
├── macros: MacroNutrients
├── meals: List<DailyMealPlan>
└── createdAt: DateTime

DailyMealPlan
├── dayNumber: int
├── breakfast: Meal
├── lunch: Meal
├── dinner: Meal
├── snacks: List<Meal>
└── totalCalories: int

Meal
├── name: String
├── description: String
├── calories: int
├── protein: int (grams)
├── carbs: int (grams)
├── fats: int (grams)
├── ingredients: List<String>
└── prepTime: int (minutes)

MacroNutrients
├── protein: int (grams)
├── carbs: int (grams)
├── fats: int (grams)
└── calories: int
```

---

## Low-Level Design

### 1. Meal Plan Generator Service

```dart
class MealPlanGenerator {
  // Generate meal plan based on fitness level
  static MealPlan generateMealPlan(String fitnessLevel, String userId) {
    // Calculate daily calorie needs
    int dailyCalories = _calculateCalories(fitnessLevel);
    
    // Calculate macro split
    MacroNutrients macros = _calculateMacros(dailyCalories, fitnessLevel);
    
    // Generate 7-day meal plan
    List<DailyMealPlan> meals = _generateWeeklyMeals(fitnessLevel, macros);
    
    return MealPlan(...);
  }
  
  // Calorie targets by fitness level
  static int _calculateCalories(String level) {
    switch (level) {
      case 'beginner': return 2000;      // Maintenance
      case 'intermediate': return 2300;  // Slight surplus
      case 'advanced': return 2500;      // Muscle building
      default: return 2000;
    }
  }
  
  // Macro split by fitness level
  static MacroNutrients _calculateMacros(int calories, String level) {
    // Beginner: 30% protein, 40% carbs, 30% fats
    // Intermediate: 35% protein, 40% carbs, 25% fats
    // Advanced: 40% protein, 35% carbs, 25% fats
  }
  
  // Generate meals from database
  static List<DailyMealPlan> _generateWeeklyMeals(String level, MacroNutrients macros) {
    // Select meals from MealDatabase
    // Ensure variety across the week
    // Balance macros for each day
  }
}
```

### 2. Meal Database

```dart
class MealDatabase {
  // Breakfast options
  static List<Meal> beginnerBreakfast = [
    Meal(
      name: 'Oatmeal with Banana',
      calories: 350,
      protein: 12,
      carbs: 60,
      fats: 8,
      ingredients: ['Oats', 'Banana', 'Honey', 'Almonds'],
      prepTime: 10,
    ),
    Meal(
      name: 'Scrambled Eggs & Toast',
      calories: 400,
      protein: 20,
      carbs: 35,
      fats: 18,
      ingredients: ['Eggs', 'Whole wheat bread', 'Butter', 'Tomatoes'],
      prepTime: 15,
    ),
    // ... more options
  ];
  
  // Lunch options
  static List<Meal> beginnerLunch = [
    Meal(
      name: 'Chicken Rice Bowl',
      calories: 550,
      protein: 35,
      carbs: 65,
      fats: 12,
      ingredients: ['Chicken breast', 'Brown rice', 'Vegetables', 'Olive oil'],
      prepTime: 25,
    ),
    // ... more options
  ];
  
  // Dinner options
  static List<Meal> beginnerDinner = [
    Meal(
      name: 'Grilled Fish with Veggies',
      calories: 450,
      protein: 40,
      carbs: 30,
      fats: 15,
      ingredients: ['Salmon', 'Broccoli', 'Sweet potato', 'Lemon'],
      prepTime: 30,
    ),
    // ... more options
  ];
  
  // Snack options
  static List<Meal> snacks = [
    Meal(
      name: 'Greek Yogurt & Berries',
      calories: 200,
      protein: 15,
      carbs: 25,
      fats: 5,
      ingredients: ['Greek yogurt', 'Mixed berries', 'Honey'],
      prepTime: 5,
    ),
    // ... more options
  ];
  
  // Similar structures for intermediate and advanced levels
  // with higher calories and protein
}
```

### 3. Enhanced Meal Plan Screen

```dart
class EnhancedMealPlanScreen extends StatefulWidget {
  // Display meal plan with:
  // - Daily calorie target
  // - Macro breakdown (protein/carbs/fats)
  // - Meal cards for breakfast/lunch/dinner/snacks
  // - Ingredient lists
  // - Prep time
  // - Weekly view with day selector
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column([
        _buildHeader(),           // Calorie & macro summary
        _buildDaySelector(),      // Mon-Sun tabs
        _buildMealList(),         // Breakfast, Lunch, Dinner, Snacks
        _buildNutritionSummary(), // Daily totals
      ]),
    );
  }
}
```

### 4. Dashboard Data Integration

```dart
class _DashboardScreenState extends State<DashboardScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  
  // Real stats
  int _totalWorkouts = 0;
  int _currentStreak = 0;
  int _currentDay = 1;
  List<WorkoutHistory> _recentWorkouts = [];
  
  @override
  void initState() {
    super.initState();
    _loadRealData();
  }
  
  Future<void> _loadRealData() async {
    String userId = widget.profile['uid'] ?? 'user_001';
    
    // Load real data
    _totalWorkouts = await _historyService.getTotalWorkoutsCompleted(userId);
    _currentStreak = await _historyService.getCurrentStreak(userId);
    _recentWorkouts = await _historyService.getWorkoutHistory(userId);
    
    // Calculate current day
    List<int> completedDays = await _historyService.getCompletedWorkoutDays(userId);
    _currentDay = completedDays.isEmpty ? 1 : completedDays.last + 1;
    
    setState(() {});
  }
  
  Widget _buildQuickStats() {
    return Row([
      _buildStatCard('Day', '$_currentDay', ...),
      _buildStatCard('Streak', '$_currentStreak', ...),
      _buildStatCard('Workouts', '$_totalWorkouts', ...),
    ]);
  }
  
  Widget _buildWorkoutHistory() {
    if (_recentWorkouts.isEmpty) {
      return _buildEmptyHistoryCard();
    }
    
    return Column([
      _buildNextWorkoutCard(),
      ..._recentWorkouts.take(3).map((workout) => 
        _buildWorkoutHistoryCard(workout)
      ),
    ]);
  }
}
```

### 5. Progress Tracking Data Integration

```dart
class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  
  List<WorkoutHistory> _workoutHistory = [];
  int _totalWorkouts = 0;
  int _totalMinutes = 0;
  int _totalCalories = 0;
  int _currentStreak = 0;
  
  @override
  void initState() {
    super.initState();
    _loadRealData();
  }
  
  Future<void> _loadRealData() async {
    String userId = widget.profile['uid'] ?? 'user_001';
    
    // Load based on selected period
    if (_selectedPeriod == 'Week') {
      _workoutHistory = await _historyService.getWorkoutsThisWeek(userId);
    } else if (_selectedPeriod == 'Month') {
      _workoutHistory = await _historyService.getWorkoutsThisMonth(userId);
    } else {
      _workoutHistory = await _historyService.getWorkoutHistory(userId);
    }
    
    // Calculate stats
    _totalWorkouts = _workoutHistory.length;
    _totalMinutes = _workoutHistory.fold(0, (sum, w) => sum + w.durationMinutes);
    _totalCalories = _workoutHistory.fold(0, (sum, w) => sum + w.caloriesBurned);
    _currentStreak = await _historyService.getCurrentStreak(userId);
    
    setState(() {});
  }
  
  Widget _buildWorkoutChart() {
    // Use real _workoutHistory data
    // Group by day/week/month based on _selectedPeriod
    // Display actual workout durations
  }
  
  Widget _buildRecentActivity() {
    // Display actual _workoutHistory items
    return Column(
      _workoutHistory.take(5).map((workout) =>
        _buildActivityItem(
          workout.workoutTitle,
          '${_formatDate(workout.completedAt)}, ${workout.durationMinutes} min',
          _getIconForWorkout(workout.workoutTitle),
        )
      ).toList(),
    );
  }
}
```

### 6. Enhanced Sample Data Generator

```dart
class SampleDataGenerator {
  // Generate 30 days of realistic workout data
  static Future<void> generate30DayHistory({
    required String userId,
    required String difficulty,
  }) async {
    List<WorkoutHistory> history = [];
    DateTime now = DateTime.now();
    
    // Generate 30 days back
    for (int i = 29; i >= 0; i--) {
      DateTime workoutDate = now.subtract(Duration(days: i));
      
      // Realistic rest day pattern
      bool isRestDay = _shouldBeRestDay(i, difficulty);
      if (isRestDay) continue;
      
      // Generate workout with progressive overload
      WorkoutHistory workout = _generateRealisticWorkout(
        userId: userId,
        date: workoutDate,
        difficulty: difficulty,
        daysSinceStart: 30 - i,
      );
      
      history.add(workout);
    }
    
    // Save all workouts
    for (var workout in history) {
      await WorkoutHistoryService().saveWorkout(workout);
    }
  }
  
  static bool _shouldBeRestDay(int dayIndex, String difficulty) {
    // Beginner: 4 workouts/week (rest on days 3, 5, 6)
    // Intermediate: 5 workouts/week (rest on days 2, 6)
    // Advanced: 6 workouts/week (rest on day 3)
    
    int weekDay = dayIndex % 7;
    
    switch (difficulty) {
      case 'beginner':
        return [2, 4, 5].contains(weekDay);
      case 'intermediate':
        return [1, 5].contains(weekDay);
      case 'advanced':
        return [2].contains(weekDay);
      default:
        return false;
    }
  }
  
  static WorkoutHistory _generateRealisticWorkout({
    required String userId,
    required DateTime date,
    required String difficulty,
    required int daysSinceStart,
  }) {
    // Progressive overload: reps increase over time
    double progressionFactor = 1.0 + (daysSinceStart / 100);
    
    // Workout type rotation
    List<String> workoutTypes = ['Push', 'Pull', 'Legs', 'Core'];
    String workoutType = workoutTypes[daysSinceStart % workoutTypes.length];
    
    // Generate exercises with realistic performance
    List<ExerciseResult> exercises = _generateExercisesWithProgression(
      workoutType,
      difficulty,
      progressionFactor,
    );
    
    // Calculate totals
    int totalReps = exercises.fold(0, (sum, ex) => sum + ex.actualReps);
    int totalSets = exercises.fold(0, (sum, ex) => sum + ex.completedSets);
    int duration = _calculateDuration(difficulty, exercises.length);
    int calories = (totalReps * 5 * _getDifficultyMultiplier(difficulty)).round();
    
    return WorkoutHistory(
      id: '${userId}_${date.millisecondsSinceEpoch}',
      userId: userId,
      workoutId: 'workout_day_$daysSinceStart',
      workoutTitle: 'Day $daysSinceStart: $workoutType Day',
      dayNumber: daysSinceStart,
      completedAt: date,
      durationMinutes: duration,
      exercises: exercises,
      totalReps: totalReps,
      totalSets: totalSets,
      caloriesBurned: calories,
      difficulty: difficulty,
    );
  }
}
```

---

## Implementation Tasks

### Phase 1: Meal Plan System
- [ ] Create `lib/models/meal_plan.dart` - Data models
- [ ] Create `lib/services/meal_database.dart` - Meal options database
- [ ] Create `lib/services/meal_plan_generator.dart` - Meal plan logic
- [ ] Update `lib/screens/enhanced_meal_plan_screen.dart` - Full UI implementation
- [ ] Add meal plan to navigation

### Phase 2: Data Integration
- [ ] Update `lib/screens/dashboard_screen.dart` - Connect to real data
- [ ] Update `lib/screens/progress_tracking_screen.dart` - Display real history
- [ ] Enhance `lib/services/sample_data_generator.dart` - 30-day realistic data
- [ ] Fix `lib/services/workout_history_service.dart` - Fix fold() type errors

### Phase 3: Testing & Polish
- [ ] Test complete workout flow with real data
- [ ] Test meal plan generation for all fitness levels
- [ ] Generate sample data and verify dashboard/progress screens
- [ ] Build APK and test on Android device

---

## Success Criteria

✅ Meal plan feature fully implemented for all fitness levels
✅ Dashboard shows real workout stats (not hardcoded 0s)
✅ Progress tracking displays actual workout history
✅ Sample data generator creates realistic 30-day datasets
✅ All capstone study requirements met:
  - Workout plans ✓
  - Meal plans ✓
  - AI camera tracking ✓
  - Progress tracking ✓
  - Real-time form corrections ✓

---

## Notes

- Keep meal options simple and practical (home cooking)
- Ensure meal plans align with workout intensity
- Use realistic calorie/macro calculations
- Sample data should show progression over time
- All data persists using SharedPreferences
