import 'dart:async';

import 'package:deep_focus/core/services/notification_service.dart';
import 'package:deep_focus/core/theme/app_theme.dart';
import 'package:deep_focus/navigation.dart';
import 'package:deep_focus/providers.dart';
import 'package:deep_focus/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() {
  // runZonedGuarded must wrap everything — including ensureInitialized and
  // runApp — so that Flutter bindings and the app run in the same zone.
  // Calling ensureInitialized() outside the zone and runApp() inside it
  // causes a "Zone mismatch" fatal assertion.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Pass all uncaught Flutter framework errors to Crashlytics
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('seen_splash') != true;
    if (isFirstLaunch) {
      await prefs.setBool('seen_splash', true);
    }

    await NotificationService.init();
    await ScreenUtil.ensureScreenSize();

    runApp(
      MultiProvider(
        providers: AppProviders.allProviders,
        child: MyApp(showSplash: isFirstLaunch),
      ),
    );
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

class MyApp extends StatelessWidget {
  final bool showSplash;
  const MyApp({super.key, required this.showSplash});

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
      child: showSplash ? const SplashScreen() : const Navigation(),
    );
  }
}
