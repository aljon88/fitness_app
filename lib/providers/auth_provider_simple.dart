import 'package:flutter/material.dart';
import '../services/user_storage_service.dart';

class AuthProviderSimple extends ChangeNotifier {
  String? _userEmail;
  bool _isLoading = false;

  String? get userEmail => _userEmail;
  bool get isAuthenticated => _userEmail != null;
  bool get isLoading => _isLoading;

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    _userEmail = await UserStorageService.getCurrentUser();
    notifyListeners();
  }

  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Basic validation
      if (!email.contains('@') || password.length < 6) {
        return AuthResult(success: false, message: 'Invalid email or password');
      }

      // Check if user is registered
      bool isRegistered = await UserStorageService.isUserRegistered(email);
      if (!isRegistered) {
        return AuthResult(success: false, message: 'No account found with this email. Please sign up first.');
      }

      // Simulate password verification (in real app, this would be server-side)
      _userEmail = email;
      await UserStorageService.setCurrentUser(email);
      
      // Check if user has completed onboarding
      bool hasCompletedOnboarding = await UserStorageService.hasCompletedOnboarding(email);
      
      return AuthResult(
        success: true, 
        message: 'Login successful!',
        needsOnboarding: !hasCompletedOnboarding
      );
    } catch (e) {
      print('Email sign in error: $e');
      return AuthResult(success: false, message: 'Login failed. Please try again.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> signUpWithEmail(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Basic validation
      if (!email.contains('@') || password.length < 6 || name.isEmpty) {
        return AuthResult(success: false, message: 'Please fill all fields correctly');
      }

      // Check if user already exists
      bool isRegistered = await UserStorageService.isUserRegistered(email);
      if (isRegistered) {
        return AuthResult(success: false, message: 'Account already exists. Please sign in instead.');
      }

      // Register new user
      await UserStorageService.registerUser(email, 'email');
      _userEmail = email;
      await UserStorageService.setCurrentUser(email);
      
      return AuthResult(
        success: true, 
        message: 'Account created successfully!',
        needsOnboarding: true // New users always need onboarding
      );
    } catch (e) {
      print('Email sign up error: $e');
      return AuthResult(success: false, message: 'Sign up failed. Please try again.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate Google sign in
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, you'd get the email from Google's response
      // For demo, we'll simulate getting a Google email
      String googleEmail = 'user@gmail.com'; // This would come from Google Auth
      
      // Check if this Google account is registered in our app
      bool isRegistered = await UserStorageService.isUserRegistered(googleEmail);
      
      if (!isRegistered) {
        // New Google user - register them
        await UserStorageService.registerUser(googleEmail, 'google');
        _userEmail = googleEmail;
        await UserStorageService.setCurrentUser(googleEmail);
        
        return AuthResult(
          success: true,
          message: 'Welcome! Let\'s set up your profile.',
          needsOnboarding: true
        );
      } else {
        // Existing Google user - sign them in
        _userEmail = googleEmail;
        await UserStorageService.setCurrentUser(googleEmail);
        
        // Check if they completed onboarding
        bool hasCompletedOnboarding = await UserStorageService.hasCompletedOnboarding(googleEmail);
        
        return AuthResult(
          success: true,
          message: hasCompletedOnboarding ? 'Welcome back!' : 'Please complete your profile setup.',
          needsOnboarding: !hasCompletedOnboarding
        );
      }
    } catch (e) {
      print('Google sign in error: $e');
      return AuthResult(success: false, message: 'Google sign in failed. Please try again.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding(Map<String, dynamic> profile) async {
    if (_userEmail != null) {
      await UserStorageService.completeOnboarding(_userEmail!, profile);
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_userEmail != null) {
      return await UserStorageService.getUserProfile(_userEmail!);
    }
    return null;
  }

  Future<void> signOut() async {
    await UserStorageService.clearCurrentUser();
    _userEmail = null;
    notifyListeners();
  }

  // Mock user object for compatibility
  MockUser? get user => _userEmail != null ? MockUser(_userEmail!) : null;
}

class AuthResult {
  final bool success;
  final String message;
  final bool needsOnboarding;

  AuthResult({
    required this.success,
    required this.message,
    this.needsOnboarding = false,
  });
}

class MockUser {
  final String email;
  MockUser(this.email);
}