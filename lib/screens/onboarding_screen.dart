import 'package:flutter/material.dart';
import '../services/user_storage_service.dart';
import '../services/firebase_auth_service.dart';
import 'dashboard_screen.dart';

// 🎯 User Onboarding - Setup Profile
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final UserStorageService _userService = UserStorageService();
  
  // 📋 User data collection
  int currentStep = 0;
  Map<String, dynamic> userProfile = {
    'name': '',
    'age': '',
    'height': '',
    'weight': '',
    'goal': '',
    'fitnessLevel': '',
    'workoutDays': 3,
    'workoutDuration': 30,
    'restrictions': <String>[],
  };
  
  // Step controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E88E5),
              Color(0xFF1565C0),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              currentStep = index;
            });
          },
          children: [
            _buildWelcomeStep(),
            _buildPersonalInfoStep(),
            _buildGoalsStep(),
            _buildFitnessLevelStep(),
            _buildPreferencesStep(),
            _buildRestrictionsStep(),
            _buildCompleteStep(),
          ],
        ),
      ),
    );
  }
  
  // 👋 Welcome Step
  Widget _buildWelcomeStep() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 100,
            color: Colors.white,
          ),
          SizedBox(height: 30),
          Text(
            'Welcome to FitFlow!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Let\'s create your personalized fitness profile to get the best workout recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => _nextStep(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1E88E5),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Get Started',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  // 👤 Personal Info Step
  Widget _buildPersonalInfoStep() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 40),
          
          // Name input
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Your Name',
              prefixIcon: Icon(Icons.person),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // Age input
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Age',
              prefixIcon: Icon(Icons.cake),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // Height and Weight
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Height (cm)',
                    prefixIcon: Icon(Icons.height),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icon(Icons.monitor_weight),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          
          _buildNavigationButtons(),
        ],
      ),
    );
  }
  
  // 🎯 Goals Step
  Widget _buildGoalsStep() {
    final goals = [
      {'id': 'weight_loss', 'title': 'Weight Loss', 'icon': Icons.trending_down, 'desc': 'Burn calories and lose weight'},
      {'id': 'muscle_gain', 'title': 'Muscle Gain', 'icon': Icons.fitness_center, 'desc': 'Build muscle and strength'},
      {'id': 'general_fitness', 'title': 'General Fitness', 'icon': Icons.favorite, 'desc': 'Stay healthy and active'},
      {'id': 'flexibility', 'title': 'Flexibility', 'icon': Icons.self_improvement, 'desc': 'Improve flexibility and mobility'},
    ];
    
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            'What\'s your fitness goal?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 40),
          
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final isSelected = userProfile['goal'] == goal['id'];
                
                return Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        userProfile['goal'] = goal['id'];
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white 
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            goal['icon'] as IconData,
                            size: 40,
                            color: isSelected ? Color(0xFF1E88E5) : Colors.white,
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal['title'] as String,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Color(0xFF1E88E5) : Colors.white,
                                  ),
                                ),
                                Text(
                                  goal['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected ? Color(0xFF1E88E5) : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          _buildNavigationButtons(),
        ],
      ),
    );
  }
  
  // 💪 Fitness Level Step
  Widget _buildFitnessLevelStep() {
    final levels = [
      {'id': 'beginner', 'title': 'Beginner', 'desc': 'New to fitness or getting back into it'},
      {'id': 'intermediate', 'title': 'Intermediate', 'desc': 'Some fitness experience, ready for a challenge'},
      {'id': 'advanced', 'title': 'Advanced', 'desc': 'Very experienced, want intense workouts'},
    ];
    
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            'What\'s your fitness level?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 40),
          
          ...levels.map((level) {
            final isSelected = userProfile['fitnessLevel'] == level['id'];
            
            return Container(
              margin: EdgeInsets.only(bottom: 20),
              child: InkWell(
                onTap: () {
                  setState(() {
                    userProfile['fitnessLevel'] = level['id'];
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level['title'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Color(0xFF1E88E5) : Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        level['desc'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Color(0xFF1E88E5) : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          Spacer(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }
  
  // ⚙️ Preferences Step  
  Widget _buildPreferencesStep() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            'Workout Preferences',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 40),
          
          // Workout days per week
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'Workouts per week: ${userProfile['workoutDays']}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Slider(
                  value: userProfile['workoutDays'].toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.3),
                  onChanged: (value) {
                    setState(() {
                      userProfile['workoutDays'] = value.round();
                    });
                  },
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Workout duration
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'Workout duration: ${userProfile['workoutDuration']} minutes',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Slider(
                  value: userProfile['workoutDuration'].toDouble(),
                  min: 15,
                  max: 90,
                  divisions: 5,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.3),
                  onChanged: (value) {
                    setState(() {
                      userProfile['workoutDuration'] = value.round();
                    });
                  },
                ),
              ],
            ),
          ),
          
          Spacer(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }
  
  // 🚫 Restrictions Step
  Widget _buildRestrictionsStep() {
    final restrictions = [
      'Knee problems',
      'Back problems', 
      'Shoulder problems',
      'Heart condition',
      'Joint issues',
      'No jumping exercises',
      'No high-impact exercises',
    ];
    
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            'Any physical restrictions?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Select any that apply (optional)',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 30),
          
          Expanded(
            child: ListView.builder(
              itemCount: restrictions.length,
              itemBuilder: (context, index) {
                final restriction = restrictions[index];
                final isSelected = userProfile['restrictions'].contains(restriction);
                
                return CheckboxListTile(
                  title: Text(
                    restriction,
                    style: TextStyle(color: Colors.white),
                  ),
                  value: isSelected,
                  activeColor: Colors.white,
                  checkColor: Color(0xFF1E88E5),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        userProfile['restrictions'].add(restriction);
                      } else {
                        userProfile['restrictions'].remove(restriction);
                      }
                    });
                  },
                );
              },
            ),
          ),
          
          _buildNavigationButtons(),
        ],
      ),
    );
  }
  
  // ✅ Complete Step
  Widget _buildCompleteStep() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 100,
            color: Colors.white,
          ),
          SizedBox(height: 30),
          Text(
            'Profile Complete!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Great! We\'ve created your personalized fitness profile. You\'re ready to start your fitness journey!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: _completeOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1E88E5),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Start My Fitness Journey!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  // 🎮 Navigation buttons
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        
        if (currentStep > 0) SizedBox(width: 15),
        
        Expanded(
          child: ElevatedButton(
            onPressed: _canProceed() ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1E88E5),
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              currentStep == 6 ? 'Complete' : 'Next',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
  
  // 🔄 Navigation methods
  void _nextStep() {
    if (currentStep < 6) {
      _saveCurrentStep();
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  void _previousStep() {
    if (currentStep > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  // ✅ Check if user can proceed
  bool _canProceed() {
    switch (currentStep) {
      case 0: return true; // Welcome
      case 1: return nameController.text.isNotEmpty && ageController.text.isNotEmpty; // Personal info
      case 2: return userProfile['goal'].isNotEmpty; // Goals
      case 3: return userProfile['fitnessLevel'].isNotEmpty; // Fitness level
      case 4: return true; // Preferences
      case 5: return true; // Restrictions
      case 6: return true; // Complete
      default: return false;
    }
  }
  
  // 💾 Save current step data
  void _saveCurrentStep() {
    switch (currentStep) {
      case 1: // Personal info
        userProfile['name'] = nameController.text;
        userProfile['age'] = int.tryParse(ageController.text) ?? 0;
        userProfile['height'] = int.tryParse(heightController.text) ?? 0;
        userProfile['weight'] = int.tryParse(weightController.text) ?? 0;
        break;
    }
  }
  
  // 🎉 Complete onboarding
  Future<void> _completeOnboarding() async {
    _saveCurrentStep();
    
    try {
      // Save user profile
      await _userService.saveUserProfile(userProfile);
      
      // Mark onboarding as complete
      await _userService.setOnboardingComplete(true);
      
      // Navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
      
    } catch (e) {
      print('Error completing onboarding: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile. Please try again.')),
      );
    }
  }
  
  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }
}