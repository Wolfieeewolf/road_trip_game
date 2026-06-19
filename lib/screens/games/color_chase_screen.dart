import 'dart:math';

import 'package:flutter/material.dart';

import '../../styles/game_colors.dart';
import '../../styles/spacing.dart';
import '../../widgets/game_fx.dart';
import '../../widgets/game_shell.dart';

class ColorChaseScreen extends StatefulWidget {
  final List<String> players;
  final Map<String, String> playerColors;
  final String? sessionId;

  const ColorChaseScreen({
    super.key,
    required this.players,
    required this.playerColors,
    this.sessionId,
  });

  @override
  State<ColorChaseScreen> createState() => _ColorChaseScreenState();
}

class _ColorChaseScreenState extends State<ColorChaseScreen> {
  final Map<String, int> _scores = {};
  final List<_ColorSpotEntry> _spotHistory = [];
  final Map<String, int> _colorCounts = {};
  bool _showRules = false;
  String _customColorName = "";

  // Available colors and their display values
  final Map<String, Color> _colorMap = {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.amber,
    'Black': Colors.black,
    'White': Colors.white,
    'Silver': Colors.grey.shade300,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Brown': Colors.brown,
    'Pink': Colors.pink,
  };

  @override
  void initState() {
    super.initState();
    // Initialize scores
    for (var player in widget.players) {
      _scores[player] = 0;
    }

    // Initialize color counts
    for (var color in _colorMap.keys) {
      _colorCounts[color] = 0;
    }
  }

  void _spotColor(String colorName) {
    // Find players who have this color
    final matchingPlayers = widget.players
        .where((player) => widget.playerColors[player] == colorName)
        .toList();

    setState(() {
      // Update the color counts
      _colorCounts[colorName] = (_colorCounts[colorName] ?? 0) + 1;

      // Add to history
      _spotHistory.insert(
          0,
          _ColorSpotEntry(
            color: colorName,
            matchingPlayers: matchingPlayers,
            timestamp: DateTime.now(),
          ));

      // Limit history
      if (_spotHistory.length > 15) {
        _spotHistory.removeLast();
      }

      // Add scores for matching players
      for (var player in matchingPlayers) {
        _scores[player] = (_scores[player] ?? 0) + 1;
      }
    });

    final gameColor = GameColors.primaryColors['colorChase']!;
    for (final player in matchingPlayers) {
      GameFx.scoreFloat(context, text: '+1 $player', color: gameColor);
      final score = _scores[player] ?? 0;
      if (score > 0 && score % 10 == 0) {
        GameFx.celebrate(
          context,
          message: '$player hits $score!',
          color: gameColor,
        );
      }
    }
  }

  void _addCustomColor() {
    if (_customColorName.isEmpty) return;

    final colorName = _customColorName.trim();
    if (!_colorMap.containsKey(colorName)) {
      setState(() {
        // Add a random color for the new color name
        final randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt())
            .withValues(alpha: 1.0);
        _colorMap[colorName] = randomColor;
        _colorCounts[colorName] = 0;
      });
    }

