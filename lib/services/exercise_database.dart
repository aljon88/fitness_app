import '../models/exercise.dart';

class ExerciseDatabase {
  static final ExerciseDatabase _instance = ExerciseDatabase._internal();
  factory ExerciseDatabase() => _instance;
  ExerciseDatabase._internal();

  // Beginner Exercises
  static List<Exercise> get beginnerExercises => [
    Exercise(
      id: 'push_up_knee',
      name: 'Knee Push-ups',
      description: 'Modified push-ups performed on knees for beginners',
      instructions: [
        'Start on your hands and knees',
        'Place hands slightly wider than shoulder-width apart',
        'Keep your body straight from knees to head',
        'Lower your chest toward the floor',
        'Push back up to starting position',
      ],
      category: 'Strength',
      difficulty: 'beginner',
      duration: 30,
      reps: 8,
      sets: 2,
      restTime: '30 seconds',
      targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
      equipment: ['None'],
      tips: [
        'Keep your core engaged',
        'Don\'t let your hips sag',
        'Focus on controlled movements',
      ],
      commonMistakes: [
        'Arching the back',
        'Not going down far enough',
        'Moving too fast',
      ],
      caloriesBurned: 4,
    ),

    Exercise(
      id: 'bodyweight_squat',
      name: 'Bodyweight Squats',
      description: 'Basic squats using only body weight',
      instructions: [
        'Stand with feet shoulder-width apart',
        'Lower your body as if sitting back into a chair',
        'Keep your chest up and knees behind toes',
        'Go down until thighs are parallel to floor',
        'Push through heels to return to standing',
      ],
      category: 'Strength',
      difficulty: 'beginner',
      duration: 45,
      reps: 10,
      sets: 2,
      restTime: '30 seconds',
      targetMuscles: ['Quadriceps', 'Glutes', 'Hamstrings'],
      equipment: ['None'],
      tips: [
        'Keep weight on your heels',
        'Don\'t let knees cave inward',
        'Breathe out as you stand up',
      ],
      commonMistakes: [
        'Knees going past toes',
        'Not going low enough',
        'Leaning too far forward',
      ],
      caloriesBurned: 5,
    ),

    Exercise(
      id: 'plank_basic',
      name: 'Basic Plank',
      description: 'Hold a plank position to strengthen core',
      instructions: [
        'Start in push-up position',
        'Lower to forearms, elbows under shoulders',
        'Keep body straight from head to heels',
        'Hold the position',
        'Breathe normally throughout',
      ],
      category: 'Core',
      difficulty: 'beginner',
      duration: 20,
      reps: null,
      sets: 2,
      restTime: '30 seconds',
      targetMuscles: ['Core', 'Shoulders', 'Back'],
      equipment: ['None'],
      tips: [
        'Don\'t hold your breath',
        'Keep hips level',
        'Engage your core muscles',
      ],
      commonMistakes: [
        'Hips too high or low',
        'Looking up instead of down',
        'Holding breath',
      ],
      caloriesBurned: 3,
    ),

    Exercise(
      id: 'marching_in_place',
      name: 'Marching in Place',
      description: 'Low-impact cardio exercise',
      instructions: [
        'Stand tall with feet hip-width apart',
        'Lift one knee up toward chest',
        'Lower and repeat with other leg',
        'Swing arms naturally',
        'Keep a steady rhythm',
      ],
      category: 'Cardio',
      difficulty: 'beginner',
      duration: 60,
      reps: null,
      sets: 1,
      restTime: '30 seconds',
      targetMuscles: ['Legs', 'Core'],
      equipment: ['None'],
      tips: [
        'Keep your core engaged',
        'Land softly on your feet',
        'Maintain good posture',
      ],
      commonMistakes: [
        'Leaning forward',
        'Not lifting knees high enough',
        'Moving too fast',
      ],
      caloriesBurned: 6,
    ),

    Exercise(
      id: 'wall_sit',
      name: 'Wall Sit',
      description: 'Isometric exercise against a wall',
      instructions: [
        'Stand with back against wall',
        'Slide down until thighs are parallel to floor',
        'Keep knees at 90-degree angle',
        'Hold the position',
        'Keep back flat against wall',
      ],
      category: 'Strength',
      difficulty: 'beginner',
      duration: 15,
      reps: null,
      sets: 2,
      restTime: '45 seconds',
      targetMuscles: ['Quadriceps', 'Glutes'],
      equipment: ['Wall'],
      tips: [
        'Keep feet flat on floor',
        'Don\'t hold your breath',
        'Keep knees aligned with ankles',
      ],
      commonMistakes: [
        'Sliding down the wall',
        'Knees going inward',
        'Not going low enough',
      ],
      caloriesBurned: 4,
    ),
  ];

