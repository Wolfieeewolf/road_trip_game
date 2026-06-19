import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../services/audio/game_sound_player.dart';
import '../../services/auth/auth_controller.dart';
import '../../services/friends/friends_controller.dart';
import '../../services/link/link_controller.dart';
import '../../services/windmill/windmill_types.dart';
import '../../styles/app_theme.dart';
import '../../styles/spacing.dart';
import '../../widgets/app_background.dart';
import '../../widgets/modern_panel.dart';
import 'games_screen.dart';

class GameSetupScreen extends StatefulWidget {
  final String gameId;

  const GameSetupScreen({
    super.key,
    required this.gameId,
  });

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  late List<String> _players;
  LinkController? _linkController;
  bool _usingSessionPlayers = false;
  final Map<String, String> _playerNumbers = {};
  final Map<String, String> _playerSounds = {};
  final Map<String, String> _spyObjects = {};
  final Map<String, String> _playerColors = {};
  final Map<String, dynamic> _windmillConfig = {
    'mode': 'classic',
    'mergeRadius': 150.0,
    'types': {
      for (final entry in windmillTypeDefinitions.entries)
        entry.key: {
          'enabled': entry.key == 'pump',
          'points': entry.value.defaultPoints,
        }
    },
  };
  final Map<String, List<String>> _playerSigns = {};
  int _signsTarget = 3;
  static const List<String> _auSigns = [
    'GIVE WAY',
    'STOP',
    'NO ENTRY',
    'SPEED LIMIT',
    'KANGAROO CROSSING',
    'KOALA CROSSING',
    'WOMBAT CROSSING',
    'SLOW DOWN',
    'NO RIGHT TURN',
    'ROAD WORK',
    'TRAFFIC LIGHTS',
    'SCHOOL ZONE',
    'CHILDREN CROSSING',
    'RAILWAY CROSSING',
    'PETROL',
    'FOOD',
    'REST AREA'
  ];
  static const int _maxPlayers = 8;
  bool _defaultsInitialized = false;
  final GameSoundPlayer _soundPreviewPlayer = GameSoundPlayer();
  final AudioRecorder _recorder = AudioRecorder();

  final List<String> _soundOptions = [
    'Beep',
    'Moo',
    'Baa',
    'Squeak',
    'Honk',
    'Woof',
    'Meow',
    'Roar',
  ];

  @override
  void initState() {
    super.initState();
    _players = <String>[];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final link = context.read<LinkController>();
    if (_linkController == link) {
      return;
    }

    _linkController?.removeListener(_onLinkUpdated);
    _linkController = link;
    _linkController!.addListener(_onLinkUpdated);
    _syncPlayersWithSession();
    _initializePlayersFromProfiles();
  }

