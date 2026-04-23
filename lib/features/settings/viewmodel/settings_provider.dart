import 'package:flutter/foundation.dart';

class SettingsProvider extends ChangeNotifier {
  // Default values
  static const double _defaultWork = 25;
  static const double _defaultShortBreak = 5;
  static const double _defaultLongBreak = 15;
  static const double _defaultRounds = 4;

  double _workDuration = _defaultWork;
  double _shortBreak = _defaultShortBreak;
  double _longBreak = _defaultLongBreak;
  double _sessionRounds = _defaultRounds;

  double get workDuration => _workDuration;
  double get shortBreak => _shortBreak;
  double get longBreak => _longBreak;
  double get sessionRounds => _sessionRounds;

  // Convenience getters in seconds for TimerProvider
  int get workDurationSeconds => (_workDuration * 60).toInt();
  int get shortBreakSeconds => (_shortBreak * 60).toInt();
  int get longBreakSeconds => (_longBreak * 60).toInt();
  int get totalRounds => _sessionRounds.toInt();

  void setWorkDuration(double v) {
    _workDuration = v;
    notifyListeners();
  }

  void setShortBreak(double v) {
    _shortBreak = v;
    notifyListeners();
  }

  void setLongBreak(double v) {
    _longBreak = v;
    notifyListeners();
  }

  void setSessionRounds(double v) {
    _sessionRounds = v;
    notifyListeners();
  }

  void resetToDefaults() {
    _workDuration = _defaultWork;
    _shortBreak = _defaultShortBreak;
    _longBreak = _defaultLongBreak;
    _sessionRounds = _defaultRounds;
    notifyListeners();
  }
}
