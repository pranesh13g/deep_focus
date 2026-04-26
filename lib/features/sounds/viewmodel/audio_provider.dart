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

  /// Play/toggle a sound from the Sounds library list.
  Future<void> play(SoundModel sound) async {
    if (_currentSound?.id == sound.id) {
      if (_isPlaying) {
        await _player.pause();
      } else {
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

  /// Select a sound to use on the Focus screen (does NOT auto-play).
  void selectForFocus(SoundModel sound) {
    _selectedForFocus = sound;
    notifyListeners();
  }

  /// Called by TimerProvider when user resumes the session.
  Future<void> playSelected() async {
    final sound = _selectedForFocus;
    if (sound == null) return;
    if (_currentSound?.id == sound.id) {
      if (!_isPlaying) await _player.play();
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
