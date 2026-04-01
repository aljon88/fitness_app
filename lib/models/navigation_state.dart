/// Navigation state model to track user context and active sessions
class NavigationState {
  final NavigationScreen currentScreen;
  final Map<String, dynamic>? arguments;
  final Map<String, dynamic>? userProfile;
  final Map<String, dynamic>? activeWorkout;
  final DateTime? workoutStartTime;
  final DateTime timestamp;

  NavigationState({
    this.currentScreen = NavigationScreen.dashboard,
    this.arguments,
    this.userProfile,
    this.activeWorkout,
    this.workoutStartTime,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a copy with updated values
  NavigationState copyWith({
    NavigationScreen? currentScreen,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? userProfile,
    Map<String, dynamic>? activeWorkout,
    DateTime? workoutStartTime,
    DateTime? timestamp,
  }) {
    return NavigationState(
      currentScreen: currentScreen ?? this.currentScreen,
      arguments: arguments ?? this.arguments,
      userProfile: userProfile ?? this.userProfile,
      activeWorkout: activeWorkout ?? this.activeWorkout,
      workoutStartTime: workoutStartTime ?? this.workoutStartTime,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Check if user has an active workout session
  bool get hasActiveWorkout => activeWorkout != null;

  /// Get workout duration if active
  Duration? get workoutDuration {
    if (workoutStartTime == null) return null;
    return DateTime.now().difference(workoutStartTime!);
  }

  /// Check if user is in a workout flow
  bool get isInWorkoutFlow {
    return currentScreen == NavigationScreen.workoutDetail ||
           currentScreen == NavigationScreen.workoutSession ||
           (currentScreen == NavigationScreen.camera && hasActiveWorkout);
  }

  @override
  String toString() {
    return 'NavigationState(screen: $currentScreen, hasActiveWorkout: $hasActiveWorkout)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationState &&
           other.currentScreen == currentScreen &&
           other.hasActiveWorkout == hasActiveWorkout;
  }

  @override
  int get hashCode {
    return currentScreen.hashCode ^ hasActiveWorkout.hashCode;
  }
}

/// Navigation context for history tracking
class NavigationContext {
  final NavigationScreen screen;
  final Map<String, dynamic>? arguments;
  final DateTime timestamp;

  NavigationContext({
    required this.screen,
    this.arguments,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'NavigationContext(screen: $screen, timestamp: $timestamp)';
  }
}

/// Available screens in the app
enum NavigationScreen {
  auth,
  onboarding,
  dashboard,
  camera,
  workoutProgram,
  workoutDetail,
  workoutSession,
  mealPlan,
  profile,
}

/// Navigation transition types
enum NavigationTransition {
  slide,
  fade,
  scale,
}