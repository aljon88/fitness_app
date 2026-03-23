class WorkoutDay {
  final int day;
  final String title;
  final List<Exercise> exercises;
  bool isCompleted;
  bool isUnlocked;
  final String? demoVideoPath;
  final String difficulty; // beginner, intermediate, advanced

  WorkoutDay({
    required this.day,
    required this.title,
    required this.exercises,
    this.isCompleted = false,
    this.isUnlocked = false,
    this.demoVideoPath,
    this.difficulty = 'beginner',
  });
}

class Exercise {
  final String name;
  final int sets;
  final int? reps;
  final int? duration; // in seconds
  bool isCompleted;
  final String description;
  final String? demoVideoPath;
  final String? imageAsset;
  final List<String> formCheckpoints;
  final ExerciseType type;
  
  // AI tracking properties
  int currentRep;
  int currentSet;
  double formAccuracy;
  List<String> formFeedback;

  Exercise({
    required this.name,
    required this.sets,
    this.reps,
    this.duration,
    this.isCompleted = false,
    this.description = '',
    this.demoVideoPath,
    this.imageAsset,
    this.formCheckpoints = const [],
    this.type = ExerciseType.strength,
    this.currentRep = 0,
    this.currentSet = 1,
    this.formAccuracy = 0.0,
    this.formFeedback = const [],
  });

  String get displayDescription {
    if (reps != null) {
      return '$sets sets x $reps reps';
    } else if (duration != null) {
      return '$sets sets x ${duration}s';
    }
    return '$sets sets';
  }

  String get progressText {
    if (reps != null) {
      return 'Set $currentSet: $currentRep/$reps reps';
    } else if (duration != null) {
      return 'Set $currentSet: ${duration}s hold';
    }
    return 'Set $currentSet';
  }

  bool get isSetComplete {
    if (reps != null) {
      return currentRep >= reps!;
    }
    return false; // Duration-based exercises handled differently
  }

  void completeRep() {
    if (reps != null && currentRep < reps!) {
      currentRep++;
    }
  }

  void nextSet() {
    if (currentSet < sets) {
      currentSet++;
      currentRep = 0;
    }
  }

  bool get isExerciseComplete {
    return currentSet >= sets && (reps == null || currentRep >= reps!);
  }

  void reset() {
    currentRep = 0;
    currentSet = 1;
    formAccuracy = 0.0;
    formFeedback = [];
    isCompleted = false;
  }
}

enum ExerciseType {
  strength,
  cardio,
  flexibility,
  balance,
  core
}