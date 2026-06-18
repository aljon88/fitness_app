import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/workout_journal_service.dart';
import '../services/sound_service.dart';

class WorkoutJournalScreen extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final String workoutType;
  final int duration;

  const WorkoutJournalScreen({
    Key? key,
    required this.exercises,
    required this.workoutType,
    required this.duration,
  }) : super(key: key);

  @override
  State<WorkoutJournalScreen> createState() => _WorkoutJournalScreenState();
}

class _WorkoutJournalScreenState extends State<WorkoutJournalScreen>
    with TickerProviderStateMixin {
  
  // Current step in the exciting flow
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Animation controllers
  late AnimationController _celebrationController;
  late AnimationController _stepController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  // User selections
  int _selectedEnergyRating = 3;
  final List<String> _selectedTags = [];
  final TextEditingController _notesController = TextEditingController();

  // Step data
  final List<String> _stepTitles = [
    '🎉 AMAZING!',
    '📊 Look What You Did!',
    '😊 How Do You Feel?',
    '🏷️ Tag This Victory!',
    '🚀 You\'re Unstoppable!'
  ];

  final List<String> _energyEmojis = ['😫', '😐', '😊', '💪', '🔥'];
  final List<String> _energyLabels = ['Tough', 'Okay', 'Good', 'Strong', 'BEAST!'];
  
  final List<String> _victoryTags = [
    '💪 Felt Strong', '🔥 Crushed It', '⚡ High Energy', '🎯 Perfect Form',
    '🚀 Pushed Limits', '😤 Beast Mode', '⭐ Personal Best', '🏆 Champion'
  ];
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCelebrationSequence();
  }

  void _initializeAnimations() {
    _celebrationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _stepController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _stepController, curve: Curves.easeInOut),
    );
  }

  void _startCelebrationSequence() {
    SoundService().playWorkoutCompleteSequence();
    HapticFeedback.heavyImpact();
    _celebrationController.forward();
    
    // Auto-advance after celebration
    Future.delayed(Duration(milliseconds: 3000), () {
      if (mounted) _nextStep();
    });
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _stepController.reset();
      _stepController.forward();
      SoundService().playBeep();
      HapticFeedback.lightImpact();
    }
  }

  void _selectEnergyRating(int rating) {
    setState(() {
      _selectedEnergyRating = rating;
    });
    HapticFeedback.mediumImpact();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else if (_selectedTags.length < 3) {
        _selectedTags.add(tag);
      }
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _finishJournal() async {
    try {
      final entry = WorkoutJournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        workoutType: widget.workoutType,
        duration: widget.duration,
        exercisesCompleted: widget.exercises.map((e) => e['name'] as String).toList(),
        energyRating: _selectedEnergyRating,
        notes: _notesController.text.trim(),
        tags: List.from(_selectedTags),
        totalExercises: widget.exercises.length,
      );

      await WorkoutJournalService().saveJournalEntry(entry);
      SoundService().playWorkoutCompleteSequence();
      HapticFeedback.heavyImpact();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print('❌ Error saving journal entry: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getStepBackgroundColor(),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator (hidden during celebration)
            if (_currentStep > 0) _buildProgressIndicator(),
            
            // Main content
            Expanded(
              child: AnimatedBuilder(
                animation: _stepController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_slideAnimation.value * MediaQuery.of(context).size.width, 0),
                    child: _buildCurrentStep(),
                  );
                },
              ),
            ),
            
            // Navigation buttons
            if (_currentStep > 0 && _currentStep < _totalSteps - 1) _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Color _getStepBackgroundColor() {
    switch (_currentStep) {
      case 0: return Color(0xFF007AFF); // Celebration blue
      case 1: return Colors.white; // Stats white
      case 2: return Color(0xFFF8F9FA); // Energy light
      case 3: return Color(0xFFFFF3E0); // Tags warm
      case 4: return Color(0xFF4CAF50); // Success green
      default: return Colors.white;
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            _stepTitles[_currentStep],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _currentStep == 4 ? Colors.white : Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: List.generate(_totalSteps - 1, (index) {
              final isActive = index < _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? (_currentStep == 4 ? Colors.white : Color(0xFF007AFF))
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildCelebrationStep();
      case 1: return _buildStatsStep();
      case 2: return _buildEnergyStep();
      case 3: return _buildTagsStep();
      case 4: return _buildFinalStep();
      default: return Container();
    }
  }

  Widget _buildCelebrationStep() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.celebration, size: 100, color: Colors.white),
            ),
          ),
          SizedBox(height: 40),
          Text(
            'WORKOUT\nCOMPLETE!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'You\'re absolutely CRUSHING it! 🔥',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatsStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Big number display
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF007AFF).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.exercises.length}',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'EXERCISES',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('⏱️', '${widget.duration}', 'MINUTES', Color(0xFF4CAF50)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('🔥', '${widget.duration * 5}', 'CALORIES', Color(0xFFFF9500)),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Look at those numbers! You\'re getting stronger! 💪',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
  Widget _buildEnergyStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'How do you feel right now?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final isSelected = _selectedEnergyRating == index;
              return GestureDetector(
                onTap: () => _selectEnergyRating(index),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: isSelected ? 80 : 60,
                  height: isSelected ? 80 : 60,
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF007AFF).withOpacity(0.15) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(isSelected ? 40 : 30),
                    border: Border.all(
                      color: isSelected ? Color(0xFF007AFF) : Colors.grey[300]!,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Color(0xFF007AFF).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ] : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_energyEmojis[index], style: TextStyle(fontSize: isSelected ? 32 : 24)),
                      if (isSelected) ...[
                        SizedBox(height: 4),
                        Text(
                          _energyLabels[index],
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF007AFF)),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 40),
          Text(
            _selectedEnergyRating >= 3 ? 'That\'s the spirit! 🔥' : 'Every workout counts! 💪',
            style: TextStyle(
              fontSize: 16,
              color: _selectedEnergyRating >= 3 ? Color(0xFF4CAF50) : Color(0xFF007AFF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTagsStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 40),
          Text(
            'Pick your victory tags!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
          ),
          SizedBox(height: 8),
          Text(
            'Choose up to 3 that describe this workout',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _victoryTags.length,
              itemBuilder: (context, index) {
                final tag = _victoryTags[index];
                final isSelected = _selectedTags.contains(tag);
                final canSelect = _selectedTags.length < 3 || isSelected;
                
                return GestureDetector(
                  onTap: canSelect ? () => _toggleTag(tag) : null,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
                      ) : null,
                      color: isSelected ? null : (canSelect ? Colors.grey[100] : Colors.grey[50]),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : (canSelect ? Colors.grey[300]! : Colors.grey[200]!),
                        width: 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Color(0xFF007AFF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ] : [],
                    ),
                    child: Center(
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : (canSelect ? Colors.grey[700] : Colors.grey[400]),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedTags.isNotEmpty) ...[
            SizedBox(height: 20),
            Text(
              'Selected: ${_selectedTags.length}/3',
              style: TextStyle(fontSize: 14, color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildFinalStep() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(Icons.emoji_events, size: 60, color: Colors.white),
          ),
          SizedBox(height: 32),
          Text(
            'YOU\'RE\nUNSTOPPABLE!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Workout saved to your victory collection! 🏆',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 40),
          Container(
            width: double.infinity,
            height: 56,
            margin: EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _finishJournal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Continue the Journey! 🚀',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF007AFF), Color(0xFF0051D5)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF007AFF).withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            'Continue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _stepController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}