import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // REMOVED - not using Google Sign-In
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import 'user_profile_service.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn(); // REMOVED - not using Google Sign-In
  
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  String? get userEmail => currentUser?.email;

  // Initialize auth state listener
  void initialize() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  // Sign up with email and password
  Future<AuthResult> signUpWithEmail(String email, String password, String name) async {
    try {
      // Create user account
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user document in Firestore
      await _createUserDocument(credential.user!, name);

      return AuthResult(
        success: true,
        message: 'Account created successfully!',
        needsOnboarding: true,
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        message: _getErrorMessage(e.code),
      );
    } catch (e) {
      print('General Error: $e');
      return AuthResult(
        success: false,
        message: 'Setup Error: Please enable Firebase Authentication in your Firebase Console. Error: $e',
      );
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🔐 Login successful for: $email (UID: ${credential.user!.uid})');
      
      // Check if user has completed onboarding
      bool hasCompletedOnboarding = await this.hasCompletedOnboarding(credential.user!.uid);
      
      print('📋 Onboarding status: $hasCompletedOnboarding');
      print('🚪 Needs onboarding: ${!hasCompletedOnboarding}');

      return AuthResult(
        success: true,
        message: 'Login successful!',
        needsOnboarding: !hasCompletedOnboarding,
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        message: _getErrorMessage(e.code),
      );
    } catch (e) {
      print('General Error: $e');
      return AuthResult(
        success: false,
        message: 'Setup Error: Please enable Firebase Authentication in your Firebase Console. Error: $e',
      );
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // For web, we need to configure the client ID properly
      // For now, return a helpful message
      return AuthResult(
        success: false,
        message: 'Google Sign-In requires additional setup. Please use email sign-in for now.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Google sign-in not available. Please use email sign-in.',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('🚪 Signing out user: ${currentUser?.email}');
      
      // Clear UserProfileService cache
      final profileService = UserProfileService();
      await profileService.clearProfile();
      print('✅ Cleared UserProfileService cache');
      
      // Sign out from Firebase
      await _auth.signOut();
      print('✅ Signed out from Firebase');
      
      // Notify listeners
      notifyListeners();
    } catch (e) {
      print('❌ Sign out error: $e');
      throw e;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String name, {String authMethod = 'email'}) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'onboardingCompleted': false,
      'authMethod': authMethod,
    });
  }

  // Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding(String uid) async {
    try {
      print('🔍 Checking onboarding status for UID: $uid');
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('   Document exists. Keys: ${data.keys.toList()}');
        bool completed = data['onboardingCompleted'] ?? false;
        print('   onboardingCompleted value: $completed');
        return completed;
      } else {
        print('   ⚠️ Document does not exist');
      }
      return false;
    } catch (e) {
      print('   ❌ Error checking onboarding: $e');
      return false;
    }
  }

  // Complete onboarding and save profile
  Future<void> completeOnboarding(Map<String, dynamic> profile) async {
    if (currentUser != null) {
      try {
        // Save to Firebase using set with merge to create or update
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'onboardingCompleted': true,
          'profile': profile,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        print('✅ Profile saved to Firebase for UID: ${currentUser!.uid}');
        print('   Profile data: ${profile.keys.toList()}');
        
        // Also save to local UserProfileService
        final userProfile = UserProfile.fromOnboarding(profile);
        final profileService = UserProfileService();
        await profileService.saveUserProfile(userProfile);
        
        print('✅ Profile saved to local UserProfileService');
      } catch (e) {
        print('❌ Error saving profile to Firebase: $e');
        // Still save locally even if Firebase fails
        final userProfile = UserProfile.fromOnboarding(profile);
        final profileService = UserProfileService();
        await profileService.saveUserProfile(userProfile);
      }
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser != null) {
      try {
        print('🔍 Getting profile from Firebase for UID: ${currentUser!.uid}');
        DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
        
        if (doc.exists) {
          print('✅ Firebase document exists');
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          print('   Document keys: ${data.keys.toList()}');
          
          if (data.containsKey('profile')) {
            Map<String, dynamic>? profile = data['profile'] as Map<String, dynamic>?;
            print('   Profile found with keys: ${profile?.keys.toList()}');
            return profile;
          } else {
            print('⚠️ Document exists but no "profile" field found');
            return null;
          }
        } else {
          print('⚠️ Firebase document does not exist for UID: ${currentUser!.uid}');
        }
      } catch (e) {
        print('❌ Error getting user profile from Firebase: $e');
      }
    } else {
      print('⚠️ No current user, cannot get profile');
    }
    return null;
  }

  // Get all users (for admin purposes)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'email': data['email'],
          'name': data['name'],
          'onboardingCompleted': data['onboardingCompleted'] ?? false,
          'createdAt': data['createdAt'],
          'authMethod': data['authMethod'] ?? 'unknown',
        };
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Convert Firebase error codes to user-friendly messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'permission-denied':
        return 'Firebase setup incomplete. Please enable Authentication and Firestore in Firebase Console.';
      case 'unavailable':
        return 'Firebase service unavailable. Please enable Firestore Database in Firebase Console.';
      default:
        return 'Firebase Error ($errorCode): Please check your Firebase Console setup.';
    }
  }
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