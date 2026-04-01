import 'package:flutter/material.dart';
import '../services/user_storage_service.dart';
import '../services/user_profile_service.dart';
import '../services/firebase_auth_service.dart';
import '../models/user_profile.dart';
import '../screens/auth_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/onboarding_wizard_screen.dart';

class AppInitializationService {
  static Future<Widget> getInitialScreen() async {
    print('🚀 AppInitializationService: Getting initial screen...');
    
    // Check Firebase authentication first
    final authService = FirebaseAuthService();
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      print('❌ No Firebase user logged in - showing AuthScreen');
      return AuthScreen();
    }
    
    print('✅ Firebase user logged in: ${currentUser.email}');
    print('   UID: ${currentUser.uid}');
    
    // User is logged in - check if they completed onboarding
    bool hasCompletedOnboarding = await authService.hasCompletedOnboarding(currentUser.uid);
    
    if (!hasCompletedOnboarding) {
      print('⚠️ User has not completed onboarding');
      return OnboardingWizardScreen(
        initialUserData: {
          'email': currentUser.email ?? '',
          'name': currentUser.displayName ?? '',
        },
        onCompleted: (profile) async {
          await authService.completeOnboarding(profile);
          await UserStorageService.completeOnboarding(currentUser.email ?? '', profile);
        },
      );
    }
    
    print('✅ User has completed onboarding, loading profile...');
    
    // Try to get profile from Firebase first
    Map<String, dynamic>? profile = await authService.getUserProfile();
    
    // If not in Firebase, try SharedPreferences
    if (profile == null && currentUser.email != null) {
      print('⚠️ Profile not in Firebase, checking SharedPreferences...');
      profile = await UserStorageService.getUserProfile(currentUser.email!);
      
      // If found in SharedPreferences, migrate to Firebase
      if (profile != null) {
        print('✅ Found profile in SharedPreferences, migrating to Firebase...');
        await authService.completeOnboarding(profile);
      }
    }
    
    // If still no profile, create default
    if (profile == null) {
      print('❌ No profile found anywhere, creating default profile');
      profile = {
        'name': currentUser.displayName ?? 'User',
        'email': currentUser.email ?? '',
        'age': '25',
        'height': '170',
        'weight': '65',
        'gender': 'prefer_not_to_say',
        'fitnessLevel': 'beginner',
        'allergies': [],
        'motivation': 'Stay Fit',
        'goals': ['Stay Fit'],
        'primaryGoal': 'Stay Fit',
        'selectedAdvice': 'Start small, dream big!',
        'workoutLocation': 'Floor',
      };
    }
    
    // Add UID to profile
    profile['uid'] = currentUser.uid;
    
    print('✅ Profile loaded successfully:');
    print('   Name: ${profile['name']}');
    print('   Email: ${profile['email']}');
    print('   Fitness Level: ${profile['fitnessLevel']}');
    
    // Save profile to UserProfileService so profile screen can access it
    try {
      final userProfile = UserProfile.fromOnboarding(profile);
      final profileService = UserProfileService();
      await profileService.saveUserProfile(userProfile);
      print('✅ Profile saved to UserProfileService');
    } catch (e) {
      print('❌ Error saving profile to UserProfileService: $e');
    }
    
    print('🎯 Navigating to DashboardScreen with profile');
    return DashboardScreen(profile: profile);
  }
  
  // Method to check if app should require authentication
  static Future<bool> requiresAuthentication() async {
    final authService = FirebaseAuthService();
    return authService.currentUser == null;
  }
  
  // Method to get user registration status for debugging
  static Future<Map<String, dynamic>> getAppStatus() async {
    final authService = FirebaseAuthService();
    final currentUser = authService.currentUser;
    
    return {
      'currentUser': currentUser?.email,
      'uid': currentUser?.uid,
      'isLoggedIn': currentUser != null,
      'isAuthenticated': authService.isAuthenticated,
    };
  }
}