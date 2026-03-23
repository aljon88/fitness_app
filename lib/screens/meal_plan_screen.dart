import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../models/navigation_state.dart';
import '../widgets/navigation_widgets.dart';
import '../widgets/ai_coach_character.dart';

class MealPlanScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  
  const MealPlanScreen({Key? key, required this.userProfile}) : super(key: key);

  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> with TickerProviderStateMixin {
  String selectedGoal = 'weight_loss';
  int dailyCalories = 1800;
  int consumedCalories = 1200;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
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
    
    // Set initial goal based on user profile
    if (widget.userProfile['motivation'] == 'Lose Weight' || widget.userProfile['goal'] == 'Lose Weight') {
      selectedGoal = 'weight_loss';
      dailyCalories = 1600;
    } else if (widget.userProfile['motivation'] == 'Build Muscle' || widget.userProfile['goal'] == 'Build Muscle') {
      selectedGoal = 'muscle_gain';
      dailyCalories = 2200;
    } else {
      selectedGoal = 'maintenance';
      dailyCalories = 1900;
    }
  }
  
  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                // Header with navigation integration
                NavigationHeader(
                  title: 'Nutrition Plans',
                  subtitle: 'Personalized meal recommendations',
                ),
                
                // AI Coach Message
                AICoachCharacter(
                  message: _getPersonalizedCoachMessage(),
                  mood: AICoachMood.encouraging,
                ),
                
                // Current goal display (simplified)
                _buildCurrentGoalDisplay(),
                
                // Daily calorie goal
                _buildCalorieGoal(),
                
                // Today's meal plan
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildMealPlan(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MainNavigationBar(currentScreen: NavigationScreen.mealPlan),
      floatingActionButton: WorkoutCameraFAB(),
    );
  }

  String _getPersonalizedCoachMessage() {
    String userGoal = widget.userProfile['motivation'] ?? 'Stay Fit';
    switch (selectedGoal) {
      case 'weight_loss':
        return "Perfect! Let's fuel your weight loss journey with the right nutrition! 🔥";
      case 'muscle_gain':
        return "Time to build muscle! These meals will power your strength gains! 💪";
      default:
        return "Great choice! Let's maintain your fitness with balanced nutrition! 🍎";
    }
  }

  Widget _buildCurrentGoalDisplay() {
    String goalTitle = selectedGoal == 'weight_loss' ? 'Lose Weight' : 
                      selectedGoal == 'muscle_gain' ? 'Build Muscle' : 'Stay Fit';
    IconData goalIcon = selectedGoal == 'weight_loss' ? Icons.trending_down : 
                       selectedGoal == 'muscle_gain' ? Icons.fitness_center : Icons.balance;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(goalIcon, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Goal: $goalTitle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Nutrition plan optimized for your goal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showGoalSelector(),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showGoalSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1A1B3A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Nutrition Goal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _buildGoalOption('weight_loss', 'Lose Weight', Icons.trending_down, 'Lower calorie, high protein'),
            _buildGoalOption('muscle_gain', 'Build Muscle', Icons.fitness_center, 'Higher calorie, protein focused'),
            _buildGoalOption('maintenance', 'Stay Fit', Icons.balance, 'Balanced nutrition'),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(String goalId, String title, IconData icon, String description) {
    bool isSelected = selectedGoal == goalId;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goalId;
          _updateCaloriesForGoal();
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6C5CE7).withOpacity(0.3) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF6C5CE7) : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Color(0xFF6C5CE7), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    final goals = [
      {'id': 'weight_loss', 'title': 'Lose Weight', 'icon': Icons.trending_down, 'color': Colors.red},
      {'id': 'muscle_gain', 'title': 'Gain Muscle', 'icon': Icons.fitness_center, 'color': Colors.blue},
      {'id': 'maintenance', 'title': 'Maintain', 'icon': Icons.balance, 'color': Colors.green},
    ];

    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final isSelected = selectedGoal == goal['id'];
          
          return GestureDetector(
            onTap: () => setState(() {
              selectedGoal = goal['id'] as String;
              _updateCaloriesForGoal();
            }),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                ) : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    goal['icon'] as IconData,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    goal['title'] as String,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildCalorieGoal() {
    double progress = consumedCalories / dailyCalories;
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Calorie Goal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$dailyCalories calories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$consumedCalories consumed • ${dailyCalories - consumedCalories} remaining',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Center(
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlan() {
    return Column(
      children: [
        _buildMealSection('Breakfast', _getBreakfastMeals(), Icons.wb_sunny, Colors.orange),
        SizedBox(height: 16),
        _buildMealSection('Lunch', _getLunchMeals(), Icons.lunch_dining, Colors.green),
        SizedBox(height: 16),
        _buildMealSection('Dinner', _getDinnerMeals(), Icons.dinner_dining, Colors.purple),
        SizedBox(height: 16),
        _buildMealSection('Snacks', _getSnackMeals(), Icons.cookie, Colors.amber),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMealSection(String title, List<Map<String, dynamic>> meals, IconData icon, Color color) {
    int totalCalories = _calculateTotalCalories(meals);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$totalCalories calories • ${meals.length} items',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...meals.map((meal) => _buildMealItem(meal)).toList(),
        ],
      ),
    );
  }

  Widget _buildMealItem(Map<String, dynamic> meal) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              meal['icon'] as IconData,
              color: Colors.white70,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${meal['calories']} cal • ${meal['protein']}g protein • ${meal['carbs']}g carbs',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF6C5CE7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${meal['calories']}',
              style: TextStyle(
                color: Color(0xFF6C5CE7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getBreakfastMeals() {
    switch (selectedGoal) {
      case 'weight_loss':
        return [
          {'name': 'Greek Yogurt with Berries', 'calories': 150, 'protein': 15, 'carbs': 20, 'icon': Icons.icecream},
          {'name': 'Green Smoothie', 'calories': 120, 'protein': 8, 'carbs': 25, 'icon': Icons.local_drink},
        ];
      case 'muscle_gain':
        return [
          {'name': 'Protein Pancakes', 'calories': 300, 'protein': 25, 'carbs': 35, 'icon': Icons.cake},
          {'name': 'Banana with Peanut Butter', 'calories': 200, 'protein': 8, 'carbs': 30, 'icon': Icons.food_bank},
        ];
      default:
        return [
          {'name': 'Oatmeal with Fruits', 'calories': 250, 'protein': 10, 'carbs': 45, 'icon': Icons.rice_bowl},
          {'name': 'Coffee', 'calories': 50, 'protein': 1, 'carbs': 8, 'icon': Icons.coffee},
        ];
    }
  }

  List<Map<String, dynamic>> _getLunchMeals() {
    switch (selectedGoal) {
      case 'weight_loss':
        return [
          {'name': 'Grilled Chicken Salad', 'calories': 300, 'protein': 35, 'carbs': 15, 'icon': Icons.grass},
          {'name': 'Vegetable Soup', 'calories': 120, 'protein': 5, 'carbs': 20, 'icon': Icons.soup_kitchen},
        ];
      case 'muscle_gain':
        return [
          {'name': 'Chicken & Rice Bowl', 'calories': 450, 'protein': 40, 'carbs': 50, 'icon': Icons.rice_bowl},
          {'name': 'Protein Shake', 'calories': 200, 'protein': 25, 'carbs': 15, 'icon': Icons.local_drink},
        ];
      default:
        return [
          {'name': 'Turkey Sandwich', 'calories': 350, 'protein': 25, 'carbs': 40, 'icon': Icons.lunch_dining},
          {'name': 'Mixed Vegetables', 'calories': 100, 'protein': 4, 'carbs': 20, 'icon': Icons.eco},
        ];
    }
  }

  List<Map<String, dynamic>> _getDinnerMeals() {
    switch (selectedGoal) {
      case 'weight_loss':
        return [
          {'name': 'Grilled Salmon', 'calories': 250, 'protein': 30, 'carbs': 5, 'icon': Icons.set_meal},
          {'name': 'Steamed Broccoli', 'calories': 80, 'protein': 5, 'carbs': 15, 'icon': Icons.eco},
        ];
      case 'muscle_gain':
        return [
          {'name': 'Beef Stir Fry', 'calories': 400, 'protein': 35, 'carbs': 30, 'icon': Icons.restaurant},
          {'name': 'Brown Rice', 'calories': 200, 'protein': 5, 'carbs': 45, 'icon': Icons.rice_bowl},
        ];
      default:
        return [
          {'name': 'Grilled Chicken Breast', 'calories': 300, 'protein': 35, 'carbs': 10, 'icon': Icons.restaurant},
          {'name': 'Sweet Potato', 'calories': 150, 'protein': 3, 'carbs': 35, 'icon': Icons.food_bank},
        ];
    }
  }

  List<Map<String, dynamic>> _getSnackMeals() {
    return [
      {'name': 'Apple with Almonds', 'calories': 180, 'protein': 6, 'carbs': 25, 'icon': Icons.apple},
      {'name': 'Protein Bar', 'calories': 200, 'protein': 20, 'carbs': 15, 'icon': Icons.cookie},
    ];
  }

  int _calculateTotalCalories(List<Map<String, dynamic>> meals) {
    return meals.fold(0, (sum, meal) => sum + (meal['calories'] as int));
  }

  void _updateCaloriesForGoal() {
    setState(() {
      switch (selectedGoal) {
        case 'weight_loss':
          dailyCalories = 1600;
          consumedCalories = 1100;
          break;
        case 'muscle_gain':
          dailyCalories = 2200;
          consumedCalories = 1500;
          break;
        case 'maintenance':
          dailyCalories = 1900;
          consumedCalories = 1300;
          break;
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}