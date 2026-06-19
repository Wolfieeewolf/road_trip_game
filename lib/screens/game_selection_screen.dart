import 'package:flutter/material.dart';

import '../styles/app_theme.dart';
import '../styles/spacing.dart';
import '../widgets/app_background.dart';
import '../widgets/game_fx.dart';
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
          return FadeTransition(opacity: animation, child: child);
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
      icon: Icons.format_list_numbered_rounded,
      color: Color(0xFF7C3AED),
    ),
    Game(
      id: 'soundSpy',
      name: 'Sound Spy',
      description: 'Make sounds when you spot your chosen objects.',
      icon: Icons.hearing_rounded,
      color: Color(0xFF10B981),
    ),
    Game(
      id: 'windmill',
      name: 'Windmill Count',
      description: 'Count windmills along your journey.',
      icon: Icons.wind_power_rounded,
      color: Color(0xFFF59E0B),
    ),
    Game(
      id: 'roadTripBingo',
      name: 'Road Trip Bingo',
      description: 'Find road trip sights to complete your bingo card.',
      icon: Icons.grid_view_rounded,
      color: Color(0xFFEC4899),
    ),
    Game(
      id: 'colorChase',
      name: 'Colour Chase',
      description: 'Compete to spot cars of specific colours.',
      icon: Icons.palette_rounded,
      color: Color(0xFF3B82F6),
    ),
    Game(
      id: 'signScramble',
      name: 'Sign Scramble',
      description: 'Pick road signs to spot and earn points.',
      icon: Icons.traffic_rounded,
      color: Color(0xFF14B8A6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: true,
              backgroundColor: AppTheme.canvas.withValues(alpha: 0.92),
              surfaceTintColor: Colors.transparent,
              title: const Text('Choose a game'),
              leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: Spacing.lg),
                  child: _FeaturedBadge(),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.xl,
                  0,
                  Spacing.xl,
                  Spacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Six games built for back-seat fun and front-seat focus.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.inkMuted,
                      ),
                    ),
                    const SizedBox(height: Spacing.xl),
                    const _GameLegend(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xl,
                0,
                Spacing.xl,
                Spacing.xxl,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 340,
                  mainAxisSpacing: Spacing.lg2,
                  crossAxisSpacing: Spacing.lg2,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = games[index];
                    return FadeSlideIn(
                      delay: Duration(milliseconds: 70 * index),
                      child: _GameCard(
                        game: game,
                        onOpen: () => _openGame(context, game),
                      ),
                    );
                  },
                  childCount: games.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameLegend extends StatelessWidget {
  const _GameLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: AppTheme.softShadow(blur: 14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.seed),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.ink,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.warmGradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            '6 games',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatefulWidget {
  const _GameCard({
    required this.game,
    required this.onOpen,
  });

  final Game game;
  final VoidCallback onOpen;

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _pressed = false;

  Game get game => widget.game;
  VoidCallback get onOpen => widget.onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Hero(
      tag: 'game-${game.id}',
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onOpen,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: AppTheme.softShadow(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: game.color,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.lg2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: game.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(game.icon, color: game.color, size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text(game.name, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              game.description,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Play',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: game.color,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: game.color,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
