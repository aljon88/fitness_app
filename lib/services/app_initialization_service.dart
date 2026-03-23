import 'package:flutter/material.dart';
import '../services/user_storage_service.dart';
import '../screens/auth_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/onboarding_wizard_screen.dart';

class AppInitializationService {
  static Future<Widget> getInitialScreen() async {
    // Check if user is logged in
    String? currentUser = await UserStorageService.getCurrentUser();
    
    if (currentUser == null) {
      // No user logged in - show auth screen
      return AuthScreen();
    }
    
    // User is logged in - check if they completed onboarding
    bool hasCompletedOnboarding = await UserStorageService.hasCompletedOnboarding(currentUser);
    
    if (!hasCompletedOnboarding) {
      // User needs to complete onboarding
      return OnboardingWizardScreen(
        onCompleted: (profile) async {
          await UserStorageService.completeOnboarding(currentUser, profile);
          // Navigation will be handled by the onboarding screen
        },
      );
    }
    
    // User is fully set up - get their profile and go to dashboard
    Map<String, dynamic>? profile = await UserStorageService.getUserProfile(currentUser);
    
    // If profile doesn't exist (shouldn't happen), create default
    profile ??= {
      'name': 'User',
      'age': '25',
      'height': '170',
      'weight': '65',
      'gender': 'prefer_not_to_say',
      'fitnessLevel': 'beginner',
      'allergies': [],
      'motivation': 'Stay Fit',
      'goals': ['Stay Fit'],
      'workoutLocation': 'Floor',
    };
    
    return DashboardScreen(profile: profile);
  }
  
  // Method to check if app should require authentication
  static Future<bool> requiresAuthentication() async {
    String? currentUser = await UserStorageService.getCurrentUser();
    return currentUser == null;
  }
  
  // Method to get user registration status for debugging
  static Future<Map<String, dynamic>> getAppStatus() async {
    List<String> registeredUsers = await UserStorageService.getAllRegisteredUsers();
    String? currentUser = await UserStorageService.getCurrentUser();
    
    return {
      'registeredUsers': registeredUsers,
      'currentUser': currentUser,
      'totalUsers': registeredUsers.length,
      'isLoggedIn': currentUser != null,
    };
  }
}