import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider extends ChangeNotifier {
  static const int totalRounds = 4;
  static const int sessionDurationSeconds = 25 * 60;

  int _currentRound = 1;
  int _remainingSeconds = sessionDurationSeconds;
  bool _isRunning = true;
  Timer? _timer;

  int get currentRound => _currentRound;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get minutesPart => formattedTime.split(':')[0];
  String get secondsPart => formattedTime.split(':')[1];

  TimerProvider() {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _isRunning = false;
        notifyListeners();
      }
    });
  }

  void togglePause() {
    _isRunning = !_isRunning;
    if (_isRunning) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }

  void restartSession() {
    _timer?.cancel();
    _remainingSeconds = sessionDurationSeconds;
    _isRunning = true;
    _startTimer();
    notifyListeners();
  }

  void endSession() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void nextRound() {
    if (_currentRound < totalRounds) {
      _currentRound++;
      _remainingSeconds = sessionDurationSeconds;
      _isRunning = true;
      _startTimer();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
