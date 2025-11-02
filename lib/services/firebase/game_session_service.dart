import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

import '../../models/game_session.dart';

class GameSessionService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const String _sessionsPath = 'sessions';

  // Generate a random 6-character session code
  String generateSessionCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excluding confusing chars
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Create a new game session
  Future<GameSession> createSession({
    required String gameType,
    required String hostId,
    required List<String> players,
  }) async {
    // Generate a unique session code
    String sessionCode = generateSessionCode();

    // Check if code already exists (rare but possible)
    var snapshot = await _database.ref('$_sessionsPath/$sessionCode').get();
    while (snapshot.exists) {
      sessionCode = generateSessionCode();
      snapshot = await _database.ref('$_sessionsPath/$sessionCode').get();
    }

    final session = GameSession.create(
      sessionId: sessionCode,
      gameType: gameType,
      hostId: hostId,
      initialPlayers: players,
    );

    // Save to Firebase
    await _database.ref('$_sessionsPath/$sessionCode').set(session.toJson());

    return session;
  }

  // Join an existing session
  Future<GameSession?> joinSession({
    required String sessionCode,
    required String playerName,
  }) async {
    final sessionRef = _database.ref('$_sessionsPath/$sessionCode');
    final snapshot = await sessionRef.get();

    if (!snapshot.exists) {
      return null; // Session not found
    }

    final sessionData = Map<String, dynamic>.from(snapshot.value as Map);
    final session = GameSession.fromJson(sessionData);

    // Check if session is still accepting players
    if (session.status == 'completed') {
      return null; // Session already completed
    }

    // Add player if not already in session
    if (!session.players.contains(playerName)) {
      final updatedSession = session.addPlayer(playerName);
      await sessionRef.update(updatedSession.toJson());
      return updatedSession;
    }

    return session;
  }

  // Get a session by code
  Future<GameSession?> getSession(String sessionCode) async {
    final snapshot = await _database.ref('$_sessionsPath/$sessionCode').get();

    if (!snapshot.exists) {
      return null;
    }

    final sessionData = Map<String, dynamic>.from(snapshot.value as Map);
    return GameSession.fromJson(sessionData);
  }

  // Update player score
  Future<void> updateScore({
    required String sessionCode,
    required String playerName,
    required int score,
  }) async {
    final sessionRef = _database.ref('$_sessionsPath/$sessionCode');

    await sessionRef.child('scores/$playerName').set(score);

    // Update status to active if it was waiting
    final snapshot = await sessionRef.child('status').get();
    if (snapshot.exists && snapshot.value == 'waiting') {
      await sessionRef.update({
        'status': 'active',
        'startedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Increment player score
  Future<void> incrementScore({
    required String sessionCode,
    required String playerName,
    int increment = 1,
  }) async {
    final sessionRef = _database.ref('$_sessionsPath/$sessionCode');
    final scoreRef = sessionRef.child('scores/$playerName');

    final snapshot = await scoreRef.get();
    final currentScore = snapshot.exists ? (snapshot.value as int? ?? 0) : 0;

    await updateScore(
      sessionCode: sessionCode,
      playerName: playerName,
      score: currentScore + increment,
    );
  }

  // Update game-specific data
  Future<void> updateGameData({
    required String sessionCode,
    required Map<String, dynamic> data,
  }) async {
    final sessionRef = _database.ref('$_sessionsPath/$sessionCode/gameData');
    await sessionRef.update(data);
  }

  // Start a session
  Future<void> startSession(String sessionCode) async {
    await _database.ref('$_sessionsPath/$sessionCode').update({
      'status': 'active',
      'startedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Complete a session
  Future<void> completeSession(String sessionCode) async {
    await _database.ref('$_sessionsPath/$sessionCode').update({
      'status': 'completed',
      'completedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Listen to session changes in real-time
  Stream<GameSession?> watchSession(String sessionCode) {
    return _database
        .ref('$_sessionsPath/$sessionCode')
        .onValue
        .map((event) {
      if (!event.snapshot.exists) {
        return null;
      }

      final sessionData = Map<String, dynamic>.from(event.snapshot.value as Map);
      return GameSession.fromJson(sessionData);
    });
  }

  // Listen to score changes for a specific player
  Stream<int> watchPlayerScore({
    required String sessionCode,
    required String playerName,
  }) {
    return _database
        .ref('$_sessionsPath/$sessionCode/scores/$playerName')
        .onValue
        .map((event) {
      if (!event.snapshot.exists) {
        return 0;
      }
      return event.snapshot.value as int? ?? 0;
    });
  }

  // Delete a session (for cleanup)
  Future<void> deleteSession(String sessionCode) async {
    await _database.ref('$_sessionsPath/$sessionCode').remove();
  }

  // Get all active sessions for a game type (optional, for lobby)
  Stream<List<GameSession>> watchActiveSessions(String gameType) {
    return _database
        .ref(_sessionsPath)
        .orderByChild('gameType')
        .equalTo(gameType)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) {
        return <GameSession>[];
      }

      final sessionsMap = Map<String, dynamic>.from(event.snapshot.value as Map);
      return sessionsMap.entries
          .map((entry) {
            final sessionData = Map<String, dynamic>.from(entry.value as Map);
            return GameSession.fromJson(sessionData);
          })
          .where((session) => session.status == 'active' || session.status == 'waiting')
          .toList();
    });
  }

  // Remove a player from a session
  Future<void> removePlayer({
    required String sessionCode,
    required String playerName,
  }) async {
    final sessionRef = _database.ref('$_sessionsPath/$sessionCode');
    final snapshot = await sessionRef.get();

    if (!snapshot.exists) return;

    final sessionData = Map<String, dynamic>.from(snapshot.value as Map);
    final session = GameSession.fromJson(sessionData);
    final updatedSession = session.removePlayer(playerName);

    // If no players left, delete the session
    if (updatedSession.players.isEmpty) {
      await deleteSession(sessionCode);
    } else {
      await sessionRef.update(updatedSession.toJson());
    }
  }
}
