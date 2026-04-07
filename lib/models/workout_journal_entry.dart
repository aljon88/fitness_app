class WorkoutJournalEntry {
  final String id;
  final DateTime date;
  final String workoutType;
  final int duration; // in minutes
  final List<String> exercisesCompleted;
  final int energyRating; // 1-5 (😫 😐 😊 💪 🔥)
  final String notes;
  final List<String> tags;
  final int totalExercises;
  final int completedExercises;

  WorkoutJournalEntry({
    required this.id,
    required this.date,
    required this.workoutType,
    required this.duration,
    required this.exercisesCompleted,
    required this.energyRating,
    required this.notes,
    required this.tags,
    required this.totalExercises,
    required this.completedExercises,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'workoutType': workoutType,
      'duration': duration,
      'exercisesCompleted': exercisesCompleted,
      'energyRating': energyRating,
      'notes': notes,
      'tags': tags,
      'totalExercises': totalExercises,
      'completedExercises': completedExercises,
    };
  }

  // Create from JSON
  factory WorkoutJournalEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutJournalEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      workoutType: json['workoutType'],
      duration: json['duration'],
      exercisesCompleted: List<String>.from(json['exercisesCompleted']),
      energyRating: json['energyRating'],
      notes: json['notes'],
      tags: List<String>.from(json['tags']),
      totalExercises: json['totalExercises'],
      completedExercises: json['completedExercises'],
    );
  }

  // Get energy emoji
  String get energyEmoji {
    switch (energyRating) {
      case 1: return '😫';
      case 2: return '😐';
      case 3: return '😊';
      case 4: return '💪';
      case 5: return '🔥';
      default: return '😊';
    }
  }

  // Get completion percentage
  double get completionPercentage {
    if (totalExercises == 0) return 0.0;
    return completedExercises / totalExercises;
  }
}