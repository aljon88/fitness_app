import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/sound_service.dart';

class TimerWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final int currentSet;
  final int totalSets;
  final int targetReps;
  final String fitnessLevel;
  final Function(int reps) onSetComplete;

  const TimerWorkoutScreen({
    Key? key,
    required this.exercise,
    required this.currentSet,
    required this.totalSets,
    required this.targetReps,
    required this.fitnessLevel,
    required this.onSetComplete,
  }) : super(key: key);

  @override
  State<TimerWorkoutScreen> createState() => _TimerWorkoutScreenState();
}

class _TimerWorkoutScreenState extends State<TimerWorkoutScreen> {
  final SoundService _soundService = SoundService();
  
  int _currentReps = 0;
  int _elapsedSeconds = 0;
  Timer? _workoutTimer;
  Timer? _restTimer;
  Timer? _autoCountTimer;
  int _restSecondsRemaining = 0;
  bool _isResting = false;
  bool _hasPlayedHalfwaySound = false;
  bool _isAutoCounting = false;
  int _autoCountInterval = 3; // 3 seconds per rep (adjustable)

  @override
  void initState() {
    super.initState();
    _startWorkoutTimer();
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    _autoCountTimer?.cancel();
    super.dispose();
  }

  void _startWorkoutTimer() {
    _workoutTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isResting) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _toggleAutoCounting() {
    if (_isAutoCounting) {
      // Stop auto counting
      _autoCountTimer?.cancel();
      setState(() {
        _isAutoCounting = false;
      });
    } else {
      // Start auto counting
      setState(() {
        _isAutoCounting = true;
      });
      _startAutoCounting();
    }
  }

  void _startAutoCounting() {
    _autoCountTimer = Timer.periodic(Duration(seconds: _autoCountInterval), (timer) async {
      if (_currentReps >= widget.targetReps) {
        timer.cancel();
        await _completeSet();
        return;
      }
      
      await _incrementRep();
    });
  }

  Future<void> _incrementRep() async {
    if (_isResting) return;

    setState(() {
      _currentReps++;
    });

    // Professional rep complete sequence
    await SoundService().playRepSequence();

    // Check for halfway point with motivational boost
    if (_currentReps == (widget.targetReps / 2).ceil() && !_hasPlayedHalfwaySound) {
      _hasPlayedHalfwaySound = true;
      await Future.delayed(Duration(milliseconds: 500));
      await SoundService().playHalfwayBoost();
    }

    // Check if set is complete
    if (_currentReps >= widget.targetReps) {
      _autoCountTimer?.cancel();
      setState(() {
        _isAutoCounting = false;
      });
      await _completeSet();
    }
  }

  Future<void> _decrementRep() async {
    if (_currentReps > 0 && !_isResting) {
      setState(() {
        _currentReps--;
      });
    }
  }

  Future<void> _startRepRest() async {
    setState(() {
      _isResting = true;
      _restSecondsRemaining = 5; // 5 seconds rest between reps
    });

    _restTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _restSecondsRemaining--;
      });

      if (_restSecondsRemaining <= 0) {
        timer.cancel();
        setState(() {
          _isResting = false;
        });
      }
    });
  }

  Future<void> _completeSet() async {
    _workoutTimer?.cancel();
    
    // Professional set complete sequence
    await SoundService().playSetCompleteSequence();

    // Return to previous screen with rep count
    if (mounted) {
      Navigator.pop(context);
      widget.onSetComplete(_currentReps);
    }
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSecondsRemaining = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final exerciseName = widget.exercise['name'] ?? 'Exercise';
    final gifUrl = widget.exercise['gifUrl'] as String?;

    return Scaffold(
      backgroundColor: Color(0xFF0D0E21),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isResting ? _buildRestScreen() : _buildWorkoutScreen(exerciseName, gifUrl),
            ),
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
            onPressed: () => _showQuitDialog(),
            icon: Icon(Icons.close_rounded, color: Colors.white, size: 28),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.exercise['name'] ?? 'Exercise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Set ${widget.currentSet} of ${widget.totalSets}',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildWorkoutScreen(String exerciseName, String? gifUrl) {
    final progress = _currentReps / widget.targetReps;
    
    return Column(
      children: [
        // Timer
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF1A1B3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: Color(0xFF6C5CE7), size: 32),
              SizedBox(width: 12),
              Text(
                _formatTime(_elapsedSeconds),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        
        // Exercise demo (smaller, as reference)
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: 150,
          decoration: BoxDecoration(
            color: Color(0xFF1A1B3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: gifUrl != null
                ? CachedNetworkImage(
                    imageUrl: gifUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.fitness_center,
                      color: Color(0xFF6C5CE7),
                      size: 60,
                    ),
                  )
                : Icon(
                    Icons.fitness_center,
                    color: Color(0xFF6C5CE7),
                    size: 60,
                  ),
          ),
        ),
        SizedBox(height: 24),
        
        // Rep counter
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'REPS',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$_currentReps',
                      style: TextStyle(
                        color: Color(0xFF6C5CE7),
                        fontSize: 96,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    Text(
                      ' / ${widget.targetReps}',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                
                // Progress bar
                Container(
                  width: 200,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF6C5CE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Control buttons
        Container(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Auto count toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isAutoCounting ? 'Auto Counting...' : 'Manual Mode',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Switch(
                    value: _isAutoCounting,
                    onChanged: (value) => _toggleAutoCounting(),
                    activeColor: Color(0xFF6C5CE7),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  // Minus button
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        onPressed: _decrementRep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A1B3A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Icon(Icons.remove, size: 32),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  
                  // Plus button (main)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        onPressed: _incrementRep,
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
                            Icon(Icons.add, size: 32),
                            SizedBox(width: 8),
                            Text(
                              'REP',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.spa_rounded,
            color: Colors.green,
            size: 80,
          ),
          SizedBox(height: 24),
          Text(
            'Quick Rest',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.2),
              border: Border.all(color: Colors.green, width: 4),
            ),
            child: Center(
              child: Text(
                '$_restSecondsRemaining',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: _skipRest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Skip Rest',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Quit Exercise?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Your progress for this set won\'t be saved.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
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
