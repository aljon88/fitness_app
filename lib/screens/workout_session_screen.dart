import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../services/ai_exercise_tracker.dart';
import '../services/navigation_service.dart';
import '../widgets/navigation_widgets.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final Map<String, dynamic> workout;
  final Map<String, dynamic> profile;
  final VoidCallback onWorkoutCompleted;

  const WorkoutSessionScreen({
    Key? key,
    required this.workout,
    required this.profile,
    required this.onWorkoutCompleted,
  }) : super(key: key);

  @override
  _WorkoutSessionScreenState createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isWorkoutStarted = false;
  bool _isWorkoutCompleted = false;
  
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _currentReps = 0;
  int _targetReps = 12;
  int _targetSets = 3;
  bool _isResting = false;
  int _restTimeLeft = 0;
  Timer? _restTimer;
  Timer? _workoutTimer;
  int _totalWorkoutTime = 0;
  
  late AIExerciseTracker _aiTracker;

  @override
  void initState() {
    super.initState();
    _aiTracker = AIExerciseTracker();
    _setupWorkout();
    // Initialize camera but don't block the UI if it fails
    _initializeCamera();
  }

  void _setupWorkout() {
    final exercises = widget.workout['exercises'] as List<Map<String, dynamic>>;
    if (exercises.isNotEmpty) {
      final currentExercise = exercises[_currentExerciseIndex];
      _targetReps = currentExercise['reps'] ?? 12;
      _targetSets = currentExercise['sets'] ?? 3;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      print('🎥 Starting camera initialization...');
      
      // Get available cameras first
      _cameras = await availableCameras();
      print('📱 Found ${_cameras?.length ?? 0} cameras');
      
      if (_cameras == null || _cameras!.isEmpty) {
        print('❌ No cameras available - using simulation mode');
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
          });
        }
        return;
      }

      // Select camera (prefer front camera for workouts)
      CameraDescription selectedCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      
      print('✅ Selected camera: ${selectedCamera.name} (${selectedCamera.lensDirection})');
      
      // Initialize camera controller
      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      print('🎉 Camera controller initialized successfully');
      
      if (mounted && _cameraController!.value.isInitialized) {
        setState(() {
          _isCameraInitialized = true;
        });
        print('✅ Camera state updated - ready to use');
      } else {
        print('❌ Camera not properly initialized');
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
          });
        }
      }
      
    } catch (e) {
      print('❌ Camera initialization error: $e');
      // Don't block the app if camera fails - use simulation mode
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  void _processCameraImage(CameraImage image) {
    // Simplified camera processing - just notify AI tracker that camera is active
    if (_isWorkoutStarted && _aiTracker.isTracking) {
      // Let the AI tracker know camera is providing data
      // In a real implementation, this would process the actual image
      // For now, we'll rely on the simulation with enhanced realism
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
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - kBottomNavigationBarHeight,
              ),
              child: Column(
                children: [
                  // Compact Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 8 : 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _showExitDialog(),
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.workout['title'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Day ${widget.workout['day']} • ${widget.workout['duration']}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isSmallScreen ? 11 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isWorkoutStarted)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFF6C5CE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_currentExerciseIndex + 1}/${widget.workout['exercises'].length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Main Content
                  _isWorkoutStarted ? _buildCompactWorkoutInterface(isSmallScreen) : _buildCompactPreWorkoutInterface(isSmallScreen),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: WorkoutCameraFAB(
        onPressed: () => NavigationService().navigateToCamera(fromWorkout: true),
      ),
    );
  }

  Widget _buildCompactPreWorkoutInterface(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Camera Preview - Compact
          Container(
            height: isSmallScreen ? 200 : 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _isCameraInitialized && _cameraController != null && _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white60,
                            size: isSmallScreen ? 32 : 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            _isCameraInitialized ? 'Camera Ready' : 'Camera Initializing...',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          if (!_isCameraInitialized) ...[
                            SizedBox(height: 4),
                            Text(
                              'AI tracking will work in simulation mode',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // AI Ready Info - Compact
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF6C5CE7),
                  size: isSmallScreen ? 18 : 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Movement Detection Ready',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          // Exercise Preview - Compact
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Exercises:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                ...widget.workout['exercises'].take(3).map<Widget>((exercise) => Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    '• ${exercise['name']} - ${exercise['reps']} × ${exercise['sets']}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 10 : 11,
                    ),
                  ),
                )).toList(),
                if (widget.workout['exercises'].length > 3)
                  Text(
                    '... and ${widget.workout['exercises'].length - 3} more',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: isSmallScreen ? 10 : 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 16 : 20),
          
          // Start Button
          Container(
            width: double.infinity,
            height: isSmallScreen ? 44 : 48,
            child: ElevatedButton(
              onPressed: _startWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: Color(0xFF6C5CE7).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                'Start Workout',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCompactWorkoutInterface(bool isSmallScreen) {
    final exercises = widget.workout['exercises'] as List<Map<String, dynamic>>;
    final currentExercise = exercises[_currentExerciseIndex];
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Camera View - Compact
          Container(
            height: isSmallScreen ? 220 : 280,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  if (_isCameraInitialized && _cameraController != null && _cameraController!.value.isInitialized)
                    Positioned.fill(child: CameraPreview(_cameraController!))
                  else
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2D3561),
                              Color(0xFF1A1B3A),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                color: Colors.white.withOpacity(0.3),
                                size: isSmallScreen ? 40 : 50,
                              ),
                              SizedBox(height: 8),
                              Text(
                                _isCameraInitialized ? 'Camera Active' : 'Simulation Mode',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: isSmallScreen ? 11 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Rep Counter & Set Info - Compact
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$_currentReps / $_targetReps',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Set $_currentSet/$_targetSets',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 10 : 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // AI Status - Compact
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isCameraInitialized 
                            ? (_aiTracker.userDetected ? Colors.green : Colors.orange)
                            : Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            _isCameraInitialized 
                                ? (_aiTracker.userDetected ? 'AI Active' : 'Looking')
                                : 'AI Sim',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Workout Timer - Compact
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined, color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text(
                            _formatTime(_totalWorkoutTime),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Rest Period Overlay
                  if (_isResting)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pause_circle_filled_rounded,
                                color: Colors.orange,
                                size: isSmallScreen ? 40 : 50,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Rest Time',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: isSmallScreen ? 60 : 80,
                                height: isSmallScreen ? 60 : 80,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: isSmallScreen ? 60 : 80,
                                      height: isSmallScreen ? 60 : 80,
                                      child: CircularProgressIndicator(
                                        value: 1.0 - (_restTimeLeft / (widget.workout['exercises'][_currentExerciseIndex]['restTime'] ?? 60)),
                                        strokeWidth: 4,
                                        backgroundColor: Colors.white.withOpacity(0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '$_restTimeLeft',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isSmallScreen ? 20 : 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Exercise Info & Controls - Compact
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        currentExercise['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!_isResting)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF6C5CE7).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Set $_currentSet/$_targetSets',
                          style: TextStyle(
                            color: Color(0xFF6C5CE7),
                            fontSize: isSmallScreen ? 10 : 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  currentExercise['instructions'],
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 11 : 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF6C5CE7).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Tip: ${currentExercise['tips']}',
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontSize: isSmallScreen ? 9 : 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Control Buttons - Compact
                Row(
                  children: [
                    if (!_isResting) ...[
                      Expanded(
                        child: Container(
                          height: isSmallScreen ? 36 : 40,
                          child: ElevatedButton(
                            onPressed: _skipExercise,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: isSmallScreen ? 36 : 40,
                          child: ElevatedButton(
                            onPressed: _completeSet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00B894),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Complete Set',
                              style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: Container(
                          height: isSmallScreen ? 36 : 40,
                          child: ElevatedButton(
                            onPressed: () {
                              _restTimer?.cancel();
                              setState(() {
                                _isResting = false;
                                _restTimeLeft = 0;
                              });
                              
                              // Resume AI tracking
                              final exercises = widget.workout['exercises'] as List<Map<String, dynamic>>;
                              _aiTracker.startTracking(
                                exercises[_currentExerciseIndex]['name'], 
                                (reps) {
                                  if (mounted) {
                                    setState(() {
                                      _currentReps = reps;
                                    });
                                    
                                    if (_currentReps >= _targetReps) {
                                      _completeSet();
                                    }
                                  }
                                },
                                onFormFeedback: (feedback) {
                                  if (mounted && feedback != FormFeedback.none) {
                                    _showFormFeedback(feedback);
                                  }
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6C5CE7),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Skip Rest',
                              style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _startWorkout() {
    print('🏋️ Starting workout...');
    final exercises = widget.workout['exercises'] as List<Map<String, dynamic>>;
    
    setState(() {
      _isWorkoutStarted = true;
      _currentSet = 1;
      _targetReps = exercises[_currentExerciseIndex]['reps'];
      _targetSets = exercises[_currentExerciseIndex]['sets'];
      _totalWorkoutTime = 0;
    });
    
    // Ensure camera is still active
    if (_cameraController != null && !_cameraController!.value.isInitialized) {
      print('⚠️ Camera not initialized, reinitializing...');
      _initializeCamera();
    }
    
    // Start workout timer
    _workoutTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && _isWorkoutStarted && !_isResting) {
        setState(() {
          _totalWorkoutTime++;
        });
      }
    });
    
    // Start AI tracking with form feedback
    _aiTracker.startTracking(
      exercises[_currentExerciseIndex]['name'], 
      (reps) {
        if (mounted) {
          setState(() {
            _currentReps = reps;
          });
          
          // Check if set is complete
          if (_currentReps >= _targetReps) {
            _completeSet();
          }
        }
      },
      onFormFeedback: (feedback) {
        if (mounted && feedback != FormFeedback.none) {
          _showFormFeedback(feedback);
        }
      },
    );
    
    print('✅ Workout started with AI tracking for ${exercises[_currentExerciseIndex]['name']}');
  }

  void _completeSet() {
    print('✅ Set $_currentSet completed!');
    
    if (_currentSet < _targetSets) {
      // Start rest period
      setState(() {
        _isResting = true;
        _restTimeLeft = widget.workout['exercises'][_currentExerciseIndex]['restTime'] ?? 60;
        _currentSet++;
        _currentReps = 0;
      });
      
      _aiTracker.resetReps();
      _startRestTimer();
    } else {
      // Exercise complete, move to next
      _completeExercise();
    }
  }

  void _startRestTimer() {
    _restTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _restTimeLeft--;
        });
        
        if (_restTimeLeft <= 0) {
          timer.cancel();
          setState(() {
            _isResting = false;
          });
          
          // Resume AI tracking for next set
          final exercises = widget.workout['exercises'] as List<Map<String, dynamic>>;
          _aiTracker.startTracking(
            exercises[_currentExerciseIndex]['name'], 
            (reps) {
              if (mounted) {
                setState(() {
                  _currentReps = reps;
                });
                
                if (_currentReps >= _targetReps) {
                  _completeSet();
                }
              }
            },
            onFormFeedback: (feedback) {
              if (mounted && feedback != FormFeedback.none) {
                _showFormFeedback(feedback);
              }
            },
          );
        }
      }
    });
  }

  void _completeExercise() {
    final exercises = widget.workout['exercises'] as List<Map<String, dynamic>>;
    if (_currentExerciseIndex < exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _currentReps = 0;
        _targetReps = exercises[_currentExerciseIndex]['reps'];
        _targetSets = exercises[_currentExerciseIndex]['sets'];
      });
      
      // Update AI tracker for new exercise
      _aiTracker.startTracking(
        exercises[_currentExerciseIndex]['name'], 
        (reps) {
          if (mounted) {
            setState(() {
              _currentReps = reps;
            });
            
            if (_currentReps >= _targetReps) {
              _completeSet();
            }
          }
        },
        onFormFeedback: (feedback) {
          if (mounted && feedback != FormFeedback.none) {
            _showFormFeedback(feedback);
          }
        },
      );
    } else {
      _completeWorkout();
    }
  }

  void _skipExercise() {
    _completeExercise();
  }

  void _completeWorkout() {
    setState(() {
      _isWorkoutCompleted = true;
    });
    
    _aiTracker.stopTracking();
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    
    // Show completion dialog with stats
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.celebration_rounded, color: Color(0xFF6C5CE7), size: 28),
            SizedBox(width: 12),
            Text(
              'Workout Complete!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Congratulations! You\'ve completed Day ${widget.workout['day']}.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Time:',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        _formatTime(_totalWorkoutTime),
                        style: TextStyle(
                          color: Color(0xFF6C5CE7),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exercises:',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        '${widget.workout['exercises'].length} completed',
                        style: TextStyle(
                          color: Color(0xFF00B894),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Keep up the momentum! 💪',
              style: TextStyle(
                color: Color(0xFF6C5CE7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              NavigationService().completeWorkoutSession();
              widget.onWorkoutCompleted();
              NavigationService().navigateBack();
            },
            child: Text(
              'Continue',
              style: TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showFormFeedback(FormFeedback feedback) {
    String message = _aiTracker.getFormFeedbackMessage(feedback);
    Color feedbackColor;
    
    switch (feedback) {
      case FormFeedback.excellent:
        feedbackColor = Colors.green;
        break;
      case FormFeedback.good:
        feedbackColor = Colors.blue;
        break;
      case FormFeedback.needsImprovement:
        feedbackColor = Colors.orange;
        break;
      case FormFeedback.poor:
        feedbackColor = Colors.red;
        break;
      default:
        return;
    }
    
    // Show form feedback as a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              feedback == FormFeedback.excellent || feedback == FormFeedback.good
                  ? Icons.check_circle
                  : Icons.warning,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: feedbackColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Exit Workout?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to exit? Your progress will not be saved.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Exit',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('🧹 Disposing workout session...');
    try {
      if (_cameraController != null) {
        _cameraController!.dispose();
        print('✅ Camera disposed');
      }
    } catch (e) {
      print('❌ Error disposing camera: $e');
    }
    
    // Clean up timers
    _restTimer?.cancel();
    _workoutTimer?.cancel();
    
    _aiTracker.stopTracking();
    print('✅ AI tracker stopped');
    super.dispose();
  }
}