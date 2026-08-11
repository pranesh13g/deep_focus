class SoundModel {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath; // URL or asset path
  final String iconPath;

  const SoundModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.iconPath,
  });
}

final List<SoundModel> essentialTones = [
  SoundModel(
    id: 'white_noise',
    title: 'White Noise',
    subtitle: 'Pure static for deep focus',
    assetPath: 'assets/audio/white_noise.mp3',
    iconPath: 'white',
  ),
  SoundModel(
    id: 'calm',
    title: 'Calm',
    subtitle: 'Soothing minimalist ambient',
    assetPath: 'assets/audio/calm.mp3',
    iconPath: 'calm',
  ),
  SoundModel(
    id: 'chill',
    title: 'Chill',
    subtitle: 'Relaxed lo-fi vibes',
    assetPath: 'assets/audio/chill.mp3',
    iconPath: 'chill',
  ),
];

final List<SoundModel> natureSounds = [
  SoundModel(
    id: 'heavy_rain',
    title: 'Heavy Rain',
    subtitle: 'Intense rain for focus',
    assetPath: 'assets/audio/heavy_rain.mp3',
    iconPath: 'rain',
  ),
  SoundModel(
    id: 'ocean_waves',
    title: 'Ocean Waves',
    subtitle: 'Gentle rhythmic tide',
    assetPath: 'assets/audio/ocean_waves.mp3',
    iconPath: 'ocean',
  ),
  SoundModel(
    id: 'thunderstorm',
    title: 'Thunderstorm',
    subtitle: 'Distant thunder and rain',
    assetPath: 'assets/audio/thunder_strom.mp3',
    iconPath: 'thunder',
  ),
];

final List<SoundModel> allSounds = [
  ...essentialTones,
  ...natureSounds,
];

const clockTickingSound = SoundModel(
  id: 'clock_ticking',
  title: 'Clock Ticking',
  subtitle: 'Break time rhythm',
  assetPath: 'assets/audio/clock_ticking.mp3',
  iconPath: 'clock',
);
