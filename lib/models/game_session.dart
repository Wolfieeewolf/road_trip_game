import 'package:flutter/foundation.dart';

@immutable
class GameSession {
  final String sessionId;
  final String gameType;
  final Map<String, int> scores;
  final List<String> players;
  final String hostId;
  final String status; // 'waiting', 'active', 'completed'
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> gameData; // Game-specific data

  const GameSession({
    required this.sessionId,
    required this.gameType,
    required this.scores,
    required this.players,
    required this.hostId,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.gameData = const {},
  });

  // Create a new session
  factory GameSession.create({
    required String sessionId,
    required String gameType,
    required String hostId,
    required List<String> initialPlayers,
  }) {
    final scores = <String, int>{};
    for (final player in initialPlayers) {
      scores[player] = 0;
    }

    return GameSession(
      sessionId: sessionId,
      gameType: gameType,
      scores: scores,
      players: initialPlayers,
      hostId: hostId,
      status: 'waiting',
      createdAt: DateTime.now(),
    );
  }

  // Copy with method
  GameSession copyWith({
    String? sessionId,
    String? gameType,
    Map<String, int>? scores,
    List<String>? players,
    String? hostId,
    String? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? gameData,
  }) {
    return GameSession(
      sessionId: sessionId ?? this.sessionId,
      gameType: gameType ?? this.gameType,
      scores: scores ?? Map.from(this.scores),
      players: players ?? List.from(this.players),
      hostId: hostId ?? this.hostId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      gameData: gameData ?? Map.from(this.gameData),
    );
  }

  // Update a player's score
  GameSession updateScore(String playerName, int newScore) {
    final updatedScores = Map<String, int>.from(scores);
    updatedScores[playerName] = newScore;

    return copyWith(
      scores: updatedScores,
      status: status == 'waiting' ? 'active' : status,
      startedAt: startedAt ?? DateTime.now(),
    );
  }

  // Add a player
  GameSession addPlayer(String playerName) {
    if (players.contains(playerName)) {
      return this;
    }

    final updatedPlayers = List<String>.from(players)..add(playerName);
    final updatedScores = Map<String, int>.from(scores);
    updatedScores[playerName] = 0;

    return copyWith(
      players: updatedPlayers,
      scores: updatedScores,
    );
  }

  // Remove a player
  GameSession removePlayer(String playerName) {
    final updatedPlayers = List<String>.from(players)..remove(playerName);
    final updatedScores = Map<String, int>.from(scores);
    updatedScores.remove(playerName);

    return copyWith(
      players: updatedPlayers,
      scores: updatedScores,
    );
  }

  // Start the game
  GameSession start() {
    return copyWith(
      status: 'active',
      startedAt: DateTime.now(),
    );
  }

  // Complete the game
  GameSession complete() {
    return copyWith(
      status: 'completed',
      completedAt: DateTime.now(),
    );
  }

  // Get winner(s)
  List<String> get winners {
    if (scores.isEmpty) return [];

    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    return scores.entries
        .where((entry) => entry.value == maxScore)
        .map((entry) => entry.key)
        .toList();
  }

  // Get player rank
  int getPlayerRank(String playerName) {
    final sortedScores = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedScores.indexWhere((entry) => entry.key == playerName) + 1;
  }

  // Update game-specific data
  GameSession updateGameData(Map<String, dynamic> data) {
    return copyWith(
      gameData: {...gameData, ...data},
    );
  }

  // Serialization for Firebase
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'gameType': gameType,
      'scores': scores,
      'players': players,
      'hostId': hostId,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'startedAt': startedAt?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'gameData': gameData,
    };
  }

  // Deserialization from Firebase
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      sessionId: json['sessionId'] as String,
      gameType: json['gameType'] as String,
      scores: Map<String, int>.from(json['scores'] as Map? ?? {}),
      players: List<String>.from(json['players'] as List? ?? []),
      hostId: json['hostId'] as String,
      status: json['status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      startedAt: json['startedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['startedAt'] as int)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
          : null,
      gameData: Map<String, dynamic>.from(json['gameData'] as Map? ?? {}),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameSession && other.sessionId == sessionId;
  }

  @override
  int get hashCode => sessionId.hashCode;
}
