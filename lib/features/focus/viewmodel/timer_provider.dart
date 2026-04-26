import 'dart:async';

import 'package:deep_focus/features/settings/viewmodel/settings_provider.dart';
import 'package:flutter/material.dart';

enum TimerPhase { work, shortBreak, longBreak }

class TimerProvider extends ChangeNotifier {
  SettingsProvider? _settings;

  int _currentRound = 1;
  TimerPhase _phase = TimerPhase.work;
  int _remainingSeconds = 1500; // Default 25 mins
  bool _isRunning = false;
  Timer? _timer;

  TimerProvider();

  /// Syncs settings from the UI layer.
  void syncSettings(SettingsProvider settings) {
    final oldSettings = _settings;
    _settings = settings;

    // Only update remaining seconds if settings actually changed and timer isn't running
    if (!_isRunning && (oldSettings == null || _hasDurationsChanged(oldSettings, settings))) {
      if (_phase == TimerPhase.work) {
        _remainingSeconds = settings.workDurationSeconds;
      } else if (_phase == TimerPhase.shortBreak) {
        _remainingSeconds = settings.shortBreakSeconds;
      } else {
        _remainingSeconds = settings.longBreakSeconds;
      }
    }
    notifyListeners();
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
        return 'DEEP WORK SESSION';
      case TimerPhase.shortBreak:
        return 'SHORT BREAK';
      case TimerPhase.longBreak:
        return 'LONG BREAK';
    }
  }

  // ── Controls ───────────────────────────────────────────────────────────────
  void togglePause() {
    _isRunning = !_isRunning;
    if (_isRunning) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }

  /// Reset: stop timer, go back to round 1 work phase, stay paused.
  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _currentRound = 1;
    _phase = TimerPhase.work;
    _remainingSeconds = _settings?.workDurationSeconds ?? 1500;
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

    switch (_phase) {
      case TimerPhase.work:
        // Move to break
        final isLongBreak = _currentRound % settings.totalRounds == 0;
        _phase = isLongBreak ? TimerPhase.longBreak : TimerPhase.shortBreak;
        _remainingSeconds = isLongBreak
            ? settings.longBreakSeconds
            : settings.shortBreakSeconds;
        break;

      case TimerPhase.shortBreak:
      case TimerPhase.longBreak:
        // Move to next work round
        if (_currentRound < settings.totalRounds) {
          _currentRound++;
        } else {
          // All rounds done – reset to start, stay paused
          _currentRound = 1;
          _isRunning = false;
          _phase = TimerPhase.work;
          _remainingSeconds = settings.workDurationSeconds;
          notifyListeners();
          return;
        }
        _phase = TimerPhase.work;
        _remainingSeconds = settings.workDurationSeconds;
        break;
    }

    if (_isRunning) {
      _startTimer();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
