import 'package:flutter/material.dart';

import '../../styles/spacing.dart';
import 'color_chase_screen.dart';
import 'number_plate_match_screen.dart';
import 'road_trip_bingo_screen.dart';
import 'sign_scramble_screen.dart';
import 'sound_spy_screen.dart';
import 'windmill_screen.dart';

class GamesScreen extends StatelessWidget {
  final String gameId;
  final List<String> players;
  final Map<String, String> playerNumbers;
  final Map<String, String> playerSounds;
  final Map<String, String> spyObjects;
  final Map<String, String> playerColors;
  final Map<String, List<String>> playerSigns;
  final Map<String, dynamic> windmillConfig;

  const GamesScreen({
    super.key,
    required this.gameId,
    required this.players,
    this.playerNumbers = const {},
    this.playerSounds = const {},
    this.spyObjects = const {},
    this.playerColors = const {},
    this.playerSigns = const {},
    this.windmillConfig = const {},
  });

  @override
  Widget build(BuildContext context) {
    switch (gameId) {
      case 'numberPlateMatch':
        return NumberPlateMatchScreen(
          players: players,
          playerNumbers: playerNumbers,
        );
      case 'soundSpy':
        return SoundSpyScreen(
          players: players,
          playerSounds: playerSounds,
          spyObjects: spyObjects,
        );
      case 'windmill':
        return WindmillScreen(
          players: players,
          config: windmillConfig,
        );
      case 'roadTripBingo':
        return RoadTripBingoScreen(players: players);
      case 'colorChase':
        return ColorChaseScreen(
          players: players,
          playerColors: playerColors,
        );
      case 'signScramble':
        return SignScrambleScreen(
          players: players,
          playerSigns: playerSigns,
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
                SizedBox(height: Spacing.lg),
                Text('Game ID: $gameId'),
                SizedBox(height: Spacing.lg),
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
