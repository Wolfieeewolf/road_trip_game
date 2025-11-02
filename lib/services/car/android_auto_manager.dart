import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import 'car_scoreboard.dart';

/// Handles pushing scoreboard updates to an Android Auto head unit.
///
/// The native Android Car App Library module can subscribe to the
/// `road_trip_car/android_auto` method channel and render the scoreboard using
/// templates that comply with Android Auto design constraints.
class AndroidAutoManager {
  AndroidAutoManager(this._scoreboardController);

  final CarScoreboardController _scoreboardController;
  static const MethodChannel _channel =
      MethodChannel('road_trip_car/android_auto');

  bool _initialized = false;
  bool _channelAvailable = true;
  int _successfulPushes = 0;
  int _failedPushes = 0;

  void initialize() {
    if (_initialized) {
      developer.log(
        'AndroidAutoManager already initialized',
        name: 'AndroidAutoManager',
      );
      return;
    }
    _initialized = true;
    developer.log(
      'AndroidAutoManager initialized, adding listener',
      name: 'AndroidAutoManager',
    );
    _scoreboardController.scoreboardNotifier.addListener(_pushSnapshot);
    _pushSnapshot();
  }

  void dispose() {
    if (!_initialized) return;
    developer.log(
      'AndroidAutoManager disposing (pushes: $_successfulPushes success, $_failedPushes failed)',
      name: 'AndroidAutoManager',
    );
    _scoreboardController.scoreboardNotifier.removeListener(_pushSnapshot);
    _initialized = false;
  }

  Future<void> _pushSnapshot() async {
    if (!_channelAvailable) {
      developer.log(
        'Skipping push - MethodChannel unavailable',
        name: 'AndroidAutoManager',
        level: 900,
      );
      return;
    }

    final snapshot = _scoreboardController.scoreboardNotifier.value;
    developer.log(
      'Pushing snapshot: session=${snapshot.sessionCode}, '
      'entries=${snapshot.entries.length}',
      name: 'AndroidAutoManager',
    );

    try {
      await _channel.invokeMethod<void>('updateScoreboard', {
        'sessionCode': snapshot.sessionCode,
        'updatedAt': snapshot.updatedAt.millisecondsSinceEpoch,
        'entries': snapshot.entries
            .map(
              (entry) => {
                'name': entry.displayName,
                'isHost': entry.isHost,
                'score': entry.score,
              },
            )
            .toList(),
      });
      _successfulPushes++;
      developer.log(
        'Successfully pushed snapshot ($_successfulPushes total)',
        name: 'AndroidAutoManager',
      );
    } on MissingPluginException catch (e) {
      _channelAvailable = false;
      _failedPushes++;
      developer.log(
        'MethodChannel not available - Android Auto not connected or app not running. '
        'This is normal if not using Android Auto. Error: $e',
        name: 'AndroidAutoManager',
        level: 900,
      );
    } on PlatformException catch (e, stackTrace) {
      _failedPushes++;
      developer.log(
        'Platform error pushing to Android Auto: ${e.code} - ${e.message}',
        name: 'AndroidAutoManager',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
    } catch (err, stackTrace) {
      _failedPushes++;
      developer.log(
        'Unexpected error pushing to Android Auto',
        name: 'AndroidAutoManager',
        error: err,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
  }
}
