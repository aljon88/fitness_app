import 'package:shared_preferences/shared_preferences.dart';

class MockAuthService {
  static const String _userKey = 'mock_user';
  static const String _isLoggedInKey = 'is_logged_in';

  static MockAuthService? _instance;
  static MockAuthService get instance {
    _instance ??= MockAuthService._();
    return _instance!;
  }

  MockAuthService._();

  // Mock user data
  String? _currentUserEmail;
  bool _isLoggedIn = false;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    if (_isLoggedIn) {
      _currentUserEmail = prefs.getString(_userKey);
    }
    return _isLoggedIn;
  }

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 500));

      // Mock validation
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Invalid email format');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      if (fullName.isEmpty) {
        throw Exception('Full name is required');
      }

      // Save user data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, email);
      await prefs.setString('user_name', fullName);
      await prefs.setBool(_isLoggedInKey, true);

      _currentUserEmail = email;
      _isLoggedIn = true;

      return {
        'success': true,
        'user': {
          'email': email,
          'displayName': fullName,
          'uid': 'mock_${email.hashCode}',
        }
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 500));

      // Mock validation
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Invalid email format');
      }
      if (password.length < 6) {
        throw Exception('Invalid password');
      }

      // Check if user exists (in a real app, this would check against database)
      final prefs = await SharedPreferences.getInstance();
      final savedUser = prefs.getString(_userKey);
      final savedName = prefs.getString('user_name') ?? 'Mock User';

      if (savedUser == email) {
        // User exists, sign them in
        await prefs.setBool(_isLoggedInKey, true);
        _currentUserEmail = email;
        _isLoggedIn = true;

        return {
          'success': true,
          'user': {
            'email': email,
            'displayName': savedName,
            'uid': 'mock_${email.hashCode}',
          }
        };
      } else {
        // For demo purposes, allow any email/password combination
        await prefs.setString(_userKey, email);
        await prefs.setString('user_name', 'Demo User');
        await prefs.setBool(_isLoggedInKey, true);

        _currentUserEmail = email;
        _isLoggedIn = true;

        return {
          'success': true,
          'user': {
            'email': email,
            'displayName': 'Demo User',
            'uid': 'mock_${email.hashCode}',
          }
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    _currentUserEmail = null;
    _isLoggedIn = false;
  }

  // Get current user
  Map<String, dynamic>? getCurrentUser() {
    if (_isLoggedIn && _currentUserEmail != null) {
      return {
        'email': _currentUserEmail,
        'displayName': 'Demo User',
        'uid': 'mock_${_currentUserEmail.hashCode}',
      };
    }
    return null;
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _currentUserEmail;
  }

  // Get current user ID
  String? getCurrentUserId() {
    if (_currentUserEmail != null) {
      return 'mock_${_currentUserEmail.hashCode}';
    }
    return null;
  }
}