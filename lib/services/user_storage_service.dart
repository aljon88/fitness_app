import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorageService {
  static const String _registeredUsersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _userProfilesKey = 'user_profiles';

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
      
      // Store registration method and timestamp
      await prefs.setString('${userEmail}_auth_method', authMethod);
      await prefs.setString('${userEmail}_registered_at', DateTime.now().toIso8601String());
    }
  }

  // Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${email.toLowerCase()}_onboarding_complete') ?? false;
  }

  // Mark onboarding as complete and save profile
  static Future<void> completeOnboarding(String email, Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = email.toLowerCase();
    
    await prefs.setBool('${userEmail}_onboarding_complete', true);
    await prefs.setString('${userEmail}_profile', jsonEncode(profile));
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('${email.toLowerCase()}_profile');
    
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