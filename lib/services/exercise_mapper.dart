/// Maps app exercise names to ExerciseDB names
class ExerciseMapper {
  // Map your exercise names to ExerciseDB names
  static const Map<String, String> exerciseNameMap = {
    'Push-ups': 'push-up',
    'Squats': 'bodyweight squat',
    'Plank': 'plank',
    'Jumping Jacks': 'jumping jack',
    'Lunges': 'lunge',
    'Burpees': 'burpee',
    'Mountain Climbers': 'mountain climber',
    'Crunches': 'crunch',
    'Sit-ups': 'sit-up',
    'Leg Raises': 'leg raise',
    'Glute Bridge': 'glute bridge',
    'Superman': 'superman',
    'Bicycle Crunches': 'bicycle crunch',
    'Russian Twists': 'russian twist',
    'High Knees': 'high knees',
    'Butt Kicks': 'butt kicks',
    'Wall Sit': 'wall sit',
    'Tricep Dips': 'tricep dip',
    'Diamond Push-ups': 'diamond push-up',
    'Wide Push-ups': 'wide push-up',
  };
  
  static String? getExerciseDBName(String yourName) {
    return exerciseNameMap[yourName];
  }
}
