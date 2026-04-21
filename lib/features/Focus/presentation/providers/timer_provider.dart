import 'dart:async';
import 'package:deep_focus/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';

enum TimerPhase { work, shortBreak, longBreak }

class TimerProvider extends ChangeNotifier {
  SettingsProvider _settings;

  int _currentRound = 1;
  TimerPhase _phase = TimerPhase.work;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;

  // Callback invoked when timer resumes (so audio can auto-start)
  VoidCallback? onResume;

  TimerProvider(this._settings) {
    _remainingSeconds = _settings.workDurationSeconds;
  }

  // Called by ProxyProvider when SettingsProvider changes
  void update(SettingsProvider settings) {
    _settings = settings;

    // If we're in work phase and not running, update the display time
    if (!_isRunning) {
      if (_phase == TimerPhase.work) {
        _remainingSeconds = _settings.workDurationSeconds;
      } else if (_phase == TimerPhase.shortBreak) {
        _remainingSeconds = _settings.shortBreakSeconds;
      } else {
        _remainingSeconds = _settings.longBreakSeconds;
      }
    }
    notifyListeners();
  }

  // ── Getters ────────────────────────────────────────────────────────────────
  int get currentRound => _currentRound;
  int get totalRounds => _settings.totalRounds;
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
      onResume?.call(); // auto-play audio
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
    _remainingSeconds = _settings.workDurationSeconds;
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
    switch (_phase) {
      case TimerPhase.work:
        // Move to break
        final isLongBreak = _currentRound % _settings.totalRounds == 0;
        _phase = isLongBreak ? TimerPhase.longBreak : TimerPhase.shortBreak;
        _remainingSeconds = isLongBreak
            ? _settings.longBreakSeconds
            : _settings.shortBreakSeconds;
        break;

      case TimerPhase.shortBreak:
      case TimerPhase.longBreak:
        // Move to next work round
        if (_currentRound < _settings.totalRounds) {
          _currentRound++;
        } else {
          // All rounds done – reset to start, stay paused
          _currentRound = 1;
          _isRunning = false;
          _phase = TimerPhase.work;
          _remainingSeconds = _settings.workDurationSeconds;
          notifyListeners();
          return;
        }
        _phase = TimerPhase.work;
        _remainingSeconds = _settings.workDurationSeconds;
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
