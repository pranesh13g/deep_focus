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

  SoundModel? get currentSound => _currentSound;
  SoundModel? get selectedForFocus => _selectedForFocus;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  AudioPlayer get player => _player;

  AudioProvider() {
    // Default: first essential tone is selected for Focus
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

  /// Play a sound from the Sounds library list.
  Future<void> play(SoundModel sound) async {
    if (_currentSound?.id == sound.id) {
      if (!_isPlaying) {
        await _player.play();
      }
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

  /// Toggle a sound (play if different or paused, pause if same and playing)
  Future<void> togglePlay(SoundModel sound) async {
    if (_currentSound?.id == sound.id) {
      await togglePlayPause();
    } else {
      await play(sound);
    }
  }

  /// Select a sound to use on the Focus screen (does NOT auto-play).
  void selectForFocus(SoundModel sound) {
    _selectedForFocus = sound;
    notifyListeners();
  }

  bool _isFocusSoundEnabled = false;
  bool get isFocusSoundEnabled => _isFocusSoundEnabled;

  Future<void> toggleFocusSound() async {
    _isFocusSoundEnabled = !_isFocusSoundEnabled;
    if (_isFocusSoundEnabled) {
      await playSelected();
    } else {
      await pauseAudio();
    }
    notifyListeners();
  }

  /// Called by TimerProvider when user resumes the session.
  Future<void> playSelected() async {
    if (!_isFocusSoundEnabled) {
      await pauseAudio();
      return;
    }
    final sound = _selectedForFocus;
    if (sound == null) return;
    await play(sound);
  }

  Future<void> playBreakSound() async {
    await play(clockTickingSound);
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> pauseAudio() async {
    await _player.pause();
  }

  Future<void> playNext() async {
    if (_currentSound == null) return;
    final index = allSounds.indexWhere((s) => s.id == _currentSound!.id);
    if (index != -1) {
      final nextIndex = (index + 1) % allSounds.length;
      final nextSound = allSounds[nextIndex];
      _selectedForFocus = nextSound; // Select also
      await play(nextSound);
    }
  }

  Future<void> playPrevious() async {
    if (_currentSound == null) return;
    final index = allSounds.indexWhere((s) => s.id == _currentSound!.id);
    if (index != -1) {
      final prevIndex = (index - 1 + allSounds.length) % allSounds.length;
      final prevSound = allSounds[prevIndex];
      _selectedForFocus = prevSound; // Select also
      await play(prevSound);
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

  bool isCurrentlyPlaying(String id) => _currentSound?.id == id && _isPlaying;
  bool isCurrent(String id) => _currentSound?.id == id;
  bool isSelectedForFocus(String id) => _selectedForFocus?.id == id;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