  @override
  void dispose() {
    _linkController?.removeListener(_onLinkUpdated);
    _soundPreviewPlayer.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _onLinkUpdated() {
    _syncPlayersWithSession();
  }

  void _syncPlayersWithSession() {
    final session = _linkController?.session;
    if (session != null && session.participants.isNotEmpty) {
      final names = session.participants
          .map((participant) => participant.displayName)
          .toList();
      _replacePlayers(names, usingSession: true);
      return;
    }

    if (_usingSessionPlayers) {
      _replacePlayers(
        _profileDefaultPlayers(),
        usingSession: false,
        force: true,
      );
      _defaultsInitialized = true;
    }
  }

  void _initializePlayersFromProfiles() {
    if (_defaultsInitialized || _usingSessionPlayers) {
      return;
    }
    if (_players.isNotEmpty) {
      _defaultsInitialized = true;
      return;
    }

    _replacePlayers(
      _profileDefaultPlayers(),
      usingSession: false,
      force: true,
    );
    _defaultsInitialized = true;
  }

  List<String> _profileDefaultPlayers() {
    final auth = context.read<AuthController>();

    final names = <String>[];
    final seen = <String>{};

    void addName(String? rawName) {
      final trimmed = rawName?.trim();
      if (trimmed == null || trimmed.isEmpty) {
        return;
      }
      final lower = trimmed.toLowerCase();
      if (seen.contains(lower)) {
        return;
      }
      names.add(trimmed);
      seen.add(lower);
    }

    addName(auth.user?.displayName);

    if (names.length > _maxPlayers) {
      return names.sublist(0, _maxPlayers);
    }
    return names;
  }

  String _normalizeSoundSelection(String? value) {
    if (value == null || value.isEmpty) return 'asset:Beep';
    if (value.startsWith('asset:') || value.startsWith('custom:')) {
      if (value.startsWith('custom:') && value.length == 7) {
        return value; // custom with no path yet
      }
      return value;
    }
    return 'asset:$value';
  }

  bool _hasCustomRecording(String selection) {
    return selection.startsWith('custom:') && selection.length > 7;
  }

  String _sanitizeFileName(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
  }

  Future<void> _previewCustomSound(String selection) async {
    if (!_hasCustomRecording(selection)) {
      _showSnack('Record a custom sound first.');
      return;
    }
    final path = selection.substring('custom:'.length);
    final file = File(path);
    if (!await file.exists()) {
      _showSnack('Custom sound file is missing. Please record again.');
      return;
    }
    final played = await _soundPreviewPlayer.playFile(path);
    if (!played) {
      _showSnack('Could not play custom sound on this device.');
    }
  }

  Future<void> _recordCustomSound(String player) async {
    if (!await _recorder.hasPermission()) {
      _showSnack('Microphone permission is required to record sounds.');
      return;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final soundDir = Directory('${docsDir.path}/sound_spy');
    if (!await soundDir.exists()) {
      await soundDir.create(recursive: true);
    }
    final sanitized = _sanitizeFileName(player.toLowerCase());
    final filePath = '${soundDir.path}/$sanitized.m4a';

    bool isRecording = false;
    String? recordedPath;

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> toggleRecording() async {
              if (!isRecording) {
                await _recorder.start(
                  const RecordConfig(
                    encoder: AudioEncoder.aacLc,
                    bitRate: 128000,
                    sampleRate: 44100,
                  ),
                  path: filePath,
                );
                setModalState(() => isRecording = true);
              } else {
                recordedPath = await _recorder.stop();
                if (!context.mounted) {
                  return;
                }
                setModalState(() => isRecording = false);
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Record custom sound for $player',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: toggleRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecording ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                    ),
                    icon: Icon(isRecording ? Icons.stop : Icons.mic),
                    label: Text(
                        isRecording ? 'Stop recording' : 'Start recording'),
                  ),
                  const SizedBox(height: 8),
                  if (_hasCustomRecording(_playerSounds[player] ?? ''))
                    Text('Current custom recording will be overwritten.'),
                ],
              ),
            );
          },
        );
      },
    );

    if (isRecording) {
      recordedPath = await _recorder.stop();
      if (!mounted) return;
    }

    if (!mounted) return;
    final path = recordedPath ?? filePath;
    if (!await File(path).exists()) {
      _showSnack('Recording failed. Please try again.');
      return;
    }

    setState(() {
      _playerSounds[player] = 'custom:$path';
    });
    _showSnack('Custom sound saved for $player.');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<String> _availablePlayerSuggestions(
    AuthController auth,
    FriendsController friends,
  ) {
    final suggestions = <String>[];
    final existing = _players.map((name) => name.toLowerCase()).toSet();

    void addSuggestion(String? rawName) {
      final trimmed = rawName?.trim();
      if (trimmed == null || trimmed.isEmpty) {
        return;
      }
      final lower = trimmed.toLowerCase();
      final alreadyQueued = suggestions.any(
        (value) => value.toLowerCase() == lower,
      );
      if (existing.contains(lower) || alreadyQueued) {
        return;
      }
      suggestions.add(trimmed);
    }

    addSuggestion(auth.user?.displayName);

    for (final friend in friends.friends) {
      addSuggestion(friend.displayName);
      if (suggestions.length >= _maxPlayers) {
        break;
      }
    }

    return suggestions;
  }

  void _showPlayerExistsMessage(String name) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name is already part of this game.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _addPlayerByName(String name) {
    if (_usingSessionPlayers || _players.length >= _maxPlayers) {
      return false;
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final lower = trimmed.toLowerCase();
    final exists = _players.any((player) => player.toLowerCase() == lower);
    if (exists) {
      _showPlayerExistsMessage(trimmed);
      return false;
    }
    setState(() {
      _players.add(trimmed);
    });
    return true;
  }

  void _transferPlayerMapEntry(
    Map<String, String> map,
    String oldName,
    String newName,
  ) {
    if (map.containsKey(oldName)) {
      final value = map.remove(oldName)!;
      map[newName] = value;
    }
  }

  void _replacePlayers(
    List<String> newPlayers, {
    required bool usingSession,
    bool force = false,
  }) {
    if (!force && listEquals(_players, newPlayers)) {
      _usingSessionPlayers = usingSession;
      return;
    }

    final oldPlayers = List<String>.from(_players);
    final prevNumbers = Map<String, String>.from(_playerNumbers);
    final prevSounds = Map<String, String>.from(_playerSounds);
    final prevObjects = Map<String, String>.from(_spyObjects);
    final prevColors = Map<String, String>.from(_playerColors);
    final prevSigns = Map<String, List<String>>.from(_playerSigns);

    setState(() {
      _players = List<String>.from(newPlayers);
      _usingSessionPlayers = usingSession;

      _playerNumbers.clear();
      _playerSounds.clear();
      _spyObjects.clear();
      _playerColors.clear();
      _playerSigns.clear();

      for (var i = 0; i < _players.length; i++) {
        final name = _players[i];
        final previousName = i < oldPlayers.length ? oldPlayers[i] : null;

        final number = _inheritValue(prevNumbers, name, previousName);
        if (number != null) _playerNumbers[name] = number;

        final sound = _inheritValue(prevSounds, name, previousName);
        if (sound != null) _playerSounds[name] = sound;

        final spyObject = _inheritValue(prevObjects, name, previousName);
        if (spyObject != null) _spyObjects[name] = spyObject;

        final color = _inheritValue(prevColors, name, previousName);
        if (color != null) _playerColors[name] = color;

        if (previousName != null && prevSigns.containsKey(previousName)) {
          _playerSigns[name] = List<String>.from(prevSigns[previousName]!);
        } else if (prevSigns.containsKey(name)) {
          _playerSigns[name] = List<String>.from(prevSigns[name]!);
        }
      }
    });
  }

  String? _inheritValue(
    Map<String, String> previous,
    String name,
    String? previousName,
  ) {
    if (previous.containsKey(name)) {
      return previous[name];
    }
    if (previousName != null && previous.containsKey(previousName)) {
      return previous[previousName];
    }
    return null;
  }

  Future<void> _addPlayer() async {
    if (_usingSessionPlayers || _players.length >= _maxPlayers) {
      return;
    }

    final controller = TextEditingController();
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Player'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Player name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) {
                return;
              }
              Navigator.pop(context, value);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (!mounted) return;
    if (newName != null && newName.trim().isNotEmpty) {
      _addPlayerByName(newName.trim());
    }
  }

  void _removePlayer(int index) {
    if (_usingSessionPlayers) return;
    if (index < _players.length) {
      setState(() {
        final player = _players[index];
        _players.removeAt(index);
        _playerNumbers.remove(player);
        _playerSounds.remove(player);
        _spyObjects.remove(player);
        _playerColors.remove(player);
        _playerSigns.remove(player);
      });
    }
  }

  Future<void> _renamePlayer(int index) async {
    if (_usingSessionPlayers) return;
    final controller = TextEditingController(text: _players[index]);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Player'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Player name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final nextName = controller.text.trim();
              if (nextName.isEmpty) {
                return;
              }

              final duplicate = _players.asMap().entries.any(
                    (entry) =>
                        entry.key != index &&
                        entry.value.toLowerCase() == nextName.toLowerCase(),
                  );
              if (duplicate) {
                _showPlayerExistsMessage(nextName);
                return;
              }

              setState(() {
                final oldName = _players[index];
                _players[index] = nextName;

                _transferPlayerMapEntry(_playerNumbers, oldName, nextName);
                _transferPlayerMapEntry(_playerSounds, oldName, nextName);
                _transferPlayerMapEntry(_spyObjects, oldName, nextName);
                _transferPlayerMapEntry(_playerColors, oldName, nextName);
                if (_playerSigns.containsKey(oldName)) {
                  _playerSigns[nextName] = _playerSigns.remove(oldName)!;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Widget _buildNumberMatchSetup() {
    return Column(
      children: _players.map((player) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(player),
              ),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Lucky Number',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _playerNumbers[player],
                  items: List.generate(10, (index) {
                    return DropdownMenuItem(
                      value: index.toString(),
                      child: Text(index.toString()),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _playerNumbers[player] = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorChaseSetup() {
    final colors = [
      'Red',
      'Blue',
      'Green',
      'Yellow',
      'Black',
      'White',
      'Silver',
      'Orange',
      'Purple',
      'Brown',
      'Pink'
    ];

    return Column(
      children: _players.map((player) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(player),
              ),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Car Color',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _playerColors[player],
                  items: colors.map((color) {
                    return DropdownMenuItem(
                      value: color,
                      child: Text(color),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _playerColors[player] = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSoundSpySetup() {
    return Column(
      children: _players.map((player) {
        // Read-only normalization; the start-game flow normalizes again.
        final selection = _normalizeSoundSelection(_playerSounds[player]);
        final dropdownValue =
            selection.startsWith('custom:') ? 'custom' : selection;
        final hasCustom = _hasCustomRecording(selection);
        final customLabel =
            hasCustom ? 'Custom recording' : 'Custom recording (record new)';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(player, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: dropdownValue,
                      decoration: const InputDecoration(
                        labelText: 'Player sound',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: [
                        ..._soundOptions.map((sound) {
                          final value = 'asset:$sound';
                          return DropdownMenuItem(
                            value: value,
                            child: Text(sound),
                          );
                        }),
                        DropdownMenuItem(
                            value: 'custom', child: Text(customLabel)),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          if (value == 'custom') {
                            if (!_playerSounds[player]!.startsWith('custom:')) {
                              _playerSounds[player] = 'custom:';
                            }
                          } else {
                            _playerSounds[player] = value;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Record custom sound',
                    icon: const Icon(Icons.mic),
                    onPressed: () => _recordCustomSound(player),
                  ),
                  if (hasCustom)
                    IconButton(
                      tooltip: 'Preview custom sound',
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => _previewCustomSound(selection),
                    ),
                ],
              ),
              if (selection.startsWith('custom:') && !hasCustom)
                const Padding(
                  padding: EdgeInsets.only(top: 6.0, left: 4),
                  child: Text(
                    'No recording saved yet. Tap the mic to record.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'What do they spy?',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                initialValue: _spyObjects[player],
                onChanged: (value) {
                  setState(() {
                    _spyObjects[player] = value;
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _applyClassicWindmillConfig() {
    final types = (_windmillConfig['types'] as Map<String, dynamic>);
    for (final entry in windmillTypeDefinitions.entries) {
      final map = types[entry.key] as Map<String, dynamic>;
      map['enabled'] = entry.key == 'pump';
      map['points'] = entry.value.defaultPoints;
    }
    _windmillConfig['mode'] = 'classic';
    _windmillConfig['mergeRadius'] = 150.0;
    setState(() {});
  }

  void _ensureWindmillTypeSelected() {
    final types = (_windmillConfig['types'] as Map<String, dynamic>);
    final hasEnabled = types.values.any((value) => value['enabled'] == true);
    if (!hasEnabled) {
      types['pump']['enabled'] = true;
    }
  }

  Map<String, dynamic> _cloneWindmillConfig() {
    final types = (_windmillConfig['types'] as Map<String, dynamic>);
    final clonedTypes = <String, Map<String, dynamic>>{};
    for (final entry in types.entries) {
      clonedTypes[entry.key] = {
        'enabled': entry.value['enabled'] == true,
        'points': (entry.value['points'] as num?)?.toDouble() ??
            windmillTypeDefinitions[entry.key]?.defaultPoints ??
            1.0,
      };
    }
    return {
      'mode': _windmillConfig['mode'],
      'mergeRadius': (_windmillConfig['mergeRadius'] as num).toDouble(),
      'types': clonedTypes,
    };
  }

  Map<String, String> _buildSoundSelectionsForGame() {
    final result = <String, String>{};
    for (final player in _players) {
      var selection = _normalizeSoundSelection(_playerSounds[player]);
      if (selection.startsWith('custom:')) {
        final path = selection.substring('custom:'.length);
        if (path.isEmpty || !File(path).existsSync()) {
          selection = 'asset:Beep';
        }
      }
      result[player] = selection;
    }
    return result;
  }

  Widget _buildWindmillSetup() {
    final mode = (_windmillConfig['mode'] as String?) ?? 'classic';
    final mergeRadius =
        (_windmillConfig['mergeRadius'] as num?)?.toDouble() ?? 150.0;
    final types = (_windmillConfig['types'] as Map<String, dynamic>);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Windmill mode', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Classic'),
              selected: mode == 'classic',
              onSelected: (selected) {
                if (selected) _applyClassicWindmillConfig();
              },
            ),
            ChoiceChip(
              label: const Text('Custom'),
              selected: mode == 'custom',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _windmillConfig['mode'] = 'custom';
                    _ensureWindmillTypeSelected();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Merge radius (${mergeRadius.toStringAsFixed(0)} m)',
            style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: mergeRadius.clamp(50, 500),
          min: 50,
          max: 500,
          divisions: 9,
          label: '${mergeRadius.toStringAsFixed(0)} m',
          onChanged: (value) {
            setState(() {
              _windmillConfig['mergeRadius'] = value;
            });
          },
        ),
        const SizedBox(height: 12),
        if (mode == 'classic')
          Text(
            'Classic mode counts every farm windmill the same (1 point each). '
            'Switch to custom to include turbines, pinwheels, or special scoring.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else ...[
          Text(
            'Select the windmill types you want to count and adjust their points.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ...windmillTypeDefinitions.entries.map((entry) {
            final typeKey = entry.key;
            final data = types[typeKey] as Map<String, dynamic>;
            final enabled = data['enabled'] == true;
            final points = (data['points'] as num?)?.toDouble() ??
                entry.value.defaultPoints;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.value.label),
                    subtitle: Text(entry.value.description),
                    value: enabled,
                    onChanged: (value) {
                      setState(() {
                        data['enabled'] = value ?? false;
                        _ensureWindmillTypeSelected();
                      });
                    },
                  ),
                  if (enabled)
                    Padding(
                      padding: const EdgeInsets.only(left: 32, right: 16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue: points
                                  .toStringAsFixed(points % 1 == 0 ? 0 : 1),
                              decoration: const InputDecoration(
                                labelText: 'Points',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (value) {
                                final parsed = double.tryParse(value);
                                setState(() {
                                  data['points'] =
                                      parsed ?? entry.value.defaultPoints;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                              'Default: ${entry.value.defaultPoints.toStringAsFixed(1)}'),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSignScrambleSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Signs per player',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: _signsTarget,
              items: [
                for (var n = 1; n <= 6; n++)
                  DropdownMenuItem(value: n, child: Text('$n'))
              ],
              onChanged: (v) => setState(() {
                _signsTarget = v ?? 3;
                // Trim selections to new target
                _playerSigns.updateAll(
                    (key, list) => List<String>.from(list.take(_signsTarget)));
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._players.map((player) {
          final selected = _playerSigns[player] ?? <String>[];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(player,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('(${selected.length}/$_signsTarget)',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _auSigns.map((name) {
                    final isSelected = selected.contains(name);
                    final canAdd = isSelected || selected.length < _signsTarget;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(name),
                      onSelected: canAdd
                          ? (value) {
                              setState(() {
                                final list = List<String>.from(selected);
                                if (value) {
                                  if (!list.contains(name) &&
                                      list.length < _signsTarget) {
                                    list.add(name);
                                  }
                                } else {
                                  list.remove(name);
                                }
                                _playerSigns[player] = list;
                              });
                            }
                          : null,
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget? _buildGameSpecificSetup() {
    switch (widget.gameId) {
      case 'numberPlateMatch':
        return _buildNumberMatchSetup();
      case 'soundSpy':
        return _buildSoundSpySetup();
      case 'colorChase':
        return _buildColorChaseSetup();
      case 'windmill':
        return _buildWindmillSetup();
      case 'signScramble':
        return _buildSignScrambleSetup();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final friends = context.watch<FriendsController>();
    final suggestedNames = _availablePlayerSuggestions(auth, friends);
    final gameSpecificSetup = _buildGameSpecificSetup();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModernPanel(
                margin: const EdgeInsets.only(bottom: Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.people_alt_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Players',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.canvas,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            '${_players.length}/$_maxPlayers',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_usingSessionPlayers && suggestedNames.isNotEmpty) ...[
                      const Text(
                        'Quick add from your friends list',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: suggestedNames
                            .map(
                              (name) => ActionChip(
                                label: Text(name),
                                onPressed: _players.length >= _maxPlayers
                                    ? null
                                    : () => _addPlayerByName(name),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_usingSessionPlayers) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Linked session is managing the player list.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _players.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final readOnly = _usingSessionPlayers;
                        final canRemove = !readOnly && _players.length > 2;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _players[index],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    iconSize: 20,
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.edit_rounded),
                                    onPressed: readOnly
                                        ? null
                                        : () => _renamePlayer(index),
                                    tooltip: readOnly
                                        ? 'Players are managed by the session host'
                                        : 'Rename player',
                                    color: readOnly ? Colors.grey : Colors.blue,
                                  ),
                                  IconButton(
                                    iconSize: 20,
                                    visualDensity: VisualDensity.compact,
                                    icon:
                                        const Icon(Icons.remove_circle_rounded),
                                    onPressed: canRemove
                                        ? () => _removePlayer(index)
                                        : null,
                                    tooltip: readOnly
                                        ? 'Players are managed by the session host'
                                        : (canRemove
                                            ? 'Remove player'
                                            : 'Minimum 2 players required'),
                                    color: canRemove ? Colors.red : Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_usingSessionPlayers)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock, color: Colors.grey, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Linked session controls players',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    else if (_players.length < _maxPlayers)
                      InkWell(
                        onTap: _addPlayer,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Add Player',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.grey, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Maximum players reached',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (gameSpecificSetup != null) ...[
                ModernPanel(
                  margin: const EdgeInsets.only(bottom: Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Game settings',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: Spacing.md),
                      gameSpecificSetup,
                    ],
                  ),
                ),
              ],
              GradientPrimaryButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          GamesScreen(
                        gameType: widget.gameId,
                        players: _players,
                        playerNumbers: _playerNumbers,
                        playerSounds: _buildSoundSelectionsForGame(),
                        spyObjects: _spyObjects,
                        playerColors: _playerColors,
                        playerSigns: _playerSigns,
                        windmillConfig: _cloneWindmillConfig(),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                label: 'Start game',
                icon: Icons.play_arrow_rounded,
              ),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
