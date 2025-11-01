import 'package:flutter/material.dart';

@immutable
class Player {
  final String id;
  final String name;
  final String? avatarUrl;
  final Map<String, GameStats> gameStats;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime lastPlayedAt;

  Player({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.gameStats = const {},
    this.preferences = const {},
    DateTime? createdAt,
    DateTime? lastPlayedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    lastPlayedAt = lastPlayedAt ?? DateTime.now();

  // Create a new player
  factory Player.create({
    required String name,
    String? avatarUrl,
  }) {
    return Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      avatarUrl: avatarUrl,
      gameStats: const {},
      preferences: const {},
    );
  }

  // Copy with method for immutability
  Player copyWith({
    String? name,
    String? avatarUrl,
    Map<String, GameStats>? gameStats,
    Map<String, dynamic>? preferences,
    DateTime? lastPlayedAt,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gameStats: gameStats ?? Map.from(this.gameStats),
      preferences: preferences ?? Map.from(this.preferences),
      createdAt: createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  // Update stats for a specific game
  Player updateGameStats(String gameId, GameStats stats) {
    final updatedStats = Map<String, GameStats>.from(gameStats);
    updatedStats[gameId] = stats;
    return copyWith(
      gameStats: updatedStats,
      lastPlayedAt: DateTime.now(),
    );
  }

  // Update player preferences
  Player updatePreferences(Map<String, dynamic> newPreferences) {
    return copyWith(
      preferences: {
        ...preferences,
        ...newPreferences,
      },
    );
  }

  // Get total score across all games
  int get totalScore {
    return gameStats.values.fold(0, 
      (sum, stats) => sum + (stats.totalScore ?? 0));
  }

  // Get total games played
  int get totalGamesPlayed {
    return gameStats.values.fold(0, 
      (sum, stats) => sum + (stats.gamesPlayed ?? 0));
  }

  // Get favorite game based on play count
  String? get favoriteGame {
    if (gameStats.isEmpty) return null;
    
    return gameStats.entries
      .reduce((a, b) => 
        (a.value.gamesPlayed ?? 0) > (b.value.gamesPlayed ?? 0) ? a : b)
      .key;
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'gameStats': gameStats.map(
        (key, value) => MapEntry(key, value.toJson())
      ),
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
    };
  }

  // Deserialization
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      gameStats: (json['gameStats'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key, 
          GameStats.fromJson(value as Map<String, dynamic>),
        ),
      ),
      preferences: json['preferences'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastPlayedAt: DateTime.parse(json['lastPlayedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@immutable
class GameStats {
  final int? totalScore;
  final int? gamesPlayed;
  final int? highScore;
  final DateTime? bestGame;
  final Map<String, dynamic>? gameSpecificStats;

  const GameStats({
    this.totalScore,
    this.gamesPlayed,
    this.highScore,
    this.bestGame,
    this.gameSpecificStats,
  });

  factory GameStats.create() {
    return const GameStats(
      totalScore: 0,
      gamesPlayed: 0,
      highScore: 0,
      gameSpecificStats: {},
    );
  }

  GameStats copyWith({
    int? totalScore,
    int? gamesPlayed,
    int? highScore,
    DateTime? bestGame,
    Map<String, dynamic>? gameSpecificStats,
  }) {
    return GameStats(
      totalScore: totalScore ?? this.totalScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      highScore: highScore ?? this.highScore,
      bestGame: bestGame ?? this.bestGame,
      gameSpecificStats: gameSpecificStats ?? this.gameSpecificStats,
    );
  }

  GameStats addGame({
    required int score,
    Map<String, dynamic>? additionalStats,
  }) {
    final newTotalScore = (totalScore ?? 0) + score;
    final newGamesPlayed = (gamesPlayed ?? 0) + 1;
    final newHighScore = (highScore ?? 0) < score ? score : highScore;
    final newBestGame = (highScore ?? 0) < score ? DateTime.now() : bestGame;

    return copyWith(
      totalScore: newTotalScore,
      gamesPlayed: newGamesPlayed,
      highScore: newHighScore,
      bestGame: newBestGame,
      gameSpecificStats: additionalStats != null
          ? {...?gameSpecificStats, ...additionalStats}
          : gameSpecificStats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScore': totalScore,
      'gamesPlayed': gamesPlayed,
      'highScore': highScore,
      'bestGame': bestGame?.toIso8601String(),
      'gameSpecificStats': gameSpecificStats,
    };
  }

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      totalScore: json['totalScore'] as int?,
      gamesPlayed: json['gamesPlayed'] as int?,
      highScore: json['highScore'] as int?,
      bestGame: json['bestGame'] != null 
          ? DateTime.parse(json['bestGame'] as String)
          : null,
      gameSpecificStats: json['gameSpecificStats'] as Map<String, dynamic>?,
    );
  }
}

// Game-specific stats classes
class NumberPlateStats {
  final int uniquePlates;
  final int specialPlates;
  final List<String> recentPlates;

  NumberPlateStats({
    this.uniquePlates = 0,
    this.specialPlates = 0,
    this.recentPlates = const [],
  });

  Map<String, dynamic> toJson() => {
    'uniquePlates': uniquePlates,
    'specialPlates': specialPlates,
    'recentPlates': recentPlates,
  };

  factory NumberPlateStats.fromJson(Map<String, dynamic> json) {
    return NumberPlateStats(
      uniquePlates: json['uniquePlates'] as int,
      specialPlates: json['specialPlates'] as int,
      recentPlates: List<String>.from(json['recentPlates'] as List),
    );
  }
}

class SoundSpyStats {
  final int correctGuesses;
  final int totalSpots;
  final Map<String, int> soundUsage;

  SoundSpyStats({
    this.correctGuesses = 0,
    this.totalSpots = 0,
    this.soundUsage = const {},
  });

  Map<String, dynamic> toJson() => {
    'correctGuesses': correctGuesses,
    'totalSpots': totalSpots,
    'soundUsage': soundUsage,
  };

  factory SoundSpyStats.fromJson(Map<String, dynamic> json) {
    return SoundSpyStats(
      correctGuesses: json['correctGuesses'] as int,
      totalSpots: json['totalSpots'] as int,
      soundUsage: Map<String, int>.from(json['soundUsage'] as Map),
    );
  }
}

class WindmillStats {
  final int totalWindmills;
  final int longestStreak;
  final double averagePerGame;

  WindmillStats({
    this.totalWindmills = 0,
    this.longestStreak = 0,
    this.averagePerGame = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'totalWindmills': totalWindmills,
    'longestStreak': longestStreak,
    'averagePerGame': averagePerGame,
  };

  factory WindmillStats.fromJson(Map<String, dynamic> json) {
    return WindmillStats(
      totalWindmills: json['totalWindmills'] as int,
      longestStreak: json['longestStreak'] as int,
      averagePerGame: json['averagePerGame'] as double,
    );
  }
}

// Example usage:
/*
final player = Player.create(name: 'John Doe');

// After playing a number plate game
final numberPlateStats = NumberPlateStats(
  uniquePlates: 10,
  specialPlates: 2,
  recentPlates: ['ABC123', 'XYZ789'],
);

final updatedPlayer = player.updateGameStats(
  'numberPlateClassic',
  GameStats(
    totalScore: 12,
    gamesPlayed: 1,
    highScore: 12,
    gameSpecificStats: numberPlateStats.toJson(),
  ),
);

// Save player data
final jsonData = updatedPlayer.toJson();
// Later, restore player data
final restoredPlayer = Player.fromJson(jsonData);
*/


