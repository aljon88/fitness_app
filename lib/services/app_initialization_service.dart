import 'package:flutter/material.dart';
import '../services/user_storage_service.dart';
import '../services/user_profile_service.dart';
import '../services/mock_auth_service.dart';
import '../models/user_profile.dart';
import '../screens/auth_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/onboarding_wizard_screen.dart';

class AppInitializationService {
  static Future<Widget> getInitialScreen() async {
    print('🚀 AppInitializationService: Getting initial screen...');
    
    // Check if user is logged in using mock auth
    final authService = MockAuthService.instance;
    bool isLoggedIn = await authService.isLoggedIn();
    
    if (!isLoggedIn) {
      print('❌ No user logged in - showing AuthScreen');
      return AuthScreen();
    }
    
    final userEmail = authService.getCurrentUserEmail();
    print('✅ User logged in: $userEmail');
    
    // User is logged in - check if they completed onboarding
    Map<String, dynamic>? profile = await UserStorageService.getUserProfile(userEmail!);
    
    if (profile == null || profile.isEmpty) {
      print('⚠️ User has not completed onboarding');
      return OnboardingWizardScreen(
        initialUserData: {
          'email': userEmail,
          'name': 'User',
        },
        onCompleted: (profile) async {
          await UserStorageService.completeOnboarding(userEmail, profile);
        },
      );
    }
    
    print('✅ User has completed onboarding, loading profile...');
    
    // Add mock UID to profile
    profile['uid'] = authService.getCurrentUserId();
    
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
    final authService = MockAuthService.instance;
    return !(await authService.isLoggedIn());
  }
  
  // Method to get user registration status for debugging
  static Future<Map<String, dynamic>> getAppStatus() async {
    final authService = MockAuthService.instance;
    final isLoggedIn = await authService.isLoggedIn();
    final userEmail = authService.getCurrentUserEmail();
    
    return {
      'currentUser': userEmail,
      'uid': authService.getCurrentUserId(),
      'isLoggedIn': isLoggedIn,
      'isAuthenticated': isLoggedIn,
    };
  }
}