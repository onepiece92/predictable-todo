import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../tasks/providers/task_provider.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../models/leaderboard_entry_model.dart';
import '../widgets/podium.dart';
import '../widgets/invite_button.dart';
import '../../../shared/widgets/rainbow_glimmer.dart';
import '../../../shared/widgets/app_avatar.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  String _filter = 'weekly';
  bool _inviteSent = false;
  final Set<String> _challengeSent = {};

  @override
  Widget build(BuildContext context) {
    final tState = ref.watch(taskProvider);
    final gState = ref.watch(gamificationProvider);
    final totalXp = tState.doneXp + gState.bonusXp;
    final level = XpCalculator.level(totalXp);

    // Build the "You" entry from real state, replace the seed placeholder
    final youEntry = LeaderboardEntry(
      name: 'You',
      xp: _filter == 'weekly' ? tState.doneXp : totalXp,
      avatar: '🧑‍💻',
      level: level,
      streak: gState.currentStreak,
      tasksWeek: tState.doneCount,
      isYou: true,
    );

    // Replace seed "You" with live entry, sort by the relevant XP field
    final others = tState.leaderboardOthers;
    final entries = [youEntry, ...others]..sort((a, b) => b.xp.compareTo(a.xp));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Leaderboard',
                      style: AppTheme.mono(size: 20, weight: FontWeight.w800)),
                  Row(
                    children: ['weekly', 'all-time'].map((f) {
                      final active = _filter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.accent.withValues(alpha: 0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  active ? AppColors.accent : AppColors.border,
                            ),
                          ),
                          child: Text(
                            f == 'weekly' ? 'Weekly' : 'All-Time',
                            style: AppTheme.sans(
                              size: 10,
                              weight: FontWeight.w700,
                              color:
                                  active ? AppColors.accent : AppColors.muted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 130),
                itemCount:
                    1 + (entries.length > 3 ? entries.length - 3 : 0) + 1,
                itemBuilder: (_, i) {
                  // 1. Podium (Handled at Index 0)
                  if (i == 0) {
                    return Podium(top3: entries.take(3).toList());
                  }

                  final cardsCount =
                      entries.length > 3 ? entries.length - 3 : 0;

                  // 2. Invite Button (Handled as the very last item)
                  if (i == cardsCount + 1) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: InviteButton(
                        sent: _inviteSent,
                        onTap: () => setState(() => _inviteSent = !_inviteSent),
                      ),
                    );
                  }

                  // 3. Leaderboard Cards (Ranks 4 and below)
                  // ListView index 1 maps to entries index 3 (Rank 4)
                  final entryIndex = i + 2;
                  final entry = entries[entryIndex];
                  final rank = entryIndex + 1;

                  return _LeaderboardCard(
                    entry: entry,
                    rank: rank,
                    filter: _filter,
                    challengeSent: _challengeSent.contains(entry.name),
                    onChallenge: () => setState(() {
                      if (_challengeSent.contains(entry.name)) {
                        _challengeSent.remove(entry.name);
                      } else {
                        _challengeSent.add(entry.name);
                      }
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final String filter;
  final bool challengeSent;
  final VoidCallback onChallenge;

  const _LeaderboardCard({
    required this.entry,
    required this.rank,
    required this.filter,
    required this.challengeSent,
    required this.onChallenge,
  });

  Color get _rankColor {
    if (rank == 1) return AppColors.gold;
    if (rank == 2) return const Color(0xFFAAAAAA);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.subtle;
  }

  void _showPlayerCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.bg.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Stack(
          children: [
            if (entry.isYou)
              Positioned.fill(
                child: RainbowGlimmer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(30)),
                      border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          width: 2),
                    ),
                  ),
                ),
              ),
            Column(
              children: [
                const SizedBox(height: 12),
                AppTheme.handleBar,
                const SizedBox(height: 40),
                AppAvatar(avatar: entry.avatar, size: 100, fontSize: 60),
                const SizedBox(height: 16),
                Text(entry.name,
                    style: AppTheme.mono(size: 24, weight: FontWeight.w900)),
                Text('LEVEL ${entry.level} CHAMPION',
                    style: AppTheme.sans(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.accent,
                        letterSpacing: 1.2)),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(label: 'TOTAL XP', value: '${entry.xp}'),
                      _Stat(label: 'STREAK', value: '${entry.streak}d'),
                      _Stat(label: 'RANK', value: '#$rank'),
                    ],
                  ),
                ),
                const Spacer(),
                if (!entry.isYou)
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          onChallenge();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text('SEND CHALLENGE',
                            style: AppTheme.mono(
                                size: 14, weight: FontWeight.w800)),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Weekly view shows tasks/week; all-time shows streak
    final statLabel = filter == 'weekly'
        ? '${entry.tasksWeek} tasks/wk'
        : '🔥 ${entry.streak}d streak';

    return GestureDetector(
      onTap: () => _showPlayerCard(context),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: entry.isYou
                  ? AppColors.accent.withValues(alpha: 0.04)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: entry.isYou
                    ? AppColors.accent.withValues(alpha: 0.28)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: Text('$rank',
                      textAlign: TextAlign.center,
                      style: AppTheme.mono(
                          size: 12,
                          weight: FontWeight.w800,
                          color: _rankColor)),
                ),
                const SizedBox(width: 8),
                AppAvatar(avatar: entry.avatar, size: 32, fontSize: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.name,
                          style: AppTheme.sans(
                              size: 11,
                              weight: FontWeight.w700,
                              color: entry.isYou
                                  ? AppColors.accent
                                  : AppColors.text)),
                      const SizedBox(height: 2),
                      Text('${entry.xp} XP',
                          style:
                              AppTheme.mono(size: 9, color: AppColors.accent)),
                      Row(
                        children: [
                          Text('LVL ${entry.level}',
                              style: AppTheme.mono(
                                  size: 8, color: AppColors.purple)),
                          const SizedBox(width: 6),
                          Text(statLabel,
                              style: AppTheme.sans(
                                  size: 8, color: AppColors.subtle)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!entry.isYou)
                  GestureDetector(
                    onTap: onChallenge,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: challengeSent
                            ? AppColors.accent.withValues(alpha: 0.1)
                            : AppColors.purple.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: challengeSent
                              ? AppColors.accent.withValues(alpha: 0.28)
                              : AppColors.purple.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Text(
                        challengeSent ? 'Sent ✓' : 'Challenge',
                        style: AppTheme.sans(
                          size: 9,
                          weight: FontWeight.w700,
                          color: challengeSent
                              ? AppColors.accent
                              : AppColors.purple,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (entry.isYou)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: RainbowGlimmer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTheme.mono(
                size: 20, weight: FontWeight.w900, color: AppColors.text)),
        const SizedBox(height: 4),
        Text(label,
            style: AppTheme.sans(
                size: 9, weight: FontWeight.w700, color: AppColors.subtle)),
      ],
    );
  }
}
