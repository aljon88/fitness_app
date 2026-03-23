import 'dart:math';
import 'pose_detection_service.dart'; // Import MockPose from here

enum ExerciseType {
  pushUp,
  squat,
  plank,
  jumpingJacks,
}

enum RepState {
  up,
  down,
  neutral,
}

class ExerciseRepCounter {
  ExerciseType exerciseType;
  int _repCount = 0;
  RepState _currentState = RepState.neutral;
  DateTime? _lastRepTime;
  
  // Simplified thresholds
  static const Map<ExerciseType, double> _minTimeBetweenReps = {
    ExerciseType.pushUp: 0.8,
    ExerciseType.squat: 1.0,
    ExerciseType.jumpingJacks: 0.5,
    ExerciseType.plank: 0.0,
  };

  ExerciseRepCounter(this.exerciseType);

  int get repCount => _repCount;
  RepState get currentState => _currentState;

  void reset() {
    _repCount = 0;
    _currentState = RepState.neutral;
    _lastRepTime = null;
  }

  void updatePose(MockPose pose) {
    // Simulate rep counting with timer-based logic for demo
    final now = DateTime.now();
    final minTime = _minTimeBetweenReps[exerciseType] ?? 1.0;
    
    if (_lastRepTime == null || 
        now.difference(_lastRepTime!).inMilliseconds > (minTime * 1000)) {
      
      // Simulate rep detection every few seconds for demo
      if (now.millisecondsSinceEpoch % 3000 < 100) {
        _repCount++;
        _lastRepTime = now;
        _currentState = RepState.down;
      } else if (now.millisecondsSinceEpoch % 1500 < 100) {
        _currentState = RepState.up;
      }
    }
  }

  // Get feedback based on current form (simplified)
  String getFormFeedback(MockPose pose) {
    switch (exerciseType) {
      case ExerciseType.pushUp:
        return _currentState == RepState.down 
            ? "Push back up!" 
            : "Good form! Lower down slowly";
      case ExerciseType.squat:
        return _currentState == RepState.down 
            ? "Stand back up!" 
            : "Good! Now squat down";
      case ExerciseType.jumpingJacks:
        return "Keep jumping! Great rhythm!";
      case ExerciseType.plank:
        return "Hold steady! Keep that form!";
    }
  }
}