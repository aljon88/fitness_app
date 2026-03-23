import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ai_exercise_tracker.dart';
import '../services/navigation_service.dart';
import '../models/navigation_state.dart';
import '../widgets/navigation_widgets.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  
  late AIExerciseTracker _aiTracker;
  int _repCount = 0;
  String _selectedExercise = 'Push-ups';
  
  final List<String> _exercises = [
    'Push-ups',
    'Squats',
    'Jumping Jacks',
    'Plank',
    'Burpees',
    'Mountain Climbers',
  ];

  @override
  void initState() {
    super.initState();
    _aiTracker = AIExerciseTracker();
    // Initialize AI tracker and camera
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize AI tracker first
    await _aiTracker.initialize();
    // Then initialize camera
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission first
      final permission = await Permission.camera.request();
      if (permission != PermissionStatus.granted) {
        print('Camera permission denied');
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
          });
        }
        return;
      }

      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Prefer front camera for workout tracking
        CameraDescription selectedCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );
        
        _cameraController = CameraController(
          selectedCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
        
        await _cameraController!.initialize();
        
        // Start image stream for AI processing
        await _cameraController!.startImageStream(_processCameraImage);
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        print('No cameras available');
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  void _processCameraImage(CameraImage image) {
    // Process camera frames for AI detection
    if (_isRecording) {
      _aiTracker.processCameraFrame(image);
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Camera Trainer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Real-time movement detection',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(10),
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
                                _isRecording ? 'Recording' : 'Ready',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Camera View - Responsive height
                  Container(
                    height: isSmallScreen ? 280 : 350,
                    child: _buildCameraView(),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  
                  // Compact Controls
                  _buildCompactControls(isSmallScreen),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: MainNavigationBar(currentScreen: NavigationScreen.camera),
    );
  }

  Widget _buildCameraView() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Camera Preview
            if (_isCameraInitialized && _cameraController != null)
              Positioned.fill(child: CameraPreview(_cameraController!))
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white60,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _cameras == null || _cameras!.isEmpty 
                          ? 'No Camera Available'
                          : 'Camera Initializing...',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                    ),
                    if (_cameras == null || _cameras!.isEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        'AI tracking will be simulated',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            
            // Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            
            // Rep Counter
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '$_repCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'REPS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Exercise Name
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedExercise,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            // AI Status
            if (_isRecording)
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'AI Detecting',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildCompactControls(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Exercise Selector
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedExercise,
                dropdownColor: Color(0xFF1A1B3A),
                style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 14 : 16),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                items: _exercises.map((exercise) => DropdownMenuItem(
                  value: exercise,
                  child: Text(exercise),
                )).toList(),
                onChanged: (value) {
                  if (value != null && !_isRecording) {
                    setState(() {
                      _selectedExercise = value;
                    });
                  }
                },
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Control Buttons
          Row(
            children: [
              // Reset Button
              Expanded(
                child: Container(
                  height: isSmallScreen ? 44 : 48,
                  child: ElevatedButton(
                    onPressed: _resetCount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: isSmallScreen ? 16 : 18),
                        SizedBox(width: 6),
                        Text(
                          'Reset',
                          style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Start/Stop Button
              Expanded(
                flex: 2,
                child: Container(
                  height: isSmallScreen ? 44 : 48,
                  child: ElevatedButton(
                    onPressed: (_isCameraInitialized || (_cameras != null && _cameras!.isEmpty)) ? _toggleRecording : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.red : Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: (_isRecording ? Colors.red : Color(0xFF6C5CE7)).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isRecording ? Icons.stop_rounded : Icons.play_arrow_rounded,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          _isRecording ? 'Stop' : 'Start',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
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
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (_isRecording) {
      _aiTracker.startTracking(
        _selectedExercise, 
        (reps) {
          if (mounted) {
            setState(() {
              _repCount = reps;
            });
          }
        },
        onFormFeedback: (feedback) {
          if (mounted && feedback != FormFeedback.none) {
            _showFormFeedback(feedback);
          }
        },
      );
    } else {
      _aiTracker.stopTracking();
    }
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

  void _resetCount() {
    setState(() {
      _repCount = 0;
    });
    _aiTracker.resetReps();
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _aiTracker.stopTracking();
    super.dispose();
  }
}