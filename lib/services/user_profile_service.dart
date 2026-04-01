import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  static const String _profileKey = 'user_profile';
  UserProfile? _cachedProfile;

  Future<UserProfile?> getUserProfile() async {
    if (_cachedProfile != null) return _cachedProfile;

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);
      
      if (profileJson != null) {
        final Map<String, dynamic> json = jsonDecode(profileJson);
        _cachedProfile = UserProfile.fromJson(json);
        return _cachedProfile;
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
    
    return null;
  }

  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );
      
      final profileJson = jsonEncode(updatedProfile.toJson());
      final success = await prefs.setString(_profileKey, profileJson);
      
      if (success) {
        _cachedProfile = updatedProfile;
      }
      
      return success;
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    return await saveUserProfile(profile);
  }

  Future<bool> deleteUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedProfile = null;
      return await prefs.remove(_profileKey);
    } catch (e) {
      print('Error deleting user profile: $e');
      return false;
    }
  }

  void clearCache() {
    _cachedProfile = null;
  }
  
  Future<void> clearProfile() async {
    try {
      print('🗑️ Clearing user profile cache and storage');
      _cachedProfile = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      print('✅ Profile cleared successfully');
    } catch (e) {
      print('❌ Error clearing profile: $e');
    }
  }
}
