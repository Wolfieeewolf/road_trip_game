import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth/auth_controller.dart';
import '../services/auth/auth_user.dart';
import '../styles/spacing.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Road Trip Games'),
            actions: [
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: openSettings,
              ),
            ],
            expandedHeight: 220,
            automaticallyImplyLeading: false,
            flexibleSpace: const FlexibleSpaceBar(
              background: _MainMenuBackdrop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.xl, 0, Spacing.xl, Spacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileCard(user: user),
                  const SizedBox(height: Spacing.xl),
                  _QuickStatsRow(user: user),
                  const SizedBox(height: Spacing.xxl),
                  Text(
                    "Let's play",
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: Spacing.lg),
                  FilledButton.icon(
                    onPressed: openGameSelection,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start a game'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                  const SizedBox(height: Spacing.xxl),
                  Text(
                    'Explore',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: Spacing.lg),
                  _MainMenuActionTile(
                    icon: Icons.grid_view_rounded,
                    title: 'Game library',
                    subtitle: 'Browse challenges for every passenger',
                    accentColor: colorScheme.primary,
                    onTap: openGameSelection,
                  ),
                  const SizedBox(height: Spacing.md),
                  _MainMenuActionTile(
                    icon: Icons.emoji_events_outlined,
                    title: 'Achievements',
                    subtitle: 'Celebrate milestones along the journey',
                    accentColor: colorScheme.secondary,
                    onTap: openAchievements,
                  ),
                  const SizedBox(height: Spacing.md),
                  _MainMenuActionTile(
                    icon: Icons.insights_rounded,
                    title: 'Statistics',
                    subtitle: 'Track scores and progress over time',
                    accentColor: colorScheme.tertiary,
                    onTap: openStatistics,
                  ),
                  const SizedBox(height: Spacing.md),
                  _MainMenuActionTile(
                    icon: Icons.group_outlined,
                    title: 'Friends & Link',
                    subtitle: 'Manage linked travelers and shared games',
                    accentColor: colorScheme.secondaryContainer,
                    onTap: openLinkHub,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainMenuBackdrop extends StatelessWidget {
  const _MainMenuBackdrop();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.25),
            colorScheme.secondary.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 36,
            left: 24,
            child: _BackdropBadge(
              icon: Icons.route,
              color: colorScheme.primary,
            ),
          ),
          Positioned(
            bottom: 30,
            right: 40,
            child: _BackdropBadge(
              icon: Icons.alt_route,
              color: colorScheme.secondary,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            child: Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.directions_car_rounded,
                size: 56,
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropBadge extends StatelessWidget {
  const _BackdropBadge({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        color: color.withValues(alpha: 0.7),
        size: 30,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
  });

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayName = user?.displayName ?? 'Traveler';
    final initials = displayName.trim().isNotEmpty
        ? displayName.trim().substring(0, 1).toUpperCase()
        : 'T';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Spacing.lg2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey $displayName 👋',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'Ready to make the kilometres fly by?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({
    required this.user,
  });

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
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatChip(
          icon: Icons.person_outline,
          label: 'Logged in as',
          value: displayName,
        ),
        _StatChip(
          icon: Icons.link_rounded,
          label: 'Friend code',
          value: friendCode,
        ),
        _StatChip(
          icon: Icons.calendar_month_outlined,
          label: 'Member since',
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
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            '$label · ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
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
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        splashColor: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg2, vertical: 18),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
