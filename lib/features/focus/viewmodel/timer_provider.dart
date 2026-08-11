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

  /// Timestamp recorded when the app moves to background while timer is running.
  /// Used to calculate elapsed time on resume so the timer stays accurate even
  /// when the Dart isolate is throttled or the screen is off.
  DateTime? _backgroundedAt;

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
  bool get breakSoundMutedByUser => _breakSoundMutedByUser;

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
      if (!_breakSoundMutedByUser) {
        _audio?.playBreakSound();
      }
    }
  }

  /// Whether the user explicitly paused the break sound via the in-session
  /// player button. Resets automatically when a new break phase starts.
  bool _breakSoundMutedByUser = false;

  /// Toggles focus-session audio.
  ///
  /// When the session is **running**: gates on [_isFocusSoundEnabled] so that
  /// resuming the session knows whether to restart audio.
  ///
  /// When the session is **paused**: simply plays/pauses directly without
  /// touching [_isFocusSoundEnabled], so the user can preview the sound while
  /// the timer is stopped without changing the enabled-on-resume preference.
  void toggleFocusSessionSound() {
    if (_audio == null) return;
    if (_isRunning) {
      // Running: delegate to AudioProvider which manages _isFocusSoundEnabled
      _audio!.toggleFocusSound();
    } else {
      // Paused: just toggle playback directly, don't flip the enabled flag
      _audio!.togglePlayPause();
    }
  }

  /// Toggles the clock-ticking sound during a break phase.
  /// Keeps [_breakSoundMutedByUser] in sync so "Resume Session" doesn't
  /// unexpectedly restart audio the user intentionally stopped.
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
        _breakSoundMutedByUser = false; // fresh break — always auto-play
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
      id: _notificationId++,
      title: title,
      body: body,
    );
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Call from [WidgetsBindingObserver.didChangeAppLifecycleState] when the
  /// app enters [AppLifecycleState.paused].
  ///
  /// Cancels the [Timer.periodic] (preventing Dart-isolate drift) and records
  /// the wall-clock time so [handleForeground] can fast-forward correctly.
  void handleBackground() {
    if (!_isRunning) return;
    _timer?.cancel();
    _timer = null;
    _backgroundedAt = DateTime.now();
    _audio?.pauseAudio();
    // Keep _isRunning = true so the UI still shows the running state on resume.
  }

  /// Call from [WidgetsBindingObserver.didChangeAppLifecycleState] when the
  /// app enters [AppLifecycleState.resumed].
  ///
  /// Calculates the real elapsed seconds since [handleBackground] was called,
  /// fast-forwards through as many phase transitions as needed, fires any
  /// missed notifications, then restarts the tick timer.
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

  /// Advances the timer state by [seconds], crossing phase boundaries as
  /// needed.  Each crossed boundary fires a notification just as the live
  /// timer would have.
  void _applyElapsed(int seconds) {
    int remaining = seconds;

    while (remaining > 0 && _isRunning) {
      if (remaining < _remainingSeconds) {
        // Elapsed time fits within the current phase — simply subtract.
        _remainingSeconds -= remaining;
        remaining = 0;
      } else {
        // Elapsed time exhausts this phase; advance and keep consuming.
        remaining -= _remainingSeconds;
        _remainingSeconds = 0;
        _advancePhase();
        // _advancePhase may set _isRunning = false (session complete); if so
        // the while-loop exits naturally.
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
