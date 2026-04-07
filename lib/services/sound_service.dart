import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  bool _soundEnabled = true;
  double _volume = 0.8;

  // Professional sound categories
  static const Map<String, String> _sounds = {
    // HYPE SOUNDS - High energy
    'workout_start': 'sounds/workout_start.mp3',
    'set_complete': 'sounds/set_complete.mp3',
    'workout_complete': 'sounds/workout_complete.mp3',
    
    // FOCUS SOUNDS - Clear feedback
    'rep_complete': 'sounds/rep_complete.mp3',
    'beep': 'sounds/beep.mp3',
    'countdown': 'sounds/countdown.mp3',
    
    // MOTIVATION SOUNDS - Encouragement
    'motivation': 'sounds/motivation.mp3',
    'halfway_boost': 'sounds/motivation.mp3', // Reuse for now
    
    // CALM SOUNDS - Recovery
    'rest_start': 'sounds/rest_start.mp3',
  };

  // Volume levels for different sound types
  static const Map<String, double> _volumeLevels = {
    'workout_start': 1.0,      // Max hype
    'set_complete': 0.9,       // Victory
    'workout_complete': 1.0,   // Champion
    'rep_complete': 0.6,       // Subtle feedback
    'beep': 0.5,              // Background timing
    'countdown': 0.8,         // Clear countdown
    'motivation': 0.9,        // Pump up
    'halfway_boost': 0.9,     // Encouragement
    'rest_start': 0.4,        // Calm
  };

  // Getters and setters
  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool enabled) => _soundEnabled = enabled;
  
  double get volume => _volume;
  set volume(double vol) => _volume = vol.clamp(0.0, 1.0);

  // Initialize the sound service
  Future<void> initialize() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _backgroundPlayer.setReleaseMode(ReleaseMode.stop);
      if (kDebugMode) {
        print('🔊 Professional SoundService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SoundService initialization failed: $e');
      }
    }
  }

  // Professional sound playing with dynamic volume
  Future<void> _playSound(String soundKey, {double? customVolume, bool fadeIn = false}) async {
    if (!_soundEnabled) {
      if (kDebugMode) {
        print('🔇 Sound disabled, skipping: $soundKey');
      }
      return;
    }
    
    final soundPath = _sounds[soundKey];
    if (soundPath == null) {
      if (kDebugMode) {
        print('❌ Sound not found: $soundKey');
      }
      return;
    }
    
    try {
      await _audioPlayer.stop();
      
      // Calculate final volume
      final baseVolume = _volumeLevels[soundKey] ?? 0.7;
      final finalVolume = (customVolume ?? baseVolume) * _volume;
      
      await _audioPlayer.setVolume(finalVolume);
      
      if (kDebugMode) {
        print('🔊 Playing $soundKey at volume ${(finalVolume * 100).round()}%');
      }
      
      if (fadeIn) {
        await _audioPlayer.setVolume(0.0);
        await _audioPlayer.play(AssetSource(soundPath));
        // Simple fade in effect
        for (int i = 0; i <= 10; i++) {
          await Future.delayed(Duration(milliseconds: 50));
          await _audioPlayer.setVolume(finalVolume * (i / 10));
        }
      } else {
        await _audioPlayer.play(AssetSource(soundPath));
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to play $soundKey: $e');
      }
    }
  }

  // HYPE SOUNDS - Maximum energy
  Future<void> playWorkoutStart() async => _playSound('workout_start', fadeIn: true);
  Future<void> playSetComplete() async => _playSound('set_complete');
  Future<void> playWorkoutComplete() async => _playSound('workout_complete');

  // FOCUS SOUNDS - Clear feedback
  Future<void> playRepComplete() async => _playSound('rep_complete');
  Future<void> playBeep() async => _playSound('beep');
  Future<void> playCountdown() async => _playSound('countdown');

  // MOTIVATION SOUNDS - Encouragement
  Future<void> playMotivation() async => _playSound('motivation');
  Future<void> playHalfwayBoost() async {
    if (kDebugMode) {
      print('💪 HALFWAY THERE! Keep pushing!');
    }
    await _playSound('halfway_boost');
  }

  // CALM SOUNDS - Recovery
  Future<void> playRestStart() async => _playSound('rest_start');
  Future<void> playMeditation() async => _playSound('rest_start'); // Alias

  // Professional sequences
  Future<void> playRepSequence() async {
    await playRepComplete();
    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> playSetCompleteSequence() async {
    await playSetComplete();
    await Future.delayed(Duration(milliseconds: 800));
    await playBeep(); // Victory confirmation
  }

  Future<void> playWorkoutCompleteSequence() async {
    await playWorkoutComplete();
    await Future.delayed(Duration(milliseconds: 1000));
    await playBeep();
    await Future.delayed(Duration(milliseconds: 300));
    await playBeep();
  }

  // Test method with professional feedback
  Future<void> testSound() async {
    if (kDebugMode) {
      print('🧪 Testing professional sound system...');
    }
    await _playSound('beep');
    await Future.delayed(Duration(milliseconds: 500));
    await _playSound('rep_complete');
  }

  // Stop any currently playing sound
  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      await _backgroundPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to stop sound: $e');
      }
    }
  }

  // Dispose of resources
  void dispose() {
    _audioPlayer.dispose();
    _backgroundPlayer.dispose();
  }
}