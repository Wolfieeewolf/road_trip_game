import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_carplay/flutter_carplay.dart';

import 'car_scoreboard.dart';

/// Handles presenting the live scoreboard on Apple CarPlay.
///
/// Uses a [CPListTemplate] so CarPlay-compatible dashboards can show the
/// current session code and participant list without needing to unlock the
/// phone. The template updates whenever the [CarScoreboardController] emits a
/// new snapshot.
class CarPlayManager {
  CarPlayManager(this._scoreboardController) {
    if (!_isSupported) {
      developer.log(
        'CarPlay not supported on this platform',
        name: 'CarPlayManager',
      );
      return;
    }
    _carPlay = FlutterCarplay();
    developer.log('CarPlayManager created', name: 'CarPlayManager');
  }

  final CarScoreboardController _scoreboardController;
  FlutterCarplay? _carPlay;
  bool _initialized = false;
  int _templateRefreshes = 0;

  bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  void initialize() {
    if (_initialized || !_isSupported) {
      if (_initialized) {
        developer.log(
          'CarPlayManager already initialized',
          name: 'CarPlayManager',
        );
      }
      return;
    }
    _initialized = true;
    developer.log(
      'CarPlayManager initialized, adding listeners',
      name: 'CarPlayManager',
    );
    _scoreboardController.scoreboardNotifier.addListener(_refreshTemplate);
    _carPlay?.addListenerOnConnectionChange((_) {
      developer.log(
        'CarPlay connection state changed',
        name: 'CarPlayManager',
      );
      _refreshTemplate();
    });
    _refreshTemplate();
  }

  void dispose() {
    if (!_initialized) return;
    developer.log(
      'CarPlayManager disposing (refreshes: $_templateRefreshes)',
      name: 'CarPlayManager',
    );
    _initialized = false;
    _scoreboardController.scoreboardNotifier.removeListener(_refreshTemplate);
    _carPlay?.removeListenerOnConnectionChange();
  }

  void _refreshTemplate() {
    if (_carPlay == null) {
      developer.log(
        'Cannot refresh template - CarPlay not available',
        name: 'CarPlayManager',
        level: 900,
      );
      return;
    }

    _templateRefreshes++;
    final snapshot = _scoreboardController.scoreboardNotifier.value;
    developer.log(
      'Refreshing template ($_templateRefreshes): '
      'session=${snapshot.sessionCode}, entries=${snapshot.entries.length}',
      name: 'CarPlayManager',
    );

    try {
      final template = CPListTemplate(
        title: 'Road Trip Scoreboard',
        sections: snapshot.hasSession
            ? _buildActiveSections(snapshot)
            : _buildIdleSections(),
        systemIcon: 'list.bullet',
      );

      FlutterCarplay.setRootTemplate(
        rootTemplate: template,
        animated: true,
      );
      developer.log(
        'Template set successfully',
        name: 'CarPlayManager',
      );
    } catch (err, stackTrace) {
      developer.log(
        'Error setting CarPlay template',
        name: 'CarPlayManager',
        error: err,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
  }

  List<CPListSection> _buildIdleSections() {
    return [
      CPListSection(
        header: 'Status',
        items: [
          CPListItem(
            text: 'Waiting for game',
            detailText: 'Start a game from your phone.',
            onPress: (complete, _) => complete(),
          ),
        ],
      ),
    ];
  }

  List<CPListSection> _buildActiveSections(
    CarScoreboardSnapshot snapshot,
  ) {
    final infoItems = [
      CPListItem(
        text: 'Session code',
        detailText: snapshot.sessionCode ?? '-',
        onPress: (complete, _) => complete(),
      ),
      CPListItem(
        text: 'Players',
        detailText: snapshot.entries.length.toString(),
        onPress: (complete, _) => complete(),
      ),
    ];

    final participantItems = snapshot.entries.map((entry) {
      final details = <String>['Score: ${entry.score}'];
      if (entry.isHost) {
        details.add('Host');
      }

      return CPListItem(
        text: entry.displayName,
        detailText: details.join(', '),
        accessoryType: entry.isHost
            ? CPListItemAccessoryType.cloud
            : CPListItemAccessoryType.none,
        onPress: (complete, _) => complete(),
      );
    }).toList();

    return [
      CPListSection(header: 'Game info', items: infoItems),
      CPListSection(
        header: 'Players',
        items: participantItems.isEmpty
            ? [
                CPListItem(
                  text: 'Waiting for players',
                  detailText: 'Invite friends to join.',
                  onPress: (complete, _) => complete(),
                ),
              ]
            : participantItems,
      ),
    ];
  }
}
