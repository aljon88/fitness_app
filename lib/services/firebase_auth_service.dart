import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
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

      // Check if user has completed onboarding
      bool hasCompletedOnboarding = await this.hasCompletedOnboarding(credential.user!.uid);

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
      // Only sign out from Firebase (skip Google sign out for now)
      await _auth.signOut();
      
      // Notify listeners
      notifyListeners();
    } catch (e) {
      print('Firebase sign out error: $e');
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
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['onboardingCompleted'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Complete onboarding and save profile
  Future<void> completeOnboarding(Map<String, dynamic> profile) async {
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'onboardingCompleted': true,
        'profile': profile,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return data['profile'] as Map<String, dynamic>?;
        }
      } catch (e) {
        print('Error getting user profile: $e');
      }
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