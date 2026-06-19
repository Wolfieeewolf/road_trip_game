import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/car/car_scoreboard.dart';
import '../services/link/link_controller.dart';
import '../services/link/link_session.dart';
import '../styles/spacing.dart';

enum GameType {
  numberPlateMatch,
  soundSpy,
  windmill,
}

class GameScoreBoard extends StatefulWidget {
  const GameScoreBoard({
    super.key,
    required this.gameType,
    required this.scores,
    required this.onScoreIncrement,
    this.onScoreDecrement,
    this.additionalInfo,
    this.customAction,
    this.showTotalScore = false,
  });

  final GameType gameType;
  final Map<String, int> scores;
  final Map<String, dynamic>? additionalInfo;
  final Function(String) onScoreIncrement;
  final Function(String)? onScoreDecrement;
  final Widget? customAction;
  final bool showTotalScore;

  @override
  State<GameScoreBoard> createState() => _GameScoreBoardState();
}

class _GameScoreBoardState extends State<GameScoreBoard> {
  Map<String, int> _lastPushedScores = const {};

  Color _getGameColor() {
    switch (widget.gameType) {
      case GameType.numberPlateMatch:
        return Colors.purple;
      case GameType.soundSpy:
        return Colors.green;
      case GameType.windmill:
        return Colors.orange;
    }
  }

  IconData _getGameIcon() {
    switch (widget.gameType) {
      case GameType.numberPlateMatch:
        return Icons.format_list_numbered;
      case GameType.soundSpy:
        return Icons.volume_up;
      case GameType.windmill:
        return Icons.wind_power;
    }
  }

  void _syncScores(BuildContext context) {
    CarScoreboardController? scoreboard;
    LinkController? linkController;
    try {
      scoreboard = context.read<CarScoreboardController>();
    } catch (_) {
      scoreboard = null;
    }
    if (scoreboard == null) return;

    try {
      linkController = context.read<LinkController>();
    } catch (_) {
      linkController = null;
    }

    final resolvedScores = _resolveScores(linkController?.session);
    if (mapEquals(_lastPushedScores, resolvedScores)) {
      return;
    }

    _lastPushedScores = Map<String, int>.unmodifiable(resolvedScores);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scoreboard?.updateScores(resolvedScores);
    });
  }

  Map<String, int> _resolveScores(LinkSession? session) {
    if (session == null) {
      return const {};
    }

    final buckets = <String, List<String>>{};
    for (final participant in session.sortedParticipants) {
      final key = participant.displayName.toLowerCase();
      buckets.putIfAbsent(key, () => <String>[]).add(participant.id);
    }

    final usage = <String, int>{};
    final resolved = <String, int>{};

    widget.scores.forEach((name, score) {
      final normalized = name.toLowerCase();
      final bucket = buckets[normalized];
      if (bucket == null || bucket.isEmpty) {
        return;
      }
      final index =
          usage.update(normalized, (value) => value + 1, ifAbsent: () => 0);
      if (index < bucket.length) {
        resolved[bucket[index]] = score;
      }
    });

    return resolved;
  }

  Widget _buildPlayerCard(String player, int score) {
    final gameColor = _getGameColor();

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gameColor.withValues(alpha: 0.1),
              gameColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    player,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.additionalInfo != null &&
                    widget.additionalInfo![player] != null)
                  _buildAdditionalInfo(player),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              score.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: gameColor,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.onScoreDecrement != null)
                  _ScoreButton(
                    onPressed: () => widget.onScoreDecrement!(player),
                    icon: Icons.remove,
                    label: '-1',
                    color: gameColor,
                  ),
                _ScoreButton(
                  onPressed: () => widget.onScoreIncrement(player),
                  icon: Icons.add,
                  label: '+1',
                  color: gameColor,
                ),
                if (widget.customAction != null) widget.customAction!,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(String player) {
    switch (widget.gameType) {
      case GameType.numberPlateMatch:
        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.additionalInfo![player].toString(),
            style: TextStyle(
              color: Colors.purple.withValues(alpha: 0.95),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case GameType.soundSpy:
        return _buildSoundSpyInfo(player);
      case GameType.windmill:
        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${widget.additionalInfo![player]} streak',
            style: TextStyle(
              color: Colors.orange.withValues(alpha: 0.95),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  Widget _buildSoundSpyInfo(String player) {
    final info = widget.additionalInfo![player] as Map<String, String>;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            info['sound']!,
            style: TextStyle(
              color: Colors.green.withValues(alpha: 0.95),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncScores(context);
    return Column(
      children: [
        if (widget.showTotalScore)
          Card(
            child: Container(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getGameIcon(), color: _getGameColor()),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    'Total: ${widget.scores.values.fold(0, (sum, score) => sum + score)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getGameColor(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: Spacing.lg,
            mainAxisSpacing: Spacing.lg,
          ),
          itemCount: widget.scores.length,
          itemBuilder: (context, index) {
            final player = widget.scores.keys.elementAt(index);
            return _buildPlayerCard(player, widget.scores[player]!);
          },
        ),
      ],
    );
  }
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }
}
