import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth/auth_controller.dart';
import '../services/auth/auth_user.dart';
import '../styles/app_theme.dart';
import '../styles/spacing.dart';
import '../widgets/app_background.dart';
import '../widgets/game_fx.dart';
import '../widgets/modern_panel.dart';
import 'achievements_screen.dart';
import 'game_selection_screen.dart';
import 'link/link_hub_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = context.watch<AuthController>();
    final AuthUser? user = auth.user;

    void openGameSelection() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GameSelectionScreen()),
      );
    }

    void openStatistics() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StatisticsScreen()),
      );
    }

    void openAchievements() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AchievementsScreen()),
      );
    }

    void openLinkHub() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LinkHubScreen()),
      );
    }

    void openSettings() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }

    return Scaffold(
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const AppHeroHeader(
                    height: 200,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        Spacing.xl,
                        Spacing.lg,
                        Spacing.xl,
                        Spacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Road Trip Games',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Play together, mile by mile',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      tooltip: 'Settings',
                      onPressed: openSettings,
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                  child: FadeSlideIn(
                    child: _ProfileCard(user: user),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.xl,
                  Spacing.md,
                  Spacing.xl,
                  Spacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: _QuickStatsRow(user: user),
                    ),
                    const SizedBox(height: Spacing.xxl),
                    const FadeSlideIn(
                      delay: Duration(milliseconds: 140),
                      child: SectionLabel(
                        title: "Let's play",
                        subtitle: 'Jump straight into a road-trip challenge.',
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      child: GradientPrimaryButton(
                        onPressed: openGameSelection,
                        label: 'Start a game',
                        icon: Icons.play_arrow_rounded,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxl),
                    const FadeSlideIn(
                      delay: Duration(milliseconds: 260),
                      child: SectionLabel(title: 'Explore'),
                    ),
                    const SizedBox(height: Spacing.lg),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 300),
                      child: _MainMenuActionTile(
                        icon: Icons.grid_view_rounded,
                        title: 'Game library',
                        subtitle: 'Browse challenges for every passenger',
                        accentColor: colorScheme.primary,
                        onTap: openGameSelection,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 360),
                      child: _MainMenuActionTile(
                        icon: Icons.emoji_events_outlined,
                        title: 'Achievements',
                        subtitle: 'Celebrate milestones along the journey',
                        accentColor: AppTheme.accentViolet,
                        onTap: openAchievements,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 420),
                      child: _MainMenuActionTile(
                        icon: Icons.insights_rounded,
                        title: 'Statistics',
                        subtitle: 'Track scores and progress over time',
                        accentColor: AppTheme.accentCoral,
                        onTap: openStatistics,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 480),
                      child: _MainMenuActionTile(
                        icon: Icons.group_outlined,
                        title: 'Friends & Link',
                        subtitle: 'Manage linked travelers and shared games',
                        accentColor: const Color(0xFF0EA5E9),
                        onTap: openLinkHub,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = user?.displayName ?? 'Traveler';
    final initials = displayName.trim().isNotEmpty
        ? displayName.trim().substring(0, 1).toUpperCase()
        : 'T';

    return ModernPanel(
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              gradient: AppTheme.warmGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                initials,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.lg2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hey, $displayName', style: theme.textTheme.titleLarge),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Ready to make the kilometres fly by?',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'Traveler';
    final friendCode = user?.friendCode ?? '------';
    final createdAt = user?.createdAt;
    final memberSince = createdAt != null
        ? '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}'
        : 'Today';

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _StatChip(
          icon: Icons.person_outline_rounded,
          label: 'You',
          value: displayName,
        ),
        _StatChip(
          icon: Icons.link_rounded,
          label: 'Code',
          value: friendCode,
        ),
        _StatChip(
          icon: Icons.calendar_month_outlined,
          label: 'Since',
          value: memberSince,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: AppTheme.softShadow(blur: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.seed),
          const SizedBox(width: 8),
          Text(
            '$label · ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainMenuActionTile extends StatelessWidget {
  const _MainMenuActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: AppTheme.softShadow(blur: 18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg2,
              vertical: 18,
            ),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: accentColor, size: 26),
                ),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(subtitle, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
