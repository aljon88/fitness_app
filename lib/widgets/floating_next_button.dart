import 'package:flutter/material.dart';

/// Professional floating action button for workout flow navigation
/// Positioned consistently in bottom-right corner across all screens
class FloatingNextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool isVisible;

  const FloatingNextButton({
    Key? key,
    required this.onPressed,
    this.icon = Icons.arrow_forward_ios,
    this.backgroundColor,
    this.iconColor,
    this.size = 56.0,
    this.isVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 24,
      right: 24,
      child: AnimatedScale(
        scale: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: backgroundColor != null 
                ? [backgroundColor!, backgroundColor!.withOpacity(0.8)]
                : [
                    const Color(0xFF6C5CE7),
                    const Color(0xFF5B4FD8),
                  ],
            ),
            borderRadius: BorderRadius.circular(size / 2),
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? const Color(0xFF6C5CE7)).withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(size / 2),
              child: Center(
                child: Icon(
                  icon,
                  size: size * 0.35,
                  color: iconColor ?? Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Specialized floating button for workout celebration screens
class FloatingCelebrationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isFirstStep;
  final bool isVisible;

  const FloatingCelebrationButton({
    Key? key,
    required this.onPressed,
    this.isFirstStep = false,
    this.isVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingNextButton(
      onPressed: onPressed,
      backgroundColor: isFirstStep ? Colors.white : const Color(0xFF6C5CE7),
      iconColor: isFirstStep ? const Color(0xFF6C5CE7) : Colors.white,
      isVisible: isVisible,
    );
  }
}