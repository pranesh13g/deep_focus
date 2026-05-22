import 'package:deep_focus/core/services/notification_service.dart';
import 'package:deep_focus/core/theme/app_theme.dart';
import 'package:deep_focus/navigation.dart';
import 'package:deep_focus/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.init(); // Non-blocking init
  await ScreenUtil.ensureScreenSize();
  runApp(
    MultiProvider(providers: AppProviders.allProviders, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Deep Focus',
          theme: AppTheme.lightTheme,
          home: child,
        );
      },
      child: const Navigation(),
    );
  }
}