  // Intermediate Exercises
  static List<Exercise> get intermediateExercises => [
    Exercise(
      id: 'push_up_standard',
      name: 'Standard Push-ups',
      description: 'Full push-ups on toes',
      instructions: [
        'Start in plank position on toes',
        'Hands slightly wider than shoulders',
        'Lower chest to floor',
        'Push back up explosively',
        'Keep body straight throughout',
      ],
      category: 'Strength',
      difficulty: 'intermediate',
      duration: 45,
      reps: 12,
      sets: 3,
      restTime: '45 seconds',
      targetMuscles: ['Chest', 'Shoulders', 'Triceps', 'Core'],
      equipment: ['None'],
      tips: [
        'Full range of motion',
        'Control the descent',
        'Keep core tight',
      ],
      commonMistakes: [
        'Partial range of motion',
        'Sagging hips',
        'Flaring elbows too wide',
      ],
      caloriesBurned: 6,
    ),

    Exercise(
      id: 'jump_squats',
      name: 'Jump Squats',
      description: 'Explosive squats with jump',
      instructions: [
        'Start in squat position',
        'Lower into squat',
        'Explode up into a jump',
        'Land softly back in squat',
        'Repeat immediately',
      ],
      category: 'Cardio',
      difficulty: 'intermediate',
      duration: 30,
      reps: 10,
      sets: 3,
      restTime: '60 seconds',
      targetMuscles: ['Quadriceps', 'Glutes', 'Calves'],
      equipment: ['None'],
      tips: [
        'Land softly on balls of feet',
        'Use arms for momentum',
        'Keep chest up',
      ],
      commonMistakes: [
        'Landing too hard',
        'Not squatting low enough',
        'Knees caving in',
      ],
      caloriesBurned: 8,
    ),

    Exercise(
      id: 'mountain_climbers',
      name: 'Mountain Climbers',
      description: 'Dynamic core and cardio exercise',
      instructions: [
        'Start in plank position',
        'Bring one knee toward chest',
        'Quickly switch legs',
        'Keep hips level',
        'Maintain fast pace',
      ],
      category: 'Cardio',
      difficulty: 'intermediate',
      duration: 30,
      reps: null,
      sets: 3,
      restTime: '45 seconds',
      targetMuscles: ['Core', 'Shoulders', 'Legs'],
      equipment: ['None'],
      tips: [
        'Keep core engaged',
        'Don\'t bounce hips',
        'Breathe rhythmically',
      ],
      commonMistakes: [
        'Hips too high',
        'Not bringing knees far enough',
        'Going too slow',
      ],
      caloriesBurned: 10,
    ),

    Exercise(
      id: 'lunges_alternating',
      name: 'Alternating Lunges',
      description: 'Forward lunges alternating legs',
      instructions: [
        'Stand with feet hip-width apart',
        'Step forward into lunge position',
        'Lower back knee toward floor',
        'Push back to starting position',
        'Alternate legs',
      ],
      category: 'Strength',
      difficulty: 'intermediate',
      duration: 60,
      reps: 12,
      sets: 3,
      restTime: '45 seconds',
      targetMuscles: ['Quadriceps', 'Glutes', 'Hamstrings'],
      equipment: ['None'],
      tips: [
        'Keep front knee over ankle',
        'Don\'t let back knee touch floor',
        'Keep torso upright',
      ],
      commonMistakes: [
        'Knee going past toes',
        'Leaning forward',
        'Not stepping far enough',
      ],
      caloriesBurned: 7,
    ),

    Exercise(
      id: 'plank_up_down',
      name: 'Plank Up-Downs',
      description: 'Dynamic plank variation',
      instructions: [
        'Start in forearm plank',
        'Push up to hand plank one arm at a time',
        'Lower back to forearm plank',
        'Alternate leading arm',
        'Keep hips stable',
      ],
      category: 'Core',
      difficulty: 'intermediate',
      duration: 45,
      reps: 8,
      sets: 3,
      restTime: '60 seconds',
      targetMuscles: ['Core', 'Shoulders', 'Triceps'],
      equipment: ['None'],
      tips: [
        'Minimize hip movement',
        'Control the movement',
        'Keep core tight',
      ],
      commonMistakes: [
        'Rocking hips side to side',
        'Moving too fast',
        'Not maintaining plank form',
      ],
      caloriesBurned: 8,
    ),
  ];

