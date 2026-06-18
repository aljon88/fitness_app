import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sound_service.dart';
import '../services/professional_workout_tracker.dart';
import '../services/unified_auth_service.dart';
import '../services/workout_journal_service.dart';
import '../widgets/floating_next_button.dart';

class WorkoutCelebrationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final String workoutType;
  final int duration;
  final int calories; // Add calories parameter
  final VoidCallback onComplete;

  const WorkoutCelebrationScreen({
    Key? key,
    required this.exercises,
    required this.workoutType,
    required this.duration,
    required this.calories, // Add calories parameter
    required this.onComplete,
  }) : super(key: key);

  @override
  _WorkoutCelebrationScreenState createState() => _WorkoutCelebrationScreenState();
}

class _WorkoutCelebrationScreenState extends State<WorkoutCelebrationScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  static const int _totalSteps = 5;
  
  // User interaction state
  int _selectedEnergyRating = 0;
  final Set<String> _selectedTags = {};
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Configuration constants
  static const List<String> _stepTitles = [
    'WORKOUT COMPLETE!',
    'Your Stats',
    'How Did You Feel?',
    'Tag This Victory!',
    'You\'re Amazing!',
  ];
  
  static const List<String> _energyEmojis = ['😫', '😐', '😊', '💪', '🔥'];
  static const List<String> _energyLabels = ['tired', 'okay', 'good', 'strong', 'amazing'];
  
  static const List<String> _victoryTags = [
    '💪 Felt Strong',
    '🔥 Crushed It',
    '⚡ High Energy',
    '🎯 Perfect Form',
    '🚀 Pushed Limits',
    '😤 Beast Mode',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    // Play celebration sounds
    SoundService().playUltimateCelebrationSequence();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      // Reset and restart animations for next step
      _fadeController.reset();
      _scaleController.reset();
      
      setState(() {
        _currentStep++;
      });
      
      _fadeController.forward();
      _scaleController.forward();
      
      SoundService().playBeep();
      HapticFeedback.lightImpact();
    }
  }

  /// Professional workout saving with comprehensive data
  Future<void> _completeWorkoutAndSave() async {
    try {
      print('🎯 Starting professional workout save...');
      
      // Create professional workout session
      final workoutSession = ProfessionalWorkoutTracker.createFromWorkoutData(
        workoutType: widget.workoutType,
        workoutTitle: widget.workoutType,
        exercises: widget.exercises,
        durationMinutes: widget.duration,
        caloriesBurned: widget.calories,
        difficulty: _getDifficultyFromRating(_selectedEnergyRating),
        notes: _selectedTags.join(', '),
      );
      
      // Save to professional workout tracker
      final tracker = ProfessionalWorkoutTracker();
      final saveSuccess = await tracker.saveWorkoutSession(workoutSession);
      
      if (saveSuccess) {
        print('✅ Workout saved successfully to professional tracker');
        
        // Also save to journal for backwards compatibility
        final journalEntry = WorkoutJournalEntry(
          id: workoutSession.id,
          date: workoutSession.endTime,
          workoutType: widget.workoutType,
          duration: widget.duration,
          exercisesCompleted: widget.exercises.map((ex) => ex['name']?.toString() ?? 'Exercise').toList(),
          energyRating: _selectedEnergyRating > 0 ? _selectedEnergyRating : 3,
          notes: _selectedTags.join(', '),
          tags: _selectedTags.toList(),
          totalExercises: widget.exercises.length,
        );
        
        await WorkoutJournalService().saveJournalEntry(journalEntry);
        print('✅ Workout also saved to journal service');
        
        // Show success feedback
        HapticFeedback.heavyImpact();
        SoundService().playWorkoutCompleteSequence();
        
      } else {
        print('❌ Failed to save workout to professional tracker');
      }
    } catch (e) {
      print('❌ Error saving workout: $e');
    }
    
    // Always complete the flow regardless of save success
    widget.onComplete();
  }
  
  /// Convert energy rating to difficulty level
  String _getDifficultyFromRating(int rating) {
    switch (rating) {
      case 1: return 'very hard';
      case 2: return 'hard';
      case 3: return 'moderate';
      case 4: return 'easy';
      case 5: return 'easy';
      default: return 'moderate';
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

  int _calculateCalories() {
    // Use the actual calories from the workout program data
    return widget.calories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _getStepBackground(),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  children: [
                    if (_currentStep > 0) _buildProgressIndicator(),
                    Expanded(
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: _buildCurrentStep(),
                              );
                            },
                          ),
                          // Position floating button in bottom-right corner
                          if (_currentStep < _totalSteps - 1)
                            FloatingCelebrationButton(
                              onPressed: _nextStep,
                              isFirstStep: _currentStep == 0,
                              isVisible: true,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  BoxDecoration _getStepBackground() {
    switch (_currentStep) {
      case 0:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0E21),
              Color(0xFF1A1B3A),
              Color(0xFF2D2E5F),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        );
      case 1:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6C5CE7),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        );
      case 2:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4facfe),
              Color(0xFF00f2fe),
              Color(0xFF43e97b),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        );
      case 3:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8360c3),
              Color(0xFF2ebf91),
              Color(0xFF52c234),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        );
      case 4:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C5CE7),
              Color(0xFF8B7FE8),
              Color(0xFFB794F6),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        );
      default:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6C5CE7),
              Color(0xFFB794F6),
            ],
          ),
        );
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            _stepTitles[_currentStep],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _currentStep == 4 ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          // Hyper-modern progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: (_currentStep == 4 ? Colors.white : Colors.grey[200])?.withOpacity(0.3),
            ),
            child: Row(
              children: List.generate(_totalSteps - 1, (index) {
                final isActive = index < _currentStep;
                return Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      gradient: isActive 
                          ? LinearGradient(
                              colors: _currentStep == 4 
                                  ? [Colors.white, Colors.white70]
                                  : [const Color(0xFF6C5CE7), const Color(0xFFB794F6)],
                            )
                          : null,
                      color: isActive ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: (_currentStep == 4 ? Colors.white : const Color(0xFF6C5CE7)).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                  ),
                );
              }),
            ),
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
      default: return const SizedBox.shrink();
    }
  }

  // STEP 1: HYPER-MODERN CELEBRATION
  Widget _buildCelebrationStep() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated header
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFB794F6)],
              ).createShader(bounds),
              child: const Text(
                'WORKOUT',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'COMPLETE!',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Color(0xFF6C5CE7),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Premium celebration video container
            Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF8F9FA)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 4,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _CelebrationVideoWidget(),
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Animated message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Text(
                'You\'re absolutely CRUSHING it! 🔥',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: HYPER-MODERN STATS
  Widget _buildStatsStep() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Animated stats cards
            _buildStatCard(
              icon: Icons.timer_outlined,
              value: '${widget.duration}',
              label: 'MINUTES',
              gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
            ),
            const SizedBox(height: 24),
            _buildStatCard(
              icon: Icons.fitness_center,
              value: '${widget.exercises.length}',
              label: 'EXERCISES',
              gradient: [const Color(0xFF6C5CE7), const Color(0xFFB794F6)],
            ),
            const SizedBox(height: 24),
            _buildStatCard(
              icon: Icons.local_fire_department,
              value: '${_calculateCalories()}',
              label: 'CALORIES',
              gradient: [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
            ),
            const SizedBox(height: 40),
            
            // Achievement message
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Text(
                '🏆 Another victory in the books!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradient,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: HYPER-MODERN ENERGY RATING
  Widget _buildEnergyStep() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'How did you feel?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 50),
            
            // Energy rating selector
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 8,
                runSpacing: 8,
                children: List.generate(5, (index) {
                  final isSelected = _selectedEnergyRating == index + 1;
                  return GestureDetector(
                    onTap: () => _selectEnergyRating(index + 1),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _energyEmojis[index],
                            style: TextStyle(
                              fontSize: isSelected ? 32 : 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _energyLabels[index],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? const Color(0xFF4facfe) : Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 40),
            
            if (_selectedEnergyRating > 0)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  _getEnergyMessage(_selectedEnergyRating),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _getEnergyMessage(int rating) {
    switch (rating) {
      case 1: return 'Rest up! You pushed through 💪';
      case 2: return 'Solid effort! Keep building 🌱';
      case 3: return 'Great work! You\'re getting stronger 💪';
      case 4: return 'Fantastic! You\'re on fire 🔥';
      case 5: return 'INCREDIBLE! You\'re unstoppable! 🚀';
      default: return '';
    }
  }

  // STEP 4: HYPER-MODERN VICTORY TAGS
  Widget _buildTagsStep() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Tag this victory!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select up to 3 tags',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            
            // Victory tags grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _victoryTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () => _toggleTag(tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.white 
                            : Colors.white.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF8360c3) : Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 40),
            
            if (_selectedTags.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  '${_selectedTags.length}/3 tags selected',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // STEP 5: HYPER-MODERN FINAL CELEBRATION
  Widget _buildFinalStep() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Animated crown or trophy
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF8F9FA)],
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 60,
                color: Color(0xFF6C5CE7),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Final message
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFE8E8E8)],
              ).createShader(bounds),
              child: const Text(
                'YOU\'RE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 6,
                ),
              ),
            ),
            const Text(
              'AMAZING!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.white,
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Summary stats
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_selectedEnergyRating > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Energy: ${_energyEmojis[_selectedEnergyRating - 1]} ',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _energyLabels[_selectedEnergyRating - 1],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_selectedTags.isNotEmpty) ...[
                    Text(
                      'Victory Tags: ${_selectedTags.join(', ')}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                  ElevatedButton(
                    onPressed: _completeWorkoutAndSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6C5CE7),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 10,
                      shadowColor: Colors.white.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Continue Your Journey',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


}

