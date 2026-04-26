import 'package:deep_focus/features/focus/viewmodel/timer_provider.dart';
import 'package:deep_focus/features/settings/viewmodel/settings_provider.dart';
import 'package:deep_focus/features/sounds/viewmodel/audio_provider.dart';
import 'package:deep_focus/features/about/viewmodel/about_provider.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  static List<SingleChildWidget> get allProviders => [
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ChangeNotifierProvider(create: (_) => AudioProvider()),
    ChangeNotifierProvider(create: (_) => AboutProvider()),
    ChangeNotifierProvider(create: (_) => TimerProvider()),
  ];
}
