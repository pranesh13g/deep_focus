import 'dart:async';

import 'package:deep_focus/core/services/notification_service.dart';
import 'package:deep_focus/features/settings/viewmodel/settings_provider.dart';
import 'package:deep_focus/features/sounds/viewmodel/audio_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TimerPhase { work, shortBreak, longBreak }

class TimerProvider extends ChangeNotifier {
  SettingsProvider? _settings;
  AudioProvider? _audio;

  int _currentRound = 1;
  TimerPhase _phase = TimerPhase.work;
  int _remainingSeconds = 1500; // Default 25 mins
  bool _isRunning = false;
  Timer? _timer;

  TimerProvider();

  /// Syncs settings and audio provider from the UI layer.
  void setDependencies(SettingsProvider settings, AudioProvider audio) {
    final oldSettings = _settings;
    final bool audioProviderChanged = _audio != audio;
    _settings = settings;
    _audio = audio;

    // Only update remaining seconds if settings actually changed and timer isn't running
    if (!_isRunning) {
      if (oldSettings == null || _hasDurationsChanged(oldSettings, settings)) {
        _remainingSeconds = _getInitialSeconds(settings, _phase);
      }
    }

    // Only sync audio when the AudioProvider instance itself is replaced (first
    // load or hot-restart), NOT on every notifyListeners() from AudioProvider.
    // Calling _syncAudio() on every position/state update from AudioProvider
    // immediately re-starts playback after the user manually pauses the sound.
    if (_isRunning && audioProviderChanged) {
      _syncAudio();
    }

    notifyListeners();
  }

  int _getInitialSeconds(SettingsProvider settings, TimerPhase phase) {
    switch (phase) {
      case TimerPhase.work:
        return settings.workDurationSeconds;
      case TimerPhase.shortBreak:
        return settings.shortBreakSeconds;
      case TimerPhase.longBreak:
        return settings.longBreakSeconds;
    }
  }

  bool _hasDurationsChanged(SettingsProvider old, SettingsProvider current) {
    return old.workDurationSeconds != current.workDurationSeconds ||
        old.shortBreakSeconds != current.shortBreakSeconds ||
        old.longBreakSeconds != current.longBreakSeconds;
  }

  int get currentRound => _currentRound;
  int get totalRounds => _settings?.totalRounds ?? 4;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  TimerPhase get phase => _phase;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get minutesPart => formattedTime.split(':')[0];
  String get secondsPart => formattedTime.split(':')[1];

  String get phaseLabel {
    switch (_phase) {
      case TimerPhase.work:
        return 'PRODUCTIVITY SESSION';
      case TimerPhase.shortBreak:
        return 'QUICK BREAK';
      case TimerPhase.longBreak:
        return 'FULL BREAK';
    }
  }

  // ── Controls ───────────────────────────────────────────────────────────────
  void togglePause() {
    _isRunning = !_isRunning;
    if (_isRunning) {
      _startTimer();
      _syncAudio();
    } else {
      pause();
    }
  }

  void pause() {
    _isRunning = false;
    _timer?.cancel();
    _audio?.pauseAudio();
    notifyListeners();
  }

  void _syncAudio() {
    if (_phase == TimerPhase.work) {
      _audio?.playSelected();
    } else {
      _audio?.playBreakSound();
    }
  }

  /// Reset: stop timer, go back to round 1 work phase, stay paused.
  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _currentRound = 1;
    _phase = TimerPhase.work;
    _remainingSeconds = _settings?.workDurationSeconds ?? 1500;
    _audio?.pauseAudio();
    notifyListeners();
  }

  /// Skip: jump to the next phase immediately.
  void skip() {
    _timer?.cancel();
    _advancePhase();
  }

  // ── Internal ───────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _advancePhase();
      }
    });
  }

  void _advancePhase() {
    final settings = _settings;
    if (settings == null) return;

    final oldPhase = _phase;

    switch (_phase) {
      case TimerPhase.work:
        final isLongBreak = _currentRound % settings.totalRounds == 0;
        _phase = isLongBreak ? TimerPhase.longBreak : TimerPhase.shortBreak;
        _remainingSeconds = isLongBreak
            ? settings.longBreakSeconds
            : settings.shortBreakSeconds;
        break;

      case TimerPhase.shortBreak:
      case TimerPhase.longBreak:
        if (_currentRound < settings.totalRounds) {
          _currentRound++;
        } else {
          _currentRound = 1;
          _isRunning = false;
          _phase = TimerPhase.work;
          _remainingSeconds = settings.workDurationSeconds;
          _audio?.pauseAudio();
          notifyListeners();
          return;
        }
        _phase = TimerPhase.work;
        _remainingSeconds = settings.workDurationSeconds;
        break;
    }

    if (oldPhase == TimerPhase.work) {
      final isLong = _phase == TimerPhase.longBreak;
      _triggerNotification(
        isLong ? 'Full Break Started' : ' Quick Break Started',
        isLong
            ? 'Take a good rest. You earned it!'
            : 'Stretch a bit and relax.',
      );
    }

    if (_isRunning) {
      _startTimer();
      _syncAudio();
    }
    notifyListeners();
  }

  void _triggerNotification(String title, String body) {
    HapticFeedback.vibrate(); // Immediate vibration
    NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