  // Advanced Exercises
  static List<Exercise> get advancedExercises => [
    Exercise(
      id: 'burpees',
      name: 'Burpees',
      description: 'Full-body explosive exercise',
      instructions: [
        'Start standing',
        'Drop into squat, hands on floor',
        'Jump feet back to plank',
        'Do a push-up',
        'Jump feet back to squat',
        'Explode up with arms overhead',
      ],
      category: 'Cardio',
      difficulty: 'advanced',
      duration: 45,
      reps: 8,
      sets: 4,
      restTime: '90 seconds',
      targetMuscles: ['Full Body'],
      equipment: ['None'],
      tips: [
        'Land softly',
        'Keep core engaged throughout',
        'Maintain good form even when tired',
      ],
      commonMistakes: [
        'Skipping the push-up',
        'Not jumping high enough',
        'Poor landing mechanics',
      ],
      caloriesBurned: 12,
    ),

    Exercise(
      id: 'pistol_squats',
      name: 'Pistol Squats',
      description: 'Single-leg squats',
      instructions: [
        'Stand on one leg',
        'Extend other leg forward',
        'Lower into single-leg squat',
        'Keep extended leg straight',
        'Push back up to standing',
      ],
      category: 'Strength',
      difficulty: 'advanced',
      duration: 60,
      reps: 5,
      sets: 3,
      restTime: '90 seconds',
      targetMuscles: ['Quadriceps', 'Glutes', 'Core'],
      equipment: ['None'],
      tips: [
        'Use arms for balance',
        'Go as low as possible',
        'Keep chest up',
      ],
      commonMistakes: [
        'Not going low enough',
        'Losing balance',
        'Knee caving inward',
      ],
      caloriesBurned: 9,
    ),

    Exercise(
      id: 'handstand_push_ups',
      name: 'Handstand Push-ups',
      description: 'Push-ups in handstand position against wall',
      instructions: [
        'Get into handstand against wall',
        'Lower head toward floor',
        'Push back up to full extension',
        'Keep body straight',
        'Control the movement',
      ],
      category: 'Strength',
      difficulty: 'advanced',
      duration: 30,
      reps: 5,
      sets: 3,
      restTime: '120 seconds',
      targetMuscles: ['Shoulders', 'Triceps', 'Core'],
      equipment: ['Wall'],
      tips: [
        'Start with partial range',
        'Keep core very tight',
        'Don\'t rush the movement',
      ],
      commonMistakes: [
        'Arching back too much',
        'Not going full range',
        'Losing balance',
      ],
      caloriesBurned: 10,
    ),

    Exercise(
      id: 'plyometric_push_ups',
      name: 'Plyometric Push-ups',
      description: 'Explosive push-ups with clap',
      instructions: [
        'Start in push-up position',
        'Lower chest to floor',
        'Push up explosively',
        'Clap hands in air',
        'Land and immediately repeat',
      ],
      category: 'Strength',
      difficulty: 'advanced',
      duration: 30,
      reps: 6,
      sets: 4,
      restTime: '90 seconds',
      targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
      equipment: ['None'],
      tips: [
        'Generate maximum power',
        'Land softly',
        'Keep core engaged',
      ],
      commonMistakes: [
        'Not pushing hard enough',
        'Landing too hard',
        'Poor form when tired',
      ],
      caloriesBurned: 11,
    ),

    Exercise(
      id: 'dragon_squats',
      name: 'Dragon Squats',
      description: 'Advanced single-leg squat variation',
      instructions: [
        'Stand on one leg',
        'Extend other leg behind you',
        'Lower into deep squat',
        'Touch floor with fingertips',
        'Rise back up maintaining balance',
      ],
      category: 'Strength',
      difficulty: 'advanced',
      duration: 45,
      reps: 6,
      sets: 3,
      restTime: '90 seconds',
      targetMuscles: ['Quadriceps', 'Glutes', 'Core', 'Balance'],
      equipment: ['None'],
      tips: [
        'Focus on balance',
        'Control the descent',
        'Keep extended leg active',
      ],
      commonMistakes: [
        'Losing balance',
        'Not going deep enough',
        'Touching down with extended leg',
      ],
      caloriesBurned: 8,
    ),
  ];

  // Get exercises by difficulty
  static List<Exercise> getExercisesByDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return beginnerExercises;
      case 'intermediate':
        return intermediateExercises;
      case 'advanced':
        return advancedExercises;
      default:
        return beginnerExercises;
    }
  }

  // Get exercises by category
  static List<Exercise> getExercisesByCategory(String category, String difficulty) {
    List<Exercise> exercises = getExercisesByDifficulty(difficulty);
    return exercises.where((exercise) => 
        exercise.category.toLowerCase() == category.toLowerCase()).toList();
  }

  // Get random exercises for a workout
  static List<Exercise> getRandomWorkout(String difficulty, int count) {
    List<Exercise> exercises = getExercisesByDifficulty(difficulty);
    exercises.shuffle();
    return exercises.take(count).toList();
  }
}