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
  bool _isRunning = false;
  Timer? _timer;

  // ── Wall-clock timing anchors ──────────────────────────────────────────────

  /// Total seconds the current phase lasts. Set when the phase is entered.
  int _phaseTotalSeconds = 1500;

  /// Seconds already elapsed in this phase before the current run segment.
  /// Accumulates across pause/resume cycles within the same phase.
  int _elapsedBeforeStart = 0;

  /// Wall-clock time when the current run segment started (null when paused).
  /// [_updateTimer] derives remaining time from this anchor rather than
  /// counting periodic callbacks.
  DateTime? _runStartedAt;

  /// Timestamp recorded when the app moves to background while the timer is
  /// running. Used by [handleForeground] to fast-forward by real wall time.
  DateTime? _backgroundedAt;

  /// Derived remaining seconds – updated by [_updateTimer] every 100 ms and
  /// kept in sync with [_elapsedBeforeStart] + real wall-clock elapsed.
  int _remainingSeconds = 1500;

  /// Last elapsed-second boundary for which a tick sound was played.
  /// Guards against playing more than one tick per elapsed second.
  int _lastTickSecond = -1;

  // ── Whether the user explicitly paused the break sound ────────────────────
  bool _breakSoundMutedByUser = false;

  TimerProvider();

  // ── Dependency injection ───────────────────────────────────────────────────

  /// Syncs settings and audio provider from the UI layer.
  void setDependencies(SettingsProvider settings, AudioProvider audio) {
    final oldSettings = _settings;
    final bool audioProviderChanged = _audio != audio;
    _settings = settings;
    _audio = audio;

    // Only reset the phase duration if settings changed and timer is paused.
    if (!_isRunning) {
      if (oldSettings == null || _hasDurationsChanged(oldSettings, settings)) {
        _phaseTotalSeconds = _getInitialSeconds(settings, _phase);
        _remainingSeconds = _phaseTotalSeconds;
        _elapsedBeforeStart = 0;
        _runStartedAt = null;
        _lastTickSecond = -1;
      }
    }

    // Sync audio only when the AudioProvider instance itself changes (first
    // load / hot-restart), not on every position/state update it broadcasts.
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

  // ── Getters ────────────────────────────────────────────────────────────────

  int get currentRound => _currentRound;
  int get totalRounds => _settings?.totalRounds ?? 4;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  TimerPhase get phase => _phase;
  bool get breakSoundMutedByUser => _breakSoundMutedByUser;

  String get formattedTime {
    final s = _remainingSeconds.clamp(0, _phaseTotalSeconds);
    final minutes = s ~/ 60;
    final seconds = s % 60;
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
    if (_isRunning) {
      pause();
    } else {
      _isRunning = true;
      _startTimer();
      _syncAudio();
    }
  }

  void pause() {
    if (!_isRunning) return;

    // Capture elapsed wall time so it is not lost across this pause.
    if (_runStartedAt != null) {
      _elapsedBeforeStart +=
          DateTime.now().difference(_runStartedAt!).inSeconds;
      _runStartedAt = null;
    }

    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    _audio?.pauseAudio();
    notifyListeners();
  }

  void _syncAudio() {
    if (_phase == TimerPhase.work) {
      _audio?.playSelected();
    } else {
      if (!_breakSoundMutedByUser) {
        _audio?.playBreakSound();
      }
    }
  }

  /// Toggles focus-session audio.
  ///
  /// Running → delegates to AudioProvider (manages its own enabled flag).
  /// Paused  → direct play/pause without touching the enabled flag so the user
  ///           can preview sound while stopped without changing resume behaviour.
  void toggleFocusSessionSound() {
    if (_audio == null) return;
    if (_isRunning) {
      _audio!.toggleFocusSound();
    } else {
      _audio!.togglePlayPause();
    }
  }

  /// Toggles the clock-ticking sound during a break phase.
  void toggleBreakSound() {
    if (_audio == null) return;
    if (_audio!.isPlaying) {
      _breakSoundMutedByUser = true;
      _audio!.pauseAudio();
    } else {
      _breakSoundMutedByUser = false;
      _audio!.playBreakSound();
    }
  }

  /// Reset: stop timer, return to round 1 work phase, stay paused.
  void reset() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _currentRound = 1;
    _phase = TimerPhase.work;
    _phaseTotalSeconds = _settings?.workDurationSeconds ?? 1500;
    _remainingSeconds = _phaseTotalSeconds;
    _elapsedBeforeStart = 0;
    _runStartedAt = null;
    _backgroundedAt = null;
    _lastTickSecond = -1;
    _audio?.pauseAudio();
    notifyListeners();
  }

  /// Skip: jump to the next phase immediately.
  void skip() {
    _timer?.cancel();
    _timer = null;
    _runStartedAt = null;
    _advancePhase();
  }

  // ── Core timer loop ────────────────────────────────────────────────────────

  /// Starts (or restarts) the 100 ms refresh loop. Records a fresh
  /// [_runStartedAt] anchor so every [_updateTimer] call measures wall time
  /// from a known point rather than counting callback firings.
  void _startTimer() {
    _timer?.cancel();
    _runStartedAt = DateTime.now();

    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _updateTimer(),
    );
  }

  /// Called ~10× per second. Derives remaining time from real wall-clock
  /// elapsed time – never by counting how many times this callback fires.
  void _updateTimer() {
    if (!_isRunning || _runStartedAt == null) return;

    final wallElapsed =
        DateTime.now().difference(_runStartedAt!).inSeconds;
    final totalElapsed = _elapsedBeforeStart + wallElapsed;
    final newRemaining = _phaseTotalSeconds - totalElapsed;

    // Phase complete.
    if (newRemaining <= 0) {
      _remainingSeconds = 0;
      notifyListeners();
      _timer?.cancel();
      _timer = null;
      _runStartedAt = null;
      _advancePhase();
      return;
    }

    // Update display only when the second changes (avoids noisy rebuilds).
    if (newRemaining != _remainingSeconds) {
      _remainingSeconds = newRemaining;
      notifyListeners();
    }

    // Tick sound: fire exactly once per elapsed second, anchored to the same
    // wall-clock calculation used for the display – never to callback count.
    if (totalElapsed != _lastTickSecond) {
      _lastTickSecond = totalElapsed;
      // TODO: uncomment when a single-shot tick asset is added:
      // _audio?.playTick();
    }
  }

  // ── Phase transitions ──────────────────────────────────────────────────────

  void _advancePhase() {
    final settings = _settings;
    if (settings == null) return;

    final oldPhase = _phase;

    switch (_phase) {
      case TimerPhase.work:
        final isLongBreak = _currentRound % settings.totalRounds == 0;
        _phase = isLongBreak ? TimerPhase.longBreak : TimerPhase.shortBreak;
        _phaseTotalSeconds = isLongBreak
            ? settings.longBreakSeconds
            : settings.shortBreakSeconds;
        _breakSoundMutedByUser = false; // fresh break – always auto-play
        break;

      case TimerPhase.shortBreak:
      case TimerPhase.longBreak:
        if (_currentRound < settings.totalRounds) {
          _currentRound++;
        } else {
          // All rounds complete – session finished.
          _currentRound = 1;
          _isRunning = false;
          _phase = TimerPhase.work;
          _phaseTotalSeconds = settings.workDurationSeconds;
          _remainingSeconds = _phaseTotalSeconds;
          _elapsedBeforeStart = 0;
          _runStartedAt = null;
          _lastTickSecond = -1;
          _audio?.pauseAudio();
          notifyListeners();
          return;
        }
        _phase = TimerPhase.work;
        _phaseTotalSeconds = settings.workDurationSeconds;
        break;
    }

    // Reset elapsed-state for the new phase.
    _remainingSeconds = _phaseTotalSeconds;
    _elapsedBeforeStart = 0;
    _runStartedAt = null;
    _lastTickSecond = -1;

    if (oldPhase == TimerPhase.work) {
      final isLong = _phase == TimerPhase.longBreak;
      _triggerNotification(
        isLong ? 'Full Break Started' : 'Quick Break Started',
        isLong ? 'Take a good rest. You earned it!' : 'Stretch a bit and relax.',
      );
    }

    if (_isRunning) {
      _startTimer(); // creates a fresh _runStartedAt for the new phase
      _syncAudio();
    }
    notifyListeners();
  }

  void _triggerNotification(String title, String body) {
    HapticFeedback.vibrate();
    NotificationService.showNotification(
      id: _notificationId++,
      title: title,
      body: body,
    );
  }

  // ── App lifecycle ──────────────────────────────────────────────────────────

  /// Call from [WidgetsBindingObserver] when the app enters
  /// [AppLifecycleState.paused].
  ///
  /// Captures the current elapsed time into [_elapsedBeforeStart], cancels the
  /// refresh loop, and records the wall-clock time for [handleForeground].
  void handleBackground() {
    if (!_isRunning) return;

    // Freeze elapsed so far into the accumulator.
    if (_runStartedAt != null) {
      _elapsedBeforeStart +=
          DateTime.now().difference(_runStartedAt!).inSeconds;
      _runStartedAt = null;
    }

    _timer?.cancel();
    _timer = null;
    _backgroundedAt = DateTime.now();
    _audio?.pauseAudio();
    // Keep _isRunning = true; the UI shows the running state on resume.
  }

  /// Call from [WidgetsBindingObserver] when the app enters
  /// [AppLifecycleState.resumed].
  ///
  /// Calculates real wall-clock elapsed since [handleBackground], fast-forwards
  /// through phase boundaries as needed, then restarts the timer.
  void handleForeground() {
    final bg = _backgroundedAt;
    if (!_isRunning || bg == null) return;
    _backgroundedAt = null;

    final elapsed = DateTime.now().difference(bg).inSeconds;
    _applyElapsed(elapsed);

    if (_isRunning) {
      _startTimer();
      _syncAudio();
    }
  }

  /// Advances the timer by [seconds] of real elapsed time, crossing phase
  /// boundaries as needed and firing a notification at each boundary.
  void _applyElapsed(int seconds) {
    int remaining = seconds;

    while (remaining > 0 && _isRunning) {
      // How much time is left in the current phase from the accumulated state?
      final phaseRemaining = _phaseTotalSeconds - _elapsedBeforeStart;

      if (remaining < phaseRemaining) {
        // Fits within the current phase.
        _elapsedBeforeStart += remaining;
        _remainingSeconds = _phaseTotalSeconds - _elapsedBeforeStart;
        remaining = 0;
      } else {
        // Exhausts this phase; advance and keep consuming.
        remaining -= phaseRemaining;
        _elapsedBeforeStart = _phaseTotalSeconds; // mark phase as fully elapsed
        _remainingSeconds = 0;
        _advancePhase();
        // _advancePhase resets _elapsedBeforeStart for the new phase.
        // If _isRunning became false (session over), the while-loop exits.
      }
    }

    notifyListeners();
  }

  int _notificationId = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
