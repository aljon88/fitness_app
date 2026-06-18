import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/user_profile.dart';
import 'user_profile_service.dart';
import 'user_storage_service.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _lastUserId;
  
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  String? get userEmail => currentUser?.email;

  void initialize() {
    print('🔧 Initializing FirebaseAuthService...');
    _auth.authStateChanges().listen((User? user) async {
      final currentUserId = user?.uid;
      
      if (_lastUserId != currentUserId) {
        print('🔄 User changed from $_lastUserId to $currentUserId');
        if (_lastUserId != null) {
          await _clearCachedDataForUserChange();
        }
        _lastUserId = currentUserId;
      }
      
      print('📢 FirebaseAuthService: Notifying listeners');
      notifyListeners();
    });
  }

  Future<void> _clearCachedDataForUserChange() async {
    try {
      print('🧹 Clearing cached data for user change...');
      
      final profileService = UserProfileService();
      profileService.clearCache();
      
      await DefaultCacheManager().emptyCache();
      
      print('✅ Cached data cleared for user change');
    } catch (e) {
      print('❌ Error clearing cached data: $e');
    }
  }

  Future<AuthResult> signUpWithEmail(String email, String password, String name) async {
    try {
      print('🔧 Starting account creation for: $email');
      
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ Firebase Auth account created successfully');
      print('   UID: ${credential.user!.uid}');

      await credential.user?.updateDisplayName(name);
      print('✅ Display name updated');

      bool firestoreSuccess = await _createUserDocumentSafely(credential.user!, name);
      
      if (firestoreSuccess) {
        print('✅ User document created in Firestore');
      } else {
        print('⚠️ Firestore document creation failed, but account is still functional');
        print('   User will use local storage until Firestore permissions are fixed');
      }

      await UserStorageService.registerUser(email, 'email');
      print('✅ User registered in local storage');

      return AuthResult(
        success: true,
        message: 'Account created successfully!',
        needsOnboarding: true,
      );
      
    } catch (e) {
      print('❌ Firebase Auth Error: ${e.toString()}');
      return AuthResult(
        success: false,
        message: 'Failed to create account: ${e.toString()}',
        needsOnboarding: false,
      );
    }
  }

  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🔐 Login successful for: $email (UID: ${credential.user!.uid})');
      
      bool hasCompletedOnboarding = await this.hasCompletedOnboarding(credential.user!.uid);
      
      print('📋 Onboarding status: $hasCompletedOnboarding');
      print('🚪 Needs onboarding: ${!hasCompletedOnboarding}');

      return AuthResult(
        success: true,
        message: 'Login successful!',
        needsOnboarding: !hasCompletedOnboarding,
      );
    } catch (e) {
      print('❌ Firebase Auth Error: ${e.toString()}');
      return AuthResult(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      return AuthResult(
        success: false,
        message: 'Google Sign-In requires additional setup. Please use email sign-in for now.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Google sign-in failed: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    try {
      print('🚪 Signing out user: ${currentUser?.email}');
      
      await _clearCachedDataForUserChange();
      
      await _auth.signOut();
      print('✅ Signed out from Firebase');
      
      notifyListeners();
    } catch (e) {
      print('❌ Sign out error: $e');
      throw e;
    }
  }

  Future<bool> _createUserDocumentSafely(User user, String name, {String authMethod = 'email'}) async {
    try {
      print('📝 Creating user document in Firestore...');
      
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': false,
        'authMethod': authMethod,
      });
      
      print('✅ User document created successfully in Firestore');
      return true;
      
    } catch (e) {
      print('❌ Firestore Error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> hasCompletedOnboarding(String uid) async {
    try {
      print('🔍 Checking onboarding status for UID: $uid');
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        bool completed = data['onboardingCompleted'] ?? false;
        print('   📋 Firestore onboarding status: $completed');
        return completed;
      } else {
        print('   ⚠️ User document not found in Firestore');
        return false;
      }
    } catch (e) {
      print('   ❌ Error checking onboarding: ${e.toString()}');
      return false;
    }
  }

  Future<void> completeOnboarding(Map<String, dynamic> profile) async {
    if (currentUser != null) {
      try {
        profile['email'] = currentUser!.email;
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'onboardingCompleted': true,
          ...profile,
        }, SetOptions(merge: true));
        
        print('✅ Profile saved to Firebase for UID: ${currentUser!.uid}');
        print('   Profile keys: ${profile.keys.toList()}');
        
        final userProfile = UserProfile.fromOnboarding(profile);
        final profileService = UserProfileService();
        await profileService.saveUserProfile(userProfile);
        
        print('✅ Profile saved to local UserProfileService');
      } catch (e) {
        print('❌ Error saving profile to Firebase: $e');
        final userProfile = UserProfile.fromOnboarding(profile);
        final profileService = UserProfileService();
        await profileService.saveUserProfile(userProfile);
      }
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser != null) {
      try {
        print('🔍 Getting profile from Firebase for UID: ${currentUser!.uid}');
        DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
        
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          print('✅ Profile loaded from Firebase');
          return data;
        } else {
          print('⚠️ Firebase document does not exist for UID: ${currentUser!.uid}');
        }
      } catch (e) {
        print('❌ Error getting user profile from Firebase: $e');
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'email': data['email'] ?? 'N/A',
          'name': data['name'] ?? 'N/A',
          'createdAt': data['createdAt'],
          'onboardingCompleted': data['onboardingCompleted'] ?? false,
        };
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final User? user;
  final bool needsOnboarding;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.needsOnboarding = false,
  });
}