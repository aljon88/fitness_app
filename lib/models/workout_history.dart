class WorkoutHistory {
  final String id;
  final String userId;
  final String workoutId;
  final String workoutTitle;
  final int dayNumber;
  final DateTime completedAt;
  final int durationMinutes;
  final List<ExerciseResult> exercises;
  final int totalReps;
  final int totalSets;
  final int caloriesBurned;
  final String difficulty;

  WorkoutHistory({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.workoutTitle,
    required this.dayNumber,
    required this.completedAt,
    required this.durationMinutes,
    required this.exercises,
    required this.totalReps,
    required this.totalSets,
    required this.caloriesBurned,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'workoutId': workoutId,
      'workoutTitle': workoutTitle,
      'dayNumber': dayNumber,
      'completedAt': completedAt.toIso8601String(),
      'durationMinutes': durationMinutes,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'totalReps': totalReps,
      'totalSets': totalSets,
      'caloriesBurned': caloriesBurned,
      'difficulty': difficulty,
    };
  }

  factory WorkoutHistory.fromJson(Map<String, dynamic> json) {
    return WorkoutHistory(
      id: json['id'],
      userId: json['userId'],
      workoutId: json['workoutId'],
      workoutTitle: json['workoutTitle'],
      dayNumber: json['dayNumber'],
      completedAt: DateTime.parse(json['completedAt']),
      durationMinutes: json['durationMinutes'],
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseResult.fromJson(e))
          .toList(),
      totalReps: json['totalReps'],
      totalSets: json['totalSets'],
      caloriesBurned: json['caloriesBurned'],
      difficulty: json['difficulty'],
    );
  }
}

class ExerciseResult {
  final String exerciseId;
  final String exerciseName;
  final int targetReps;
  final int actualReps;
  final int targetSets;
  final int completedSets;
  final bool completed;
  final List<SetResult> setResults;

  ExerciseResult({
    required this.exerciseId,
    required this.exerciseName,
    required this.targetReps,
    required this.actualReps,
    required this.targetSets,
    required this.completedSets,
    required this.completed,
    required this.setResults,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'targetReps': targetReps,
      'actualReps': actualReps,
      'targetSets': targetSets,
      'completedSets': completedSets,
      'completed': completed,
      'setResults': setResults.map((s) => s.toJson()).toList(),
    };
  }

  factory ExerciseResult.fromJson(Map<String, dynamic> json) {
    return ExerciseResult(
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      targetReps: json['targetReps'],
      actualReps: json['actualReps'],
      targetSets: json['targetSets'],
      completedSets: json['completedSets'],
      completed: json['completed'],
      setResults: (json['setResults'] as List)
          .map((s) => SetResult.fromJson(s))
          .toList(),
    );
  }
}

class SetResult {
  final int setNumber;
  final int reps;
  final DateTime completedAt;

  SetResult({
    required this.setNumber,
    required this.reps,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory SetResult.fromJson(Map<String, dynamic> json) {
    return SetResult(
      setNumber: json['setNumber'],
      reps: json['reps'],
      completedAt: DateTime.parse(json['completedAt']),
    );
  }
}
