import 'package:flutter/material.dart';

import '../../styles/game_colors.dart';
import '../../styles/spacing.dart';
import '../../widgets/game_fx.dart';
import '../../widgets/game_shell.dart';

class SignScrambleScreen extends StatefulWidget {
  final List<String> players;
  final Map<String, List<String>> playerSigns;
  final String? sessionId;

  const SignScrambleScreen({
    super.key,
    required this.players,
    required this.playerSigns,
    this.sessionId,
  });

  @override
  State<SignScrambleScreen> createState() => _SignScrambleScreenState();
}

class _SignScrambleScreenState extends State<SignScrambleScreen> {
  final Map<String, int> _scores = {};
  final List<_SignSpotEntry> _history = [];
  final Map<String, Set<String>> _spottedByPlayer = {};
  final Set<String> _celebratedWinners = {};
  bool _showRules = false;

  @override
  void initState() {
    super.initState();
    for (final p in widget.players) {
      _scores[p] = 0;
      _spottedByPlayer[p] = <String>{};
    }
  }

  void _spot(String sign) {
    final impacted = <String>[];
    for (final p in widget.players) {
      final targets = widget.playerSigns[p] ?? const [];
      if (targets.contains(sign) && !_spottedByPlayer[p]!.contains(sign)) {
        _spottedByPlayer[p]!.add(sign);
        _scores[p] = (_scores[p] ?? 0) + 1;
        impacted.add(p);
      }
    }
    if (impacted.isEmpty) return;
    setState(() {
      _history.insert(
          0,
          _SignSpotEntry(
              sign: sign, players: impacted, timestamp: DateTime.now()));
    });

    final gameColor = GameColors.primaryColors['signScramble']!;
    for (final player in impacted) {
      final targets = widget.playerSigns[player] ?? const [];
      final hasWon = targets.isNotEmpty &&
          _spottedByPlayer[player]!.length >= targets.length;
      if (hasWon && !_celebratedWinners.contains(player)) {
        _celebratedWinners.add(player);
        GameFx.celebrate(
          context,
          message: '$player found them all!',
          color: gameColor,
        );
      } else {
        GameFx.scoreFloat(context, text: '+1 $player', color: gameColor);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameColor = GameColors.primaryColors['signScramble']!;

    return GameShell(
      title: 'Sign Scramble',
      subtitle: 'Find every sign on your list!',
      color: gameColor,
      icon: Icons.signpost_rounded,
      onHelp: () => setState(() => _showRules = !_showRules),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          GameRulesCard(
            visible: _showRules,
            color: gameColor,
            rules: const [
              'Each player chooses an Australian road sign to look for.',
              'When someone spots their sign, tap Spotted! to earn a point.',
            ],
          ),
          // Quick spot from all chosen signs
          FadeSlideIn(child: _buildSpottingPanel()),
          const SizedBox(height: Spacing.lg),
          ...widget.players.toList().asMap().entries.map(
                (entry) => FadeSlideIn(
                  delay: Duration(milliseconds: 80 * (entry.key + 1)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.md),
                    child: _buildPlayerCard(entry.value),
                  ),
                ),
              ),
          const SizedBox(height: Spacing.lg),
          GameSectionTitle(
            icon: Icons.history_rounded,
            title: 'Spot history',
            color: gameColor,
          ),
          const SizedBox(height: Spacing.sm),
          if (_history.isEmpty)
            GamePanel(
              accent: gameColor,
              child: Center(
                child: Text(
                  'Nothing spotted yet — eyes on the road signs!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ..._history.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: GamePanel(
                accent: gameColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm2,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: gameColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.signpost_outlined,
                          color: gameColor, size: 20),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.sign,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Spotted by: ${e.players.join(', ')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(String player) {
    final gameColor = GameColors.primaryColors['signScramble']!;
    final targets = widget.playerSigns[player] ?? const <String>[];
    final spotted = _spottedByPlayer[player] ?? const <String>{};
    final score = _scores[player] ?? 0;
    final hasWon = targets.isNotEmpty && spotted.length >= targets.length;

    return GamePanel(
      accent: hasWon ? const Color(0xFFFFC107) : gameColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gameColor,
                      Color.lerp(gameColor, Colors.black, 0.2)!,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    player.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${spotted.length}/${targets.length} signs found',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gameColor,
                      Color.lerp(gameColor, Colors.black, 0.2)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScorePop(
                      value: score,
                      popColor: Colors.amber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      ' pts',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasWon) ...[
                const SizedBox(width: 8),
                const PulseGlow(
                  child: Text('🏆', style: TextStyle(fontSize: 24)),
                ),
              ],
            ],
          ),
          const SizedBox(height: Spacing.md),
          // Progress toward finding all signs.
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              tween: Tween(
                end: targets.isEmpty ? 0 : spotted.length / targets.length,
              ),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: gameColor.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(
                  hasWon ? const Color(0xFFFFC107) : gameColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: targets.map((s) {
              final gotIt = spotted.contains(s);
              return BouncyTap(
                pressedScale: 0.9,
                onTap: () => _spot(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        gotIt ? gameColor : gameColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color:
                          gotIt ? gameColor : gameColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (gotIt) ...[
                        const Icon(Icons.check_rounded,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        s,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: gotIt ? Colors.white : gameColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpottingPanel() {
    final gameColor = GameColors.primaryColors['signScramble']!;
    final allSigns = widget.playerSigns.values.expand((e) => e).toSet().toList()
      ..sort();

    return GamePanel(
      accent: gameColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameSectionTitle(
            icon: Icons.visibility_rounded,
            title: 'Spot a sign',
            color: gameColor,
          ),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: allSigns
                .map((name) => ChunkyButton(
                      color: gameColor,
                      onTap: () => _spot(name),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SignSpotEntry {
  final String sign;
  final List<String> players;
  final DateTime timestamp;
  _SignSpotEntry(
      {required this.sign, required this.players, required this.timestamp});
}
