import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/sound_service.dart';

class TimeBasedWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final int currentSet;
  final int totalSets;
  final int duration; // Duration in seconds
  final String fitnessLevel;
  final Function() onSetComplete;

  const TimeBasedWorkoutScreen({
    Key? key,
    required this.exercise,
    required this.currentSet,
    required this.totalSets,
    required this.duration,
    required this.fitnessLevel,
    required this.onSetComplete,
  }) : super(key: key);

  @override
  State<TimeBasedWorkoutScreen> createState() => _TimeBasedWorkoutScreenState();
}

class _TimeBasedWorkoutScreenState extends State<TimeBasedWorkoutScreen> {
  final SoundService _soundService = SoundService();
  
  int _secondsRemaining = 0;
  int _totalElapsed = 0;
  Timer? _countdownTimer;
  bool _isPaused = false;
  bool _isReady = true;
  int _readyCountdown = 8;
  Timer? _readyTimer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.duration;
    _startReadyCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _readyTimer?.cancel();
    super.dispose();
  }

  void _startReadyCountdown() {
    _readyTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _readyCountdown--;
      });

      // Play beep sound on each countdown
      if (_readyCountdown > 0) {
        SoundService().playBeep();
      }

      if (_readyCountdown <= 0) {
        timer.cancel();
        setState(() {
          _isReady = false;
        });
        _startExercise();
      }
    });
  }

  void _startExercise() {
    SoundService().playWorkoutStart();
    
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsRemaining--;
          _totalElapsed++;
        });

        // Halfway motivation
        if (_secondsRemaining == (widget.duration / 2).ceil()) {
          SoundService().playBeep(); // Play motivational beep
        }

        // Last 3 seconds countdown beeps
        if (_secondsRemaining <= 3 && _secondsRemaining > 0) {
          SoundService().playCountdown();
        }

        // Exercise complete
        if (_secondsRemaining <= 0) {
          timer.cancel();
          _completeSet();
        }
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _completeSet() async {
    await _soundService.playSetCompleteSequence();

    if (mounted) {
      Navigator.pop(context);
      widget.onSetComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady) {
      return _buildReadyScreen();
    }
    
    return _buildExerciseScreen();
  }

  Widget _buildReadyScreen() {
    final exerciseName = widget.exercise['name'] ?? 'Exercise';
    final gifUrl = widget.exercise['gifUrl'] as String?;

    return Scaffold(
      backgroundColor: Color(0xFF0D0E21).withOpacity(0.95),
      body: SafeArea(
        child: Stack(
          children: [
            // Background exercise demo
            Positioned.fill(
              child: gifUrl != null
                  ? CachedNetworkImage(
                      imageUrl: gifUrl,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.5),
                      colorBlendMode: BlendMode.darken,
                    )
                  : Container(color: Colors.black),
            ),
            
            // Content
            Column(
              children: [
                // Top bar
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.white, size: 28),
                      ),
                      Spacer(),
                      Text(
                        'Exercises ${widget.currentSet}/${widget.totalSets}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Text(
                        _formatTime(_totalElapsed),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
                
                Spacer(),
                
                // Ready to go
                Text(
                  'READY TO GO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 24),
                
                // Countdown number
                Text(
                  '$_readyCountdown',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                
                Spacer(),
                
                // Exercise info
                Container(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Exercise ${widget.currentSet}/${widget.totalSets}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            exerciseName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.help_outline, color: Colors.white60, size: 20),
                        ],
                      ),
                      SizedBox(height: 32),
                      
                      // Start button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            _readyTimer?.cancel();
                            setState(() {
                              _isReady = false;
                            });
                            _startExercise();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Start!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseScreen() {
    final exerciseName = widget.exercise['name'] ?? 'Exercise';
    final gifUrl = widget.exercise['gifUrl'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen exercise demo - Using placeholder for now
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1E88E5).withOpacity(0.1),
                      Color(0xFF1E88E5).withOpacity(0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 120,
                        color: Color(0xFF1E88E5),
                      ),
                      SizedBox(height: 24),
                      Text(
                        exerciseName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E88E5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Follow the form',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _showQuitDialog(),
                      icon: Icon(Icons.close, color: Colors.white, size: 28),
                    ),
                    Spacer(),
                    Text(
                      'Exercises ${widget.currentSet}/${widget.totalSets}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.fullscreen, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          exerciseName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.help_outline, color: Colors.white70, size: 20),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Timer
                    Text(
                      _formatTime(_secondsRemaining),
                      style: TextStyle(
                        color: Color(0xFF007AFF),
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Pause/Play button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _togglePause,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xFF007AFF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPaused ? Icons.play_arrow : Icons.pause,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        SizedBox(width: 24),
                        IconButton(
                          onPressed: () => _completeSet(),
                          icon: Icon(Icons.skip_next, color: Colors.white, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Quit Exercise?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text('Your progress for this set won\'t be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Quit',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
