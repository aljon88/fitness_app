import 'package:flutter/material.dart';
import 'dart:async';

class OnboardingWizardScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onCompleted;
  final Map<String, dynamic>? initialUserData;

  const OnboardingWizardScreen({
    Key? key, 
    required this.onCompleted,
    this.initialUserData,
  }) : super(key: key);

  @override
  _OnboardingWizardScreenState createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> 
    with TickerProviderStateMixin {
  int currentStep = 1;
  final int totalSteps = 9; // Separate motivation and goals steps
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Form controllers for basic info
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  Map<String, dynamic> userProfile = {
    'name': '',
    'age': '',
    'height': '',
    'weight': '',
    'gender': '',
    'goals': [],
    'primaryGoal': '',
    'motivation': '',
    'equipment': [],
    'workoutLocation': 'Floor', // Default for home workouts
    'selectedAdvice': '',
    'fitnessLevel': 'beginner',
    'allergies': [],
    'dietaryPreferences': [],
  };

  @override
  void initState() {
    super.initState();
    
    // Pre-populate with initial user data if provided
    if (widget.initialUserData != null) {
      userProfile.addAll(widget.initialUserData!);
      // Pre-populate text controllers
      if (userProfile['name'] != null && userProfile['name'].isNotEmpty) {
        _nameController.text = userProfile['name'];
      }
      if (userProfile['email'] != null && userProfile['email'].isNotEmpty) {
        // We don't have an email field in onboarding, but we store it
        userProfile['email'] = widget.initialUserData!['email'];
      }
    }
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
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
          child: Column(
            children: [
              // Progress indicator - Compact
              _buildCompactProgressHeader(isSmallScreen),
              
              // Current step content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildCurrentStep(isSmallScreen),
                ),
              ),
              
              // Navigation buttons - Compact
              _buildCompactNavigationButtons(isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactProgressHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step $currentStep/$totalSteps',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
            minHeight: isSmallScreen ? 4 : 6,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(bool isSmallScreen) {
    switch (currentStep) {
      case 1: return _buildWelcomeStep(isSmallScreen);
      case 2: return _buildBasicInfoStep(isSmallScreen);
      case 3: return _buildGenderStep(isSmallScreen);
      case 4: return _buildFitnessLevelStep(isSmallScreen);
      case 5: return _buildAllergyStep(isSmallScreen);
      case 6: return _buildMotivationStep(isSmallScreen);
      case 7: return _buildGoalsStep(isSmallScreen);
      case 8: return _buildMotivationalAdviceStep(isSmallScreen);
      case 9: return _buildCompletionStep(isSmallScreen);
      default: return Container();
    }
  }

  Widget _buildWelcomeStep(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 16 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: isSmallScreen ? 20 : 40),
          // AI Character - Compact
          Container(
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: isSmallScreen ? 40 : 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 32),
          Text(
            'Meet Your AI Coach!',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 22 : 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'I\'m here to guide you, and I\'d love for us to get to know each other!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 14 : 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 40 : 60),
        ],
      ),
    );
  }
  Widget _buildBasicInfoStep(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          // AI Character with message - Compact
          Container(
            width: isSmallScreen ? 60 : 70,
            height: isSmallScreen ? 60 : 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology, size: isSmallScreen ? 30 : 35, color: Colors.white),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            'Tell me about yourself',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 24 : 32),
          
          // Basic info form - Compact
          _buildCompactTextField('Full Name', _nameController, 'name', isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildCompactTextField('Age', _ageController, 'age', isSmallScreen, isNumber: true),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildCompactTextField('Height (cm)', _heightController, 'height', isSmallScreen, isNumber: true),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildCompactTextField('Weight (kg)', _weightController, 'weight', isSmallScreen, isNumber: true),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCompactTextField(String label, TextEditingController controller, String field, bool isSmallScreen, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 14 : 16),
        onChanged: (value) => setState(() => userProfile[field] = value),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70, fontSize: isSmallScreen ? 12 : 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isSmallScreen ? 14 : 16),
        ),
      ),
    );
  }
  Widget _buildGenderStep(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          // AI Character with message - Compact
          Container(
            width: isSmallScreen ? 60 : 70,
            height: isSmallScreen ? 60 : 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology, size: isSmallScreen ? 30 : 35, color: Colors.white),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            'What\'s your Identity?',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 24 : 32),
          
          // Gender options - Compact
          _buildCompactGenderOption('Male', Icons.male, 'male', isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildCompactGenderOption('Female', Icons.female, 'female', isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildCompactGenderOption('LGBT', Icons.favorite, 'lgbt', isSmallScreen),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCompactGenderOption(String title, IconData icon, String value, bool isSmallScreen) {
    bool isSelected = userProfile['gender'] == value;
    
    return GestureDetector(
      onTap: () => setState(() => userProfile['gender'] = value),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6C5CE7) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF6C5CE7) : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFitnessLevelStep(bool isSmallScreen) {
    final levels = [
      {
        'level': 'beginner',
        'title': 'Beginner',
        'subtitle': 'New to fitness or returning after a break',
        'description': 'Simple exercises, basic movements',
        'icon': Icons.child_friendly,
        'color': Colors.green,
      },
      {
        'level': 'intermediate',
        'title': 'Intermediate',
        'subtitle': 'Some fitness experience, can do basic exercises',
        'description': 'Moderate intensity, varied exercises',
        'icon': Icons.fitness_center,
        'color': Colors.orange,
      },
      {
        'level': 'advanced',
        'title': 'Advanced',
        'subtitle': 'Regular exerciser, comfortable with challenging workouts',
        'description': 'High intensity, complex movements',
        'icon': Icons.sports_gymnastics,
        'color': Colors.red,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          Text(
            'What\'s your fitness level?',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'Choose the level that best describes you',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 20 : 32),
          
          ...levels.map((level) {
            bool isSelected = userProfile['fitnessLevel'] == level['level'];
            
            return Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
              child: GestureDetector(
                onTap: () => setState(() => userProfile['fitnessLevel'] = level['level']),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF6C5CE7).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Color(0xFF6C5CE7) : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: isSmallScreen ? 45 : 50,
                        height: isSmallScreen ? 45 : 50,
                        decoration: BoxDecoration(
                          color: (level['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 22 : 25),
                        ),
                        child: Icon(
                          level['icon'] as IconData,
                          color: level['color'] as Color,
                          size: isSmallScreen ? 22 : 24,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level['title'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 15 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              level['subtitle'] as String,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isSmallScreen ? 11 : 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              level['description'] as String,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: isSmallScreen ? 10 : 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: isSmallScreen ? 20 : 24,
                          height: isSmallScreen ? 20 : 24,
                          decoration: BoxDecoration(
                            color: Color(0xFF6C5CE7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: isSmallScreen ? 12 : 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget _buildAllergyStep(bool isSmallScreen) {
    final allergies = [
      {
        'name': 'Milk & Dairy',
        'description': 'Milk, cheese, yogurt, butter',
        'icon': '🥛',
        'value': 'dairy',
      },
      {
        'name': 'Eggs',
        'description': 'Chicken eggs and egg products',
        'icon': '🥚',
        'value': 'eggs',
      },
      {
        'name': 'Nuts',
        'description': 'Peanuts, tree nuts, nut oils',
        'icon': '🥜',
        'value': 'nuts',
      },
      {
        'name': 'Fish & Seafood',
        'description': 'Fish, shellfish, seaweed',
        'icon': '🐟',
        'value': 'seafood',
      },
      {
        'name': 'Wheat & Gluten',
        'description': 'Bread, pasta, wheat products',
        'icon': '🌾',
        'value': 'gluten',
      },
      {
        'name': 'No Allergies',
        'description': 'I can eat all foods safely',
        'icon': '✅',
        'value': 'none',
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          Text(
            'Do you have any food allergies?',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'Select all that apply to keep you safe',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 20 : 32),
          
          ...allergies.map((allergy) {
            bool isSelected = (userProfile['allergies'] as List).contains(allergy['value']);
            bool isNone = allergy['value'] == 'none';
            
            return Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 10),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    List allergiesList = userProfile['allergies'] as List;
                    
                    if (isNone) {
                      // If "No Allergies" is selected, clear all others
                      allergiesList.clear();
                      if (!isSelected) {
                        allergiesList.add('none');
                      }
                    } else {
                      // Remove "No Allergies" if any specific allergy is selected
                      allergiesList.remove('none');
                      
                      if (isSelected) {
                        allergiesList.remove(allergy['value']);
                      } else {
                        allergiesList.add(allergy['value']);
                      }
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? (isNone ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2))
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected 
                          ? (isNone ? Colors.green : Colors.red)
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: isSmallScreen ? 40 : 45,
                        height: isSmallScreen ? 40 : 45,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? (isNone ? Colors.green : Colors.red)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 22),
                        ),
                        child: Center(
                          child: Text(
                            allergy['icon'] as String,
                            style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allergy['name'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 14 : 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              allergy['description'] as String,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isSmallScreen ? 10 : 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: isSmallScreen ? 20 : 24,
                          height: isSmallScreen ? 20 : 24,
                          decoration: BoxDecoration(
                            color: isNone ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: isSmallScreen ? 12 : 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget _buildMotivationStep(bool isSmallScreen) {
    final motivations = [
      {'title': 'Breakup', 'icon': Icons.broken_image, 'color': Colors.red},
      {'title': 'Passion', 'icon': Icons.local_fire_department, 'color': Colors.orange},
      {'title': 'Family', 'icon': Icons.family_restroom, 'color': Colors.pink},
      {'title': 'Goals', 'icon': Icons.flag, 'color': Colors.blue},
      {'title': 'Self-improvement', 'icon': Icons.psychology, 'color': Colors.purple},
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          Text(
            'What motivates you the most?',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 24 : 32),
          
          ...motivations.map((motivation) {
            bool isSelected = userProfile['motivation'] == motivation['title'];
            
            return Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
              child: GestureDetector(
                onTap: () => setState(() => userProfile['motivation'] = motivation['title']),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF6C5CE7) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Color(0xFF6C5CE7) : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: isSmallScreen ? 40 : 45,
                        height: isSmallScreen ? 40 : 45,
                        decoration: BoxDecoration(
                          color: (motivation['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 22),
                        ),
                        child: Icon(
                          motivation['icon'] as IconData,
                          color: motivation['color'] as Color,
                          size: isSmallScreen ? 20 : 22,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),
                      Text(
                        motivation['title'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGoalsStep(bool isSmallScreen) {
    final goals = [
      {
        'title': 'Strength',
        'subtitle': 'Build power and muscle strength',
        'description': 'Progressive strength-building workouts',
        'icon': Icons.fitness_center,
        'color': Colors.blue,
      },
      {
        'title': 'Weight Loss',
        'subtitle': 'Burn calories and get lean',
        'description': 'Cardio-focused workouts for fat burning',
        'icon': Icons.trending_down,
        'color': Colors.red,
      },
      {
        'title': 'Muscle Gain',
        'subtitle': 'Build muscle mass and size',
        'description': 'Strength training and resistance exercises',
        'icon': Icons.sports_gymnastics,
        'color': Colors.indigo,
      },
      {
        'title': 'Flexibility',
        'subtitle': 'Improve mobility and movement',
        'description': 'Stretching and mobility exercises',
        'icon': Icons.self_improvement,
        'color': Colors.teal,
      },
      {
        'title': 'Healthy Lifestyle',
        'subtitle': 'Stay active and feel great',
        'description': 'Balanced fitness for overall wellness',
        'icon': Icons.favorite,
        'color': Colors.green,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          Text(
            'What is your main fitness goal?',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'Choose your primary focus',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 24 : 32),
          
          ...goals.map((goal) {
            bool isSelected = userProfile['primaryGoal'] == goal['title'];
            
            return Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    userProfile['primaryGoal'] = goal['title'];
                    // Also update the goals array for backward compatibility
                    userProfile['goals'] = [goal['title']];
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF6C5CE7).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Color(0xFF6C5CE7) : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: isSmallScreen ? 45 : 50,
                        height: isSmallScreen ? 45 : 50,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Color(0xFF6C5CE7) 
                              : (goal['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 22 : 25),
                        ),
                        child: Icon(
                          goal['icon'] as IconData,
                          color: isSelected ? Colors.white : goal['color'] as Color,
                          size: isSmallScreen ? 22 : 24,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['title'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 15 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              goal['subtitle'] as String,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isSmallScreen ? 11 : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              goal['description'] as String,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: isSmallScreen ? 10 : 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: isSmallScreen ? 20 : 24,
                          height: isSmallScreen ? 20 : 24,
                          decoration: BoxDecoration(
                            color: Color(0xFF6C5CE7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: isSmallScreen ? 12 : 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget _buildMotivationalAdviceStep(bool isSmallScreen) {
    final advices = [
      {
        'title': 'Start Small, Dream Big',
        'advice': 'Every expert was once a beginner. Your journey starts with a single step!',
        'icon': Icons.rocket_launch,
        'color': Colors.blue,
      },
      {
        'title': 'Consistency Over Perfection',
        'advice': 'It\'s better to do 10 minutes daily than 2 hours once a week. Small steps lead to big changes!',
        'icon': Icons.repeat,
        'color': Colors.green,
      },
      {
        'title': 'Listen to Your Body',
        'advice': 'Rest when you need it, push when you can. Your body knows what it needs.',
        'icon': Icons.favorite,
        'color': Colors.red,
      },
      {
        'title': 'Celebrate Small Wins',
        'advice': 'Every workout completed is a victory. Celebrate your progress, no matter how small!',
        'icon': Icons.celebration,
        'color': Colors.orange,
      },
      {
        'title': 'You\'re Stronger Than You Think',
        'advice': 'The only impossible journey is the one you never begin. You\'ve got this!',
        'icon': Icons.psychology,
        'color': Colors.purple,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 60 : 70,
            height: isSmallScreen ? 60 : 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb, size: isSmallScreen ? 30 : 35, color: Colors.white),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            'A little motivation for your journey',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'Choose the advice that resonates with you most',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 24 : 32),
          
          ...advices.map((advice) {
            bool isSelected = userProfile['selectedAdvice'] == advice['title'];
            
            return Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
              child: GestureDetector(
                onTap: () => setState(() => userProfile['selectedAdvice'] = advice['title']),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF6C5CE7).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Color(0xFF6C5CE7) : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 40 : 45,
                            height: isSmallScreen ? 40 : 45,
                            decoration: BoxDecoration(
                              color: (advice['color'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 22),
                            ),
                            child: Icon(
                              advice['icon'] as IconData,
                              color: advice['color'] as Color,
                              size: isSmallScreen ? 20 : 22,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 12 : 16),
                          Expanded(
                            child: Text(
                              advice['title'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: isSmallScreen ? 20 : 24,
                              height: isSmallScreen ? 20 : 24,
                              decoration: BoxDecoration(
                                color: Color(0xFF6C5CE7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: isSmallScreen ? 12 : 16,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Text(
                        advice['advice'] as String,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isSmallScreen ? 13 : 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget _buildCompletionStep(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 12 : 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: isSmallScreen ? 20 : 40),
          Container(
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.celebration,
              size: isSmallScreen ? 40 : 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 32),
          Text(
            'You\'re All Set!',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 22 : 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'I\'ve created a personalized program just for you. Let\'s start your transformation journey!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 16 : 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 24 : 32),
          
          // Summary of selections - Compact
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Profile Summary:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                _buildCompactSummaryItem('Name', userProfile['name'], isSmallScreen),
                _buildCompactSummaryItem('Age', '${userProfile['age']} years old', isSmallScreen),
                _buildCompactSummaryItem('Height', '${userProfile['height']} cm', isSmallScreen),
                _buildCompactSummaryItem('Weight', '${userProfile['weight']} kg', isSmallScreen),
                _buildCompactSummaryItem('Gender', userProfile['gender'], isSmallScreen),
                _buildCompactSummaryItem('Fitness Level', userProfile['fitnessLevel'], isSmallScreen),
                _buildCompactSummaryItem('Allergies', (userProfile['allergies'] as List).isEmpty ? 'None' : (userProfile['allergies'] as List).join(', '), isSmallScreen),
                _buildCompactSummaryItem('Motivation', userProfile['motivation'], isSmallScreen),
                _buildCompactSummaryItem('Primary Goal', userProfile['primaryGoal'], isSmallScreen),
                _buildCompactSummaryItem('Chosen Advice', userProfile['selectedAdvice'], isSmallScreen),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 40 : 60),
        ],
      ),
    );
  }

  Widget _buildCompactSummaryItem(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCompactNavigationButtons(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 16 : 20),
      child: Row(
        children: [
          if (currentStep > 1)
            Expanded(
              child: Container(
                height: isSmallScreen ? 44 : 48,
                child: ElevatedButton(
                  onPressed: _previousStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          if (currentStep > 1) SizedBox(width: 12),
          Expanded(
            flex: currentStep == 1 ? 1 : 2,
            child: Container(
              height: isSmallScreen ? 44 : 48,
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: Color(0xFF6C5CE7).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  currentStep == totalSteps ? 'Start My Journey!' : 'Continue',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (currentStep) {
      case 1: return true; // Welcome step
      case 2: return userProfile['name'].isNotEmpty && 
                     userProfile['age'].isNotEmpty && 
                     userProfile['height'].isNotEmpty && 
                     userProfile['weight'].isNotEmpty; // Basic info step
      case 3: return userProfile['gender'].isNotEmpty; // Gender step
      case 4: return userProfile['fitnessLevel'].isNotEmpty; // Fitness level step
      case 5: return true; // Allergy step (optional, can be empty)
      case 6: return userProfile['motivation'].isNotEmpty; // Motivation step
      case 7: return userProfile['primaryGoal'].isNotEmpty; // Goals step
      case 8: return userProfile['selectedAdvice'].isNotEmpty; // Motivational advice step
      case 9: return true; // Completion step
      default: return false;
    }
  }

  void _nextStep() {
    if (currentStep < totalSteps) {
      setState(() {
        currentStep++;
      });
      _fadeController.reset();
      _fadeController.forward();
    } else {
      // Complete onboarding
      widget.onCompleted(userProfile);
    }
  }

  void _previousStep() {
    if (currentStep > 1) {
      setState(() {
        currentStep--;
      });
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}