import 'package:flutter/material.dart';
import '../models/navigation_state.dart';
import '../screens/dashboard_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/workout_program_screen.dart';
import '../screens/workout_detail_screen.dart';
import '../screens/workout_session_screen.dart';
import '../screens/enhanced_meal_plan_screen.dart';

/// Central navigation service for managing app-wide navigation
/// Provides consistent navigation patterns and state preservation
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  NavigationState _currentState = NavigationState();
  
  // Navigation history stack for breadcrumb navigation
  final List<NavigationContext> _navigationHistory = [];
  
  // Active workout session state
  Map<String, dynamic>? _activeWorkout;
  Map<String, dynamic>? _userProfile;
  
  // Getters
  NavigationState get currentState => _currentState;
  List<NavigationContext> get navigationHistory => List.unmodifiable(_navigationHistory);
  Map<String, dynamic>? get activeWorkout => _activeWorkout;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get hasActiveWorkout => _activeWorkout != null;

  /// Initialize navigation service with user profile
  void initialize(Map<String, dynamic> profile) {
    _userProfile = profile;
    _currentState = NavigationState(
      currentScreen: NavigationScreen.dashboard,
      userProfile: profile,
    );
  }

  /// Navigate to a screen with context preservation
  Future<T?> navigateTo<T>(
    NavigationScreen screen, {
    Map<String, dynamic>? arguments,
    bool preserveState = true,
    NavigationTransition transition = NavigationTransition.slide,
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null) return null;

    // Create navigation context for history
    final navContext = NavigationContext(
      screen: _currentState.currentScreen,
      arguments: _currentState.arguments,
      timestamp: DateTime.now(),
    );

    // Add to history if preserving state
    if (preserveState) {
      _navigationHistory.add(navContext);
      // Keep history manageable (max 10 entries)
      if (_navigationHistory.length > 10) {
        _navigationHistory.removeAt(0);
      }
    }

    // Update current state
    _currentState = _currentState.copyWith(
      currentScreen: screen,
      arguments: arguments,
    );

    // Get the route for the screen
    final route = _getRouteForScreen(screen, arguments);
    if (route == null) return null;

    // Apply transition
    final pageRoute = _createPageRoute<T>(route, transition);
    
    return Navigator.of(context).push<T>(pageRoute);
  }

  /// Navigate back with state restoration
  void navigateBack({bool restoreState = true}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      
      // Restore previous state if available
      if (restoreState && _navigationHistory.isNotEmpty) {
        final previousContext = _navigationHistory.removeLast();
        _currentState = _currentState.copyWith(
          currentScreen: previousContext.screen,
          arguments: previousContext.arguments,
        );
      }
    }
  }

  /// Navigate to dashboard (home)
  Future<void> navigateToHome() async {
    await navigateTo(NavigationScreen.dashboard, preserveState: false);
  }

  /// Start a workout session with state preservation
  Future<void> startWorkoutSession(Map<String, dynamic> workout) async {
    _activeWorkout = workout;
    _currentState = _currentState.copyWith(
      activeWorkout: workout,
      workoutStartTime: DateTime.now(),
    );
    
    await navigateTo(
      NavigationScreen.workoutSession,
      arguments: {
        'workout': workout,
        'profile': _userProfile,
      },
    );
  }

  /// Complete workout session and clear state
  void completeWorkoutSession() {
    _activeWorkout = null;
    _currentState = _currentState.copyWith(
      activeWorkout: null,
      workoutStartTime: null,
    );
  }

  /// Navigate to camera with workout context
  Future<void> navigateToCamera({bool fromWorkout = false}) async {
    await navigateTo(
      NavigationScreen.camera,
      arguments: {
        'fromWorkout': fromWorkout,
        'activeWorkout': _activeWorkout,
        'profile': _userProfile,
      },
    );
  }

  /// Navigate to workout program
  Future<void> navigateToWorkoutProgram() async {
    await navigateTo(
      NavigationScreen.workoutProgram,
      arguments: {'profile': _userProfile},
    );
  }

  /// Navigate to meal plan
  Future<void> navigateToMealPlan() async {
    await navigateTo(
      NavigationScreen.mealPlan,
      arguments: {'profile': _userProfile},
    );
  }

  /// Get route widget for screen
  Widget? _getRouteForScreen(NavigationScreen screen, Map<String, dynamic>? arguments) {
    switch (screen) {
      case NavigationScreen.dashboard:
        return _getDashboardScreen();
      case NavigationScreen.camera:
        return _getCameraScreen(arguments);
      case NavigationScreen.workoutProgram:
        return _getWorkoutProgramScreen(arguments);
      case NavigationScreen.workoutDetail:
        return _getWorkoutDetailScreen(arguments);
      case NavigationScreen.workoutSession:
        return _getWorkoutSessionScreen(arguments);
      case NavigationScreen.mealPlan:
        return _getMealPlanScreen(arguments);
      default:
        return null;
    }
  }

  /// Create page route with transition
  PageRoute<T> _createPageRoute<T>(Widget screen, NavigationTransition transition) {
    switch (transition) {
      case NavigationTransition.slide:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
      case NavigationTransition.fade:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      case NavigationTransition.scale:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(scale: animation, child: child);
          },
        );
    }
  }

  // Screen factory methods
  Widget _getDashboardScreen() {
    return DashboardScreen(profile: _userProfile ?? {});
  }

  Widget _getCameraScreen(Map<String, dynamic>? arguments) {
    return CameraScreen();
  }

  Widget _getWorkoutProgramScreen(Map<String, dynamic>? arguments) {
    return WorkoutProgramScreen(userProfile: arguments?['profile'] ?? _userProfile ?? {});
  }

  Widget _getWorkoutDetailScreen(Map<String, dynamic>? arguments) {
    return WorkoutDetailScreen(
      workout: arguments?['workout'] ?? {},
      profile: arguments?['profile'] ?? _userProfile ?? {},
      onWorkoutCompleted: arguments?['onWorkoutCompleted'] ?? () {},
    );
  }

  Widget _getWorkoutSessionScreen(Map<String, dynamic>? arguments) {
    return WorkoutSessionScreen(
      workout: arguments?['workout'] ?? {},
      profile: arguments?['profile'] ?? _userProfile ?? {},
      onWorkoutCompleted: arguments?['onWorkoutCompleted'] ?? () {},
    );
  }

  Widget _getMealPlanScreen(Map<String, dynamic>? arguments) {
    return EnhancedMealPlanScreen(userProfile: arguments?['profile'] ?? _userProfile ?? {});
  }

  /// Clear all navigation state
  void clearState() {
    _navigationHistory.clear();
    _activeWorkout = null;
    _currentState = NavigationState();
  }

  /// Get breadcrumb navigation path
  List<String> getBreadcrumbs() {
    final breadcrumbs = <String>[];
    
    // Add history breadcrumbs
    for (final context in _navigationHistory.take(3)) {
      breadcrumbs.add(_getScreenDisplayName(context.screen));
    }
    
    // Add current screen
    breadcrumbs.add(_getScreenDisplayName(_currentState.currentScreen));
    
    return breadcrumbs;
  }

  /// Get display name for screen
  String _getScreenDisplayName(NavigationScreen screen) {
    switch (screen) {
      case NavigationScreen.dashboard:
        return 'Dashboard';
      case NavigationScreen.camera:
        return 'AI Camera';
      case NavigationScreen.workoutProgram:
        return 'Workouts';
      case NavigationScreen.workoutDetail:
        return 'Workout Details';
      case NavigationScreen.workoutSession:
        return 'Active Workout';
      case NavigationScreen.mealPlan:
        return 'Meal Plan';
      case NavigationScreen.auth:
        return 'Login';
      case NavigationScreen.onboarding:
        return 'Setup';
    }
  }
}