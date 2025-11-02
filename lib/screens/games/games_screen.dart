import 'package:flutter/material.dart';

import '../../styles/spacing.dart';
import 'color_chase_screen.dart';
import 'number_plate_match_screen.dart';
import 'road_trip_bingo_screen.dart';
import 'sign_scramble_screen.dart';
import 'sound_spy_screen.dart';
import 'windmill_screen.dart';

class GamesScreen extends StatelessWidget {
  final String gameType;
  final List<String> players;
  final String? sessionId; // Optional session ID for multiplayer sync
  final Map<String, String> playerNumbers;
  final Map<String, String> playerSounds;
  final Map<String, String> spyObjects;
  final Map<String, String> playerColors;
  final Map<String, List<String>> playerSigns;
  final Map<String, dynamic> windmillConfig;

  const GamesScreen({
    super.key,
    required this.gameType,
    required this.players,
    this.sessionId,
    this.playerNumbers = const {},
    this.playerSounds = const {},
    this.spyObjects = const {},
    this.playerColors = const {},
    this.playerSigns = const {},
    this.windmillConfig = const {},
  });

  // Backwards compatibility with old 'gameId' parameter
  // ignore: prefer_constructors_over_static_methods
  static GamesScreen fromGameId({
    required String gameId,
    required List<String> players,
    Map<String, String> playerNumbers = const {},
    Map<String, String> playerSounds = const {},
    Map<String, String> spyObjects = const {},
    Map<String, String> playerColors = const {},
    Map<String, List<String>> playerSigns = const {},
    Map<String, dynamic> windmillConfig = const {},
  }) {
    return GamesScreen(
      gameType: gameId,
      players: players,
      sessionId: null,
      playerNumbers: playerNumbers,
      playerSounds: playerSounds,
      spyObjects: spyObjects,
      playerColors: playerColors,
      playerSigns: playerSigns,
      windmillConfig: windmillConfig,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (gameType) {
      case 'numberPlateMatch':
        return NumberPlateMatchScreen(
          players: players,
          playerNumbers: playerNumbers,
          sessionId: sessionId,
        );
      case 'soundSpy':
        return SoundSpyScreen(
          players: players,
          playerSounds: playerSounds,
          spyObjects: spyObjects,
          sessionId: sessionId,
        );
      case 'windmill':
        return WindmillScreen(
          players: players,
          config: windmillConfig,
          sessionId: sessionId,
        );
      case 'roadTripBingo':
        return RoadTripBingoScreen(
          players: players,
          sessionId: sessionId,
        );
      case 'colorChase':
        return ColorChaseScreen(
          players: players,
          playerColors: playerColors,
          sessionId: sessionId,
        );
      case 'signScramble':
        return SignScrambleScreen(
          players: players,
          playerSigns: playerSigns,
          sessionId: sessionId,
        );
      default:
        // Handle unknown game type
        return Scaffold(
          appBar: AppBar(
            title: const Text('Unknown Game'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Game not found'),
                const SizedBox(height: Spacing.lg),
                Text('Game ID: $gameType'),
                const SizedBox(height: Spacing.lg),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        );
    }
  }
}
