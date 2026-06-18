import 'package:flutter/material.dart';
import '../services/user_storage_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/mock_auth_service.dart';
import 'dashboard_screen.dart';

// 🚀 Quick Profile Setup - For users who see empty profile
class QuickProfileSetup extends StatefulWidget {
  @override
  _QuickProfileSetupState createState() => _QuickProfileSetupState();
}

class _QuickProfileSetupState extends State<QuickProfileSetup> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  
  String selectedGoal = '';
  String selectedLevel = '';
  bool isLoading = false;
  
  final goals = [
    {'id': 'weight_loss', 'title': 'Weight Loss', 'icon': Icons.trending_down},
    {'id': 'muscle_gain', 'title': 'Muscle Gain', 'icon': Icons.fitness_center},
    {'id': 'general_fitness', 'title': 'General Fitness', 'icon': Icons.favorite},
    {'id': 'flexibility', 'title': 'Flexibility', 'icon': Icons.self_improvement},
  ];
  
  final levels = [
    {'id': 'beginner', 'title': 'Beginner'},
    {'id': 'intermediate', 'title': 'Intermediate'},
    {'id': 'advanced', 'title': 'Advanced'},
  ];
  
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                
                // Header
                Text(
                  'Quick Setup',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Let\'s get your profile ready in 2 minutes!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 40),
                
                // Name input
                Text(
                  'Your Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                // Age input
                Text(
                  'Your Age',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter your age',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                
                // Fitness Goal
                Text(
                  'Fitness Goal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 15),
                ...goals.map((goal) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedGoal = goal['id'] as String;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedGoal == goal['id'] 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedGoal == goal['id'] 
                                ? Colors.white 
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              goal['icon'] as IconData,
                              color: selectedGoal == goal['id'] 
                                  ? Color(0xFF1E88E5) 
                                  : Colors.white,
                            ),
                            SizedBox(width: 15),
                            Text(
                              goal['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: selectedGoal == goal['id'] 
                                    ? Color(0xFF1E88E5) 
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                
                SizedBox(height: 30),
                
                // Fitness Level
                Text(
                  'Fitness Level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 15),
                ...levels.map((level) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedLevel = level['id'] as String;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedLevel == level['id'] 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedLevel == level['id'] 
                                ? Colors.white 
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          level['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: selectedLevel == level['id'] 
                                ? Color(0xFF1E88E5) 
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                
                SizedBox(height: 40),
                
                // Create Profile Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canCreateProfile() ? _createProfile : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF1E88E5),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Color(0xFF1E88E5),
                            strokeWidth: 2,
                          )
                        : Text(
                            'Create My Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  bool _canCreateProfile() {
    return _nameController.text.isNotEmpty &&
           _ageController.text.isNotEmpty &&
           selectedGoal.isNotEmpty &&
           selectedLevel.isNotEmpty &&
           !isLoading;
  }
  
  Future<void> _createProfile() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Get current user from either Firebase or Mock auth
      String? userEmail;
      String? userId;
      
      final firebaseUser = FirebaseAuthService().currentUser;
      if (firebaseUser != null) {
        userEmail = firebaseUser.email ?? 'user@example.com';
        userId = firebaseUser.uid;
        print('✅ Quick Setup: Using Firebase user: $userEmail');
      } else {
        final mockUser = MockAuthService.instance.getCurrentUser();
        if (mockUser != null) {
          userEmail = mockUser['email'];
          userId = mockUser['uid'];
          print('✅ Quick Setup: Using Mock user: $userEmail');
        } else {
          userEmail = 'user@example.com';
          userId = 'mock_user_id';
          print('⚠️ Quick Setup: No user found, using fallback');
        }
      }
      
      // Create profile data
      final profileData = {
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 25,
        'email': userEmail,
        'goals': [selectedGoal],
        'primaryGoal': selectedGoal,
        'fitnessLevel': selectedLevel,
        'workoutLocation': 'Home',
        'equipment': ['Bodyweight'],
        'height': 170,
        'weight': 70,
        'gender': 'Not specified',
        'birthday': '',
        'motivation': 'Get fit and healthy',
        'selectedAdvice': 'Stay consistent',
        'allergies': [],
        'physicalRestrictions': [],
        'uid': userId,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      print('📝 Quick Setup: Saving profile for $userEmail with UID: $userId');
      print('Profile data keys: ${profileData.keys.toList()}');
      
      // Save profile
      await UserStorageService.completeOnboarding(userEmail!, profileData);
      
      print('✅ Profile created successfully!');
      
      // Navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardScreen(profile: profileData),
        ),
      );
      
    } catch (e) {
      print('❌ Error creating profile: $e');
      
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}