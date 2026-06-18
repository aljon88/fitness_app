import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import 'unified_auth_service.dart';

class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  static const String _profileKey = 'user_profile';
  UserProfile? _cachedProfile;
  String? _cachedUserId; // Track which user's profile is cached

  /// Get user-specific key using Unified Auth (works with both Firebase and Mock)
  String _getUserProfileKey() {
    return UnifiedAuthService().getUserKey(_profileKey);
  }

  Future<UserProfile?> getUserProfile() async {
    final authService = UnifiedAuthService();
    final currentUserId = authService.getCurrentUserId();
    
    // Print auth status for debugging
    authService.printAuthStatus();
    
    // If we have a cached profile for the current user, return it
    if (_cachedProfile != null && _cachedUserId == currentUserId) {
      return _cachedProfile;
    }
    
    // Clear cache if it's for a different user
    if (_cachedUserId != currentUserId) {
      print('🧹 Clearing cached profile - user changed from $_cachedUserId to $currentUserId');
      _cachedProfile = null;
      _cachedUserId = null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userProfileKey = _getUserProfileKey();
      final profileJson = prefs.getString(userProfileKey);
      
      print('🔍 Loading profile for user: $currentUserId');
      print('   Profile key: $userProfileKey');
      print('   Profile found: ${profileJson != null}');
      
      if (profileJson != null) {
        final Map<String, dynamic> json = jsonDecode(profileJson);
        _cachedProfile = UserProfile.fromJson(json);
        _cachedUserId = currentUserId;
        print('✅ Profile loaded and cached for user: $currentUserId');
        return _cachedProfile;
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
    }
    
    return null;
  }

  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final authService = UnifiedAuthService();
      final currentUserId = authService.getCurrentUserId();
      
      final prefs = await SharedPreferences.getInstance();
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );
      
      final userProfileKey = _getUserProfileKey();
      final profileJson = jsonEncode(updatedProfile.toJson());
      final success = await prefs.setString(userProfileKey, profileJson);
      
      print('💾 Saving profile for user: $currentUserId');
      print('   Profile key: $userProfileKey');
      print('   Save success: $success');
      
      if (success) {
        _cachedProfile = updatedProfile;
        _cachedUserId = currentUserId;
        print('✅ Profile saved and cached for user: $currentUserId');
      }
      
      return success;
    } catch (e) {
      print('❌ Error saving user profile: $e');
      return false;
    }
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    return await saveUserProfile(profile);
  }

  Future<bool> deleteUserProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserId = currentUser?.uid;
      
      final prefs = await SharedPreferences.getInstance();
      final userProfileKey = _getUserProfileKey();
      
      print('🗑️ Deleting profile for user: $currentUserId');
      print('   Profile key: $userProfileKey');
      
      _cachedProfile = null;
      _cachedUserId = null;
      
      final success = await prefs.remove(userProfileKey);
      print('   Delete success: $success');
      
      return success;
    } catch (e) {
      print('❌ Error deleting user profile: $e');
      return false;
    }
  }

  void clearCache() {
    print('🧹 Clearing UserProfileService cache');
    _cachedProfile = null;
    _cachedUserId = null;
  }
  
  Future<void> clearProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserId = currentUser?.uid;
      
      print('🗑️ Clearing user profile cache and storage for user: $currentUserId');
      
      _cachedProfile = null;
      _cachedUserId = null;
      
      final prefs = await SharedPreferences.getInstance();
      final userProfileKey = _getUserProfileKey();
      await prefs.remove(userProfileKey);
      
      print('✅ Profile cleared successfully for user: $currentUserId');
    } catch (e) {
      print('❌ Error clearing profile: $e');
    }
  }
}
