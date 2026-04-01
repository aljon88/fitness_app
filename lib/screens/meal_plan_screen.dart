import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal_plan.dart';
import '../services/meal_plan_generator.dart';
import '../services/real_time_calendar_service.dart';
import '../services/navigation_service.dart';
import '../models/navigation_state.dart';
import '../widgets/navigation_widgets.dart';

class MealPlanScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const MealPlanScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  MealPlan? _mealPlan;
  int _selectedDayIndex = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _calendarDays = [];
  final RealTimeCalendarService _calendarService = RealTimeCalendarService();

  @override
  void initState() {
    super.initState();
    _loadMealPlanWithCalendar();
    _selectedDayIndex = 0;
  }

  Future<void> _loadMealPlanWithCalendar() async {
    setState(() => _isLoading = true);
    
    String fitnessLevel = widget.profile['fitnessLevel'] ?? 'beginner';
    String primaryGoal = widget.profile['primaryGoal'] ?? 'Healthy Lifestyle';
    List<String> allergies = List<String>.from(widget.profile['allergies'] ?? []);
    String userId = widget.profile['uid'] ?? 'user_001';
    
    // Load calendar to get workout schedule
    _calendarDays = await _calendarService.generateProgramCalendar(primaryGoal, fitnessLevel);
    int todayDay = await _calendarService.getTodayProgramDay();
    
    // Get workout schedule for next 7 days
    List<bool> workoutDays = [];
    for (int i = 0; i < 7; i++) {
      int dayIndex = todayDay + i - 1;
      if (dayIndex < _calendarDays.length) {
        workoutDays.add(!_calendarDays[dayIndex]['isRestDay']);
      } else {
        workoutDays.add(true); // Default to workout day
      }
    }
    
    // Generate meal plan aligned with workout schedule
    final mealPlan = await MealPlanGenerator.generateMealPlan(
      primaryGoal,
      fitnessLevel,
      allergies,
      userId,
      startProgramDay: todayDay,
      workoutDays: workoutDays,
    );
    
    setState(() {
      _mealPlan = mealPlan;
      _isLoading = false;
    });
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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _mealPlan == null
                        ? _buildEmptyState()
                        : _buildMealPlanContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainNavigationBar(currentScreen: NavigationScreen.mealPlan),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meal Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _mealPlan != null
                          ? 'Personalized for ${_mealPlan!.fitnessLevel} • ${widget.profile['primaryGoal'] ?? 'General Fitness'}'
                          : 'Loading your nutrition plan...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF00B894).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  color: Color(0xFF00B894),
                  size: 28,
                ),
              ),
            ],
          ),
          if (_mealPlan != null) ...[
            SizedBox(height: 16),
            _buildMacroSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMacroItem(
              'Calories',
              '${_mealPlan!.dailyCalories}',
              'kcal',
              Color(0xFF6C5CE7),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
          Expanded(
            child: _buildMacroItem(
              'Protein',
              '${_mealPlan!.macros.protein}g',
              '${((_mealPlan!.macros.protein * 4 / _mealPlan!.dailyCalories) * 100).round()}%',
              Colors.green,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
          Expanded(
            child: _buildMacroItem(
              'Carbs',
              '${_mealPlan!.macros.carbs}g',
              '${((_mealPlan!.macros.carbs * 4 / _mealPlan!.dailyCalories) * 100).round()}%',
              Colors.orange,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
          Expanded(
            child: _buildMacroItem(
              'Fats',
              '${_mealPlan!.macros.fats}g',
              '${((_mealPlan!.macros.fats * 9 / _mealPlan!.dailyCalories) * 100).round()}%',
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, String subtitle, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF00B894)),
          SizedBox(height: 16),
          Text(
            'Generating your meal plan...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
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
          Icon(Icons.restaurant_menu, size: 64, color: Colors.white30),
          SizedBox(height: 16),
          Text(
            'No meal plan available',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMealPlanWithCalendar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00B894),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: Text('Generate Meal Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanContent() {
    return Column(
      children: [
        _buildDaySelector(),
        SizedBox(height: 16),
        Expanded(
          child: _buildDayMeals(),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    if (_calendarDays.isEmpty) {
      // Fallback to simple date selector
      DateTime now = DateTime.now();
      return Container(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: 7,
          itemBuilder: (context, index) {
            DateTime date = now.add(Duration(days: index));
            final isSelected = index == _selectedDayIndex;
            final isToday = index == 0;
            
            List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            String dayName = dayNames[date.weekday - 1];
            
            return _buildDayCard(dayName, date, isSelected, isToday, false, index);
          },
        ),
      );
    }
    
    // Use calendar data
    int todayIndex = _calendarDays.indexWhere((d) => d['isToday']);
    if (todayIndex == -1) todayIndex = 0;
    
    // Show 7 days starting from today
    List<Map<String, dynamic>> weekDays = [];
    for (int i = 0; i < 7 && (todayIndex + i) < _calendarDays.length; i++) {
      weekDays.add(_calendarDays[todayIndex + i]);
    }
    
    return Container(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          var calDay = weekDays[index];
          DateTime date = calDay['date'];
          bool isSelected = index == _selectedDayIndex;
          bool isToday = calDay['isToday'];
          bool isRestDay = calDay['isRestDay'];
          
          String dayName = calDay['dayOfWeekShort'];
          
          return _buildDayCard(dayName, date, isSelected, isToday, isRestDay, index);
        },
      ),
    );
  }
  
  Widget _buildDayCard(String dayName, DateTime date, bool isSelected, bool isToday, bool isRestDay, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedDayIndex = index),
      child: Container(
        width: 70,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isRestDay 
                      ? [Colors.green, Colors.green.shade700]
                      : [Color(0xFF00B894), Color(0xFF00CEC9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isSelected ? null : Color(0xFF1E1F3A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : isToday 
                    ? Color(0xFF00B894) 
                    : isRestDay
                        ? Colors.green.withOpacity(0.3)
                        : Colors.white.withOpacity(0.15),
            width: isToday ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isToday)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Color(0xFF00B894),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'TODAY',
                    style: TextStyle(
                      color: isSelected ? Color(0xFF00B894) : Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              if (isToday) SizedBox(height: 6),
              if (isRestDay && !isSelected)
                Icon(Icons.hotel_rounded, color: Colors.green, size: 16),
              if (isRestDay && !isSelected) SizedBox(height: 4),
              Text(
                dayName,
                style: TextStyle(
                  color: Colors.white.withOpacity(isSelected ? 1.0 : 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${date.day}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 2),
              Text(
                _getMonthName(date.month),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  height: 1.0,
                ),
              ),
              if (isRestDay && isSelected) ...[
                SizedBox(height: 4),
                Text(
                  'REST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _getMonthName(int month) {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildDayMeals() {
    final dayPlan = _mealPlan!.weeklyMeals[_selectedDayIndex];
    
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildMealCard('Breakfast', dayPlan.breakfast, Icons.wb_sunny, Colors.orange),
        SizedBox(height: 16),
        _buildMealCard('Lunch', dayPlan.lunch, Icons.lunch_dining, Colors.green),
        SizedBox(height: 16),
        _buildMealCard('Dinner', dayPlan.dinner, Icons.dinner_dining, Color(0xFF6C5CE7)),
        SizedBox(height: 16),
        ...dayPlan.snacks.map((snack) => Column(
          children: [
            _buildMealCard('Snack', snack, Icons.cookie, Colors.amber),
            SizedBox(height: 16),
          ],
        )),
        _buildDayTotalCard(dayPlan),
        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMealCard(String mealType, Meal meal, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        meal.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                
                // Nutrition info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildNutritionChip(
                          '${meal.calories} cal',
                          Color(0xFF6C5CE7),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildNutritionChip(
                          '${meal.protein}g protein',
                          Colors.green,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildNutritionChip(
                          '${meal.prepTime}min',
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                
                // Ingredients
                ExpansionTile(
                  title: Text(
                    'Ingredients',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white70,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: meal.ingredients.map((ingredient) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: color, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ingredient,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDayTotalCard(DailyMealPlan dayPlan) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00B894).withOpacity(0.2), Color(0xFF00CEC9).withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF00B894).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Daily Total',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTotalItem('Calories', '${dayPlan.totalCalories}', 'kcal', Color(0xFF6C5CE7)),
              _buildTotalItem('Protein', '${_calculateDayProtein(dayPlan)}', 'g', Colors.green),
              _buildTotalItem('Carbs', '${_calculateDayCarbs(dayPlan)}', 'g', Colors.orange),
              _buildTotalItem('Fats', '${_calculateDayFats(dayPlan)}', 'g', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white60,
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
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: unit,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _calculateDayProtein(DailyMealPlan day) {
    return day.breakfast.protein +
           day.lunch.protein +
           day.dinner.protein +
           day.snacks.fold(0, (sum, snack) => sum + snack.protein);
  }

  int _calculateDayCarbs(DailyMealPlan day) {
    return day.breakfast.carbs +
           day.lunch.carbs +
           day.dinner.carbs +
           day.snacks.fold(0, (sum, snack) => sum + snack.carbs);
  }

  int _calculateDayFats(DailyMealPlan day) {
    return day.breakfast.fats +
           day.lunch.fats +
           day.dinner.fats +
           day.snacks.fold(0, (sum, snack) => sum + snack.fats);
  }
}
