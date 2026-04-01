import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import 'user_profile_service.dart';

class UserStorageService {
  static const String _registeredUsersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';

  /// Get user-specific key using Firebase UID
  static String _getUserKey(String baseKey) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return '${user.uid}_$baseKey';
    }
    // Fallback to email-based key for backward compatibility
    return baseKey;
  }

  // Check if user is registered
  static Future<bool> isUserRegistered(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final registeredUsers = prefs.getStringList(_registeredUsersKey) ?? [];
    return registeredUsers.contains(email.toLowerCase());
  }

  // Register a new user
  static Future<void> registerUser(String email, String authMethod) async {
    final prefs = await SharedPreferences.getInstance();
    final registeredUsers = prefs.getStringList(_registeredUsersKey) ?? [];
    
    final userEmail = email.toLowerCase();
    if (!registeredUsers.contains(userEmail)) {
      registeredUsers.add(userEmail);
      await prefs.setStringList(_registeredUsersKey, registeredUsers);
      
      // Store registration method and timestamp with UID
      await prefs.setString(_getUserKey('auth_method'), authMethod);
      await prefs.setString(_getUserKey('registered_at'), DateTime.now().toIso8601String());
    }
  }

  // Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding(String email) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check with UID first
    bool uidCheck = prefs.getBool(_getUserKey('onboarding_complete')) ?? false;
    if (uidCheck) return true;
    
    // Fallback to email-based key for backward compatibility
    bool emailCheck = prefs.getBool('${email.toLowerCase()}_onboarding_complete') ?? false;
    
    // If found with email key, migrate to UID key
    if (emailCheck) {
      await prefs.setBool(_getUserKey('onboarding_complete'), true);
      print('✅ Migrated onboarding status from email to UID key');
    }
    
    return emailCheck;
  }

  // Mark onboarding as complete and save profile
  static Future<void> completeOnboarding(String email, Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save with UID
    await prefs.setBool(_getUserKey('onboarding_complete'), true);
    await prefs.setString(_getUserKey('profile'), jsonEncode(profile));
    
    // Also save to UserProfileService using the new model
    final userProfile = UserProfile.fromOnboarding(profile);
    final profileService = UserProfileService();
    await profileService.saveUserProfile(userProfile);
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String email) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try UID-based key first
    String? profileJson = prefs.getString(_getUserKey('profile'));
    
    // Fallback to email-based key for backward compatibility
    if (profileJson == null) {
      profileJson = prefs.getString('${email.toLowerCase()}_profile');
      
      // If found with email key, migrate to UID key
      if (profileJson != null) {
        await prefs.setString(_getUserKey('profile'), profileJson);
        print('✅ Migrated profile from email to UID key');
      }
    }
    
    if (profileJson != null) {
      return jsonDecode(profileJson);
    }
    return null;
  }

  // Set current logged-in user
  static Future<void> setCurrentUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, email.toLowerCase());
  }

  // Get current logged-in user
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // Clear current user (logout)
  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    // Note: We keep user profile data so they can log back in
    // Only clear session-specific data
  }

  // Clear user-specific session data on logout
  static Future<void> clearUserSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = email.toLowerCase();
    
    // Clear session data but keep profile
    // This prevents data leakage between users
    await prefs.remove(_currentUserKey);
  }

  // Check if this is a fresh user (no profile data)
  static Future<bool> isFreshUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = email.toLowerCase();
    final hasProfile = prefs.containsKey('${userEmail}_profile');
    final hasOnboarding = prefs.containsKey('${userEmail}_onboarding_complete');
    return !hasProfile && !hasOnboarding;
  }

  // Get all registered users (for debugging)
  static Future<List<String>> getAllRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_registeredUsersKey) ?? [];
  }

  // Clear all data (for testing/reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
