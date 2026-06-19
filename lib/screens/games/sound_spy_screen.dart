import 'package:flutter/material.dart';

import '../../services/audio/game_sound_player.dart';
import '../../styles/game_colors.dart';
import '../../styles/spacing.dart';
import '../../widgets/game_fx.dart';
import '../../widgets/game_shell.dart';

class SoundSpyScreen extends StatefulWidget {
  final List<String> players;
  final Map<String, String> playerSounds;
  final Map<String, String> spyObjects;
  final String? sessionId;

  const SoundSpyScreen({
    super.key,
    required this.players,
    required this.playerSounds,
    required this.spyObjects,
    this.sessionId,
  });

  @override
  State<SoundSpyScreen> createState() => _SoundSpyScreenState();
}

class _SoundSpyScreenState extends State<SoundSpyScreen> {
  final Map<String, int> _scores = {};
  final Map<String, int> _guessScores = {};
  final List<_SpyEvent> _eventHistory = [];
  final GameSoundPlayer _soundPlayer = GameSoundPlayer();
  bool _showRules = false;

  // Sound mapping
  static const String _defaultSoundAsset = 'sounds/beep.mp3';
  final Map<String, String> _soundFiles = const {
    'Beep': 'sounds/beep.mp3',
    'Moo': 'sounds/moo.mp3',
    'Baa': 'sounds/baa.mp3',
    'Squeak': 'sounds/squeak.mp3',
    'Honk': 'sounds/honk.mp3',
    'Woof': 'sounds/woof.mp3',
    'Meow': 'sounds/meow.mp3',
    'Roar': 'sounds/roar.mp3',
  };

  final Map<String, IconData> _soundIcons = const {
    'Beep': Icons.music_note,
    'Moo': Icons.agriculture,
    'Baa': Icons.radar,
    'Squeak': Icons.hearing,
    'Honk': Icons.directions_bus,
    'Woof': Icons.pets,
    'Meow': Icons.tag_faces,
    'Roar': Icons.auto_awesome,
  };

  @override
  void initState() {
    super.initState();
    // Initialize scores
    for (var player in widget.players) {
      _scores[player] = 0;
      _guessScores[player] = 0;
    }
  }

  @override
  void dispose() {
    _soundPlayer.dispose();
    super.dispose();
  }

  String? _assetKeyForSelection(String? selection) {
    if (selection == null || selection.isEmpty) return null;
    if (selection.startsWith('asset:')) {
      return selection.substring('asset:'.length);
    }
    if (selection.startsWith('custom:')) {
      return null;
    }
    return selection;
  }

  String? _customPathForSelection(String? selection) {
    if (selection == null || selection.isEmpty) return null;
    if (!selection.startsWith('custom:')) return null;
    final path = selection.substring('custom:'.length);
    return path.isEmpty ? null : path;
  }

  String _displayNameForSelection(String? selection) {
    if (selection == null || selection.isEmpty) return 'Not set';
    if (selection.startsWith('custom:')) {
      return selection.length > 'custom:'.length
          ? 'Custom recording'
          : 'Custom recording (record to enable)';
    }
    if (selection.startsWith('asset:')) {
      return selection.substring('asset:'.length);
    }
    return selection;
  }

