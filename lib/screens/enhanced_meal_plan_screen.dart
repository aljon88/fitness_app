import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../models/navigation_state.dart';
import '../widgets/navigation_widgets.dart';
import '../widgets/ai_coach_character.dart';
import '../models/meal_models.dart';
import '../services/personalized_meal_planner.dart';
import '../services/meal_tracking_service.dart';

class EnhancedMealPlanScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  
  const EnhancedMealPlanScreen({Key? key, required this.userProfile}) : super(key: key);

  @override
  _EnhancedMealPlanScreenState createState() => _EnhancedMealPlanScreenState();
}

class _EnhancedMealPlanScreenState extends State<EnhancedMealPlanScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final PersonalizedMealPlanner _mealPlanner = PersonalizedMealPlanner();
  final MealTrackingService _trackingService = MealTrackingService();
  
  WeeklyMealPlan? _currentMealPlan;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  UserNutritionProfile? _nutritionProfile;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    
    _initializeNutritionProfile();
    _generateMealPlan();
  }

  void _initializeNutritionProfile() {
    // Convert user profile to nutrition profile
    final fitnessGoal = _mapFitnessGoal(widget.userProfile['motivation'] ?? 'Stay Fit');
    final allergies = List<String>.from(widget.userProfile['allergies'] ?? []);
    final fitnessLevel = widget.userProfile['fitnessLevel'] ?? 'beginner';
    
    _nutritionProfile = UserNutritionProfile(
      userId: 'user_001', // In real app, get from auth
      fitnessGoal: fitnessGoal,
      allergies: allergies,
      dietaryRestrictions: _getDietaryRestrictions(),
      dislikedFoods: [],
      preferredCuisines: ['American', 'Mediterranean', 'Asian'],
      dailyCalorieTarget: _calculateCalorieTarget(fitnessGoal, fitnessLevel),
      macroTargets: _calculateMacroTargets(fitnessGoal),
      weeklyBudget: 150.0, // $150 per week
      cookingSkillLevel: 'intermediate',
      maxPrepTime: 45, // 45 minutes max prep time
      ingredientPreferences: {},
      cuisineAffinities: {},
    );
  }
  String _mapFitnessGoal(String motivation) {
    switch (motivation.toLowerCase()) {
      case 'lose weight':
        return 'weight_loss';
      case 'build muscle':
        return 'muscle_gain';
      default:
        return 'maintenance';
    }
  }

  List<String> _getDietaryRestrictions() {
    final restrictions = <String>[];
    final allergies = widget.userProfile['allergies'] ?? [];
    
    // Map allergies to dietary restrictions
    if (allergies.contains('Milk & Dairy')) {
      restrictions.add('dairy-free');
    }
    if (allergies.contains('Wheat & Gluten')) {
      restrictions.add('gluten-free');
    }
    if (allergies.contains('Nuts')) {
      restrictions.add('nut-free');
    }
    
    return restrictions;
  }

  int _calculateCalorieTarget(String goal, String fitnessLevel) {
    int baseCalories = 1800;
    
    // Adjust for fitness level
    switch (fitnessLevel) {
      case 'beginner':
        baseCalories = 1700;
        break;
      case 'intermediate':
        baseCalories = 1900;
        break;
      case 'advanced':
        baseCalories = 2100;
        break;
    }
    
    // Adjust for goal
    switch (goal) {
      case 'weight_loss':
        return (baseCalories * 0.85).round(); // 15% deficit
      case 'muscle_gain':
        return (baseCalories * 1.15).round(); // 15% surplus
      default:
        return baseCalories;
    }
  }

  Map<String, double> _calculateMacroTargets(String goal) {
    switch (goal) {
      case 'weight_loss':
        return {'protein': 130.0, 'carbs': 150.0, 'fat': 60.0};
      case 'muscle_gain':
        return {'protein': 160.0, 'carbs': 220.0, 'fat': 80.0};
      default:
        return {'protein': 140.0, 'carbs': 190.0, 'fat': 70.0};
    }
  }

  Future<void> _generateMealPlan() async {
    if (_nutritionProfile == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      print('Generating meal plan for profile: ${_nutritionProfile!.userId}');
      final mealPlan = await _mealPlanner.generateWeeklyPlan(
        profile: _nutritionProfile!,
        startDate: _selectedDate,
        days: 7,
      );
      
      print('Generated meal plan with cost: ${mealPlan.totalEstimatedCost}');
      
      setState(() {
        _currentMealPlan = mealPlan;
        _isLoading = false;
      });
    } catch (e) {
      print('Error generating meal plan: $e');
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to generate meal plan: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0E21),
              Color(0xFF1A1B3A),
              Color(0xFF2D3561),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - kBottomNavigationBarHeight,
                ),
                child: Column(
                  children: [
                    // Compact Header
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 8 : 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Smart Meal Plans',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 18 : 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'AI-powered personalized nutrition',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: isSmallScreen ? 11 : 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.restaurant_menu, color: Color(0xFF6C5CE7), size: 24),
                        ],
                      ),
                    ),
                    
                    // AI Coach Message - Compact
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Color(0xFF6C5CE7), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getPersonalizedCoachMessage(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 11 : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // All content in one scrollable column
                    _buildCompactScrollableContent(isSmallScreen),
                    
                    // Bottom spacing for FABs
                    SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: MainNavigationBar(currentScreen: NavigationScreen.mealPlan),
      floatingActionButton: Stack(
        children: [
          // Workout Camera FAB
          Positioned(
            bottom: 80,
            right: 0,
            child: WorkoutCameraFAB(),
          ),
          // Floating Nutrition Info FAB
          if (_currentMealPlan != null)
            Positioned(
              bottom: 140,
              right: 0,
              child: _buildNutritionFAB(),
            ),
        ],
      ),
    );
  }

  String _getPersonalizedCoachMessage() {
    if (_nutritionProfile == null) return "Let's create your personalized meal plan! 🍎";
    
    switch (_nutritionProfile!.fitnessGoal) {
      case 'weight_loss':
        return "Smart nutrition for your weight loss journey! Each meal is optimized for your goals! 🔥";
      case 'muscle_gain':
        return "Fuel your gains! These meals are packed with the right nutrients for muscle building! 💪";
      default:
        return "Balanced nutrition made simple! Your personalized meal plan is ready! 🌟";
    }
  }
  // Compact nutrition bar
  Widget _buildCompactNutritionBar(bool isSmallScreen) {
    final summary = _currentMealPlan!.weeklyNutrition;
    final todaysPlan = _getTodaysMealPlan();
    final todaysCalories = todaysPlan?.dailyNutrition.calories ?? 0;
    final todaysProtein = todaysPlan?.dailyNutrition.protein ?? 0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Color(0xFF1E1F3A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFF6C5CE7).withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Today's calories
          Expanded(
            child: Column(
              children: [
                Text(
                  '${todaysCalories.round()}',
                  style: TextStyle(
                    color: Color(0xFF6C5CE7),
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Cal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 9 : 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          Container(width: 1, height: 25, color: Colors.white.withOpacity(0.2)),
          
          // Today's protein
          Expanded(
            child: Column(
              children: [
                Text(
                  '${todaysProtein.round()}g',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Protein',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 9 : 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          Container(width: 1, height: 25, color: Colors.white.withOpacity(0.2)),
          
          // Weekly cost
          Expanded(
            child: Column(
              children: [
                Text(
                  '\${(_currentMealPlan?.totalEstimatedCost ?? 0.0).toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Week',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 9 : 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDateSelector(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 60 : 70,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = _selectedDate.add(Duration(days: index));
          final isSelected = index == 0; // Today is selected by default
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: isSmallScreen ? 50 : 55,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ) : null,
                color: isSelected ? null : Color(0xFF1E1F3A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date),
                    style: TextStyle(
                      color: Colors.white.withOpacity(isSelected ? 1.0 : 0.7),
                      fontSize: isSmallScreen ? 9 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactWorkoutAccess(bool isSmallScreen) {
    final navigationService = NavigationService();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6C5CE7).withOpacity(0.15),
            Color(0xFF74B9FF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Workout Program Button
          Expanded(
            child: GestureDetector(
              onTap: () => navigationService.navigateToWorkoutProgram(),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, color: Color(0xFF6C5CE7), size: isSmallScreen ? 16 : 18),
                    SizedBox(width: 6),
                    Text(
                      'Workouts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          // Camera Button
          Expanded(
            child: GestureDetector(
              onTap: () => navigationService.navigateToCamera(),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Color(0xFF74B9FF), size: isSmallScreen ? 16 : 18),
                    SizedBox(width: 6),
                    Text(
                      'Camera',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Floating nutrition info button with FIXED modal
  Widget _buildNutritionFAB() {
    return FloatingActionButton(
      heroTag: "nutrition_fab",
      onPressed: _showDetailedNutritionInfo,
      backgroundColor: Color(0xFF6C5CE7),
      child: Icon(
        Icons.analytics_outlined,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  // FIXED: Show detailed nutrition information in a scrollable modal
  void _showDetailedNutritionInfo() {
    final summary = _currentMealPlan!.weeklyNutrition;
    final todaysPlan = _getTodaysMealPlan();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75, // Fixed height to prevent overflow
        decoration: BoxDecoration(
          color: Color(0xFF1A1B3A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'Detailed Nutrition Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Today's detailed nutrition
                    if (todaysPlan != null) ...[
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6C5CE7).withOpacity(0.2), Color(0xFF74B9FF).withOpacity(0.2)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFF6C5CE7).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Nutrition',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailedNutritionItem(
                                    'Calories', 
                                    '${todaysPlan.dailyNutrition.calories.round()}', 
                                    'kcal',
                                    Color(0xFF6C5CE7),
                                  ),
                                ),
                                Expanded(
                                  child: _buildDetailedNutritionItem(
                                    'Protein', 
                                    '${todaysPlan.dailyNutrition.protein.round()}', 
                                    'g',
                                    Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailedNutritionItem(
                                    'Carbs', 
                                    '${todaysPlan.dailyNutrition.carbs.round()}', 
                                    'g',
                                    Colors.orange,
                                  ),
                                ),
                                Expanded(
                                  child: _buildDetailedNutritionItem(
                                    'Fat', 
                                    '${todaysPlan.dailyNutrition.fat.round()}', 
                                    'g',
                                    Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _generateMealPlan();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6C5CE7),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Regenerate Plan',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Close',
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Bottom padding for safe area
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDetailedNutritionItem(String label, String value, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = _selectedDate.add(Duration(days: index));
          final isSelected = index == 0; // Today is selected by default
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 65,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ) : null,
                color: isSelected ? null : Color(0xFF1E1F3A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Color(0xFF6C5CE7).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date),
                    style: TextStyle(
                      color: Colors.white.withOpacity(isSelected ? 1.0 : 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDayName(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF6C5CE7),
          ),
          SizedBox(height: 16),
          Text(
            'Creating your personalized meal plan...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Analyzing your preferences and nutrition goals',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.white30,
          ),
          SizedBox(height: 16),
          Text(
            'No meal plan available',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the button below to generate your personalized meal plan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _generateMealPlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C5CE7),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Generate Meal Plan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactScrollableContent(bool isSmallScreen) {
    if (_isLoading) {
      return Container(
        height: 200,
        child: _buildLoadingState(),
      );
    }
    
    if (_currentMealPlan == null) {
      return Container(
        height: 200,
        child: _buildEmptyState(),
      );
    }

    final todaysPlan = _getTodaysMealPlan();
    if (todaysPlan == null) {
      return Container(
        height: 200,
        child: _buildEmptyState(),
      );
    }

    return Column(
      children: [
        // Compact nutrition bar
        _buildCompactNutritionBar(isSmallScreen),
        SizedBox(height: 12),
        
        // Compact date selector
        _buildCompactDateSelector(isSmallScreen),
        SizedBox(height: 16),
        
        // Quick workout access
        _buildCompactWorkoutAccess(isSmallScreen),
        SizedBox(height: 16),
        
        // Meals - Compact
        if (todaysPlan.breakfast != null) ...[
          _buildCompactMealCard('Breakfast', todaysPlan.breakfast!, Icons.wb_sunny, Colors.orange, isSmallScreen),
          SizedBox(height: 12),
        ],
        if (todaysPlan.lunch != null) ...[
          _buildCompactMealCard('Lunch', todaysPlan.lunch!, Icons.lunch_dining, Colors.green, isSmallScreen),
          SizedBox(height: 12),
        ],
        if (todaysPlan.dinner != null) ...[
          _buildCompactMealCard('Dinner', todaysPlan.dinner!, Icons.dinner_dining, Colors.purple, isSmallScreen),
          SizedBox(height: 12),
        ],
        if (todaysPlan.snacks.isNotEmpty) ...[
          ...todaysPlan.snacks.take(2).map((snack) => Column(
            children: [
              _buildCompactMealCard('Snack', snack, Icons.cookie, Colors.amber, isSmallScreen),
              SizedBox(height: 12),
            ],
          )),
        ],
      ],
    );
  }
  DailyMealPlan? _getTodaysMealPlan() {
    if (_currentMealPlan == null) return null;
    
    try {
      return _currentMealPlan!.dailyPlans.firstWhere(
        (plan) => _isSameDay(plan.date, _selectedDate),
      );
    } catch (e) {
      return _currentMealPlan!.dailyPlans.isNotEmpty 
        ? _currentMealPlan!.dailyPlans.first 
        : null;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Widget _buildCompactMealCard(String mealType, Recipe recipe, IconData icon, Color color, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFF1E1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Compact
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isSmallScreen ? 36 : 40,
                  height: isSmallScreen ? 36 : 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: Icon(icon, color: Colors.white, size: isSmallScreen ? 18 : 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallScreen ? 10 : 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        recipe.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildCompactMealActions(recipe, isSmallScreen),
              ],
            ),
          ),
          
          // Content - Compact
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description - Compact
                Text(
                  recipe.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: isSmallScreen ? 11 : 12,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                
                // Nutrition info - Compact
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildCompactNutritionChip('${recipe.nutrition.calories.round()} cal', Colors.blue, isSmallScreen),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildCompactNutritionChip('${recipe.nutrition.protein.round()}g protein', Colors.green, isSmallScreen),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildCompactNutritionChip('${recipe.prepTimeMinutes}min', Colors.orange, isSmallScreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMealActions(Recipe recipe, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showRecipeDetails(recipe),
          icon: Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8), size: isSmallScreen ? 16 : 18),
        ),
        IconButton(
          onPressed: () => _toggleFavorite(recipe),
          icon: Icon(Icons.favorite_border, color: Colors.white.withOpacity(0.8), size: isSmallScreen ? 16 : 18),
        ),
      ],
    );
  }

  Widget _buildCompactNutritionChip(String text, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: isSmallScreen ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: isSmallScreen ? 9 : 10,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  Widget _buildMealActions(Recipe recipe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showRecipeDetails(recipe),
          icon: Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8), size: 20),
        ),
        IconButton(
          onPressed: () => _toggleFavorite(recipe),
          icon: Icon(Icons.favorite_border, color: Colors.white.withOpacity(0.8), size: 20),
        ),
      ],
    );
  }

  Widget _buildNutritionChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCompactNutritionInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Quick workout access similar to dashboard
  Widget _buildQuickWorkoutAccess() {
    final navigationService = NavigationService();
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6C5CE7).withOpacity(0.15),
            Color(0xFF74B9FF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Workout Program Button
          Expanded(
            child: GestureDetector(
              onTap: () => navigationService.navigateToWorkoutProgram(),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, color: Color(0xFF6C5CE7), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Workouts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Camera Button
          Expanded(
            child: GestureDetector(
              onTap: () => navigationService.navigateToCamera(),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Color(0xFF74B9FF), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Camera',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(Recipe recipe) {
    // Show recipe details modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recipe details for ${recipe.title}'),
        backgroundColor: Color(0xFF6C5CE7),
      ),
    );
  }

  void _toggleFavorite(Recipe recipe) {
    // Toggle favorite status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${recipe.title} to favorites'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}