import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FlameIcon extends StatelessWidget {
  final bool isActive;
  final bool triggerAnimation;

  const FlameIcon({
    super.key,
    required this.isActive,
    this.triggerAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget iconWidget = Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
            ? const RadialGradient(
                colors: [
                  Color(0xFFFF9E00),
                  Color(0xFFFF5400),
                  Color(0x22FF5400),
                ],
                stops: [0.3, 0.7, 1.0],
              )
            : RadialGradient(
                colors: isDark
                    ? [const Color(0xFF333333), const Color(0xFF1E1E1E)]
                    : [const Color(0xFFE0E0E0), const Color(0xFFCCCCCC)],
              ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFFF5400).withOpacity(0.45),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Icon(
          Icons.local_fire_department_rounded,
          size: 100,
          color: isActive
              ? Colors.white
              : (isDark ? Colors.white30 : Colors.black26),
        ),
      ),
    );

    if (triggerAnimation) {
      return iconWidget
          .animate(key: UniqueKey())
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.15, 1.15),
            duration: 350.ms,
            curve: Curves.easeOutBack,
          )
          .then()
          .scale(
            begin: const Offset(1.15, 1.15),
            end: const Offset(1.0, 1.0),
            duration: 250.ms,
            curve: Curves.easeInOut,
          )
          .shimmer(
            duration: 600.ms,
            color: Colors.white70,
          );
    }

    if (isActive) {
      return iconWidget
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.03, 1.03),
            duration: 1800.ms,
            curve: Curves.easeInOutSine,
          );
    }

    return iconWidget;
  }
}
