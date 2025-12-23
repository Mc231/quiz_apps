import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../logger/logger_service.dart';
import 'quiz_sound_effect.dart';

/// Service for playing sound effects in quiz applications
///
/// Provides a simple interface to play predefined sound effects with
/// volume control and muting capabilities.
///
/// Example:
/// ```dart
/// final audioService = AudioService();
/// await audioService.initialize();
/// await audioService.playSoundEffect(QuizSoundEffect.correctAnswer);
/// ```
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;
  double _volume = 1.0;

  /// Whether sound effects are currently muted
  bool get isMuted => _isMuted;

  /// Current volume level (0.0 to 1.0)
  double get volume => _volume;

  /// Initializes the audio service
  ///
  /// Should be called before playing any sounds.
  /// Sets up the audio player with default settings.
  Future<void> initialize() async {
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(_volume);
  }

  /// Plays a specific sound effect
  ///
  /// [effect] - The sound effect to play
  /// [volume] - Optional volume override for this specific sound (0.0 to 1.0)
  ///
  /// Returns a Future that completes when the sound starts playing.
  /// If muted or an error occurs, the Future completes immediately.
  Future<void> playSoundEffect(QuizSoundEffect effect, {double? volume}) async {
    if (_isMuted) return;

    try {
      final effectVolume = volume ?? _volume;
      await _player.stop();
      await _player.setVolume(effectVolume);

      // Load asset bytes manually for package assets
      final ByteData data = await rootBundle.load(effect.assetPath);
      final bytes = data.buffer.asUint8List();

      await _player.play(BytesSource(bytes));
    } catch (e, stackTrace) {
      // Log error but don't crash - sound assets may be missing
      AppLogger.instance.warning(
        'Failed to play sound effect ${effect.name}',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sets the master volume for all sound effects
  ///
  /// [volume] - Volume level between 0.0 (silent) and 1.0 (maximum)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  /// Mutes or unmutes all sound effects
  ///
  /// [muted] - true to mute, false to unmute
  void setMuted(bool muted) {
    _isMuted = muted;
  }

  /// Toggles the muted state
  ///
  /// Returns the new muted state
  bool toggleMute() {
    _isMuted = !_isMuted;
    return _isMuted;
  }

  /// Disposes of resources used by the audio service
  ///
  /// Should be called when the service is no longer needed.
  Future<void> dispose() async {
    await _player.dispose();
  }

  /// Stops any currently playing sound
  Future<void> stop() async {
    await _player.stop();
  }

  /// Preloads a sound effect to reduce latency when playing
  ///
  /// [effect] - The sound effect to preload
  ///
  /// This is optional but recommended for frequently used sounds
  /// to ensure smooth playback without delays.
  Future<void> preload(QuizSoundEffect effect) async {
    try {
      // Load asset bytes to cache them in memory
      await rootBundle.load(effect.assetPath);
    } catch (e, stackTrace) {
      // Log error but don't fail - preloading is optional
      AppLogger.instance.warning(
        'Failed to preload sound effect ${effect.name}',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Preloads multiple sound effects at once
  ///
  /// [effects] - List of sound effects to preload
  Future<void> preloadMultiple(List<QuizSoundEffect> effects) async {
    await Future.wait(effects.map((effect) => preload(effect)));
  }
}
