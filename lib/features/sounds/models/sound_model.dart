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
    assetPath: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    iconPath: 'white',
  ),
  SoundModel(
    id: 'pink_noise',
    title: 'Pink Noise',
    subtitle: 'Warm, balanced frequencies',
    assetPath: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    iconPath: 'pink',
  ),
  SoundModel(
    id: 'brown_noise',
    title: 'Brown Noise',
    subtitle: 'Low-end rumble & warmth',
    assetPath: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    iconPath: 'brown',
  ),
  SoundModel(
    id: 'delta_waves',
    title: 'Delta Waves',
    subtitle: 'Deep sleep brainwave sync',
    assetPath: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    iconPath: 'delta',
  ),
  SoundModel(
    id: 'theta_waves',
    title: 'Theta Waves',
    subtitle: 'Meditative relaxation tone',
    assetPath: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
    iconPath: 'theta',
  ),
  SoundModel(
    id: 'alpha_waves',
    title: 'Alpha Waves',
    subtitle: 'Calm alertness & flow',
    assetPath: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
    iconPath: 'alpha',
  ),
];
