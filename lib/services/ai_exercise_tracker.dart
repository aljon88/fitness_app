import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'pose_detection_service.dart';
import 'exercise_rep_counter.dart';

enum FormFeedback {
  none,
  excellent,
  good,
  needsImprovement,
  poor,
}

class AIExerciseTracker {
  final PoseDetectionService _poseDetector = PoseDetectionService();
  ExerciseRepCounter? _repCounter;
  
  bool _isTracking = false;
  String _currentExercise = '';
  Function(int)? _onRepCountChanged;
  Function(FormFeedback)? _onFormFeedback;
  
  Timer? _feedbackTimer;
  Timer? _repTimer;
  DateTime? _lastFeedbackTime;
  
  // Tracking state
  int _frameCount = 0;
  
  // Add missing getters
  bool get isTracking => _isTracking;
  bool get userDetected => _isTracking; // Simulate user detection
  
  Future<void> initialize() async {
    await _poseDetector.initialize();
  }

  void startTracking(
    String exercise, 
    Function(int) onRepCountChanged, {
    Function(FormFeedback)? onFormFeedback,
  }) {
    _currentExercise = exercise;
    _onRepCountChanged = onRepCountChanged;
    _onFormFeedback = onFormFeedback;
    _isTracking = true;
    
    // Initialize rep counter based on exercise
    ExerciseType exerciseType = _getExerciseType(exercise);
    _repCounter = ExerciseRepCounter(exerciseType);
    
    // Start feedback timer (lightweight)
    _feedbackTimer = Timer.periodic(Duration(seconds: 3), (_) {
      _provideFeedback();
    });
    
    // Start rep simulation timer for demo
    _repTimer = Timer.periodic(Duration(seconds: 2), (_) {
      if (_repCounter != null) {
        final previousCount = _repCounter!.repCount;
        _repCounter!.updatePose(MockPose());
        final currentCount = _repCounter!.repCount;
        
        if (currentCount != previousCount) {
          _onRepCountChanged?.call(currentCount);
        }
      }
    });
    
    print('Started tracking: $exercise (lightweight mode)');
  }

  void stopTracking() {
    _isTracking = false;
    _feedbackTimer?.cancel();
    _repTimer?.cancel();
    _repCounter = null;
    _frameCount = 0;
    print('Stopped tracking');
  }

  void resetReps() {
    _repCounter?.reset();
    _onRepCountChanged?.call(0);
  }

  Future<void> processCameraFrame(CameraImage cameraImage) async {
    if (!_isTracking || _repCounter == null) return;
    
    // Process every 10th frame to reduce load
    _frameCount++;
    if (_frameCount % 10 != 0) return;
    
    try {
      // Lightweight processing - just simulate detection
      await Future.delayed(Duration(milliseconds: 10));
    } catch (e) {
      print('Error processing camera frame: $e');
    }
  }

  void _provideFeedback() {
    if (_repCounter == null) return;
    
    // Don't provide feedback too frequently
    final now = DateTime.now();
    if (_lastFeedbackTime != null && 
        now.difference(_lastFeedbackTime!).inSeconds < 4) {
      return;
    }
    
    // Simulate feedback
    final feedbacks = [
      FormFeedback.excellent,
      FormFeedback.good,
      FormFeedback.needsImprovement,
    ];
    feedbacks.shuffle();
    final feedback = feedbacks.first;
    
    _onFormFeedback?.call(feedback);
    _lastFeedbackTime = now;
  }

  ExerciseType _getExerciseType(String exercise) {
    switch (exercise.toLowerCase()) {
      case 'push-ups':
      case 'push ups':
      case 'pushups':
        return ExerciseType.pushUp;
      case 'squats':
      case 'squat':
        return ExerciseType.squat;
      case 'jumping jacks':
      case 'jumping jack':
        return ExerciseType.jumpingJacks;
      case 'plank':
        return ExerciseType.plank;
      default:
        return ExerciseType.pushUp;
    }
  }

  String getFormFeedbackMessage(FormFeedback feedback) {
    switch (feedback) {
      case FormFeedback.excellent:
        return "Perfect form! Keep it up! 🔥";
      case FormFeedback.good:
        return "Good form! You're doing great! 👍";
      case FormFeedback.needsImprovement:
        return "Watch your form - small adjustments needed 💪";
      case FormFeedback.poor:
        return "Focus on proper form for better results ⚠️";
      case FormFeedback.none:
        return "";
    }
  }

  void dispose() {
    stopTracking();
    _poseDetector.dispose();
  }
}