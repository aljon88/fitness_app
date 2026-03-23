import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/exercise_demo_service.dart';

class ExerciseDemoScreen extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onStartWorkout;

  const ExerciseDemoScreen({
    Key? key,
    required this.exercise,
    required this.onStartWorkout,
  }) : super(key: key);

  @override
  _ExerciseDemoScreenState createState() => _ExerciseDemoScreenState();
}

class _ExerciseDemoScreenState extends State<ExerciseDemoScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentStep = 0;
  late List<String> _demoSteps;

  @override
  void initState() {
    super.initState();
    _demoSteps = ExerciseDemoService().getDemoSteps(widget.exercise.id);
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _demoSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
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
              Color(0xFF6C5CE7).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(isSmallScreen),
              
              // Demo Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Exercise Info Card
                      _buildExerciseInfoCard(isSmallScreen),
                      
                      SizedBox(height: 20),
                      
                      // Demo Steps
                      _buildDemoSteps(isSmallScreen),
                      
                      SizedBox(height: 20),
                      
                      // Tips and Safety
                      _buildTipsSection(isSmallScreen),
                      
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              
              // Bottom Controls
              _buildBottomControls(isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercise Demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Learn proper form before starting',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getDifficultyColor(widget.exercise.difficulty),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.exercise.difficulty.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfoCard(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getExerciseIcon(widget.exercise.category),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.exercise.description,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Exercise Stats
          Row(
            children: [
              _buildStatChip('${widget.exercise.duration}s', 'Duration', isSmallScreen),
              SizedBox(width: 12),
              if (widget.exercise.reps != null)
                _buildStatChip('${widget.exercise.reps}', 'Reps', isSmallScreen),
              if (widget.exercise.sets != null) ...[
                SizedBox(width: 12),
                _buildStatChip('${widget.exercise.sets}', 'Sets', isSmallScreen),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoSteps(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of ${_demoSteps.length}',
                style: TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${((_currentStep + 1) / _demoSteps.length * 100).round()}%',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Progress Bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentStep + 1) / _demoSteps.length,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Current Step
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              _demoSteps[_currentStep],
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Navigation Buttons
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _previousStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                ),
              
              if (_currentStep > 0 && _currentStep < _demoSteps.length - 1)
                SizedBox(width: 12),
              
              if (_currentStep < _demoSteps.length - 1)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Next Step',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(bool isSmallScreen) {
    return Column(
      children: [
        // Quick Tip
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF6C5CE7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF6C5CE7).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Color(0xFF6C5CE7),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Pro Tip',
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                ExerciseDemoService().getQuickTip(widget.exercise.id),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 12 : 14,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 12),
        
        // Safety Reminder
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Safety First',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                ExerciseDemoService().getSafetyReminder(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 12 : 14,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Motivational Message
          Text(
            ExerciseDemoService().getMotivationalMessage(widget.exercise.difficulty),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 12 : 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Start Workout Button
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 48 : 52,
            child: ElevatedButton(
              onPressed: widget.onStartWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: Color(0xFF6C5CE7).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Start Workout',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getExerciseIcon(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center_rounded;
      case 'cardio':
        return Icons.favorite_rounded;
      case 'core':
        return Icons.center_focus_strong_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }
}