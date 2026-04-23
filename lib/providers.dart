import 'package:deep_focus/features/Focus/viewmodels/timer_provider.dart';
import 'package:deep_focus/features/settings/viewmodel/settings_provider.dart';
import 'package:deep_focus/features/sounds/viewmodel/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  static List<SingleChildWidget> get allProviders => [
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ChangeNotifierProvider(create: (_) => AudioProvider()),
    ChangeNotifierProxyProvider<SettingsProvider, TimerProvider>(
      create: (ctx) =>
          TimerProvider(ctx.read<SettingsProvider>())
            ..onResume = () => ctx.read<AudioProvider>().playSelected(),
      update: (ctx, settings, previous) {
        final provider = previous ?? TimerProvider(settings);
        provider.update(settings);
        provider.onResume = () => ctx.read<AudioProvider>().playSelected();
        return provider;
      },
    ),
  ];
}
