import 'package:flutter/material.dart';
import 'dart:async';
import '../services/sound_service.dart';

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
    _restSeconds = widget.exercise['rest'] ?? 30; // Use 30 seconds as default rest time
    _calculateSetDuration();
  }

  void _calculateSetDuration() {
    // Use actual program data for proper timing
    if (widget.exercise['duration'] != null) {
      // Duration-based exercise (like plank, high knees)
      _totalSeconds = widget.exercise['duration'] as int;
    } else if (widget.exercise['reps'] != null) {
      // Rep-based exercise - use full set duration, not per rep
      final reps = widget.exercise['reps'] as int;
      _totalSeconds = (reps * 2); // 2 seconds per rep for the entire set
    } else {
      // Fallback to 30 seconds if no data
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
        SoundService().playBeep(); // Play beep when rest ends
        _startSet();
      } else {
        // All sets complete, move to next exercise
        SoundService().playSetComplete(); // Play set complete sound
        widget.onComplete();
      }
    } else {
      // SET complete (not individual rep), start rest if more sets remain
      if (_currentSet < _totalSets) {
        SoundService().playRestStart(); // Play rest start sound
        _startRest();
      } else {
        // Last set complete, move to next exercise
        SoundService().playSetComplete(); // Play set complete sound
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
    
    // Only print debug info once, not on every timer tick
    if (_secondsElapsed == 0) {
      print('🎬 ExerciseTimerScreen building for: $exerciseName');
      print('   gifUrl value: $gifUrl');
      print('   gifUrl is null: ${gifUrl == null}');
      print('   gifUrl is empty: ${gifUrl?.toString().isEmpty ?? true}');
      print('   gifUrl type: ${gifUrl.runtimeType}');
      print('   Full exercise data keys: ${widget.exercise.keys.toList()}');
    }
    
    final progress = _totalSeconds > 0 ? _secondsElapsed / _totalSeconds : 0.0;

    return Scaffold(
      backgroundColor: _isResting ? Color(0xFF1A1B3A) : Color(0xFF1A1B3A), // Always use your app's dark theme
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with progress - HIDE during rest
            if (!_isResting)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1B3A), // Dark background like your app
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                            color: Color(0xFF2D3561), // Darker shade for button
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: widget.onPause,
                            icon: Icon(
                              Icons.close_rounded, 
                              size: 24,
                              color: Colors.white, // White icon on dark background
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
                                color: Colors.white, // Bright white for better contrast
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
                            color: Color(0xFF2D3561), // Dark progress track
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
                color: Colors.black,
                child: _isResting
                    ? _buildRestDisplay()
                    : Stack(
                        children: [
                          // Video/GIF background - improved container for proper fit
                          if (gifUrl != null && gifUrl.toString().isNotEmpty)
                            Positioned.fill(
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                child: _ExerciseGifWidget(gifUrl: gifUrl.toString()),
                              ),
                            ),
                          // Dark overlay for better text readability - reduced opacity
                          if (gifUrl != null && gifUrl.toString().isNotEmpty)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.1), // Reduced from 0.3
                                      Colors.transparent,             // Reduced from 0.1
                                      Colors.black.withOpacity(0.2), // Reduced from 0.4
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          // Pause overlay - shows when timer is paused
                          if (_isPaused && gifUrl != null && gifUrl.toString().isNotEmpty)
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
                          // Fallback placeholder if no video
                          if (gifUrl == null || gifUrl.toString().isEmpty)
                            Positioned.fill(child: _buildDemoPlaceholder()),
                        ],
                      ),
              ),
            ),

            // Exercise info and timer - DARK THEME
            if (!_isResting)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24, 24, 24, 28),
                decoration: BoxDecoration(
                  color: Color(0xFF2D3561), // Lighter dark background for better text contrast
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
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
                          color: Colors.white, // Bright white for maximum readability
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
                            color: Color(0xFF6C5CE7).withOpacity(0.2), // Your app's purple
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFF6C5CE7).withOpacity(0.5), // Purple border
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'SET $_currentSet OF $_totalSets',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white, // White text
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        )
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // COMPACT TIMER DISPLAY - BETTER CONTRAST
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF6C5CE7).withOpacity(0.15), // Slightly more opacity for better contrast
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF6C5CE7).withOpacity(0.4), // Stronger border
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 20,
                          color: Colors.white, // White icon for better visibility
                        ),
                        SizedBox(width: 8),
                        Text(
                          _formatTime(_totalSeconds - _secondsElapsed),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white, // White text for maximum readability
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 18),
                  
                  // Control buttons - EXACT APP COLORS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pause/Resume button - YOUR APP'S EXACT PURPLE
                      Container(
                        width: 100,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(0xFF6C5CE7), // Your app's exact purple
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6C5CE7).withOpacity(0.3),
                              blurRadius: 6,
                              offset: Offset(0, 2),
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
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, 
                                size: 16
                              ),
                              SizedBox(width: 4),
                              Text(
                                _isPaused ? 'Resume' : 'Pause',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Skip button - DARK THEME
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(0xFF2D3561), // Dark button background
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Color(0xFF6C5CE7).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _skipSet,
                          icon: Icon(
                            Icons.skip_next_rounded, 
                            size: 16,
                            color: Colors.white70, // Light icon on dark background
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1B3A), // Your app's dark background
            Color(0xFF2D3561), // Lighter dark shade
            Color(0xFF1A1B3A), // Back to dark
          ],
        ),
      ),
      child: Column(
        children: [
          // Top section with REST TIME badge
          Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF6C5CE7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Color(0xFF6C5CE7).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'REST TIME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),

          Spacer(),

          // Large circular timer - SIMPLE AND CLEAN
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2D3561).withOpacity(0.4),
              border: Border.all(
                color: Color(0xFF6C5CE7).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _formatTime(_totalSeconds - _secondsElapsed),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ),

          SizedBox(height: 50),

          // Action buttons - ALIGNED WITH YOUR COLORS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // +20s button - SIMPLE DARK STYLE
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Color(0xFF2D3561).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Color(0xFF6C5CE7).withOpacity(0.3),
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
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
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
              SizedBox(width: 20),
              // SKIP button - YOUR PURPLE COLOR
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: ElevatedButton(
                  onPressed: _skipSet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'SKIP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
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
              widget.exercise['name'] ?? 'Exercise',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Follow the timer below',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
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
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Loading demo...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
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

// Separate widget for GIF to prevent rebuilds during timer updates
class _ExerciseGifWidget extends StatelessWidget {
  final String gifUrl;

  const _ExerciseGifWidget({required this.gifUrl});

  @override
  Widget build(BuildContext context) {
    // Validate gifUrl before attempting to load
    if (gifUrl.isEmpty || gifUrl == 'null' || gifUrl == null) {
      return _buildFallbackDemo();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Image.network(
        gifUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingDemo();
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Failed to load exercise GIF: $gifUrl');
          print('   Error: $error');
          return _buildFallbackDemo();
        },
      ),
    );
  }

  Widget _buildLoadingDemo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading indicator
          TweenAnimationBuilder<double>(
            duration: Duration(seconds: 2),
            tween: Tween(begin: 0.8, end: 1.2),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF007AFF).withOpacity(0.2),
                    border: Border.all(
                      color: Color(0xFF007AFF).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    size: 60,
                    color: Color(0xFF007AFF),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            'Loading Exercise Demo...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackDemo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF007AFF).withOpacity(0.2),
              border: Border.all(
                color: Color(0xFF007AFF).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.fitness_center,
              size: 60,
              color: Color(0xFF007AFF),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Exercise Demo',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Follow the timer below',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
