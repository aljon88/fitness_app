import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/sound_service.dart';
import '../widgets/muscle_diagram_widget.dart';
import 'timer_workout_screen.dart';

class PreWorkoutDemoScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final int currentSet;
  final int totalSets;
  final int targetReps;
  final String fitnessLevel;
  final Function(int reps) onSetComplete;

  const PreWorkoutDemoScreen({
    Key? key,
    required this.exercise,
    required this.currentSet,
    required this.totalSets,
    required this.targetReps,
    required this.fitnessLevel,
    required this.onSetComplete,
  }) : super(key: key);

  @override
  State<PreWorkoutDemoScreen> createState() => _PreWorkoutDemoScreenState();
}

class _PreWorkoutDemoScreenState extends State<PreWorkoutDemoScreen> with SingleTickerProviderStateMixin {
  final SoundService _soundService = SoundService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exerciseName = widget.exercise['name'] ?? 'Exercise';
    final instructions = widget.exercise['instructions'] as List? ?? [];
    final tips = widget.exercise['tips'] as List? ?? [];
    final gifUrl = widget.exercise['gifUrl'] as String?;
    final primaryMuscles = (widget.exercise['primaryMuscles'] as List?)?.cast<String>() ?? [];
    final secondaryMuscles = (widget.exercise['secondaryMuscles'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: Color(0xFF0D0E21),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Exercise name
                    Text(
                      exerciseName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Set ${widget.currentSet} of ${widget.totalSets} • ${widget.targetReps} reps',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Exercise demo GIF
                    _buildExerciseDemo(gifUrl),
                    SizedBox(height: 24),
                    
                    // Target muscles
                    MuscleDiagramWidget(
                      primaryMuscles: primaryMuscles,
                      secondaryMuscles: secondaryMuscles,
                    ),
                    SizedBox(height: 20),
                    
                    // Instructions
                    if (instructions.isNotEmpty) ...[
                      _buildInstructionsSection(instructions),
                      SizedBox(height: 16),
                    ],
                    
                    // Tips
                    if (tips.isNotEmpty) ...[
                      _buildTipsSection(tips),
                      SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
            
            // Start button
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: Colors.white, size: 28),
          ),
          Expanded(
            child: Text(
              'Exercise Demo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildExerciseDemo(String? gifUrl) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Color(0xFF1A1B3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF6C5CE7).withOpacity(0.3), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: gifUrl != null
            ? CachedNetworkImage(
                imageUrl: gifUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6C5CE7),
                  ),
                ),
                errorWidget: (context, url, error) => _buildPlaceholderDemo(),
              )
            : _buildPlaceholderDemo(),
      ),
    );
  }

  Widget _buildPlaceholderDemo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.play_circle_outline,
          color: Color(0xFF6C5CE7),
          size: 80,
        ),
        SizedBox(height: 12),
        Text(
          'Exercise Demo',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsSection(List instructions) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color(0xFF1A1B3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_list_numbered, color: Color(0xFF6C5CE7), size: 20),
              SizedBox(width: 8),
              Text(
                'How to Perform',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...instructions.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Color(0xFF6C5CE7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTipsSection(List tips) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Pro Tips',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ...tips.map((tip) {
            return Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF0D0E21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _startWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Color(0xFF6C5CE7).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 32),
                    SizedBox(width: 8),
                    Text(
                      'READY? START!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: Color(0xFF6C5CE7), size: 16),
              SizedBox(width: 6),
              Text(
                'Timer starts when you begin',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _startWorkout() async {
    // Play exciting start sound
    await _soundService.playSound(SoundService.workoutStart);
    
    // Navigate to timer workout screen
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TimerWorkoutScreen(
          exercise: widget.exercise,
          currentSet: widget.currentSet,
          totalSets: widget.totalSets,
          targetReps: widget.targetReps,
          fitnessLevel: widget.fitnessLevel,
          onSetComplete: widget.onSetComplete,
        ),
      ),
    );
  }
}
