import 'package:flutter/material.dart';
import '../controllers/streak_controller.dart';
import '../models/badge_model.dart';
import 'widgets/celebration_dialog.dart';
import 'widgets/new_reward_dialog.dart';

class RewardsScreen extends StatelessWidget {
  final StreakController controller;

  const RewardsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Recompensas & Conquistas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Insígnias'),
              Tab(text: 'Minhas Metas'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return TabBarView(
              children: [
                _BadgesTab(controller: controller),
                _CustomRewardsTab(controller: controller),
              ],
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (ctx) {
            // Mostra o FAB apenas na aba de recompensas
            return FloatingActionButton.extended(
              onPressed: () {
                NewRewardDialog.show(context, (title, targetDays, icon) {
                  controller.addCustomReward(
                    title: title,
                    targetDays: targetDays,
                    icon: icon,
                  );
                });
              },
              backgroundColor: const Color(0xFFFF5400),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nova Meta'),
            );
          },
        ),
      ),
    );
  }
}

class _BadgesTab extends StatelessWidget {
  final StreakController controller;

  const _BadgesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final badges = BadgeModel.defaultBadges;
    final unlockedIds = controller.unlockedBadgeIds;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final isUnlocked = unlockedIds.contains(badge.id);

        return InkWell(
          onTap: () {
            CelebrationDialog.show(context, badge);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: isUnlocked
                  ? (isDark ? const Color(0xFF2C2216) : const Color(0xFFFFF7ED))
                  : (isDark ? const Color(0xFF222222) : const Color(0xFFF1F1F1)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUnlocked
                    ? const Color(0xFFFF9E00).withOpacity(0.5)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnlocked
                            ? const Color(0xFFFF7A00)
                            : (isDark ? Colors.white12 : Colors.black12),
                      ),
                      child: Icon(
                        badge.icon,
                        size: 32,
                        color: isUnlocked
                            ? Colors.white
                            : (isDark ? Colors.white24 : Colors.black26),
                      ),
                    ),
                    if (!isUnlocked)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  badge.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? null
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${badge.requiredDays} dias',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? const Color(0xFFFF7A00)
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CustomRewardsTab extends StatelessWidget {
  final StreakController controller;

  const _CustomRewardsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rewards = controller.customRewards;
    final currentStreak = controller.streak;

    if (rewards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 72,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma recompensa criada',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crie metas próprias (ex: Jantar especial com 15 dias de ofensiva) para se manter motivado!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
      itemCount: rewards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reward = rewards[index];
        final isReached = currentStreak >= reward.targetDays;
        final progress = (currentStreak / reward.targetDays).clamp(0.0, 1.0);

        return Card(
          elevation: isReached ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isReached
                  ? const Color(0xFF2E7D32).withOpacity(0.4)
                  : theme.dividerColor.withOpacity(0.15),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isReached
                            ? const Color(0xFFE8F5E9)
                            : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        reward.iconData,
                        color: isReached
                            ? const Color(0xFF2E7D32)
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reward.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isReached
                                ? '🎉 Meta Atingida! Aproveite sua recompensa'
                                : '$currentStreak de ${reward.targetDays} dias',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isReached ? FontWeight.bold : FontWeight.w500,
                              color: isReached
                                  ? const Color(0xFF2E7D32)
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: Colors.red.withOpacity(0.7),
                      onPressed: () {
                        controller.removeCustomReward(reward.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isReached ? const Color(0xFF2E7D32) : const Color(0xFFFF7A00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
