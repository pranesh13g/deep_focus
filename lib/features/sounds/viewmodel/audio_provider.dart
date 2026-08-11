import 'package:deep_focus/features/sounds/model/sound_model.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  SoundModel? _currentSound;
  SoundModel? _selectedForFocus;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Whether the focus session has sound enabled (only affects focus session,
  // NOT sounds-library preview playback).
  bool _isFocusSoundEnabled = false;

  SoundModel? get currentSound => _currentSound;
  SoundModel? get selectedForFocus => _selectedForFocus;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isFocusSoundEnabled => _isFocusSoundEnabled;
  AudioPlayer get player => _player;

  AudioProvider() {
    _selectedForFocus = essentialTones.first;

    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading =
          state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      notifyListeners();
    });

    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });
  }

  // ── Sounds Library (preview) playback ─────────────────────────────────────

  /// Load and play a sound. If the same sound is already loaded, just resume.
  Future<void> play(SoundModel sound) async {
    if (_currentSound?.id == sound.id) {
      if (!_player.playing) await _player.play();
      return;
    }
    _currentSound = sound;
    _isLoading = true;
    notifyListeners();
    try {
      await _player.setAsset(sound.assetPath);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tap handler for a tile: select for focus + play/pause toggle.
  /// Does NOT call notifyListeners mid-operation to avoid rebuild races.
  Future<void> selectAndToggle(SoundModel sound) async {
    _selectedForFocus = sound;

    if (_currentSound?.id == sound.id) {
      // Same sound already loaded — toggle with live player state
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } else {
      // Different sound — load and play
      _currentSound = sound;
      _isLoading = true;
      notifyListeners();
      try {
        await _player.setAsset(sound.assetPath);
        await _player.setLoopMode(LoopMode.one);
        await _player.play();
      } catch (e) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Mini-player play/pause button.
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> pauseAudio() async {
    await _player.pause();
  }

  // ── Focus session sound ────────────────────────────────────────────────────

  /// Select a sound for the focus session without affecting current playback.
  void selectForFocus(SoundModel sound) {
    _selectedForFocus = sound;
    notifyListeners();
  }

  Future<void> toggleFocusSound() async {
    // Base the decision on the actual player state, not _isFocusSoundEnabled,
    // so it stays correct even when the sounds-screen preview changed _isPlaying
    // without touching _isFocusSoundEnabled.
    if (_player.playing) {
      _isFocusSoundEnabled = false;
      await pauseAudio();
    } else {
      _isFocusSoundEnabled = true;
      await _playForFocusSession();
    }
    notifyListeners();
  }

  /// Called by TimerProvider when the work phase starts/resumes.
  /// Only plays if the user has enabled focus sound.
  Future<void> playSelected() async {
    if (!_isFocusSoundEnabled) {
      await pauseAudio();
      return;
    }
    final sound = _selectedForFocus;
    if (sound == null) return;
    await play(sound);
  }

  Future<void> _playForFocusSession() async {
    final sound = _selectedForFocus;
    if (sound == null) return;
    await play(sound);
  }

  Future<void> playBreakSound() async {
    await play(clockTickingSound);
  }

  // ── Skip / Next / Prev ─────────────────────────────────────────────────────

  Future<void> playNext() async {
    if (_currentSound == null) return;
    final index = allSounds.indexWhere((s) => s.id == _currentSound!.id);
    if (index != -1) {
      final next = allSounds[(index + 1) % allSounds.length];
      _selectedForFocus = next;
      await play(next);
    }
  }

  Future<void> playPrevious() async {
    if (_currentSound == null) return;
    final index = allSounds.indexWhere((s) => s.id == _currentSound!.id);
    if (index != -1) {
      final prev = allSounds[(index - 1 + allSounds.length) % allSounds.length];
      _selectedForFocus = prev;
      await play(prev);
    }
  }

  Future<void> seekForward() async {
    final newPos = _position + const Duration(seconds: 10);
    await _player.seek(newPos < _duration ? newPos : _duration);
  }

  Future<void> seekBackward() async {
    final newPos = _position - const Duration(seconds: 10);
    await _player.seek(newPos > Duration.zero ? newPos : Duration.zero);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool isCurrentlyPlaying(String id) => _currentSound?.id == id && _isPlaying;
  bool isCurrent(String id) => _currentSound?.id == id;
  bool isSelectedForFocus(String id) => _selectedForFocus?.id == id;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
