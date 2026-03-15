import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class SfxManager {
  static final SfxManager _instance = SfxManager._internal();
  static SfxManager get instance => _instance;

  SfxManager._internal();

  late final SoLoud _soloud;
  final Random _random = Random();
  bool _isInitialized = false;
  bool _initializationFailed = false;

  AudioSource? _collectSource;
  AudioSource? _deathScreamSource;
  AudioSource? _fallingSource;
  AudioSource? _flagSource;
  AudioSource? _footstepSource;
  AudioSource? _jumpSource;
  AudioSource? _dashSource;
  AudioSource? _damageSource;

  double _getRandomRate({double minRate = 0.85, double maxRate = 1.15}) {
    final rate = minRate + (_random.nextDouble() * (maxRate - minRate));
    return rate.clamp(0.75, 2.0); // Extra safety clamp
  }

  Future<void> initialize() async {
    if (_isInitialized || _initializationFailed) {
      return;
    }

    try {
      if (kIsWeb) {
        debugPrint('SFX Manager: Running on web, audio may be limited');
      }

      _soloud = SoLoud.instance;
      await _soloud.init();

      await _loadAudioSources();

      _isInitialized = true;
      debugPrint('SFX Manager: Successfully initialized');
    } on Exception catch (e) {
      _initializationFailed = true;
      debugPrint('SFX Manager: Failed to initialize (audio disabled): $e');

      if (kIsWeb) {
        debugPrint('SFX Manager: Continuing without audio on web platform');
      }
    }
  }

  Future<void> _loadAudioSources() async {
    try {
      _collectSource = await _soloud.loadAsset('assets/audios/sfx_collect.wav');
      _deathScreamSource =
          await _soloud.loadAsset('assets/audios/sfx_deathscream.wav');
      _fallingSource = await _soloud.loadAsset('assets/audios/sfx_falling.wav');
      _flagSource = await _soloud.loadAsset('assets/audios/sfx_flag.wav');
      _footstepSource =
          await _soloud.loadAsset('assets/audios/sfx_footstep.wav');
      _jumpSource = await _soloud.loadAsset('assets/audios/sfx_jump.wav');
      _dashSource = await _soloud.loadAsset('assets/audios/sfx_dash.wav');
      _damageSource = await _soloud.loadAsset('assets/audios/sfx_damage.wav');
    } on Exception catch (e) {
      debugPrint('Failed to load audio sources: $e');
    }
  }

  Future<SoundHandle?> playCollect({
    double volume = 1.0,
    double? rate,
    double? minRate,
    double? maxRate,
  }) async {
    return _playSound(
      _collectSource,
      volume: volume,
      rate: rate,
      minRate: minRate,
      maxRate: maxRate,
    );
  }

  Future<SoundHandle?> playDeathScream({
    double volume = 1.0,
    double? rate,
    double? minRate,
    double? maxRate,
  }) async {
    return _playSound(
      _deathScreamSource,
      volume: volume,
      rate: rate,
      minRate: minRate,
      maxRate: maxRate,
    );
  }

  Future<SoundHandle?> playFalling({
    double volume = 1.0,
    double? rate,
    double? minRate,
    double? maxRate,
  }) async {
    return _playSound(
      _fallingSource,
      volume: volume,
      rate: rate,
      minRate: minRate,
      maxRate: maxRate,
    );
  }

  Future<SoundHandle?> playFlag({
    double volume = 1.0,
    double? rate,
    double? minRate,
    double? maxRate,
  }) async {
    return _playSound(
      _flagSource,
      volume: volume,
      rate: rate,
      minRate: minRate,
      maxRate: maxRate,
    );
  }

  Future<SoundHandle?> playFootstep({
    double volume = 1.0,
    double? rate,
    double? minRate,
    double? maxRate,
  }) async {
    return _playSound(
      _footstepSource,
      volume: volume,
      rate: rate,
      minRate: minRate,
      maxRate: maxRate,
    );
  }

  Future<SoundHandle?> playJump({
    double volume = 0.5,
  }) async {
    return _playSound(
      _jumpSource,
      volume: volume,
    );
  }

  Future<SoundHandle?> playDash({
    double volume = 1.0,
    double? rate,
    double? minRate,
    double? maxRate,
  }) async {
    return _playSound(
      _dashSource,
      volume: volume,
      rate: rate,
      minRate: minRate,
      maxRate: maxRate,
    );
  }

  Future<SoundHandle?> playDamage({
    double volume = 1.0,
    double? rate,
    double? minRate,
    double? maxRate,
  }) async {
    return _playSound(
      _damageSource,
      volume: volume,
      rate: rate,
      minRate: minRate,
      maxRate: maxRate,
    );
  }

  Future<SoundHandle?> _playSound(
    AudioSource? source, {
    double volume = 1.0,
    double? rate,
    double? minRate,
    double? maxRate,
  }) async {
    if (!_isInitialized || _initializationFailed || source == null) {
      return null;
    }

    try {
      // Determine playback rate based on parameters
      final double playbackRate;
      if (rate != null) {
        // Use fixed rate if provided, but clamp to safe range
        playbackRate = rate.clamp(0.75, 2.0);
      } else if (minRate != null && maxRate != null) {
        // Use custom random range
        playbackRate = _getRandomRate(minRate: minRate, maxRate: maxRate);
      } else if (minRate != null) {
        // Use minRate as lower bound with default upper bound
        playbackRate = _getRandomRate(minRate: minRate);
      } else if (maxRate != null) {
        // Use maxRate as upper bound with default lower bound
        playbackRate = _getRandomRate(maxRate: maxRate);
      } else {
        // Use default random rate
        playbackRate = _getRandomRate();
      }

      final handle = await _soloud.play(source);

      if (volume != 1.0) {
        _soloud.setVolume(handle, volume);
      }

      _soloud.setRelativePlaySpeed(handle, playbackRate);

      return handle;
    } on Exception catch (e) {
      debugPrint('SFX Manager: Failed to play sound: $e');
      return null;
    }
  }

  Future<void> stopSound(SoundHandle handle) async {
    if (!_isInitialized || _initializationFailed) {
      return;
    }

    try {
      await _soloud.stop(handle);
    } catch (e) {
      debugPrint('SFX Manager: Failed to stop sound: $e');
    }
  }

  Future<void> stopAllSounds() async {
    if (!_isInitialized || _initializationFailed) {
      return;
    }

    try {
      await _soloud.disposeAllSources();
    } catch (e) {
      debugPrint('SFX Manager: Failed to stop all sounds: $e');
    }
  }

  Future<void> setGlobalVolume(double volume) async {
    if (!_isInitialized || _initializationFailed) {
      return;
    }

    try {
      _soloud.setGlobalVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('SFX Manager: Failed to set global volume: $e');
    }
  }

  bool get isInitialized => _isInitialized;

  Future<void> dispose() async {
    if (!_isInitialized && !_initializationFailed) {
      return;
    }

    if (_isInitialized) {
      try {
        await _soloud.disposeAllSources();

        if (_collectSource != null) {
          await _soloud.disposeSource(_collectSource!);
        }
        if (_deathScreamSource != null) {
          await _soloud.disposeSource(_deathScreamSource!);
        }
        if (_fallingSource != null) {
          await _soloud.disposeSource(_fallingSource!);
        }
        if (_flagSource != null) {
          await _soloud.disposeSource(_flagSource!);
        }
        if (_footstepSource != null) {
          await _soloud.disposeSource(_footstepSource!);
        }
        if (_jumpSource != null) {
          await _soloud.disposeSource(_jumpSource!);
        }
        if (_dashSource != null) {
          await _soloud.disposeSource(_dashSource!);
        }
        if (_damageSource != null) {
          await _soloud.disposeSource(_damageSource!);
        }

        _soloud.deinit();
      } catch (e) {
        debugPrint('SFX Manager: Failed to dispose: $e');
      }
    }

    _isInitialized = false;
    _initializationFailed = false;
  }
}
