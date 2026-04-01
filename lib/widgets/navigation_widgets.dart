import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../services/navigation_middleware.dart';
import '../models/navigation_state.dart';

/// Consistent navigation header widget
class NavigationHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showWorkoutStatus;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const NavigationHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.showWorkoutStatus = true,
    this.onBackPressed,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    final hasActiveWorkout = navigationService.hasActiveWorkout;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: onBackPressed ?? () => _handleBackNavigation(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              if (showBackButton) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          
          // Active workout status bar
          if (showWorkoutStatus && hasActiveWorkout)
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: ActiveWorkoutStatusBar(),
            ),
        ],
      ),
    );
  }

  void _handleBackNavigation(BuildContext context) {
    NavigationMiddleware().handleBackNavigation();
  }
}

/// Active workout status bar widget
class ActiveWorkoutStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    final activeWorkout = navigationService.activeWorkout;
    final workoutDuration = navigationService.currentState.workoutDuration;

    if (activeWorkout == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Workout: ${activeWorkout['title']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (workoutDuration != null)
                  Text(
                    'Duration: ${_formatDuration(workoutDuration)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _resumeWorkout(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Resume',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resumeWorkout(BuildContext context) {
    NavigationService().navigateTo(NavigationScreen.workoutSession);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Floating action button for quick camera access during workouts
class WorkoutCameraFAB extends StatelessWidget {
  final VoidCallback? onPressed;

  const WorkoutCameraFAB({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    final hasActiveWorkout = navigationService.hasActiveWorkout;
    final isInWorkoutSession = navigationService.currentState.currentScreen == NavigationScreen.workoutSession;

    // Only show during active workout sessions
    if (!hasActiveWorkout || !isInWorkoutSession) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: onPressed ?? () => _openCamera(context),
      backgroundColor: const Color(0xFF74B9FF),
      child: const Icon(
        Icons.camera_alt_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  void _openCamera(BuildContext context) {
    NavigationService().navigateToCamera(fromWorkout: true);
  }
}

/// Navigation breadcrumb widget
class NavigationBreadcrumb extends StatelessWidget {
  final bool showHome;

  const NavigationBreadcrumb({Key? key, this.showHome = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    final breadcrumbs = navigationService.getBreadcrumbs();

    if (breadcrumbs.length <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          if (showHome)
            GestureDetector(
              onTap: () => navigationService.navigateToHome(),
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white60,
                size: 16,
              ),
            ),
          if (showHome) const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildBreadcrumbItems(breadcrumbs),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems(List<String> breadcrumbs) {
    final items = <Widget>[];
    
    for (int i = 0; i < breadcrumbs.length; i++) {
      final isLast = i == breadcrumbs.length - 1;
      
      items.add(
        Text(
          breadcrumbs[i],
          style: TextStyle(
            color: isLast ? Colors.white : Colors.white60,
            fontSize: 12,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      );
      
      if (!isLast) {
        items.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right_rounded,
              color: Colors.white60,
              size: 16,
            ),
          ),
        );
      }
    }
    
    return items;
  }
}

/// Bottom navigation bar for main features
class MainNavigationBar extends StatelessWidget {
  final NavigationScreen currentScreen;

  const MainNavigationBar({Key? key, required this.currentScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B3A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              screen: NavigationScreen.dashboard,
              isActive: currentScreen == NavigationScreen.dashboard,
            ),
            _buildNavItem(
              icon: Icons.fitness_center_rounded,
              label: 'Workouts',
              screen: NavigationScreen.workoutProgram,
              isActive: currentScreen == NavigationScreen.workoutProgram,
            ),
            _buildNavItem(
              icon: Icons.camera_alt_rounded,
              label: 'AI Camera',
              screen: NavigationScreen.camera,
              isActive: currentScreen == NavigationScreen.camera,
            ),
            _buildNavItem(
              icon: Icons.restaurant_rounded,
              label: 'Nutrition',
              screen: NavigationScreen.mealPlan,
              isActive: currentScreen == NavigationScreen.mealPlan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required NavigationScreen screen,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _navigateToScreen(screen),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF6C5CE7) : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF6C5CE7) : Colors.white60,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(NavigationScreen screen) {
    final navigationService = NavigationService();
    
    switch (screen) {
      case NavigationScreen.dashboard:
        navigationService.navigateToHome();
        break;
      case NavigationScreen.workoutProgram:
        navigationService.navigateToWorkoutProgram();
        break;
      case NavigationScreen.camera:
        navigationService.navigateToCamera();
        break;
      case NavigationScreen.mealPlan:
        navigationService.navigateToMealPlan();
        break;
      case NavigationScreen.profile:
        navigationService.navigateToUserProfile();
        break;
      default:
        break;
    }
  }
}