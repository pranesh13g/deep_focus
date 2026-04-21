import 'package:deep_focus/features/Focus/presentation/providers/timer_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  static List<SingleChildWidget> get allProviders => [
    ChangeNotifierProvider(create: (_) => TimerProvider()),
  ];
}