  void _showSnack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.red,
      ),
    );
  }

  Future<void> _playSound(String? selection) async {
    final assetKey = _assetKeyForSelection(selection);
    final customPath = _customPathForSelection(selection);
    if (assetKey == null && customPath == null) {
      _showSnack('No sound selected for this player.');
      return;
    }

    bool played;
    if (customPath != null) {
      played = await _soundPlayer.playFile(customPath);
    } else {
      final key = assetKey ?? 'Beep';
      final soundPath = _soundFiles[key] ?? _defaultSoundAsset;
      final soundName = soundPath.split('/').last.split('.').first;
      played = await _soundPlayer.playAsset(soundName);
    }

    if (!played && mounted && _soundPlayer.assetSoundsAvailable) {
      _showSnack('Could not play sound on this device.');
    }
  }

  void _addSpotting(String spotter) {
    setState(() {
      _scores[spotter] = (_scores[spotter] ?? 0) + 1;
      _eventHistory.insert(
          0,
          _SpyEvent(
            type: _EventType.spotted,
            player: spotter,
            timestamp: DateTime.now(),
          ));

      // Limit history
      if (_eventHistory.length > 20) {
        _eventHistory.removeLast();
      }
    });

    GameFx.scoreFloat(
      context,
      text: '+1 $spotter',
      color: GameColors.primaryColors['soundSpy']!,
    );
    final total = (_scores[spotter] ?? 0) + (_guessScores[spotter] ?? 0);
    if (total > 0 && total % 10 == 0) {
      GameFx.celebrate(
        context,
        message: '$spotter hits $total!',
        color: GameColors.primaryColors['soundSpy'],
      );
    }

    // Play the spotter's sound
    _playSound(widget.playerSounds[spotter]);
  }

  void _addGuess(String guesser, String target) {
    setState(() {
      _guessScores[guesser] = (_guessScores[guesser] ?? 0) + 1;
      _eventHistory.insert(
          0,
          _SpyEvent(
            type: _EventType.guessed,
            player: guesser,
            targetPlayer: target,
            timestamp: DateTime.now(),
          ));
    });

    GameFx.scoreFloat(
      context,
      text: 'Nice guess, $guesser!',
      color: GameColors.primaryColors['soundSpy']!,
    );
  }

  Widget _buildPlayerCard(String player) {
    final selection = widget.playerSounds[player];
    final sound = _displayNameForSelection(selection);
    final object = widget.spyObjects[player] ?? 'Not set';
    final icon = _soundIcons[_assetKeyForSelection(selection)];

    final gameColor = GameColors.primaryColors['soundSpy']!;

    return GamePanel(
      accent: gameColor,
      margin: const EdgeInsets.only(bottom: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
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
                          player.isEmpty ? '?' : player[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Flexible(
                      child: Text(
                        player,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md, vertical: Spacing.xs),
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
                    const Text(
                      'Score: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ScorePop(
                      value:
                          (_scores[player] ?? 0) + (_guessScores[player] ?? 0),
                      popColor: Colors.amber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Sound and object info
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: GameColors.primaryColors['soundSpy']!
                      .withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                // Sound info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: GameColors.primaryColors['soundSpy']!
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon ?? Icons.music_note,
                              size: 18,
                              color: GameColors.primaryColors['soundSpy']!
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sound:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  sound,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.sm),
                      Row(
                        children: [
                          Icon(Icons.visibility,
                              size: 22,
                              color: GameColors.primaryColors['soundSpy']!),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Spotting:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  object,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Sound button
                BouncyTap(
                  pressedScale: 0.85,
                  onTap: () => _playSound(selection),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          gameColor,
                          Color.lerp(gameColor, Colors.black, 0.25)!,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gameColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.lg),

          // Scores and actions
          Row(
            children: [
              Expanded(
                child: _ScoreDisplay(
                  label: 'Spots',
                  score: _scores[player] ?? 0,
                  onAdd: () => _addSpotting(player),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _ScoreDisplay(
                  label: 'Guesses',
                  score: _guessScores[player] ?? 0,
                  onAdd: () {
                    showDialog(
                      context: context,
                      builder: (context) => _GuessDialog(
                        players: widget.players,
                        guesser: player,
                        onGuess: _addGuess,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventHistory() {
    final gameColor = GameColors.primaryColors['soundSpy']!;

    if (_eventHistory.isEmpty) {
      return GamePanel(
        accent: gameColor,
        padding: const EdgeInsets.all(Spacing.lg2),
        child: const Center(
          child: Text(
            'No events yet.\nStart spotting and guessing!',
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
      accent: gameColor,
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _eventHistory.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final event = _eventHistory[index];
          final time = _formatTimestamp(event.timestamp);

          if (event.type == _EventType.spotted) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: GameColors.primaryColors['soundSpy']!,
                child: Icon(Icons.visibility, color: Colors.white),
              ),
              title: Text('${event.player} spotted something!'),
              trailing: Text(time),
            );
          } else {
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.psychology, color: Colors.white),
              ),
              title: Text(
                  '${event.player} guessed ${event.targetPlayer}\'s object'),
              trailing: Text(time),
            );
          }
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gameColor = GameColors.primaryColors['soundSpy']!;

    return GameShell(
      title: 'Sound Spy',
      subtitle: 'Make your sound, keep them guessing!',
      color: gameColor,
      icon: Icons.graphic_eq_rounded,
      onHelp: () => setState(() => _showRules = !_showRules),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          GameRulesCard(
            visible: _showRules,
            color: gameColor,
            rules: const [
              'Each player has chosen a sound and something to spot',
              'Make your sound when you spot your object',
              'Try to guess what others are spotting',
              'Score 1 point for spotting, 1 point for correct guesses',
            ],
          ),
          // Player cards in a list instead of grid for better spacing
          ...widget.players.toList().asMap().entries.map(
                (entry) => FadeSlideIn(
                  delay: Duration(milliseconds: 80 * entry.key),
                  child: _buildPlayerCard(entry.value),
                ),
              ),

          const SizedBox(height: Spacing.lg),

          // Event history
          GameSectionTitle(
            icon: Icons.history_rounded,
            title: 'Game history',
            color: gameColor,
          ),
          const SizedBox(height: Spacing.sm),
          _buildEventHistory(),
        ],
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final String label;
  final int score;
  final VoidCallback onAdd;

  const _ScoreDisplay({
    required this.label,
    required this.score,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final gameColor = GameColors.primaryColors['soundSpy']!;

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ScorePop(
          value: score,
          popColor: Colors.amber,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: gameColor,
          ),
        ),
        const SizedBox(height: 8),
        ChunkyButton(
          color: gameColor,
          onTap: onAdd,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const SizedBox(
            width: double.infinity,
            child: Text(
              '+1',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GuessDialog extends StatelessWidget {
  final List<String> players;
  final String guesser;
  final Function(String, String) onGuess;

  const _GuessDialog({
    required this.players,
    required this.guesser,
    required this.onGuess,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Guess What Someone is Spotting'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Whose object did you guess?'),
          const SizedBox(height: Spacing.lg),
          ...players.where((p) => p != guesser).map((player) {
            return ListTile(
              title: Text(player),
              onTap: () {
                onGuess(guesser, player);
                Navigator.of(context).pop();
              },
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

enum _EventType {
  spotted,
  guessed,
}

class _SpyEvent {
  final _EventType type;
  final String player;
  final String? targetPlayer;
  final DateTime timestamp;

  _SpyEvent({
    required this.type,
    required this.player,
    this.targetPlayer,
    required this.timestamp,
  });
}
