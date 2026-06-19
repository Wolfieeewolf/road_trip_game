import 'package:flutter/material.dart';

import '../../styles/game_colors.dart';
import '../../styles/spacing.dart';
import '../../widgets/game_fx.dart';
import '../../widgets/game_shell.dart';

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

  /// Recomputes the most common digit. Must be called inside setState.
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

    _mostCommonNumber = maxNumber;
    _mostCommonCount = maxCount;
  }

  void _addPlate(String plate) {
    if (plate.isEmpty) return;

    final lastDigit = plate.characters.last;
    final matchingPlayers = widget.players
        .where((player) => widget.playerNumbers[player] == lastDigit)
        .toList();

    setState(() {
      // Update number counts
      _numberCounts[lastDigit] = (_numberCounts[lastDigit] ?? 0) + 1;
      _updateMostCommonNumber();

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
        _scores[player] = (_scores[player] ?? 0) + 1;
      }
    });

    final gameColor = GameColors.primaryColors['numberPlateMatch']!;
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

    _plateController.clear();
  }

  Widget _buildPlayerCard(String player, {int? rank, bool isLeader = false}) {
    final gameColor = GameColors.primaryColors['numberPlateMatch']!;
    final selectedNumber = widget.playerNumbers[player] ?? '?';

    return GamePlayerTile(
      name: player,
      score: _scores[player] ?? 0,
      color: gameColor,
      rank: rank,
      isLeader: isLeader,
      subtitle: 'Watching for plates ending in $selectedNumber',
      avatar: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gameColor, Color.lerp(gameColor, Colors.black, 0.2)!],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: gameColor.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            selectedNumber,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    final gameColor = GameColors.primaryColors['numberPlateMatch']!;

    return GamePanel(
      accent: gameColor,
      margin: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: GameSectionTitle(
                  icon: Icons.directions_car_rounded,
                  title: 'Enter a plate',
                  color: gameColor,
                ),
              ),
              // Styled like a real number plate.
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF374151), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(minWidth: 90),
                child: Text(
                  _plateController.text.isEmpty
                      ? '· · ·'
                      : _plateController.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    color: Color(0xFFFBBF24),
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
    final gameColor = GameColors.primaryColors['numberPlateMatch']!;

    return ChunkyButton(
      color: isSpecial ? gameColor : Colors.white,
      depth: 4,
      borderRadius: 14,
      padding: EdgeInsets.zero,
      onTap: onPressed ??
          () {
            setState(() {
              _plateController.text += text;
            });
          },
      child: SizedBox(
        width: 64,
        height: 58,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isSpecial ? Colors.white : gameColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberStats() {
    return GamePanel(
      accent: GameColors.primaryColors['numberPlateMatch'],
      margin: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameSectionTitle(
            icon: Icons.bar_chart_rounded,
            title: 'Number stats',
            color: GameColors.primaryColors['numberPlateMatch']!,
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
                        color: GameColors.primaryColors['numberPlateMatch']!
                            .withValues(alpha: 0.85),
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
                          ? GameColors.primaryColors['numberPlateMatch']!
                              .withValues(alpha: 0.1)
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
                                ? GameColors.primaryColors['numberPlateMatch']!
                                    .withValues(alpha: 0.9)
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
                                ? GameColors.primaryColors['numberPlateMatch']!
                                    .withValues(alpha: 0.9)
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
      return GamePanel(
        accent: GameColors.primaryColors['numberPlateMatch'],
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

    return GamePanel(
      accent: GameColors.primaryColors['numberPlateMatch'],
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _plateHistory.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = _plateHistory[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: GameColors.primaryColors['numberPlateMatch']!
                  .withValues(alpha: 0.1),
              child: Text(
                entry.plate.characters.last,
                style: TextStyle(
                  color: GameColors.primaryColors['numberPlateMatch']!
                      .withValues(alpha: 0.9),
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
    final gameColor = GameColors.primaryColors['numberPlateMatch']!;

    // Rank players by score for medals; display order stays the same.
    final sortedScores = _scores.values.toList()
      ..sort((a, b) => b.compareTo(a));
    final topScore = sortedScores.isEmpty ? 0 : sortedScores.first;
    int rankFor(String player) =>
        sortedScores.indexOf(_scores[player] ?? 0) + 1;

    return GameShell(
      title: 'Number Plate Match',
      subtitle: 'Last digit wins the point!',
      color: gameColor,
      icon: Icons.pin_rounded,
      onHelp: () => setState(() => _showRules = !_showRules),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          GameRulesCard(
            visible: _showRules,
            color: gameColor,
            rules: const [
              'Each player has picked a number (0-9)',
              'Enter license plates you see on the road',
              'If the last digit matches your number, you score a point!',
              'Multiple players can match the same plate',
            ],
          ),
          FadeSlideIn(child: _buildNumberPad()),
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: _buildNumberStats(),
          ),

          // Player score cards in a list
          ...widget.players.toList().asMap().entries.map((entry) {
            final player = entry.value;
            final score = _scores[player] ?? 0;
            return FadeSlideIn(
              delay: Duration(milliseconds: 80 * (entry.key + 2)),
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

          // Plate history
          GameSectionTitle(
            icon: Icons.history_rounded,
            title: 'Recent plates',
            color: gameColor,
          ),
          const SizedBox(height: Spacing.md),
          _buildPlateHistory(),
        ],
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
