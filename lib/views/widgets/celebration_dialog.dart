import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/badge_model.dart';

class CelebrationDialog extends StatelessWidget {
  final BadgeModel badge;

  const CelebrationDialog({super.key, required this.badge});

  static Future<void> show(BuildContext context, BadgeModel badge) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CelebrationDialog(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFF9E00), Color(0xFFFF5400)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66FF5400),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  badge.icon,
                  size: 54,
                  color: Colors.white,
                ),
              ),
            )
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack)
                .shimmer(delay: 200.ms, duration: 800.ms),
            const SizedBox(height: 20),
            Text(
              'Nova Insígnia!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF7A00),
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Chip(
              avatar: const Icon(Icons.local_fire_department, size: 18, color: Colors.amber),
              label: Text(
                '${badge.requiredDays} dias de ofensiva',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Continuar Firme',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
