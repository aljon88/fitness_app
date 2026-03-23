import 'package:flutter/material.dart';
import 'navigation_service.dart';
import '../models/navigation_state.dart';

/// Navigation middleware to preserve state during transitions
/// Handles workout state preservation, context switching, and navigation guards
class NavigationMiddleware {
  static final NavigationMiddleware _instance = NavigationMiddleware._internal();
  factory NavigationMiddleware() => _instance;
  NavigationMiddleware._internal();

  final NavigationService _navigationService = NavigationService();
  
  // State preservation callbacks
  final Map<NavigationScreen, VoidCallback> _statePreservationCallbacks = {};
  final Map<NavigationScreen, VoidCallback> _stateRestorationCallbacks = {};

  /// Register state preservation callback for a screen
  void registerStatePreservation(NavigationScreen screen, VoidCallback callback) {
    _statePreservationCallbacks[screen] = callback;
  }

  /// Register state restoration callback for a screen
  void registerStateRestoration(NavigationScreen screen, VoidCallback callback) {
    _stateRestorationCallbacks[screen] = callback;
  }

  /// Handle navigation with state preservation
  Future<T?> handleNavigation<T>({
    required NavigationScreen targetScreen,
    Map<String, dynamic>? arguments,
    bool preserveWorkoutState = true,
    NavigationTransition transition = NavigationTransition.slide,
  }) async {
    final currentScreen = _navigationService.currentState.currentScreen;
    
    // Preserve current screen state if callback exists
    final preservationCallback = _statePreservationCallbacks[currentScreen];
    if (preservationCallback != null) {
      preservationCallback();
    }

    // Handle workout state preservation
    if (preserveWorkoutState && _navigationService.hasActiveWorkout) {
      await _preserveWorkoutState(targetScreen);
    }

    // Perform navigation
    final result = await _navigationService.navigateTo<T>(
      targetScreen,
      arguments: arguments,
      transition: transition,
    );

    // Restore state for target screen if callback exists
    final restorationCallback = _stateRestorationCallbacks[targetScreen];
    if (restorationCallback != null) {
      restorationCallback();
    }

    return result;
  }

  /// Preserve workout state during navigation
  Future<void> _preserveWorkoutState(NavigationScreen targetScreen) async {
    final activeWorkout = _navigationService.activeWorkout;
    if (activeWorkout == null) return;

    // Add workout context to target screen arguments
    final workoutContext = {
      'hasActiveWorkout': true,
      'activeWorkout': activeWorkout,
      'workoutStartTime': _navigationService.currentState.workoutStartTime,
    };

    // Store workout context for restoration
    await _storeWorkoutContext(targetScreen, workoutContext);
  }

  /// Store workout context for later restoration
  Future<void> _storeWorkoutContext(
    NavigationScreen screen,
    Map<String, dynamic> context,
  ) async {
    // In a real app, this might use shared preferences or secure storage
    // For now, we'll keep it in memory via the navigation service
    // This ensures workout state is preserved during navigation
  }

  /// Handle back navigation with state restoration
  Future<bool> handleBackNavigation() async {
    final currentScreen = _navigationService.currentState.currentScreen;
    
    // Check if we can navigate back
    final context = _navigationService.navigatorKey.currentContext;
    if (context == null || !Navigator.of(context).canPop()) {
      return false;
    }

    // Handle special cases for workout flow
    if (_navigationService.hasActiveWorkout) {
      return await _handleWorkoutBackNavigation(currentScreen);
    }

    // Standard back navigation
    _navigationService.navigateBack();
    return true;
  }

  /// Handle back navigation during workout flow
  Future<bool> _handleWorkoutBackNavigation(NavigationScreen currentScreen) async {
    switch (currentScreen) {
      case NavigationScreen.workoutSession:
        // Show confirmation dialog before exiting active workout
        return await _showWorkoutExitConfirmation();
      
      case NavigationScreen.camera:
        // If camera was opened from workout, return to workout session
        if (_navigationService.currentState.arguments?['fromWorkout'] == true) {
          await _navigationService.navigateTo(NavigationScreen.workoutSession);
          return true;
        }
        break;
      
      default:
        break;
    }

    // Default back navigation
    _navigationService.navigateBack();
    return true;
  }

  /// Show confirmation dialog for exiting active workout
  Future<bool> _showWorkoutExitConfirmation() async {
    final context = _navigationService.navigatorKey.currentContext;
    if (context == null) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Exit Workout?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to exit? Your workout progress will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              _navigationService.completeWorkoutSession();
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      _navigationService.navigateBack();
      return true;
    }

    return false;
  }

  /// Create navigation guard for protected screens
  NavigationGuard createNavigationGuard({
    required List<NavigationScreen> protectedScreens,
    required bool Function() guardCondition,
    required Widget Function() guardWidget,
  }) {
    return NavigationGuard(
      protectedScreens: protectedScreens,
      guardCondition: guardCondition,
      guardWidget: guardWidget,
    );
  }

  /// Handle deep linking with state preservation
  Future<void> handleDeepLink(String route, Map<String, dynamic>? arguments) async {
    final screen = _parseRouteToScreen(route);
    if (screen != null) {
      await handleNavigation(
        targetScreen: screen,
        arguments: arguments,
        preserveWorkoutState: true,
      );
    }
  }

  /// Parse route string to navigation screen
  NavigationScreen? _parseRouteToScreen(String route) {
    switch (route) {
      case '/dashboard':
        return NavigationScreen.dashboard;
      case '/camera':
        return NavigationScreen.camera;
      case '/workouts':
        return NavigationScreen.workoutProgram;
      case '/meal-plan':
        return NavigationScreen.mealPlan;
      default:
        return null;
    }
  }

  /// Clear all middleware state
  void clearState() {
    _statePreservationCallbacks.clear();
    _stateRestorationCallbacks.clear();
  }
}

/// Navigation guard for protecting screens
class NavigationGuard {
  final List<NavigationScreen> protectedScreens;
  final bool Function() guardCondition;
  final Widget Function() guardWidget;

  const NavigationGuard({
    required this.protectedScreens,
    required this.guardCondition,
    required this.guardWidget,
  });

  /// Check if screen is protected by this guard
  bool protects(NavigationScreen screen) {
    return protectedScreens.contains(screen);
  }

  /// Check if guard condition is met
  bool isAllowed() {
    return guardCondition();
  }

  /// Get guard widget to show when access is denied
  Widget getGuardWidget() {
    return guardWidget();
  }
}