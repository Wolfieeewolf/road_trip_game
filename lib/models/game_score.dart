import 'package:flutter/foundation.dart';

@immutable
class GameScore {
  final String gameId;
  final String playerId;
  final DateTime timestamp;
  final int score;
  final Map<String, dynamic> details;
  final GameLocation? location;
  final Duration? duration;
  final List<GameEvent> events;

  GameScore({
    required this.gameId,
    required this.playerId,
    required this.score,
    DateTime? timestamp,
    this.details = const {},
    this.location,
    this.duration,
    this.events = const [],
  }) : timestamp = timestamp ?? DateTime.now();

  // Create a new game score
  factory GameScore.create({
    required String gameId,
    required String playerId,
    required int score,
    Map<String, dynamic> details = const {},
    GameLocation? location,
    Duration? duration,
    List<GameEvent> events = const [],
  }) {
    return GameScore(
      gameId: gameId,
      playerId: playerId,
      score: score,
      details: details,
      location: location,
      duration: duration,
      events: events,
    );
  }

  // Copy with method for immutability
  GameScore copyWith({
    int? score,
    Map<String, dynamic>? details,
    GameLocation? location,
    Duration? duration,
    List<GameEvent>? events,
  }) {
    return GameScore(
      gameId: gameId,
      playerId: playerId,
      timestamp: timestamp,
      score: score ?? this.score,
      details: details ?? Map.from(this.details),
      location: location ?? this.location,
      duration: duration ?? this.duration,
      events: events ?? List.from(this.events),
    );
  }

  // Add an event to the game score
  GameScore addEvent(GameEvent event) {
    return copyWith(
      events: [...events, event],
    );
  }

  // Update score
  GameScore updateScore(int newScore) {
    return copyWith(
      score: newScore,
    );
  }

  // Get specific game details
  T? getDetail<T>(String key) {
    return details[key] as T?;
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'playerId': playerId,
      'timestamp': timestamp.toIso8601String(),
      'score': score,
      'details': details,
      'location': location?.toJson(),
      'duration': duration?.inSeconds,
      'events': events.map((e) => e.toJson()).toList(),
    };
  }

  // Deserialization
  factory GameScore.fromJson(Map<String, dynamic> json) {
    return GameScore(
      gameId: json['gameId'] as String,
      playerId: json['playerId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      score: json['score'] as int,
      details: json['details'] as Map<String, dynamic>,
      location: json['location'] != null
          ? GameLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      events: (json['events'] as List)
          .map((e) => GameEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameScore &&
        other.gameId == gameId &&
        other.playerId == playerId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(gameId, playerId, timestamp);
}

@immutable
class GameEvent {
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  GameEvent({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    return GameEvent(
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>,
    );
  }
}

@immutable
class GameLocation {
  final double latitude;
  final double longitude;
  final String? placeName;
  final String? country;

  const GameLocation({
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'placeName': placeName,
      'country': country,
    };
  }

  factory GameLocation.fromJson(Map<String, dynamic> json) {
    return GameLocation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      placeName: json['placeName'] as String?,
      country: json['country'] as String?,
    );
  }
}

// Game-specific score details classes
class NumberPlateScoreDetails {
  final List<String> plates;
  final int regularPlates;
  final int specialPlates;
  final List<String> uniqueStates;

  NumberPlateScoreDetails({
    this.plates = const [],
    this.regularPlates = 0,
    this.specialPlates = 0,
    this.uniqueStates = const [],
  });

  Map<String, dynamic> toJson() => {
    'plates': plates,
    'regularPlates': regularPlates,
    'specialPlates': specialPlates,
    'uniqueStates': uniqueStates,
  };

  factory NumberPlateScoreDetails.fromJson(Map<String, dynamic> json) {
    return NumberPlateScoreDetails(
      plates: List<String>.from(json['plates'] as List),
      regularPlates: json['regularPlates'] as int,
      specialPlates: json['specialPlates'] as int,
      uniqueStates: List<String>.from(json['uniqueStates'] as List),
    );
  }
}

class SoundSpyScoreDetails {
  final String sound;
  final String object;
  final int spots;
  final int correctGuesses;
  final List<String> guessedBy;

  SoundSpyScoreDetails({
    required this.sound,
    required this.object,
    this.spots = 0,
    this.correctGuesses = 0,
    this.guessedBy = const [],
  });

  Map<String, dynamic> toJson() => {
    'sound': sound,
    'object': object,
    'spots': spots,
    'correctGuesses': correctGuesses,
    'guessedBy': guessedBy,
  };

  factory SoundSpyScoreDetails.fromJson(Map<String, dynamic> json) {
    return SoundSpyScoreDetails(
      sound: json['sound'] as String,
      object: json['object'] as String,
      spots: json['spots'] as int,
      correctGuesses: json['correctGuesses'] as int,
      guessedBy: List<String>.from(json['guessedBy'] as List),
    );
  }
}

class WindmillScoreDetails {
  final int windmillCount;
  final int streak;
  final List<GameLocation> windmillLocations;

  WindmillScoreDetails({
    this.windmillCount = 0,
    this.streak = 0,
    this.windmillLocations = const [],
  });

  Map<String, dynamic> toJson() => {
    'windmillCount': windmillCount,
    'streak': streak,
    'windmillLocations': windmillLocations.map((l) => l.toJson()).toList(),
  };

  factory WindmillScoreDetails.fromJson(Map<String, dynamic> json) {
    return WindmillScoreDetails(
      windmillCount: json['windmillCount'] as int,
      streak: json['streak'] as int,
      windmillLocations: (json['windmillLocations'] as List)
          .map((l) => GameLocation.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Example usage:
/*
// Create a new game score for Number Plate game
final plateDetails = NumberPlateScoreDetails(
  plates: ['ABC123', 'XYZ789'],
  regularPlates: 1,
  specialPlates: 1,
  uniqueStates: ['NY', 'CA'],
);

final gameScore = GameScore.create(
  gameId: 'numberPlateClassic',
  playerId: 'player123',
  score: 3,
  details: plateDetails.toJson(),
  location: GameLocation(
    latitude: 40.7128,
    longitude: -74.0060,
    placeName: 'Sydney',
    country: 'Australia',
  ),
  duration: Duration(minutes: 30),
);

// Add events during gameplay
final updatedScore = gameScore.addEvent(
  GameEvent(
    type: 'plate_spotted',
    data: {
      'plate': 'ABC123',
      'type': 'regular',
    },
  ),
);

// Save score
final jsonData = updatedScore.toJson();
// Later, restore score
final restoredScore = GameScore.fromJson(jsonData);
*/


