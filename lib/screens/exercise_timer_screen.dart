import 'package:flutter/material.dart';
import 'dart:async';

class ExerciseTimerScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final int currentExerciseIndex;
  final int totalExercises;
  final VoidCallback onComplete;
  final VoidCallback onPause;

  const ExerciseTimerScreen({
    Key? key,
    required this.exercise,
    required this.currentExerciseIndex,
    required this.totalExercises,
    required this.onComplete,
    required this.onPause,
  }) : super(key: key);

  @override
  State<ExerciseTimerScreen> createState() => _ExerciseTimerScreenState();
}

class _ExerciseTimerScreenState extends State<ExerciseTimerScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  int _totalSeconds = 0;
  bool _isPaused = false;
  bool _isResting = false;
  int _currentSet = 1;
  int _totalSets = 1;
  int _restSeconds = 30;

  @override
  void initState() {
    super.initState();
    _initializeExercise();
    _startSet();
  }

  void _initializeExercise() {
    _totalSets = widget.exercise['sets'] ?? 1;
    _restSeconds = widget.exercise['rest'] ?? 30;
    _calculateSetDuration();
  }

  void _calculateSetDuration() {
    if (widget.exercise['duration'] != null) {
      // Duration-based exercise (like plank)
      _totalSeconds = widget.exercise['duration'] as int;
    } else if (widget.exercise['reps'] != null) {
      // Rep-based exercise - estimate 2 seconds per rep
      final reps = widget.exercise['reps'] as int;
      _totalSeconds = (reps * 2);
    } else {
      _totalSeconds = 30;
    }
  }

  void _startSet() {
    _secondsElapsed = 0;
    _isResting = false;
    _startTimer();
  }

  void _startRest() {
    _secondsElapsed = 0;
    _totalSeconds = _restSeconds;
    _isResting = true;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    print('🕐 Starting timer: _isPaused = $_isPaused, _secondsElapsed = $_secondsElapsed, _totalSeconds = $_totalSeconds');
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++;
          print('   Timer tick: $_secondsElapsed/$_totalSeconds');
          if (_secondsElapsed >= _totalSeconds) {
            print('   Timer complete!');
            timer.cancel();
            _handleTimerComplete();
          }
        });
      } else {
        print('   Timer paused, skipping tick');
      }
    });
  }

  void _handleTimerComplete() {
    if (_isResting) {
      // Rest complete, start next set
      _currentSet++;
      if (_currentSet <= _totalSets) {
        _calculateSetDuration();
        _startSet();
      } else {
        // All sets complete, move to next exercise
        widget.onComplete();
      }
    } else {
      // Set complete, start rest (unless it's the last set)
      if (_currentSet < _totalSets) {
        _startRest();
      } else {
        // Last set complete, move to next exercise
        widget.onComplete();
      }
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    print('🎮 Pause toggled: _isPaused = $_isPaused');
    print('   Timer active: ${_timer?.isActive ?? false}');
    
    // If resuming and timer is not active, restart it
    if (!_isPaused && (_timer == null || !_timer!.isActive)) {
      print('   Restarting timer...');
      _startTimer();
    }
  }

  void _skipSet() {
    _timer?.cancel();
    _handleTimerComplete();
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  bool _isRepBasedExercise() {
    return widget.exercise['reps'] != null && widget.exercise['duration'] == null;
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
    
    // Debug: Print the gifUrl being used
    print('🎬 ExerciseTimerScreen building for: $exerciseName');
    print('   gifUrl value: $gifUrl');
    print('   gifUrl is null: ${gifUrl == null}');
    print('   gifUrl type: ${gifUrl.runtimeType}');
    
    final progress = _totalSeconds > 0 ? _secondsElapsed / _totalSeconds : 0.0;

    return Scaffold(
      backgroundColor: _isResting ? Color(0xFF1A1A1A) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with progress - HIDE during rest
            if (!_isResting)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: widget.onPause,
                            icon: Icon(
                              Icons.close_rounded, 
                              size: 24,
                              color: Colors.black87,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              'Exercise ${widget.currentExerciseIndex + 1}/${widget.totalExercises}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Color(0xFF007AFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF007AFF),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 44), // Spacer to center the middle content
                      ],
                    ),
                    SizedBox(height: 14),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF007AFF).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Demo video/GIF area or REST message
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _isResting 
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFF9500), Color(0xFFFF8000)],
                        )
                      : null,
                  color: _isResting ? null : Colors.black,
                ),
                child: _isResting
                    ? _buildRestDisplay()
                    : Stack(
                        children: [
                          // Video/GIF background
                          if (gifUrl != null)
                            Positioned.fill(
                              child: ClipRRect(
                                child: Image.network(
                                  gifUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      print('✅ Image loaded successfully: $gifUrl');
                                      return child;
                                    }
                                    print('⏳ Loading image: $gifUrl (${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes ?? 0} bytes)');
                                    return _buildDemoPlaceholder();
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print('❌ Failed to load image: $gifUrl');
                                    print('   Error: $error');
                                    return _buildDemoPlaceholder();
                                  },
                                ),
                              ),
                            ),
                          // Dark overlay for better text readability
                          if (gifUrl != null)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.4),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          // Pause overlay - shows when timer is paused
                          if (_isPaused && gifUrl != null)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.7),
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.pause_rounded,
                                      size: 60,
                                      color: Color(0xFF007AFF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                              ),
                            ),
                          // Fallback placeholder if no video
                          if (gifUrl == null)
                            Positioned.fill(child: _buildDemoPlaceholder()),
                        ],
                      ),
              ),
            ),

            // Exercise info and timer - COMPLETELY HIDDEN during rest
            if (!_isResting)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24, 24, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Exercise name and set info
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isResting ? 'REST TIME' : exerciseName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: _isResting ? Colors.white : Color(0xFF1A1A1A),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 12),
                      
                      if (!_isResting)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF007AFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFF007AFF).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'SET $_currentSet OF $_totalSets',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF007AFF),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF9500).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFFFF9500).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Next: Set ${_currentSet + 1} of $_totalSets',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFF9500),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Main display: reps or timer
                  if (_isResting)
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF9500).withOpacity(0.15),
                            Color(0xFFFF9500).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Color(0xFFFF9500).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 48,
                            color: Color(0xFFFF9500),
                          ),
                          SizedBox(width: 16),
                          Text(
                            _formatTime(_totalSeconds - _secondsElapsed),
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF9500),
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_isRepBasedExercise())
                    // CLEAN REP DISPLAY - Professional, compact design
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF007AFF).withOpacity(0.08),
                            Color(0xFF007AFF).withOpacity(0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFF007AFF).withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(0xFF007AFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.repeat_rounded,
                              size: 18,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.exercise['reps']} reps',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF007AFF),
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                'Complete at your pace',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF007AFF).withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF007AFF).withOpacity(0.12),
                            Color(0xFF007AFF).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Color(0xFF007AFF).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 48,
                            color: Color(0xFF007AFF),
                          ),
                          SizedBox(width: 16),
                          Text(
                            _formatTime(_totalSeconds - _secondsElapsed),
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF007AFF),
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  SizedBox(height: 24),
                  
                  // Control buttons
                  Row(
                    children: [
                      // Pause/Resume button
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isResting 
                                  ? [Color(0xFFFF9500), Color(0xFFFF8000)]
                                  : [Color(0xFF007AFF), Color(0xFF0051D5)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (_isResting ? Color(0xFFFF9500) : Color(0xFF007AFF))
                                    .withOpacity(0.4),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _togglePause,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, 
                                  size: 28
                                ),
                                SizedBox(width: 8),
                                Text(
                                  _isPaused ? 'Resume' : 'Pause',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Skip button
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _isResting ? Colors.white.withOpacity(0.15) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isResting 
                                ? Colors.white.withOpacity(0.25)
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _skipSet,
                          icon: Icon(
                            Icons.skip_next_rounded, 
                            size: 28,
                            color: _isResting ? Colors.white : Colors.grey[700],
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestDisplay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          // Top section with REST TIME badge - CLEAN DESIGN
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'REST TIME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),

          Spacer(),

          // Large circular timer - COMPACT VERSION
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _formatTime(_totalSeconds - _secondsElapsed),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 32),

          // Action buttons - COMPACT VERSION
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // +20s button
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _totalSeconds += 20;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    '+20s',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // SKIP button
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _skipSet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Color(0xFFFF9500),
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'SKIP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Spacer(),
        ],
      ),
    );
  }

  Widget _buildDemoPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                _getExerciseIcon(widget.exercise['name'] ?? ''),
                size: 80,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Demo loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w600,
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
