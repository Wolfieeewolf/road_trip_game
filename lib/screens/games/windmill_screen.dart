import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../services/firebase/game_session_service.dart';
import '../../services/location/location_service.dart';
import '../../services/windmill/windmill_types.dart';
import '../../styles/game_colors.dart';
import '../../styles/spacing.dart';
import '../../widgets/game_fx.dart';
import '../../widgets/game_shell.dart';
import '../../widgets/mini_map.dart';

class WindmillScreen extends StatefulWidget {
  final List<String> players;
  final Map<String, dynamic> config;
  final String? sessionId;

  const WindmillScreen({
    super.key,
    required this.players,
    this.config = const {},
    this.sessionId,
  });

  @override
  State<WindmillScreen> createState() => _WindmillScreenState();
}

class _WindmillScreenState extends State<WindmillScreen>
    with SingleTickerProviderStateMixin {
  static const _uuid = Uuid();
  static const _defaultCenter = ll.LatLng(-25.2744, 133.7751);

  final Map<String, double> _scores = {};
  final List<_WindmillEvent> _history = [];
  final List<_WindmillPin> _pins = [];

  ll.LatLng? _current;
  bool _showRules = false;
  bool _showMap = false;

  late final List<String> _enabledTypes;
  late final Map<String, double> _typePoints;
  late final double _mergeRadiusMetres;

  late final AnimationController _spinController;
  late final Animation<double> _spinAnimation;

  StreamSubscription<Position>? _posSub;
  StreamSubscription? _sessionSub;
  final GameSessionService _sessionService = GameSessionService();

  @override
  void initState() {
    super.initState();
    for (final player in widget.players) {
      _scores[player] = 0;
    }
    _configureFromConfig();
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _spinAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
    );
    _initLocationAndLoad();
    _initFirebaseSync();
  }

  void _initFirebaseSync() {
    if (widget.sessionId == null || !GameSessionService.isAvailable) return;

    // Listen to session changes for real-time score sync
    _sessionSub =
        _sessionService.watchSession(widget.sessionId!).listen((session) {
      if (session == null) return;

      // Update scores from Firebase
      setState(() {
        for (final player in widget.players) {
          final firebaseScore = session.scores[player] ?? 0;
          _scores[player] = firebaseScore.toDouble();
        }
      });
    });
  }

  Future<void> _syncScoreToFirebase(String player) async {
    if (widget.sessionId == null) return;

    try {
      final score = (_scores[player] ?? 0).toInt();
      await _sessionService.updateScore(
        sessionCode: widget.sessionId!,
        playerName: player,
        score: score,
      );
    } catch (e) {
      // Silently fail - offline mode
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _posSub?.cancel();
    _sessionSub?.cancel();
    super.dispose();
  }

  void _configureFromConfig() {
    final mode = widget.config['mode'] as String? ?? 'classic';
    final rawTypes =
        (widget.config['types'] as Map?)?.cast<String, dynamic>() ?? {};
    final mergeRadius =
        (widget.config['mergeRadius'] as num?)?.toDouble() ?? 150.0;

    if (mode == 'custom' && rawTypes.isNotEmpty) {
      final enabled = <String>[];
      final points = <String, double>{};
      for (final entry in windmillTypeDefinitions.entries) {
        final raw = rawTypes[entry.key] as Map<String, dynamic>?;
        final enabledFlag = raw?['enabled'] == true;
        if (enabledFlag) {
          enabled.add(entry.key);
          points[entry.key] =
              (raw?['points'] as num?)?.toDouble() ?? entry.value.defaultPoints;
        }
      }
      if (enabled.isEmpty) {
        enabled.add('pump');
        points['pump'] = windmillTypeDefinitions['pump']!.defaultPoints;
      }
      _enabledTypes = enabled;
      _typePoints = points;
    } else {
      _enabledTypes = ['pump'];
      _typePoints = {'pump': windmillTypeDefinitions['pump']!.defaultPoints};
    }
    _mergeRadiusMetres = mergeRadius;
  }

  Future<void> _initLocationAndLoad() async {
    await LocationService.ensurePermission();
    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _current = ll.LatLng(pos.latitude, pos.longitude));
    } catch (_) {}
    _posSub = Geolocator.getPositionStream().listen((position) {
      if (!mounted) return;
      setState(() {
        _current = ll.LatLng(position.latitude, position.longitude);
      });
    });
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('windmill_pins');
    if (raw != null && mounted) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      setState(() {
        for (final item in decoded) {
          _pins.add(_WindmillPin.fromMap(Map<String, dynamic>.from(item)));
        }
      });
    }
  }

  Future<void> _persistPins() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_pins.map((p) => p.toMap()).toList());
    await prefs.setString('windmill_pins', jsonString);
  }

  void _playSpin() {
    if (!_spinController.isAnimating) {
      _spinController.forward(from: 0);
    }
  }

  Future<void> _handleSpot(String player) async {
    final ok = await LocationService.ensurePermission();
    if (!ok) {
      _showSnack('Location permission required to log windmills.');
      return;
    }
    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition();
    } catch (_) {
      _showSnack('Unable to get your location right now.');
      return;
    }
    final point = ll.LatLng(pos.latitude, pos.longitude);
    setState(() => _current = point);

    final matches = _nearbyPins(point);
    if (matches.isEmpty) {
      await _createNewPinFlow(player, point);
    } else {
      // ignore: use_build_context_synchronously
      final selection = await showModalBottomSheet<String?>(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text('Windmills already logged nearby'),
                  subtitle:
                      Text('Select one to update or add a brand new pin.'),
                ),
                for (final match in matches)
                  ListTile(
                    leading: Icon(
                        windmillTypeDefinitions[match.pin.type]?.icon ??
                            Icons.wind_power),
                    title: Text(
                        '${windmillTypeDefinitions[match.pin.type]?.label ?? match.pin.type} (${match.pin.count})'),
                    subtitle: Text(
                        '${_formatDistanceMeters(match.distanceMeters)} away'),
                    onTap: () => Navigator.pop(context, match.pin.id),
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add_location_alt_outlined),
                  title: const Text('Add a new windmill pin here'),
                  onTap: () => Navigator.pop(context, '_new'),
                ),
                const SizedBox(height: Spacing.sm),
              ],
            ),
          );
        },
      );
      if (!mounted) return;
      if (selection == null) return;
      if (selection == '_new') {
        await _createNewPinFlow(player, point);
      } else {
        final pin = _pins.firstWhere((p) => p.id == selection);
        await _updateExistingPinFlow(pin, player);
      }
    }
  }

  Future<void> _createNewPinFlow(String player, ll.LatLng point) async {
    final type = await _pickType();
    if (!mounted || type == null) return;
    final pin = _WindmillPin(
      id: _uuid.v4(),
      lat: point.latitude,
      lon: point.longitude,
      type: type,
      count: 1,
      lastUpdated: DateTime.now(),
    );
    setState(() {
      _pins.add(pin);
      final points = _typePoints[type] ?? 1;
      _scores[player] = (_scores[player] ?? 0) + points;
      _history.insert(
        0,
        _WindmillEvent(
          player: player,
          type: type,
          points: points,
          deltaCount: 1,
          pinId: pin.id,
          timestamp: DateTime.now(),
        ),
      );
    });
    _playSpin();
    if (mounted) {
      final points = _typePoints[type] ?? 1;
      GameFx.scoreFloat(
        context,
        text: '+${_formatPoints(points)} $player',
        color: GameColors.primaryColors['windmill']!,
      );
    }
    await _persistPins();
    await _syncScoreToFirebase(player);
  }

  String _formatPoints(num points) {
    return points % 1 == 0
        ? points.toInt().toString()
        : points.toStringAsFixed(1);
  }

  Future<void> _updateExistingPinFlow(_WindmillPin pin, String player) async {
    // ignore: use_build_context_synchronously
    final result = await showModalBottomSheet<_PinUpdateResult>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(windmillTypeDefinitions[pin.type]?.icon ??
                    Icons.wind_power),
                title:
                    Text(windmillTypeDefinitions[pin.type]?.label ?? pin.type),
                subtitle: Text('Currently logged: ${pin.count}'),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add another windmill here'),
                subtitle: const Text('Increase the total and award points.'),
                onTap: () => Navigator.pop(context,
                    const _PinUpdateResult(deltaCount: 1, awardPoints: true)),
              ),
              ListTile(
                leading: const Icon(Icons.rule_folder_outlined),
                title: const Text('Update total manually'),
                subtitle:
                    const Text('Set the total number spotted at this site.'),
                onTap: () async {
                  final controller =
                      TextEditingController(text: pin.count.toString());
                  final newTotal = await showDialog<int>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Update windmill count'),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Total windmills here'),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              final parsed = int.tryParse(controller.text);
                              if (parsed == null || parsed < pin.count) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Enter a number equal to or greater than the current total.')),
                                );
                                return;
                              }
                              Navigator.pop(context, parsed);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                  controller.dispose();
                  if (newTotal != null) {
                    if (!context.mounted) return;
                    final delta = newTotal - pin.count;
                    Navigator.pop(
                      context,
                      _PinUpdateResult(
                          deltaCount: delta, awardPoints: delta > 0),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('Already counted – no change'),
                onTap: () => Navigator.pop(context,
                    const _PinUpdateResult(deltaCount: 0, awardPoints: false)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || result == null) return;

    if (result.deltaCount > 0) {
      pin.count += result.deltaCount;
      pin.lastUpdated = DateTime.now();
      final points = (_typePoints[pin.type] ?? 1.0) * result.deltaCount;
      setState(() {
        _scores[player] = (_scores[player] ?? 0) + points;
        _history.insert(
          0,
          _WindmillEvent(
            player: player,
            type: pin.type,
            points: points,
            deltaCount: result.deltaCount,
            pinId: pin.id,
            timestamp: DateTime.now(),
          ),
        );
      });
      _playSpin();
      if (mounted) {
        final points = (_typePoints[pin.type] ?? 1.0) * result.deltaCount;
        GameFx.scoreFloat(
          context,
          text: '+${_formatPoints(points)} $player',
          color: GameColors.primaryColors['windmill']!,
        );
      }
      await _persistPins();
      await _syncScoreToFirebase(player);
    } else if (result.deltaCount == 0 && result.awardPoints == false) {
      // Just record the visit with zero points
      setState(() {
        _history.insert(
          0,
          _WindmillEvent(
            player: player,
            type: pin.type,
            points: 0,
            deltaCount: 0,
            pinId: pin.id,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  Future<String?> _pickType() async {
    if (_enabledTypes.isEmpty) return null;
    String selection = _enabledTypes.first;
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text('Select windmill type'),
                  ),
                  ..._enabledTypes.map((typeKey) {
                    final def = windmillTypeDefinitions[typeKey]!;
                    // ignore: deprecated_member_use
                    return RadioListTile<String>(
                      value: typeKey,
                      // ignore: deprecated_member_use
                      groupValue: selection,
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        setModalState(() => selection = value!);
                      },
                      title: Text(def.label),
                      subtitle: Text(
                          '${def.defaultPoints.toStringAsFixed(1)} base points'),
                      secondary: Icon(def.icon),
                    );
                  }),
                  const SizedBox(height: Spacing.sm),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, selection),
                    child: const Text('Confirm'),
                  ),
                  const SizedBox(height: Spacing.md),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<_MatchedPin> _nearbyPins(ll.LatLng point) {
    final distance = ll.Distance();
    return _pins
        .map((pin) {
          final distMeters =
              distance.as(ll.LengthUnit.Meter, point, pin.latLng);
          return _MatchedPin(pin: pin, distanceMeters: distMeters);
        })
        .where((match) => match.distanceMeters <= _mergeRadiusMetres)
        .toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _undoLastFor(String player) {
    final index = _history.indexWhere((event) => event.player == player);
    if (index == -1) return;
    setState(() {
      final event = _history.removeAt(index);
      _scores[player] = (_scores[player] ?? 0) - event.points;
      if (_scores[player]! < 0) _scores[player] = 0;
      if (event.pinId != null && event.deltaCount > 0) {
        final pinIndex = _pins.indexWhere((p) => p.id == event.pinId);
        if (pinIndex != -1) {
          final pin = _pins[pinIndex];
          pin.count -= event.deltaCount;
          if (pin.count <= 0) {
            _pins.removeAt(pinIndex);
          }
        }
      }
    });
    _persistPins();
    _syncScoreToFirebase(player);
  }

  @override
  Widget build(BuildContext context) {
    final currentScoreSummary = _scores.entries
        .map((e) => '${e.key}: ${_formatScore(e.value)}')
        .join('  •  ');
    final totalWindmills = _pins.fold<int>(0, (sum, pin) => sum + pin.count);

    final markers = <Marker>[];
    for (final pin in _pins) {
      markers.add(
        Marker(
          point: pin.latLng,
          width: 48,
          height: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                windmillTypeDefinitions[pin.type]?.icon ?? Icons.wind_power,
                color: GameColors.primaryColors['windmill']!,
              ),
              Text('${pin.count}',
                  style: const TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),
        ),
      );
    }
    if (_current != null) {
      markers.add(
        Marker(
          point: _current!,
          width: 40,
          height: 40,
          child: const Icon(Icons.my_location, color: Colors.blue),
        ),
      );
    }

    final mapCenter =
        _current ?? (_pins.isNotEmpty ? _pins.last.latLng : _defaultCenter);

    final gameColor = GameColors.primaryColors['windmill']!;

    return GameShell(
      title: 'Windmill Count',
      subtitle: 'Spot windmills, stack up points!',
      color: gameColor,
      icon: Icons.wind_power_rounded,
      onHelp: () => setState(() => _showRules = !_showRules),
      actions: [
        GameHeaderButton(
          icon: _showMap ? Icons.map_rounded : Icons.map_outlined,
          onTap: () => setState(() => _showMap = !_showMap),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          GameRulesCard(
            visible: _showRules,
            color: gameColor,
            rules: const [
              'Tap “Spotted!” when you see a windmill.',
              'Pick the type (farm windmill, turbine, pinwheel, etc.).',
              'The game keeps score using the points selected in setup.',
              'Windmills within the merge radius are grouped so the family can agree whether it is a new discovery or already counted.',
            ],
          ),
          if (_showMap)
            GamePanel(
              accent: gameColor,
              padding: const EdgeInsets.all(Spacing.xs),
              margin: const EdgeInsets.only(bottom: Spacing.md),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: MiniMap(
                  center: mapCenter,
                  markers: markers,
                  height: 220,
                  zoom: _pins.isEmpty ? 12 : 14,
                ),
              ),
            ),
          GamePanel(
            accent: gameColor,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: gameColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedBuilder(
                    animation: _spinAnimation,
                    builder: (context, child) => Transform.rotate(
                      angle: _spinAnimation.value,
                      child: child,
                    ),
                    child: Icon(Icons.wind_power, color: gameColor, size: 26),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total windmills logged: $totalWindmills',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        currentScoreSummary.isEmpty
                            ? 'No scores yet.'
                            : currentScoreSummary,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          _buildPlayerGrid(),
          const SizedBox(height: Spacing.lg),
          GameSectionTitle(
            icon: Icons.location_on_rounded,
            title: 'Windmills spotted',
            color: gameColor,
          ),
          const SizedBox(height: Spacing.sm),
          if (_pins.isEmpty)
            GamePanel(
              accent: gameColor,
              child: Center(
                child: Text(
                  'No windmills logged yet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            ..._pins.map(_buildPinTile),
          const SizedBox(height: Spacing.lg),
          GameSectionTitle(
            icon: Icons.history_rounded,
            title: 'Spotting history',
            color: gameColor,
          ),
          const SizedBox(height: Spacing.sm),
          if (_history.isEmpty)
            GamePanel(
              accent: gameColor,
              child: Center(
                child: Text(
                  'No windmills spotted yet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            ..._history.map(_buildHistoryTile),
        ],
      ),
    );
  }

  Widget _buildPlayerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.players.length,
      itemBuilder: (context, index) {
        final player = widget.players[index];
        return _buildPlayerCard(player);
      },
    );
  }

  Widget _buildPlayerCard(String player) {
    final gameColor = GameColors.primaryColors['windmill']!;
    final score = _scores[player] ?? 0;

    return GamePanel(
      accent: gameColor,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
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
                child: AnimatedBuilder(
                  animation: _spinAnimation,
                  builder: (context, child) => Transform.rotate(
                    angle: _spinAnimation.value,
                    child: child,
                  ),
                  child: const Icon(Icons.wind_power,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  player,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: gameColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_formatScore(score)} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: gameColor,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          ChunkyButton(
            color: gameColor,
            onTap: () => _handleSpot(player),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_location_alt_outlined,
                    size: 20, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Spotted!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _undoLastFor(player),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: gameColor,
                side: BorderSide(color: gameColor.withValues(alpha: 0.5)),
              ),
              icon: const Icon(Icons.undo, size: 18),
              label: const Text('Undo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinTile(_WindmillPin pin) {
    final gameColor = GameColors.primaryColors['windmill']!;
    final typeDef = windmillTypeDefinitions[pin.type];

    return GamePanel(
      accent: gameColor,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
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
            child: Icon(typeDef?.icon ?? Icons.wind_power, color: gameColor),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeDef?.label ?? pin.type,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Count: ${pin.count} • Last updated: ${_formatDate(pin.lastUpdated)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(_WindmillEvent event) {
    final gameColor = GameColors.primaryColors['windmill']!;
    final typeDef = windmillTypeDefinitions[event.type];
    final description = event.deltaCount > 0
        ? 'New windmill logged (+${event.deltaCount})'
        : 'Revisited windmill';

    return GamePanel(
      accent: gameColor,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
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
            child: Icon(typeDef?.icon ?? Icons.wind_power, color: gameColor),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${event.player} • ${typeDef?.label ?? event.type}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '$description • ${_formatDate(event.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (event.points > 0)
            Text(
              '+${_formatScore(event.points)}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: gameColor,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime timestamp) {
    final date =
        '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}';
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  String _formatScore(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  String _formatDistanceMeters(double metres) {
    if (metres < 1000) {
      return '${metres.toStringAsFixed(0)} m';
    }
    return '${(metres / 1000).toStringAsFixed(2)} km';
  }
}

class _WindmillPin {
  final String id;
  final double lat;
  final double lon;
  String type;
  int count;
  DateTime lastUpdated;

  _WindmillPin({
    required this.id,
    required this.lat,
    required this.lon,
    required this.type,
    required this.count,
    required this.lastUpdated,
  });

  ll.LatLng get latLng => ll.LatLng(lat, lon);

  Map<String, dynamic> toMap() => {
        'id': id,
        'lat': lat,
        'lon': lon,
        'type': type,
        'count': count,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory _WindmillPin.fromMap(Map<String, dynamic> map) {
    return _WindmillPin(
      id: map['id'] as String,
      lat: (map['lat'] as num).toDouble(),
      lon: (map['lon'] as num).toDouble(),
      type: map['type'] as String? ?? 'pump',
      count: (map['count'] as num?)?.toInt() ?? 1,
      lastUpdated: DateTime.tryParse(map['lastUpdated'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class _WindmillEvent {
  final String player;
  final String type;
  final double points;
  final int deltaCount;
  final String? pinId;
  final DateTime timestamp;

  _WindmillEvent({
    required this.player,
    required this.type,
    required this.points,
    required this.deltaCount,
    required this.pinId,
    required this.timestamp,
  });
}

class _PinUpdateResult {
  final int deltaCount;
  final bool awardPoints;

  const _PinUpdateResult({required this.deltaCount, required this.awardPoints});
}

class _MatchedPin {
  final _WindmillPin pin;
  final double distanceMeters;

  _MatchedPin({required this.pin, required this.distanceMeters});
}
