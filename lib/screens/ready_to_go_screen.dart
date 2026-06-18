import 'package:flutter/material.dart';
import 'dart:async';
import '../services/sound_service.dart';

class ReadyToGoScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final int currentExerciseIndex;
  final int totalExercises;
  final VoidCallback onStart;

  const ReadyToGoScreen({
    Key? key,
    required this.exercise,
    required this.currentExerciseIndex,
    required this.totalExercises,
    required this.onStart,
  }) : super(key: key);

  @override
  State<ReadyToGoScreen> createState() => _ReadyToGoScreenState();
}

class _ReadyToGoScreenState extends State<ReadyToGoScreen> {
  int _countdown = 8;
  Timer? _timer;
  bool _autoStarted = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
        // Professional countdown beeps for last 3 seconds
        if (_countdown <= 3) {
          SoundService().playCountdown();
        }
      } else {
        timer.cancel();
        if (!_autoStarted) {
          _autoStarted = true;
          SoundService().playWorkoutStart(); // Epic workout start
          widget.onStart();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exerciseName = widget.exercise['name'] ?? 'Exercise';
    final gifUrl = widget.exercise['gifUrl'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // MAIN COLUMN CONTENT
              Column(
          children: [
            // CLEAN TOP BAR - No duplicate timer
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  
                  // Exercise progress - clean and simple
                  Text(
                    'Exercise ${widget.currentExerciseIndex + 1}/${widget.totalExercises}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  
                  // Spacer to balance layout
                  SizedBox(width: 40),
                ],
              ),
            ),

            // MAIN CONTENT AREA - Clean and minimal
            Expanded(
              child: Stack(
                children: [
                  // CLEAN VIDEO SECTION
                  Positioned(
                    top: 10,
                    left: 16,
                    right: 16,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Video/GIF
                            Positioned.fill(
                              child: gifUrl != null
                                  ? Image.network(
                                      gifUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: Color(0xFF1A1A2E),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildDemoPlaceholder();
                                      },
                                    )
                                  : _buildDemoPlaceholder(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // COUNTDOWN SECTION - Clean and minimal
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.38 + 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Countdown circle - Smaller and cleaner
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF007AFF),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF007AFF).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$_countdown',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Exercise info - Clean typography
                        Text(
                          'READY TO GO',
                          style: TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        
                        SizedBox(height: 6),
                        
                        Text(
                          exerciseName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),

            // START NOW BUTTON - Small, clean, bottom-right
            Positioned(
              bottom: 24,
              right: 24,
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF007AFF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    _timer?.cancel();
                    await SoundService().testSound();
                    await SoundService().playWorkoutStart();
                    widget.onStart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Start Now',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            ],
        ),
        ),
      ),
    );
  }

  Widget _buildDemoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A2A),
            Color(0xFF1A1A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF007AFF).withOpacity(0.1),
                border: Border.all(
                  color: Color(0xFF007AFF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                _getExerciseIcon(widget.exercise['name'] ?? ''),
                size: 48,
                color: Color(0xFF007AFF).withOpacity(0.7),
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.exercise['name'] ?? 'Exercise',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              'Get ready to start!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getExerciseIcon(String exerciseName) {
    final name = exerciseName.toLowerCase();
    if (name.contains('jump')) return Icons.fitness_center;
    if (name.contains('push')) return Icons.fitness_center;
    if (name.contains('squat')) return Icons.accessibility_new;
    if (name.contains('plank')) return Icons.horizontal_rule;
    if (name.contains('run')) return Icons.directions_run;
    return Icons.fitness_center;
  }
}
