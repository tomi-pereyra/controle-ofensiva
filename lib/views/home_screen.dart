import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/streak_controller.dart';
import 'widgets/flame_icon.dart';
import 'widgets/celebration_dialog.dart';

class HomeScreen extends StatefulWidget {
  final StreakController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _playCheckInAnimation = false;

  Future<void> _handleCheckIn() async {
    setState(() => _playCheckInAnimation = true);

    final unlockedBadges = await widget.controller.performCheckIn();

    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      setState(() => _playCheckInAnimation = false);
    }

    if (unlockedBadges.isNotEmpty && mounted) {
      for (final badge in unlockedBadges) {
        await CelebrationDialog.show(context, badge);
      }
    }
  }

  Future<void> _confirmUndoCheckIn() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desfazer check-in de hoje?'),
        content: const Text(
          'Se você registrou sem querer, isso voltará a contagem em 1 dia e liberará o botão para registrar novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Desfazer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.controller.undoTodayCheckIn();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de hoje desfeito com sucesso.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _confirmResetStreak() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zerar ofensiva?'),
        content: const Text(
          'Tem certeza que deseja zerar sua ofensiva para 0? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sim, Zerar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.controller.resetStreak();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ofensiva zerada para 0.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final streak = widget.controller.streak;
        final isCompleted = widget.controller.isCompletedToday;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  // Cabeçalho minimalista com menu de opções
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40), // Espaço para manter o título centralizado
                      Text(
                        'OFENSIVA DIÁRIA',
                        style: theme.textTheme.labelMedium?.copyWith(
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.labelMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onSelected: (val) {
                          if (val == 'undo') {
                            _confirmUndoCheckIn();
                          } else if (val == 'reset') {
                            _confirmResetStreak();
                          }
                        },
                        itemBuilder: (ctx) => [
                          if (isCompleted)
                            const PopupMenuItem(
                              value: 'undo',
                              child: Row(
                                children: [
                                  Icon(Icons.undo_rounded, size: 20),
                                  SizedBox(width: 12),
                                  Text('Desfazer check-in de hoje'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'reset',
                            child: Row(
                              children: [
                                Icon(Icons.restart_alt_rounded, size: 20, color: Colors.red),
                                SizedBox(width: 12),
                                Text(
                                  'Zerar ofensiva',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Chama animada central
                  FlameIcon(
                    isActive: isCompleted,
                    triggerAnimation: _playCheckInAnimation,
                  ),

                  const SizedBox(height: 36),

                  // Número Gigante da Ofensiva
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Text(
                      '$streak',
                      key: ValueKey<int>(streak),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 84,
                        fontWeight: FontWeight.w900,
                        color: isCompleted
                            ? const Color(0xFFFF5400)
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                        height: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    streak == 1 ? 'DIA CONSECUTIVO' : 'DIAS CONSECUTIVOS',
                    style: theme.textTheme.titleSmall?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: isCompleted
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Texto de status sutil
                  Text(
                    isCompleted
                        ? 'Você garantiu a ofensiva de hoje!'
                        : (streak > 0
                            ? 'Mantenha sua chama acesa antes da meia-noite.'
                            : 'Inicie sua nova sequência hoje.'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  const Spacer(),

                  // Botão de Ação Diária
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: isCompleted
                        ? OutlinedButton.icon(
                            onPressed: null, // Desabilitado até 00:00 do dia seguinte
                            icon: const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF2E7D32)),
                            label: const Text(
                              'Concluído por hoje',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF2E7D32),
                                width: 1.8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          )
                        : FilledButton(
                            onPressed: _handleCheckIn,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5400),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(0x66FF5400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_fire_department_rounded, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Registrar Hoje',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.02, 1.02),
                              duration: 1200.ms,
                              curve: Curves.easeInOut,
                            ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
