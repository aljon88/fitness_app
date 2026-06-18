import 'package:flutter/material.dart';

enum HomeCoachMood { encouraging, celebrating, instructing, resting, motivating }

class HomeCoachCharacter extends StatefulWidget {
  final String message;
  final HomeCoachMood mood;
  final bool showAnimation;
  
  const HomeCoachCharacter({
    Key? key,
    required this.message,
    this.mood = HomeCoachMood.encouraging,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  _HomeCoachCharacterState createState() => _HomeCoachCharacterState();
}

class _HomeCoachCharacterState extends State<HomeCoachCharacter> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.showAnimation) {
      _pulseController.repeat(reverse: true);
      _bounceController.forward();
      _floatController.repeat(reverse: true);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.showAnimation ? _floatAnimation.value : 0),
          child: Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getGradientColors(),
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getGradientColors()[0].withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // AI Character Avatar - ENHANCED ANIMATIONS
                ScaleTransition(
                  scale: widget.showAnimation ? _bounceAnimation : 
                         AlwaysStoppedAnimation(1.0),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: widget.showAnimation ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getCharacterIcon(),
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                
                // AI Message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Your Home Coach',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          // ANIMATED STATUS DOT
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.6),
                                      blurRadius: widget.showAnimation ? _pulseAnimation.value * 5 : 0,
                                      spreadRadius: widget.showAnimation ? _pulseAnimation.value * 2 : 0,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        widget.message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Mood indicator - ANIMATED
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: widget.showAnimation ? _pulseAnimation.value : 1.0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getMoodEmoji(),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _getGradientColors() {
    switch (widget.mood) {
      case HomeCoachMood.encouraging:
        return [Color(0xFF6C5CE7), Color(0xFF74B9FF)];
      case HomeCoachMood.celebrating:
        return [Color(0xFFFF6B6B), Color(0xFFFFE66D)];
      case HomeCoachMood.instructing:
        return [Color(0xFF4ECDC4), Color(0xFF44A08D)];
      case HomeCoachMood.resting:
        return [Color(0xFF667eea), Color(0xFF764ba2)];
      case HomeCoachMood.motivating:
        return [Color(0xFFFF9A9E), Color(0xFFFECFEF)];
    }
  }

  IconData _getCharacterIcon() {
    switch (widget.mood) {
      case HomeCoachMood.encouraging:
        return Icons.psychology;
      case HomeCoachMood.celebrating:
        return Icons.celebration;
      case HomeCoachMood.instructing:
        return Icons.school;
      case HomeCoachMood.resting:
        return Icons.self_improvement;
      case HomeCoachMood.motivating:
        return Icons.rocket_launch;
    }
  }

  String _getMoodEmoji() {
    switch (widget.mood) {
      case HomeCoachMood.encouraging:
        return '💪';
      case HomeCoachMood.celebrating:
        return '🎉';
      case HomeCoachMood.instructing:
        return '📚';
      case HomeCoachMood.resting:
        return '😌';
      case HomeCoachMood.motivating:
        return '🔥';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }
}

class HomeCoachMessages {
  static String getPreWorkoutMessage(int day, String userGoal, String motivation) {
    if (day == 1) {
      return "Welcome to your fitness journey! Let's start strong and make today count! 💪";
    }
    
    if (day % 7 == 0) {
      return "Week ${day ~/ 7} complete! You're absolutely crushing it! Keep this momentum going! 🔥";
    }
    
    if (motivation == 'Lose Weight') {
      return "Ready to burn some calories? Today's workout will get your heart pumping! Let's go! 🏃‍♀️";
    }
    
    if (motivation == 'Build Muscle') {
      return "Time to build that strength! Every rep makes you stronger. Ready to power through? 💪";
    }
    
    if (motivation == 'More Confidence') {
      return "Day $day - You're building confidence with every workout! Let's show what you're made of! ⭐";
    }
    
    return "Day $day - Time to get stronger and feel amazing! Ready to make it happen? 🚀";
  }
  
  static String getDuringWorkoutMessage(int currentRep, int targetReps, String exerciseName) {
    double progress = currentRep / targetReps;
    
    if (progress < 0.3) {
      return "Great start on those ${exerciseName.toLowerCase()}! Keep that form perfect! 👌";
    }
    
    if (progress < 0.7) {
      return "Halfway there! You're doing amazing! Feel that strength building! 💪";
    }
    
    if (progress < 0.9) {
      return "Almost done! Push through - you've got this! Just a few more! 🔥";
    }
    
    return "Final rep! Give it everything you've got! Finish strong! ⚡";
  }
  
  static String getRestPeriodMessage(int restTimeLeft, int nextSet, int totalSets) {
    if (restTimeLeft > 30) {
      return "Great set! Take deep breaths and prepare for set $nextSet of $totalSets. You're doing fantastic! 😌";
    }
    
    if (restTimeLeft > 15) {
      return "Halfway through your rest. Stay focused - you're building incredible strength! 💭";
    }
    
    return "Almost time for set $nextSet! Get ready to show that exercise who's boss! 🔥";
  }
  
  static String getPostWorkoutMessage(double formScore, bool goalAchieved, int totalReps) {
    if (goalAchieved && formScore > 0.9) {
      return "Perfect workout! $totalReps reps with excellent form! You're a superstar! ⭐";
    }
    
    if (goalAchieved && formScore > 0.7) {
      return "Goal achieved! $totalReps reps completed! Great job staying consistent! 🎉";
    }
    
    if (goalAchieved) {
      return "Workout complete! You showed up and did the work - that's what matters most! 💯";
    }
    
    return "Good effort today! Every workout makes you stronger. Tomorrow we'll crush it even more! 💪";
  }
  
  static String getMotivationalMessage(int streak, int totalWorkouts) {
    if (streak >= 14) {
      return "🔥 TWO WEEK STREAK! You're absolutely unstoppable! This is how champions are made!";
    }
    
    if (streak >= 7) {
      return "🔥 WEEK STREAK! You're building an incredible habit! Keep this momentum going!";
    }
    
    if (streak >= 3) {
      return "💪 Three days strong! You're proving to yourself what you're capable of!";
    }
    
    if (totalWorkouts >= 30) {
      return "🏆 30 workouts completed! You've transformed into a fitness warrior!";
    }
    
    if (totalWorkouts >= 10) {
      return "💪 Double digits! You're building something amazing here!";
    }
    
    return "🌟 Every workout is a victory! You're stronger than you were yesterday!";
  }
  
  static String getFormFeedbackMessage(String feedback, String exerciseName) {
    switch (feedback.toLowerCase()) {
      case 'excellent':
        return "Perfect form on those ${exerciseName.toLowerCase()}! You're a natural! 🌟";
      case 'good':
        return "Great technique! Keep focusing on that form - you're doing awesome! 👍";
      case 'needs improvement':
        return "Good effort! Try slowing down a bit and focus on perfect form. Quality over speed! ⚠️";
      case 'poor':
        return "Let's focus on technique. Remember: perfect form builds perfect results! 🎯";
      default:
        return "Keep pushing! You're doing great! 💪";
    }
  }
}