// Professional Celebration Video Widget
class _CelebrationVideoWidget extends StatefulWidget {
  @override
  _CelebrationVideoWidgetState createState() => _CelebrationVideoWidgetState();
}

class _CelebrationVideoWidgetState extends State<_CelebrationVideoWidget> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  // Multiple celebration video URLs for fallback
  static const List<String> _celebrationUrls = [
    'https://media.giphy.com/media/5bvMcdx0gZf2mdiPjf/giphy.gif',
    'https://media.giphy.com/media/26u4cqiYI30juCOGY/giphy.gif',
    'https://media.giphy.com/media/l0MYt5jPR6QX5pnqM/giphy.gif',
  ];
  
  int _currentUrlIndex = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _tryNextUrl() {
    if (_currentUrlIndex < _celebrationUrls.length - 1) {
      setState(() {
        _currentUrlIndex++;
        _hasError = false;
      });
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildFallbackCelebration();
    }

    return Image.network(
      _celebrationUrls[_currentUrlIndex],
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingCelebration();
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ Failed to load celebration video ${_currentUrlIndex + 1}/${_celebrationUrls.length}');
        print('   URL: ${_celebrationUrls[_currentUrlIndex]}');
        print('   Error: $error');
        
        // Try next URL or show fallback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryNextUrl();
        });
        
        return _buildLoadingCelebration();
      },
    );
  }

  Widget _buildLoadingCelebration() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF6C5CE7).withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6C5CE7).withOpacity(0.2),
                      border: Border.all(
                        color: const Color(0xFF6C5CE7),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.celebration,
                      size: 60,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading Celebration...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6C5CE7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCelebration() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C5CE7).withOpacity(0.1),
            const Color(0xFFB794F6).withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_animationController.value * 0.1),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFFB794F6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.celebration,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              '🎉 🎊 🎉',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'CELEBRATION!',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF6C5CE7),
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}