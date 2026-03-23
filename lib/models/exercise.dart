class Exercise {
  final String id;
  final String name;
  final String description;
  final List<String> instructions;
  final String category;
  final String difficulty; // beginner, intermediate, advanced
  final int duration; // in seconds
  final int? reps;
  final int? sets;
  final String? restTime;
  final List<String> targetMuscles;
  final List<String> equipment;
  final String? imageUrl;
  final String? videoUrl;
  final List<String> tips;
  final List<String> commonMistakes;
  final int caloriesBurned; // approximate calories per minute

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.instructions,
    required this.category,
    required this.difficulty,
    required this.duration,
    this.reps,
    this.sets,
    this.restTime,
    required this.targetMuscles,
    required this.equipment,
    this.imageUrl,
    this.videoUrl,
    required this.tips,
    required this.commonMistakes,
    required this.caloriesBurned,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      instructions: List<String>.from(json['instructions']),
      category: json['category'],
      difficulty: json['difficulty'],
      duration: json['duration'],
      reps: json['reps'],
      sets: json['sets'],
      restTime: json['restTime'],
      targetMuscles: List<String>.from(json['targetMuscles']),
      equipment: List<String>.from(json['equipment']),
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      tips: List<String>.from(json['tips']),
      commonMistakes: List<String>.from(json['commonMistakes']),
      caloriesBurned: json['caloriesBurned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'category': category,
      'difficulty': difficulty,
      'duration': duration,
      'reps': reps,
      'sets': sets,
      'restTime': restTime,
      'targetMuscles': targetMuscles,
      'equipment': equipment,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'tips': tips,
      'commonMistakes': commonMistakes,
      'caloriesBurned': caloriesBurned,
    };
  }
}

class WorkoutDay {
  final int day;
  final String title;
  final String description;
  final List<Exercise> exercises;
  final int estimatedDuration; // in minutes
  final String focusArea;
  final String difficulty;

  WorkoutDay({
    required this.day,
    required this.title,
    required this.description,
    required this.exercises,
    required this.estimatedDuration,
    required this.focusArea,
    required this.difficulty,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      day: json['day'],
      title: json['title'],
      description: json['description'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      estimatedDuration: json['estimatedDuration'],
      focusArea: json['focusArea'],
      difficulty: json['difficulty'],
    );
  }
}

class WorkoutProgram {
  final String id;
  final String name;
  final String description;
  final String difficulty;
  final int totalDays;
  final List<WorkoutDay> workoutDays;
  final List<String> goals;
  final String equipment;

  WorkoutProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.totalDays,
    required this.workoutDays,
    required this.goals,
    required this.equipment,
  });

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    return WorkoutProgram(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      difficulty: json['difficulty'],
      totalDays: json['totalDays'],
      workoutDays: (json['workoutDays'] as List)
          .map((day) => WorkoutDay.fromJson(day))
          .toList(),
      goals: List<String>.from(json['goals']),
      equipment: json['equipment'],
    );
  }
}