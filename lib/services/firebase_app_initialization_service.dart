import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../screens/auth_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/onboarding_wizard_screen.dart';

class FirebaseAppInitializationService {
  static Future<Widget> getInitialScreen() async {
    // Check if user is authenticated with Firebase
    User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      // No user logged in - show auth screen
      return AuthScreen();
    }
    
    // User is logged in - check if they completed onboarding
    final authService = FirebaseAuthService();
    bool hasCompletedOnboarding = await authService.hasCompletedOnboarding(currentUser.uid);
    
    if (!hasCompletedOnboarding) {
      // User needs to complete onboarding
      return OnboardingWizardScreen(
        onCompleted: (profile) async {
          await authService.completeOnboarding(profile);
          // Navigation will be handled by the onboarding screen
        },
      );
    }
    
    // User is fully set up - get their profile and go to dashboard
    Map<String, dynamic>? profile = await authService.getUserProfile();
    
    // If profile doesn't exist (shouldn't happen), create default
    profile ??= {
      'name': currentUser.displayName ?? 'User',
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
    User? currentUser = FirebaseAuth.instance.currentUser;
    return currentUser == null;
  }
  
  // Method to get user registration status for debugging
  static Future<Map<String, dynamic>> getAppStatus() async {
    final authService = FirebaseAuthService();
    List<Map<String, dynamic>> allUsers = await authService.getAllUsers();
    User? currentUser = FirebaseAuth.instance.currentUser;
    
    return {
      'registeredUsers': allUsers.map((user) => user['email']).toList(),
      'currentUser': currentUser?.email,
      'totalUsers': allUsers.length,
      'isLoggedIn': currentUser != null,
    };
  }
}