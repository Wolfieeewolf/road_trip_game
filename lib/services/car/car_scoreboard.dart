import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../link/link_controller.dart';

class CarScoreboardEntry {
  const CarScoreboardEntry({
    required this.displayName,
    required this.isHost,
    this.score = 0,
  });

  final String displayName;
  final bool isHost;
  final int score;
}

class CarScoreboardSnapshot {
  const CarScoreboardSnapshot({
    required this.sessionCode,
    required this.entries,
    required this.updatedAt,
  });

  final String? sessionCode;
  final List<CarScoreboardEntry> entries;
  final DateTime updatedAt;

  bool get hasSession => sessionCode != null && sessionCode!.isNotEmpty;
}

class CarScoreboardController {
  CarScoreboardController(this._linkController);

  final LinkController _linkController;
  final ValueNotifier<CarScoreboardSnapshot> scoreboardNotifier =
      ValueNotifier<CarScoreboardSnapshot>(
    CarScoreboardSnapshot(
      sessionCode: null,
      entries: const <CarScoreboardEntry>[],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
  );

  bool _initialized = false;
  Map<String, int> _latestScores = <String, int>{};

  void initialize() {
    if (_initialized) {
      developer.log(
        'CarScoreboardController already initialized',
        name: 'CarScoreboardController',
      );
      return;
    }
    _initialized = true;
    developer.log(
      'CarScoreboardController initialized',
      name: 'CarScoreboardController',
    );
    _linkController.addListener(_rebuildSnapshot);
    _rebuildSnapshot();
  }

  void dispose() {
    if (!_initialized) return;
    _initialized = false;
    developer.log(
      'CarScoreboardController disposed',
      name: 'CarScoreboardController',
    );
    _linkController.removeListener(_rebuildSnapshot);
    scoreboardNotifier.dispose();
  }

  void updateScores(Map<String, int> scores) {
    final nextScores = Map<String, int>.from(scores);
    if (mapEquals(_latestScores, nextScores)) {
      return;
    }
    developer.log(
      'CarScoreboardController updating scores: ${scores.length} entries',
      name: 'CarScoreboardController',
    );
    _latestScores = nextScores;
    _rebuildSnapshot();
  }

  void _rebuildSnapshot() {
    final session = _linkController.session;
    if (session == null) {
      developer.log(
        'Rebuilding snapshot: no active session',
        name: 'CarScoreboardController',
      );
      final snapshot = CarScoreboardSnapshot(
        sessionCode: null,
        entries: const <CarScoreboardEntry>[],
        updatedAt: DateTime.now(),
      );
      if (_snapshotsEqual(scoreboardNotifier.value, snapshot)) {
        return;
      }
      scoreboardNotifier.value = snapshot;
      return;
    }

    final entries = session.sortedParticipants.map((participant) {
      return CarScoreboardEntry(
        displayName: participant.displayName,
        isHost: session.isHost(participant.id),
        score: _latestScores[participant.id] ?? 0,
      );
    }).toList();

    developer.log(
      'Rebuilding snapshot: session=${session.code}, entries=${entries.length}',
      name: 'CarScoreboardController',
    );

    final snapshot = CarScoreboardSnapshot(
      sessionCode: session.code,
      entries: entries,
      updatedAt: DateTime.now(),
    );
    if (_snapshotsEqual(scoreboardNotifier.value, snapshot)) {
      developer.log(
        'Snapshot unchanged, skipping notification',
        name: 'CarScoreboardController',
      );
      return;
    }
    scoreboardNotifier.value = snapshot;
    developer.log(
      'Snapshot updated and notified',
      name: 'CarScoreboardController',
    );
  }

  bool _snapshotsEqual(
    CarScoreboardSnapshot a,
    CarScoreboardSnapshot b,
  ) {
    if (a.sessionCode != b.sessionCode) return false;
    if (a.entries.length != b.entries.length) return false;
    for (var i = 0; i < a.entries.length; i++) {
      final left = a.entries[i];
      final right = b.entries[i];
      if (left.displayName != right.displayName ||
          left.isHost != right.isHost ||
          left.score != right.score) {
        return false;
      }
    }
    return true;
  }
}
