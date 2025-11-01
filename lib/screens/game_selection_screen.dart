import 'package:flutter/material.dart';

import '../styles/game_colors.dart';
import '../styles/spacing.dart';
import '../utils/game_constants.dart';
import 'games/game_setup_screen.dart';

class Game {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const Game({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  void _openGame(BuildContext context, Game game) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameSetupScreen(gameId: game.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  static const List<Game> games = [
    Game(
      id: 'numberPlateMatch',
      name: 'Number Plate Match',
      description: 'Pick your lucky number and spot matching plates.',
      icon: Icons.format_list_numbered,
      color: Color(0xFF7C4DFF),
    ),
    Game(
      id: 'soundSpy',
      name: 'Sound Spy',
      description: 'Make sounds when you spot your chosen objects.',
      icon: Icons.hearing,
      color: Color(0xFF4CAF50),
    ),
    Game(
      id: 'windmill',
      name: 'Windmill Count',
      description: 'Count windmills along your journey.',
      icon: Icons.wind_power,
      color: Color(0xFFFFB74D),
    ),
    Game(
      id: 'roadTripBingo',
      name: 'Road Trip Bingo',
      description: 'Find road trip sights to complete your bingo card.',
      icon: Icons.grid_4x4,
      color: Color(0xFFE040FB),
    ),
    Game(
      id: 'colorChase',
      name: 'Colour Chase',
      description: 'Compete to spot cars of specific colours.',
      icon: Icons.palette,
      color: Color(0xFF3F51B5),
    ),
    Game(
      id: 'signScramble',
      name: 'Sign Scramble',
      description: 'Pick road signs to spot and earn points.',
      icon: Icons.traffic,
      color: Color(0xFF009688),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Choose a game'),
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: const [
              _FeaturedBadge(),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.xl, 0, Spacing.xl, Spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start something fresh or revisit a favourite. Each game is tailored for the kilometres ahead.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: Spacing.xl),
                  const _GameLegend(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Spacing.xl, 0, Spacing.xl, Spacing.xxl),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisSpacing: Spacing.lg2,
                crossAxisSpacing: Spacing.lg2,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final game = games[index];
                  return _GameCard(
                    game: game,
                    onOpen: () => _openGame(context, game),
                  );
                },
                childCount: games.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameLegend extends StatelessWidget {
  const _GameLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _LegendChip(
          icon: Icons.family_restroom_outlined,
          label: 'Family friendly',
        ),
        _LegendChip(
          icon: Icons.timer_outlined,
          label: '< 15 mins',
        ),
        _LegendChip(
          icon: Icons.people_alt_outlined,
          label: 'Group play',
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md3, vertical: Spacing.md2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: Spacing.lg),
      child: Chip(
        avatar: Icon(
          Icons.auto_awesome,
          color: colorScheme.onPrimaryContainer,
          size: 18,
        ),
        label: Text(
          'New modes',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
        ),
        backgroundColor: colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.onOpen,
  });

  final Game game;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Hero(
      tag: 'game-${game.id}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: game.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    game.icon,
                    color: game.color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  game.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Expanded(
                  child: Text(
                    game.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play'),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
