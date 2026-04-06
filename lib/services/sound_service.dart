import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  // Sound file paths
  static const String _beep = 'sounds/beep.wav';
  static const String _countdown = 'sounds/countdown.wav';
  static const String _meditation = 'sounds/meditation.wav';
  static const String _repComplete = 'sounds/rep_complete.wav';
  static const String _restStart = 'sounds/rest_start.wav';
  static const String _setComplete = 'sounds/set_complete.wav';
  static const String _workoutComplete = 'sounds/workout_complete.wav';
  static const String _workoutStart = 'sounds/workout_start.wav';

  // Getters and setters for sound preferences
  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool enabled) => _soundEnabled = enabled;

  // Initialize the sound service
  Future<void> initialize() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      if (kDebugMode) {
        print('🔊 SoundService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SoundService initialization failed: $e');
      }
    }
  }

  // Private method to play sound
  Future<void> _playSound(String soundPath) async {
    if (!_soundEnabled) return;
    
    try {
      await _audioPlayer.stop(); // Stop any currently playing sound
      await _audioPlayer.play(AssetSource(soundPath));
      if (kDebugMode) {
        print('🔊 Playing sound: $soundPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to play sound $soundPath: $e');
      }
    }
  }

  // Public methods for different workout events
  Future<void> playBeep() async => _playSound(_beep);
  
  Future<void> playCountdown() async => _playSound(_countdown);
  
  Future<void> playMeditation() async => _playSound(_meditation);
  
  Future<void> playRepComplete() async => _playSound(_repComplete);
  
  Future<void> playRestStart() async => _playSound(_restStart);
  
  Future<void> playSetComplete() async => _playSound(_setComplete);
  
  Future<void> playWorkoutComplete() async => _playSound(_workoutComplete);
  
  Future<void> playWorkoutStart() async => _playSound(_workoutStart);

  // Stop any currently playing sound
  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to stop sound: $e');
      }
    }
  }

  // Dispose of resources
  void dispose() {
    _audioPlayer.dispose();
  }
}