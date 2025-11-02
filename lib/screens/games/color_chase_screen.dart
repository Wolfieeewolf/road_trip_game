import 'dart:math';

import 'package:flutter/material.dart';

import '../../styles/game_colors.dart';
import '../../styles/spacing.dart';

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

  void _addScore(String player) {
    setState(() {
      _scores[player] = (_scores[player] ?? 0) + 1;
    });
  }

  void _spotColor(String colorName) {
    // Update the color counts
    _colorCounts[colorName] = (_colorCounts[colorName] ?? 0) + 1;

    // Find players who have this color
    final matchingPlayers = widget.players
        .where((player) => widget.playerColors[player] == colorName)
        .toList();

    setState(() {
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
        _addScore(player);
      }
    });
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

  Widget _buildPlayerCard(String player) {
    final selectedColor = widget.playerColors[player] ?? 'Not set';
    final displayColor = _colorMap[selectedColor] ?? Colors.grey;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          children: [
            // Color circle and player name
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: displayColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          selectedColor,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Score display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: GameColors.primaryColors['colorChase']!,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_scores[player] ?? 0}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Spacing.lg),
      margin: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: GameColors.primaryColors['colorChase']),
              SizedBox(width: Spacing.sm),
              Text(
                'Tap When You Spot a Car:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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

              return InkWell(
                onTap: () => _spotColor(colorName),
                child: Stack(
                  children: [
                    // Car icon with color background
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                          border: isLightColor
                              ? Border.all(color: Colors.grey.shade300)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 2),
                            )
                          ]),
                      child: Center(
                        child: Icon(
                          Icons.directions_car,
                          // Make the icon white when background is black
                          color: color == Colors.black
                              ? Colors.white
                              : Colors.black54,
                          size: 35,
                        ),
                      ),
                    ),

                    // Color name and count
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(10),
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

                    // Count display below car
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: GameColors.primaryColors['colorChase']!.withValues(alpha: 0.8),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            count > 0 ? count.toString() : '0',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
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
                icon: Icon(Icons.add_circle, color: GameColors.primaryColors['colorChase']),
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
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colour Chase'),
        backgroundColor: GameColors.primaryColors['colorChase'],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              setState(() {
                _showRules = !_showRules;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GameColors.primaryColors['colorChase']!.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            if (_showRules)
              Container(
                margin: const EdgeInsets.all(Spacing.lg),
                padding: const EdgeInsets.all(Spacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: GameColors.primaryColors['colorChase']),
                        const SizedBox(width: Spacing.sm),
                        Text(
                          'How to Play:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: GameColors.primaryColors['colorChase']!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    _RuleItem(
                        text: 'Each player has chosen a car color to spot'),
                    _RuleItem(
                        text:
                            'When you see a car of that color, tap the color button'),
                    _RuleItem(
                        text:
                            'Players get a point when their color is spotted'),
                    _RuleItem(
                        text:
                            'Track which colors are most common on your journey!'),
                    _RuleItem(
                        text:
                            'Add custom colors by typing them in the field below'),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Spacing.lg),
                children: [
                  _buildColorButtons(),
                  // Color stats removed and integrated into color buttons

                  // Player score cards
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.players.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.md),
                        child: _buildPlayerCard(widget.players[index]),
                      );
                    },
                  ),

                  const SizedBox(height: Spacing.xl),

                  // Spot history
                  Row(
                    children: [
                      Icon(Icons.history, color: GameColors.primaryColors['colorChase']),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Recent Spots:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: GameColors.primaryColors['colorChase']!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildSpotHistory(),
                ],
              ),
            ),
          ],
        ),
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

class _RuleItem extends StatelessWidget {
  final String text;

  const _RuleItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: GameColors.primaryColors['colorChase']),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
