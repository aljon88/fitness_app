import 'package:flutter/material.dart';
import 'dart:async';
import 'workout_session_screen.dart';
import 'exercise_demo_screen.dart';
import '../widgets/ai_coach_character.dart';
import '../services/navigation_service.dart';
import '../models/navigation_state.dart';
import '../widgets/navigation_widgets.dart';
import '../models/exercise.dart';
import '../services/exercise_database.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Map<String, dynamic> workout;
  final Map<String, dynamic> profile;
  final VoidCallback onWorkoutCompleted;

  const WorkoutDetailScreen({
    Key? key,
    required this.workout,
    required this.profile,
    required this.onWorkoutCompleted,
  }) : super(key: key);

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late TabController _tabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentExerciseIndex = 0;
  bool _showingDemo = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _tabController = TabController(length: 2, vsync: this);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.workout['exercises'] as List<Map<String, dynamic>>;
    final currentExercise = exercises[_currentExerciseIndex];
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
          child: SingleChildScrollView(
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
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.workout['title'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Day ${widget.workout['day']} • ${widget.workout['duration']}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isSmallScreen ? 11 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!_showingDemo)
                          TextButton(
                            onPressed: () => setState(() => _showingDemo = true),
                            child: Text(
                              'Demo',
                              style: TextStyle(
                                color: Color(0xFF6C5CE7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
                            _getCoachMessage(),
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
                  
                  // Main Content
                  _showingDemo 
                      ? _buildCompactDemoView(currentExercise, isSmallScreen)
                      : _buildCompactExerciseList(exercises, isSmallScreen),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: MainNavigationBar(currentScreen: NavigationScreen.workoutDetail),
      floatingActionButton: WorkoutCameraFAB(),
    );
  }

  Widget _buildCompactDemoView(Map<String, dynamic> exercise, bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Exercise Demo - Compact
              Container(
                height: isSmallScreen ? 180 : 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Demo content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getExerciseIcon(exercise['name']),
                              size: isSmallScreen ? 40 : 50,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => setState(() => _isPlaying = !_isPlaying),
                              child: Container(
                                width: isSmallScreen ? 50 : 60,
                                height: isSmallScreen ? 50 : 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Color(0xFF6C5CE7),
                                  size: isSmallScreen ? 24 : 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Exercise Name
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            exercise['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      // Exercise Stats
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF6C5CE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${exercise['reps']} × ${exercise['sets']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 10 : 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              // Description - Compact
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF6C5CE7), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      exercise['instructions'],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isSmallScreen ? 11 : 12,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.amber, size: 14),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              exercise['tips'],
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isSmallScreen ? 10 : 11,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Action Buttons - Compact
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: isSmallScreen ? 40 : 44,
                      child: ElevatedButton(
                        onPressed: () {
                        final exercises = widget.workout['exercises'] as List<Map<String, dynamic>>;
                        _showExerciseDemo(exercises[_currentExerciseIndex]);
                      },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'View Demo',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: isSmallScreen ? 40 : 44,
                      child: ElevatedButton(
                        onPressed: _startWorkoutWithCamera,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6C5CE7),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: Color(0xFF6C5CE7).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: isSmallScreen ? 16 : 18),
                            SizedBox(width: 6),
                            Text(
                              'Start Workout',
                              style: TextStyle(
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
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionTab(Map<String, dynamic> exercise) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF6C5CE7), size: 20),
              SizedBox(width: 8),
              Text(
                'How to Perform',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            exercise['instructions'],
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Pro Tip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Text(
              exercise['tips'],
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab(Map<String, dynamic> exercise) {
    List<String> steps = _getExerciseSteps(exercise['name']);
    
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step-by-Step Guide',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(0xFF6C5CE7),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            steps[index],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getExerciseSteps(String exerciseName) {
    switch (exerciseName.toLowerCase()) {
      case 'push-ups':
        return [
          'Start in a plank position with hands shoulder-width apart',
          'Keep your body in a straight line from head to heels',
          'Lower your chest toward the ground by bending your elbows',
          'Push back up to the starting position',
          'Repeat for the desired number of repetitions'
        ];
      case 'squats':
        return [
          'Stand with feet shoulder-width apart',
          'Keep your chest up and core engaged',
          'Lower your body by bending your knees and hips',
          'Go down until your thighs are parallel to the floor',
          'Push through your heels to return to standing'
        ];
      case 'plank':
        return [
          'Start in a push-up position',
          'Lower onto your forearms',
          'Keep your body in a straight line',
          'Engage your core muscles',
          'Hold the position for the specified time'
        ];
      case 'jumping jacks':
        return [
          'Stand with feet together and arms at your sides',
          'Jump while spreading your feet shoulder-width apart',
          'Simultaneously raise your arms overhead',
          'Jump back to the starting position',
          'Repeat in a continuous, rhythmic motion'
        ];
      default:
        return [
          'Follow the exercise demonstration',
          'Maintain proper form throughout',
          'Breathe steadily during the movement',
          'Complete the specified repetitions',
          'Rest between sets as needed'
        ];
    }
  }

  String _getCoachMessage() {
    final exercises = widget.workout['exercises'] as List<Map<String, dynamic>>;
    final currentExercise = exercises[_currentExerciseIndex];
    
    if (_showingDemo) {
      return "Let's master the ${currentExercise['name']}! Watch the demo and get ready to crush it! 💪";
    } else {
      return "Today's workout has ${exercises.length} exercises. You've got this! Let's make it count! 🔥";
    }
  }

  void _startWorkoutWithCamera() {
    // Show preparation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.camera_alt, color: Colors.white, size: 40),
            ),
            SizedBox(height: 20),
            Text(
              'Get Ready!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Position yourself in front of the camera. The workout will start in 3 seconds.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              ),
            ),
          ],
        ),
      ),
    );

    // Auto-close dialog and start camera after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close dialog
      NavigationService().startWorkoutSession(widget.workout);
    });
  }

  Widget _buildCompactExerciseList(List<Map<String, dynamic>> exercises, bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Exercise List Header - Compact
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Exercises',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${exercises.length} exercises • ${widget.workout['duration']}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isSmallScreen ? 10 : 11,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.fitness_center, color: Color(0xFF6C5CE7), size: 20),
                ],
              ),
            ),
            
            SizedBox(height: isSmallScreen ? 12 : 16),
            
            // Exercise List - Compact
            Container(
              height: isSmallScreen ? 280 : 320,
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final isSelected = index == _currentExerciseIndex;
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Color(0xFF6C5CE7).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? Color(0xFF6C5CE7)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Color(0xFF6C5CE7)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          _getExerciseIcon(exercise['name']),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        exercise['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${exercise['reps']} reps × ${exercise['sets']} sets',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isSmallScreen ? 10 : 11,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => _showExerciseDemo(exercise),
                        icon: Icon(
                          Icons.play_circle_outline,
                          color: Color(0xFF6C5CE7),
                          size: 20,
                        ),
                      ),
                      onTap: () => _showExerciseDemo(exercise),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: isSmallScreen ? 16 : 20),
            
            // Start Workout Button - Compact
            Container(
              width: double.infinity,
              height: isSmallScreen ? 44 : 48,
              child: ElevatedButton(
                onPressed: _startWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: Color(0xFF6C5CE7).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center_rounded, size: isSmallScreen ? 18 : 20),
                    SizedBox(width: 8),
                    Text(
                      'Start Full Workout',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _getExerciseIcon(String exerciseName) {
    switch (exerciseName.toLowerCase()) {
      case 'push-ups':
        return Icons.fitness_center;
      case 'squats':
        return Icons.accessibility_new;
      case 'jumping jacks':
        return Icons.directions_run;
      case 'plank':
        return Icons.horizontal_rule;
      case 'burpees':
        return Icons.sports_gymnastics;
      case 'lunges':
        return Icons.directions_walk;
      default:
        return Icons.fitness_center;
    }
  }

  void _startWorkout() {
    NavigationService().startWorkoutSession(widget.workout);
  }

  void _showExerciseDemo(Map<String, dynamic> exerciseData) {
    // Convert exercise data to Exercise model
    Exercise exercise = Exercise(
      id: exerciseData['name'].toString().toLowerCase().replaceAll(' ', '_').replaceAll('-', '_'),
      name: exerciseData['name'],
      description: 'Effective exercise for building strength and endurance',
      instructions: exerciseData['instructions'].toString().split('\n'),
      category: _getExerciseCategory(exerciseData['name']),
      difficulty: exerciseData['difficulty'] ?? 'beginner',
      duration: 30,
      reps: exerciseData['reps'],
      sets: exerciseData['sets'],
      restTime: exerciseData['restTime'],
      targetMuscles: exerciseData['targetMuscles'].toString().split(', '),
      equipment: ['None'],
      tips: exerciseData['tips'].toString().split('\n'),
      commonMistakes: ['Maintain proper form', 'Don\'t rush the movement'],
      caloriesBurned: 5,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDemoScreen(
          exercise: exercise,
          onStartWorkout: () {
            Navigator.pop(context); // Close demo screen
            _startWorkoutWithCamera(); // Start camera workout
          },
        ),
      ),
    );
  }

  String _getExerciseCategory(String exerciseName) {
    switch (exerciseName.toLowerCase()) {
      case 'push-ups':
      case 'push ups':
      case 'burpees':
      case 'plank':
        return 'Strength';
      case 'jumping jacks':
      case 'mountain climbers':
        return 'Cardio';
      case 'squats':
      case 'lunges':
        return 'Strength';
      default:
        return 'Strength';
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}