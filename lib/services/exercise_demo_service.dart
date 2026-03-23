class ExerciseDemoService {
  static final ExerciseDemoService _instance = ExerciseDemoService._internal();
  factory ExerciseDemoService() => _instance;
  ExerciseDemoService._internal();

  // Demo instructions for each exercise
  static const Map<String, List<String>> _exerciseDemos = {
    'push_up_knee': [
      '🏃‍♀️ Get into position on your hands and knees',
      '👐 Place hands slightly wider than shoulders',
      '📏 Keep body straight from knees to head',
      '⬇️ Lower chest toward floor slowly',
      '⬆️ Push back up to starting position',
      '🔄 Repeat for desired reps',
    ],
    'bodyweight_squat': [
      '🧍‍♀️ Stand with feet shoulder-width apart',
      '🪑 Lower body as if sitting in a chair',
      '👀 Keep chest up and knees behind toes',
      '📐 Go down until thighs parallel to floor',
      '👠 Push through heels to stand up',
      '🔄 Repeat the movement',
    ],
    'plank_basic': [
      '🏃‍♀️ Start in push-up position',
      '💪 Lower to forearms, elbows under shoulders',
      '📏 Keep body straight from head to heels',
      '⏱️ Hold the position',
      '🫁 Breathe normally throughout',
      '💯 Maintain form until time is up',
    ],
    'marching_in_place': [
      '🧍‍♀️ Stand tall with feet hip-width apart',
      '🦵 Lift one knee up toward chest',
      '🔄 Lower and repeat with other leg',
      '🤲 Swing arms naturally',
      '🎵 Keep a steady rhythm',
      '⚡ Continue for set duration',
    ],
    'wall_sit': [
      '🧱 Stand with back against wall',
      '⬇️ Slide down until thighs parallel to floor',
      '📐 Keep knees at 90-degree angle',
      '⏱️ Hold the position',
      '🏠 Keep back flat against wall',
      '💪 Maintain until time is up',
    ],
    'push_up_standard': [
      '🏃‍♀️ Start in plank position on toes',
      '👐 Hands slightly wider than shoulders',
      '⬇️ Lower chest to floor with control',
      '💥 Push back up explosively',
      '📏 Keep body straight throughout',
      '🔄 Repeat for desired reps',
    ],
    'jump_squats': [
      '🧍‍♀️ Start in squat position',
      '⬇️ Lower into deep squat',
      '🚀 Explode up into a jump',
      '🦶 Land softly back in squat',
      '⚡ Repeat immediately',
      '🔥 Maintain explosive power',
    ],
    'mountain_climbers': [
      '🏃‍♀️ Start in plank position',
      '🦵 Bring one knee toward chest',
      '⚡ Quickly switch legs',
      '📏 Keep hips level',
      '🏃‍♂️ Maintain fast pace',
      '🫁 Breathe rhythmically',
    ],
    'lunges_alternating': [
      '🧍‍♀️ Stand with feet hip-width apart',
      '👣 Step forward into lunge position',
      '⬇️ Lower back knee toward floor',
      '⬆️ Push back to starting position',
      '🔄 Alternate legs',
      '⚖️ Keep torso upright',
    ],
    'plank_up_down': [
      '💪 Start in forearm plank',
      '👐 Push up to hand plank one arm at a time',
      '⬇️ Lower back to forearm plank',
      '🔄 Alternate leading arm',
      '📏 Keep hips stable',
      '💯 Control the movement',
    ],
    'burpees': [
      '🧍‍♀️ Start standing',
      '⬇️ Drop into squat, hands on floor',
      '🦶 Jump feet back to plank',
      '💪 Do a push-up',
      '🦶 Jump feet back to squat',
      '🚀 Explode up with arms overhead',
    ],
    'pistol_squats': [
      '🦵 Stand on one leg',
      '👣 Extend other leg forward',
      '⬇️ Lower into single-leg squat',
      '📏 Keep extended leg straight',
      '⬆️ Push back up to standing',
      '⚖️ Use arms for balance',
    ],
    'handstand_push_ups': [
      '🤸‍♀️ Get into handstand against wall',
      '⬇️ Lower head toward floor',
      '⬆️ Push back up to full extension',
      '📏 Keep body straight',
      '🎯 Control the movement',
      '⚠️ Advanced exercise - be careful!',
    ],
    'plyometric_push_ups': [
      '🏃‍♀️ Start in push-up position',
      '⬇️ Lower chest to floor',
      '💥 Push up explosively',
      '👏 Clap hands in air',
      '🦶 Land and immediately repeat',
      '⚡ Generate maximum power',
    ],
    'dragon_squats': [
      '🦵 Stand on one leg',
      '👣 Extend other leg behind you',
      '⬇️ Lower into deep squat',
      '👆 Touch floor with fingertips',
      '⬆️ Rise back up maintaining balance',
      '🎯 Focus on balance and control',
    ],
  };

  // Get demo steps for an exercise
  List<String> getDemoSteps(String exerciseId) {
    return _exerciseDemos[exerciseId] ?? [
      '🏃‍♀️ Position yourself properly',
      '💪 Engage your core muscles',
      '🎯 Focus on proper form',
      '🫁 Breathe steadily',
      '🔄 Repeat the movement',
      '💯 Maintain good technique',
    ];
  }

  // Get a quick tip for an exercise
  String getQuickTip(String exerciseId) {
    final tips = {
      'push_up_knee': 'Keep your core tight and don\'t let your hips sag!',
      'bodyweight_squat': 'Imagine sitting back into a chair - weight on your heels!',
      'plank_basic': 'Think of your body as a straight plank of wood!',
      'marching_in_place': 'Lift those knees high and pump your arms!',
      'wall_sit': 'Pretend you\'re sitting in an invisible chair!',
      'push_up_standard': 'Full range of motion - chest to floor, full extension up!',
      'jump_squats': 'Land soft like a cat, explode up like a rocket!',
      'mountain_climbers': 'Run in place while holding a plank - keep it fast!',
      'lunges_alternating': 'Step out far enough so your front knee stays over your ankle!',
      'plank_up_down': 'Minimize the hip wiggle - keep your core super tight!',
      'burpees': 'The ultimate full-body exercise - embrace the burn!',
      'pistol_squats': 'Balance is key - use your arms like a tightrope walker!',
      'handstand_push_ups': 'Wall is your friend - build up strength gradually!',
      'plyometric_push_ups': 'Explosive power up, controlled landing down!',
      'dragon_squats': 'Single-leg strength meets balance - you\'ve got this!',
    };
    
    return tips[exerciseId] ?? 'Focus on quality over quantity - perfect form wins!';
  }

  // Get motivational message based on exercise difficulty
  String getMotivationalMessage(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return '🌟 Every expert was once a beginner - you\'re building the foundation!';
      case 'intermediate':
        return '🔥 You\'re getting stronger! Push through and feel the progress!';
      case 'advanced':
        return '💪 Beast mode activated! You\'re crushing advanced movements!';
      default:
        return '🚀 You\'re doing amazing - keep pushing your limits!';
    }
  }

  // Get safety reminder
  String getSafetyReminder() {
    final reminders = [
      '⚠️ Stop if you feel pain - discomfort is okay, pain is not!',
      '💧 Stay hydrated throughout your workout!',
      '🫁 Never hold your breath - breathe with each movement!',
      '🎯 Quality over quantity - perfect form prevents injury!',
      '⏰ Listen to your body - rest when you need it!',
    ];
    
    reminders.shuffle();
    return reminders.first;
  }
}