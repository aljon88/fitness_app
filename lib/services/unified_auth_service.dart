import 'package:firebase_auth/firebase_auth.dart';
import 'mock_auth_service.dart';
import 'firebase_auth_service.dart';

/// Unified authentication service that works with both Firebase and Mock auth
class UnifiedAuthService {
  static final UnifiedAuthService _instance = UnifiedAuthService._internal();
  factory UnifiedAuthService() => _instance;
  UnifiedAuthService._internal();

  /// Get current user info from either Firebase or Mock auth
  Map<String, dynamic>? getCurrentUser() {
    // Try Firebase first
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName ?? 'User',
        'source': 'firebase',
      };
    }

    // Fall back to Mock auth
    final mockUser = MockAuthService.instance.getCurrentUser();
    if (mockUser != null) {
      return {
        'uid': mockUser['uid'],
        'email': mockUser['email'],
        'displayName': mockUser['displayName'] ?? 'User',
        'source': 'mock',
      };
    }

    return null;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    final user = getCurrentUser();
    return user?['uid'];
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    final user = getCurrentUser();
    return user?['email'];
  }

  /// Check if user is logged in
  bool get isLoggedIn {
    return getCurrentUser() != null;
  }

  /// Get user-specific storage key
  String getUserKey(String baseKey) {
    final userId = getCurrentUserId();
    if (userId != null) {
      return '${userId}_$baseKey';
    }
    return baseKey; // Fallback
  }
  
  /// Print current auth status for debugging
  void printAuthStatus() {
    final user = getCurrentUser();
    if (user != null) {
      print('✅ UnifiedAuth: User logged in via ${user['source']}');
      print('   UID: ${user['uid']}');
      print('   Email: ${user['email']}');
      print('   Name: ${user['displayName']}');
    } else {
      print('❌ UnifiedAuth: No user logged in');
    }
  }
}