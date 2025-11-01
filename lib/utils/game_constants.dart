import 'package:flutter/material.dart';

/// Game metadata class
class GameMetadata {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int minPlayers;
  final int maxPlayers;
  final GameDifficulty difficulty;

  const GameMetadata({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.minPlayers,
    required this.maxPlayers,
    required this.difficulty,
  });
}

/// Game difficulty levels
enum GameDifficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.hard:
        return 'Hard';
    }
  }

  IconData get icon {
    switch (this) {
      case GameDifficulty.easy:
        return Icons.sentiment_satisfied;
      case GameDifficulty.medium:
        return Icons.sentiment_neutral;
      case GameDifficulty.hard:
        return Icons.sentiment_dissatisfied;
    }
  }
}

/// Game identifiers
class GameIds {
  static const String numberPlateMatch = 'numberPlateMatch';
  static const String soundSpy = 'soundSpy';
  static const String windmill = 'windmill';
  static const String roadTripBingo = 'roadTripBingo';
  static const String colorChase = 'colorChase';
  static const String signScramble = 'signScramble';

  static const List<String> allGames = [
    numberPlateMatch,
    soundSpy,
    windmill,
    roadTripBingo,
    colorChase,
    signScramble,
  ];
}

/// Game configurations and metadata
class GameConfig {
  static const Map<String, GameMetadata> games = {
    GameIds.numberPlateMatch: GameMetadata(
      id: GameIds.numberPlateMatch,
      name: 'Number Match',
      description: 'Pick your number and spot matching plates',
      icon: Icons.format_list_numbered,
      color: Colors.purple,
      minPlayers: 2,
      maxPlayers: 8,
      difficulty: GameDifficulty.easy,
    ),
    GameIds.soundSpy: GameMetadata(
      id: GameIds.soundSpy,
      name: 'Sound Spy',
      description: 'Make sounds when you spot your chosen objects',
      icon: Icons.volume_up,
      color: Colors.green,
      minPlayers: 2,
      maxPlayers: 6,
      difficulty: GameDifficulty.medium,
    ),
    GameIds.windmill: GameMetadata(
      id: GameIds.windmill,
      name: 'Windmill Count',
      description: 'Count windmills along your journey',
      icon: Icons.wind_power,
      color: Colors.orange,
      minPlayers: 1,
      maxPlayers: 8,
      difficulty: GameDifficulty.easy,
    ),
    GameIds.roadTripBingo: GameMetadata(
      id: GameIds.roadTripBingo,
      name: 'Road Trip Bingo',
      description: 'Find common road trip sights to complete your bingo card',
      icon: Icons.grid_4x4,
      color: Colors.pink,
      minPlayers: 1,
      maxPlayers: 8,
      difficulty: GameDifficulty.easy,
    ),
    GameIds.colorChase: GameMetadata(
      id: GameIds.colorChase,
      name: 'Colour Chase',
      description: 'Compete to spot cars of specific colours',
      icon: Icons.palette,
      color: Colors.indigo,
      minPlayers: 2,
      maxPlayers: 8,
      difficulty: GameDifficulty.easy,
    ),
    GameIds.signScramble: GameMetadata(
      id: GameIds.signScramble,
      name: 'Sign Scramble',
      description: 'Collect letters from road signs to form words',
      icon: Icons.sign_language,
      color: Colors.teal,
      minPlayers: 1,
      maxPlayers: 6,
      difficulty: GameDifficulty.medium,
    ),
  };
}


