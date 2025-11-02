import 'package:flutter/material.dart';

import '../../styles/game_colors.dart';
import '../../styles/spacing.dart';

class NumberPlateMatchScreen extends StatefulWidget {
  final List<String> players;
  final Map<String, String> playerNumbers;
  final String? sessionId;

  const NumberPlateMatchScreen({
    super.key,
    required this.players,
    required this.playerNumbers,
    this.sessionId,
  });

  @override
  State<NumberPlateMatchScreen> createState() => _NumberPlateMatchScreenState();
}

class _NumberPlateMatchScreenState extends State<NumberPlateMatchScreen> {
  final Map<String, int> _scores = {};
  final List<_PlateEntry> _plateHistory = [];
  final Map<String, int> _numberCounts = {};
  String _mostCommonNumber = "";
  int _mostCommonCount = 0;
  bool _showRules = false;
  final TextEditingController _plateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize scores
    for (var player in widget.players) {
      _scores[player] = 0;
    }
    // Initialize number counts (0-9)
    for (int i = 0; i < 10; i++) {
      _numberCounts[i.toString()] = 0;
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _addScore(String player) {
    setState(() {
      _scores[player] = (_scores[player] ?? 0) + 1;
    });
  }

  void _updateMostCommonNumber() {
    if (_numberCounts.isEmpty) return;

    int maxCount = 0;
    String maxNumber = "";

    _numberCounts.forEach((number, count) {
      if (count > maxCount) {
        maxCount = count;
        maxNumber = number;
      }
    });

    setState(() {
      _mostCommonNumber = maxNumber;
      _mostCommonCount = maxCount;
    });
  }

  void _addPlate(String plate) {
    if (plate.isEmpty) return;

    final lastDigit = plate.characters.last;
    final matchingPlayers = widget.players
        .where((player) => widget.playerNumbers[player] == lastDigit)
        .toList();

    // Update number counts
    _numberCounts[lastDigit] = (_numberCounts[lastDigit] ?? 0) + 1;
    _updateMostCommonNumber();

    setState(() {
      _plateHistory.insert(
          0,
          _PlateEntry(
            plate: plate,
            matchingPlayers: matchingPlayers,
            timestamp: DateTime.now(),
          ));

      // Keep only last 10 plates
      if (_plateHistory.length > 10) {
        _plateHistory.removeLast();
      }

      // Add scores for matching players
      for (var player in matchingPlayers) {
        _addScore(player);
      }
    });

    _plateController.clear();
  }

  Widget _buildPlayerCard(String player) {
    final selectedNumber = widget.playerNumbers[player] ?? 'Not set';

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
            // Avatar and player name
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.1),
                    child: Text(
                      selectedNumber,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: GameColors.primaryColors['numberPlateMatch']!,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md, vertical: Spacing.xs),
                          decoration: BoxDecoration(
                            color: GameColors.primaryColors['numberPlateMatch']!,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Score: ${_scores[player] ?? 0}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildNumberPad() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Spacing.lg),
      margin: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: GameColors.primaryColors['numberPlateMatch']!),
              const SizedBox(width: Spacing.sm),
              const Text(
                'Enter License Plate:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _plateController.text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          // Number pad (0-9 only)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg2),
            child: Column(
              children: [
                // First row: 1 2 3
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildKeypadButton('1'),
                    _buildKeypadButton('2'),
                    _buildKeypadButton('3'),
                  ],
                ),
                const SizedBox(height: Spacing.lg),

                // Second row: 4 5 6
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildKeypadButton('4'),
                    _buildKeypadButton('5'),
                    _buildKeypadButton('6'),
                  ],
                ),
                const SizedBox(height: Spacing.lg),

                // Third row: 7 8 9
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildKeypadButton('7'),
                    _buildKeypadButton('8'),
                    _buildKeypadButton('9'),
                  ],
                ),
                const SizedBox(height: Spacing.lg),

                // Fourth row: 0 and controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildKeypadButton('0'),
                    _buildKeypadButton('⌫', isSpecial: true, onPressed: () {
                      if (_plateController.text.isNotEmpty) {
                        setState(() {
                          _plateController.text = _plateController.text
                              .substring(0, _plateController.text.length - 1);
                        });
                      }
                    }),
                    _buildKeypadButton('✓', isSpecial: true, onPressed: () {
                      if (_plateController.text.isNotEmpty) {
                        _addPlate(_plateController.text);
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String text,
      {bool isSpecial = false, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed ??
          () {
            setState(() {
              _plateController.text += text;
            });
          },
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: isSpecial ? GameColors.primaryColors['numberPlateMatch']! : GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isSpecial ? Colors.white : GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberStats() {
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
          const Text(
            'Number Stats:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // Most common number highlight
          if (_mostCommonNumber.isNotEmpty && _mostCommonCount > 0) ...[
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: GameColors.primaryColors['numberPlateMatch']!,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _mostCommonNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Most Common Digit:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Seen $_mostCommonCount times',
                      style: TextStyle(
                        color: GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
          ],

          // Display all number counts
          const Text(
            'All Number Counts:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 10, // 0-9
            itemBuilder: (context, index) {
              final number = index.toString();
              final count = _numberCounts[number] ?? 0;
              final isHighest = number == _mostCommonNumber && count > 0;

              return Container(
                decoration: BoxDecoration(
                  color: isHighest
                      ? GameColors.primaryColors['numberPlateMatch']!
                      : count > 0
                          ? GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      number,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isHighest
                            ? Colors.white
                            : count > 0
                                ? GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.9)
                                : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: isHighest
                            ? Colors.white
                            : count > 0
                                ? GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.9)
                                : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlateHistory() {
    if (_plateHistory.isEmpty) {
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
            'No plates added yet.\nPlates will appear here when added.',
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
        itemCount: _plateHistory.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = _plateHistory[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.1),
              child: Text(
                entry.plate.characters.last,
                style: TextStyle(
                  color: GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              entry.plate,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              entry.matchingPlayers.isEmpty
                  ? 'No matches'
                  : 'Matches: ${entry.matchingPlayers.join(', ')}',
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
        title: const Text('Number Plate Match'),
        backgroundColor: GameColors.primaryColors['numberPlateMatch']!,
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
              GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.05),
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
                        Icon(Icons.info_outline, color: GameColors.primaryColors['numberPlateMatch']!),
                        SizedBox(width: 8),
                        Text(
                          'How to Play:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: GameColors.primaryColors['numberPlateMatch']!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    _RuleItem(text: 'Each player has picked a number (0-9)'),
                    _RuleItem(text: 'Enter license plates you see on the road'),
                    _RuleItem(
                        text:
                            'If the last digit matches your number, you score a point!'),
                    _RuleItem(
                        text: 'Multiple players can match the same plate'),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Spacing.lg),
                children: [
                  _buildNumberPad(),
                  _buildNumberStats(),

                  // Player score cards in a list
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

                  const SizedBox(height: 24),

                  // Plate history
                  Row(
                    children: [
                      Icon(Icons.history, color: GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.85)),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Recent Plates:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildPlateHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlateEntry {
  final String plate;
  final List<String> matchingPlayers;
  final DateTime timestamp;

  _PlateEntry({
    required this.plate,
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
          Icon(Icons.check_circle, size: 16, color: GameColors.primaryColors['numberPlateMatch']!.withValues(alpha: 0.3)),
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
