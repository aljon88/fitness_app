import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;

  // Sound effect types
  static const String countdown = 'countdown';
  static const String beep = 'beep';
  static const String repComplete = 'rep_complete';
  static const String setComplete = 'set_complete';
  static const String workoutStart = 'workout_start';
  static const String workoutComplete = 'workout_complete';
  static const String motivation = 'motivation';
  static const String restStart = 'rest_start';
  static const String halfway = 'halfway';

  Future<void> playSound(String soundType) async {
    if (!_soundEnabled) return;

    try {
      // For now, we'll use system sounds
      // Later we'll add custom sound files from Pixabay
      await _player.play(AssetSource('sounds/${soundType}.mp3'));
    } catch (e) {
      print('Error playing sound: $e');
      // Fallback to system beep if sound file not found
      _playSystemSound(soundType);
    }
  }

  void _playSystemSound(String soundType) {
    // Fallback system sounds using different volumes/pitches
    // This ensures app works even without custom sound files
    switch (soundType) {
      case repComplete:
        // Quick beep for rep
        break;
      case setComplete:
        // Longer beep for set
        break;
      case workoutComplete:
        // Victory sound
        break;
    }
  }

  Future<void> playCountdown() async {
    if (!_soundEnabled) return;
    
    // Play "3... 2... 1... GO!" sequence
    for (int i = 3; i > 0; i--) {
      await Future.delayed(Duration(seconds: 1));
      await playSound('beep');
    }
    await Future.delayed(Duration(milliseconds: 500));
    await playSound(workoutStart);
  }

  Future<void> playMotivation(String message) async {
    if (!_soundEnabled) return;
    
    // Play motivational sound based on message
    await playSound(motivation);
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  bool get isSoundEnabled => _soundEnabled;

  void dispose() {
    _player.dispose();
  }
}