    _customColorName = "";
  }

  Widget _buildPlayerCard(String player, {int? rank, bool isLeader = false}) {
    final selectedColor = widget.playerColors[player] ?? 'Not set';
    final displayColor = _colorMap[selectedColor] ?? Colors.grey;

    return GamePlayerTile(
      name: player,
      score: _scores[player] ?? 0,
      color: GameColors.primaryColors['colorChase']!,
      rank: rank,
      isLeader: isLeader,
      subtitle: 'Chasing $selectedColor cars',
      avatar: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: displayColor.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.directions_car_rounded,
            color: Colors.black38, size: 22),
      ),
    );
  }

  Widget _buildColorButtons() {
    return GamePanel(
      accent: GameColors.primaryColors['colorChase'],
      margin: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameSectionTitle(
            icon: Icons.directions_car_rounded,
            title: 'Tap when you spot a car',
            color: GameColors.primaryColors['colorChase']!,
          ),
          const SizedBox(height: Spacing.lg),

          // Car color buttons
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: _colorMap.entries.map((entry) {
              final colorName = entry.key;
              final color = entry.value;
              final count = _colorCounts[colorName] ?? 0;
              final isLightColor = _isLightColor(color);

              return BouncyTap(
                pressedScale: 0.85,
                onTap: () => _spotColor(colorName),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Car icon with color background and a chunky 3D edge
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(14),
                        border: isLightColor
                            ? Border.all(color: Colors.grey.shade300)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Color.lerp(color, Colors.black, 0.35)!,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.directions_car,
                          // Make the icon white when background is black
                          color: color == Colors.black
                              ? Colors.white
                              : Colors.black54,
                          size: 32,
                        ),
                      ),
                    ),

                    // Color name strip
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(14),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            colorName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Spot count badge
                    if (count > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: GameColors.primaryColors['colorChase']!,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),

          // Add custom color section
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: Spacing.sm),

          TextField(
            decoration: InputDecoration(
              labelText: 'Add a custom color',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'e.g., Turquoise, Maroon, etc.',
              suffixIcon: IconButton(
                icon: Icon(Icons.add_circle,
                    color: GameColors.primaryColors['colorChase']),
                onPressed: _addCustomColor,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _customColorName = value;
              });
            },
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _customColorName = value;
                _addCustomColor();
              }
            },
          ),
        ],
      ),
    );
  }

  bool _isLightColor(Color color) {
    return color == Colors.white ||
        color == Colors.yellow ||
        color == Colors.grey.shade300;
  }

  Widget _buildSpotHistory() {
    if (_spotHistory.isEmpty) {
      return GamePanel(
        accent: GameColors.primaryColors['colorChase'],
        padding: const EdgeInsets.all(Spacing.lg2),
        child: const Center(
          child: Text(
            'No cars spotted yet.\nStart spotting colored cars!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return GamePanel(
      accent: GameColors.primaryColors['colorChase'],
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _spotHistory.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = _spotHistory[index];
          final displayColor = _colorMap[entry.color] ?? Colors.grey;

          return ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: displayColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            title: Text(
              entry.color,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              entry.matchingPlayers.isEmpty
                  ? 'No matches'
                  : 'Points: ${entry.matchingPlayers.join(', ')}',
            ),
            trailing: Text(
              _formatTimestamp(entry.timestamp),
              style: const TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gameColor = GameColors.primaryColors['colorChase']!;

    // Rank players by score for medals; display order stays the same.
    final sortedScores = _scores.values.toList()
      ..sort((a, b) => b.compareTo(a));
    final topScore = sortedScores.isEmpty ? 0 : sortedScores.first;
    int rankFor(String player) =>
        sortedScores.indexOf(_scores[player] ?? 0) + 1;

    return GameShell(
      title: 'Colour Chase',
      subtitle: 'Spot your colour, score a point!',
      color: gameColor,
      icon: Icons.palette_rounded,
      onHelp: () => setState(() => _showRules = !_showRules),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          GameRulesCard(
            visible: _showRules,
            color: gameColor,
            rules: const [
              'Each player has chosen a car color to spot',
              'When you see a car of that color, tap the color button',
              'Players get a point when their color is spotted',
              'Track which colors are most common on your journey!',
              'Add custom colors by typing them in the field below',
            ],
          ),
          FadeSlideIn(child: _buildColorButtons()),

          // Player score cards
          ...widget.players.toList().asMap().entries.map((entry) {
            final player = entry.value;
            final score = _scores[player] ?? 0;
            return FadeSlideIn(
              delay: Duration(milliseconds: 80 * (entry.key + 1)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: Spacing.md),
                child: _buildPlayerCard(
                  player,
                  rank: rankFor(player),
                  isLeader: topScore > 0 && score == topScore,
                ),
              ),
            );
          }),

          const SizedBox(height: Spacing.lg),

          // Spot history
          GameSectionTitle(
            icon: Icons.history_rounded,
            title: 'Recent spots',
            color: gameColor,
          ),
          const SizedBox(height: Spacing.md),
          _buildSpotHistory(),
        ],
      ),
    );
  }
}

class _ColorSpotEntry {
  final String color;
  final List<String> matchingPlayers;
  final DateTime timestamp;

  _ColorSpotEntry({
    required this.color,
    required this.matchingPlayers,
    required this.timestamp,
  });
}
