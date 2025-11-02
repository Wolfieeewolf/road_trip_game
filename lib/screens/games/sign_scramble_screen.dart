import 'package:flutter/material.dart';

import '../../styles/game_colors.dart';
import '../../styles/spacing.dart';

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
      _history.insert(0, _SignSpotEntry(sign: sign, players: impacted, timestamp: DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Scramble'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => setState(() => _showRules = !_showRules),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          if (_showRules)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('How to Play:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Each player chooses an Australian road sign to look for.'),
                    Text('When someone spots their sign, tap Spotted! to earn a point.'),
                  ],
                ),
              ),
            ),
          // Quick spot from all chosen signs
          _buildSpottingPanel(),
          const SizedBox(height: Spacing.lg),
          ...widget.players.map(_buildPlayerCard),
          const SizedBox(height: Spacing.xl),
          const Text('Spot History', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._history.map((e) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(e.sign),
                subtitle: Text('Spotted by: ${e.players.join(', ')}'),
              )),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(String player) {
    final targets = widget.playerSigns[player] ?? const <String>[];
    final spotted = _spottedByPlayer[player] ?? const <String>{};
    final score = _scores[player] ?? 0;
    final hasWon = targets.isNotEmpty && spotted.length >= targets.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(player.substring(0, 1).toUpperCase())),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    player,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GameColors.primaryColors['signScramble']!.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$score pts', style: TextStyle(fontWeight: FontWeight.bold, color: GameColors.primaryColors['signScramble']!)),
                ),
                const SizedBox(width: 8),
                if (hasWon)
                  const Chip(label: Text('WINNER'), backgroundColor: Colors.amber),
              ],
            ),
            const SizedBox(height: Spacing.md),
            const Text('Your signs:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: Spacing.sm2),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: targets.map((s) {
                final gotIt = spotted.contains(s);
                return InputChip(
                  label: Text(s),
                  selected: gotIt,
                  onSelected: (_) => _spot(s),
                  selectedColor: Colors.green.shade200,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpottingPanel() {
    final allSigns = widget.playerSigns.values.expand((e) => e).toSet().toList()..sort();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spot a sign:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allSigns
                  .map((name) => ElevatedButton(
                        onPressed: () => _spot(name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.primaryColors['signScramble']!.withValues(alpha: 0.05),
                          foregroundColor: GameColors.primaryColors['signScramble']!.withValues(alpha: 0.85),
                        ),
                        child: Text(name),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignSpotEntry {
  final String sign;
  final List<String> players;
  final DateTime timestamp;
  _SignSpotEntry({required this.sign, required this.players, required this.timestamp});
}
