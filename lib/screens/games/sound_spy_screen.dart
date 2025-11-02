import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../styles/game_colors.dart';
import '../../styles/spacing.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();
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
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    // Initialize scores
    for (var player in widget.players) {
      _scores[player] = 0;
      _guessScores[player] = 0;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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

    try {
      await _audioPlayer.stop();
      if (customPath != null) {
        await _audioPlayer.play(DeviceFileSource(customPath));
      } else {
        final soundFile = _soundFiles[assetKey] ?? _defaultSoundAsset;
        await _audioPlayer.play(AssetSource(soundFile));
      }
    } catch (e) {
      _showSnack('Could not play sound: $e');
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
  }

  Widget _buildPlayerCard(String player) {
    final selection = widget.playerSounds[player];
    final sound = _displayNameForSelection(selection);
    final object = widget.spyObjects[player] ?? 'Not set';
    final icon = _soundIcons[_assetKeyForSelection(selection)];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: Spacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GameColors.primaryColors['soundSpy']!.withValues(alpha: 0.1),
              GameColors.primaryColors['soundSpy']!.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
                  decoration: BoxDecoration(
                    color: GameColors.primaryColors['soundSpy']!,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Score: ${(_scores[player] ?? 0) + (_guessScores[player] ?? 0)}',
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
                border: Border.all(color: GameColors.primaryColors['soundSpy']!.withValues(alpha: 0.2)),
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
                                color: GameColors.primaryColors['soundSpy']!.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon ?? Icons.music_note,
                                size: 18,
                                color: GameColors.primaryColors['soundSpy']!.withValues(alpha: 0.85),
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
                                size: 22, color: GameColors.primaryColors['soundSpy']!),
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
                  ElevatedButton(
                    onPressed: () => _playSound(selection),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameColors.primaryColors['soundSpy']!,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(Spacing.md),
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
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
      ),
    );
  }

  Widget _buildEventHistory() {
    if (_eventHistory.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No events yet.\nStart spotting and guessing!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Spy'),
        backgroundColor: GameColors.primaryColors['soundSpy']!,
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
      body: SafeArea(
        child: Column(
          children: [
            if (_showRules)
              Container(
                color: GameColors.primaryColors['soundSpy']!.withValues(alpha: 0.05),
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Play:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      '1. Each player has chosen a sound and something to spot',
                      style: TextStyle(color: GameColors.primaryColors['soundSpy']!.withValues(alpha: 0.95)),
                    ),
                    Text(
                      '2. Make your sound when you spot your object',
                      style: TextStyle(color: GameColors.primaryColors['soundSpy']!.withValues(alpha: 0.95)),
                    ),
                    Text(
                      '3. Try to guess what others are spotting',
                      style: TextStyle(color: GameColors.primaryColors['soundSpy']!.withValues(alpha: 0.95)),
                    ),
                    Text(
                      '4. Score 1 point for spotting, 1 point for correct guesses',
                      style: TextStyle(color: GameColors.primaryColors['soundSpy']!.withValues(alpha: 0.95)),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Spacing.lg),
                children: [
                  // Player cards in a list instead of grid for better spacing
                  ...widget.players.map((player) => _buildPlayerCard(player)),

                  const SizedBox(height: Spacing.xl),

                  // Event history
                  const Text(
                    'Game History:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildEventHistory(),
                ],
              ),
            ),
          ],
        ),
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
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: GameColors.primaryColors['soundSpy']!,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: GameColors.primaryColors['soundSpy']!,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('+1', style: TextStyle(fontWeight: FontWeight.bold)),
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
