import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Plays short game sound effects with desktop-friendly fallbacks.
///
/// On Linux, GStreamer often cannot decode MP3 without extra plugins, so OGG
/// assets are tried first. After a failed attempt, further plays are skipped
/// to avoid log spam.
class GameSoundPlayer {
  GameSoundPlayer({AudioPlayer? player}) : _player = player ?? AudioPlayer() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  final AudioPlayer _player;

  /// `null` = untested, `true` = works, `false` = unavailable on this device.
  bool? _assetPlaybackWorks;

  void dispose() => _player.dispose();

  /// Whether bundled asset sounds are known to work on this device.
  bool get assetSoundsAvailable => _assetPlaybackWorks != false;

  Future<bool> _soundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('soundEnabled') ?? true;
  }

  /// Asset paths to try for a sound name like `beep` (no extension).
  List<String> _assetCandidates(String soundName) {
    final base = 'sounds/$soundName';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      return ['$base.ogg', '$base.mp3'];
    }
    return ['$base.mp3', '$base.ogg'];
  }

  /// Plays a bundled sound by name (e.g. `beep`, `moo`).
  ///
  /// Returns `true` if audio actually played.
  Future<bool> playAsset(String soundName) async {
    if (!await _soundEnabled()) return false;
    if (_assetPlaybackWorks == false) return false;

    for (final path in _assetCandidates(soundName)) {
      try {
        await _player.stop();
        await _player.play(AssetSource(path));
        _assetPlaybackWorks = true;
        return true;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('GameSoundPlayer: failed $path ($e)');
        }
      }
    }

    _assetPlaybackWorks = false;
    return false;
  }

  /// Plays a user-recorded file from disk.
  Future<bool> playFile(String path) async {
    if (!await _soundEnabled()) return false;

    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GameSoundPlayer: failed file $path ($e)');
      }
      return false;
    }
  }
}
