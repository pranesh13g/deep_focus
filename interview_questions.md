# Deep Focus — Flutter Interview Questions & Answers

---

## Flutter & Dart Fundamentals

**Q1. What is the difference between `StatelessWidget` and `StatefulWidget`? How are they used in this project?**

**A:** `StatelessWidget` is immutable — its build method depends only on its constructor arguments. `StatefulWidget` holds mutable state via a `State` object that can call `setState()` to rebuild.

In Deep Focus, most screens (`PresentationScreen`, `SoundsScreen`, `SettingsScreen`) are `StatelessWidget` because their state lives in providers. `Navigation` is a `StatefulWidget` because it locally tracks `selectedIndex` for the bottom nav bar and needs `WidgetsBindingObserver` lifecycle hooks.

---

**Q2. What does `WidgetsFlutterBinding.ensureInitialized()` do and why is it called in `main()`?**

**A:** It initializes the binding between the Flutter framework and the underlying platform (Flutter engine). It must be called before using any platform channels (like notifications or screen size) in an `async main()`. In this project it's needed before `NotificationService.init()` and `ScreenUtil.ensureScreenSize()`.

---

**Q3. What is `ChangeNotifier` and how does it work with `Provider`?**

**A:** `ChangeNotifier` is a mixin/class from `flutter/foundation.dart` that provides `notifyListeners()`. When called, it tells all registered listeners (widgets listening via `context.watch` or `Consumer`) to rebuild. `ChangeNotifierProvider` creates and manages the lifecycle of the notifier, disposing it when the widget tree is removed.

---

## State Management (Provider)

**Q4. Why is `ChangeNotifierProxyProvider2` used for `TimerProvider` instead of a regular `ChangeNotifierProvider`?**

**A:** `TimerProvider` has a dependency on both `SettingsProvider` and `AudioProvider`. `ChangeNotifierProxyProvider2` wires those two upstream providers into `TimerProvider` automatically — every time `SettingsProvider` or `AudioProvider` notifies, the `update` callback fires and calls `timer!..setDependencies(settings, audio)`. This keeps `TimerProvider` in sync without it needing to independently watch other providers, which would create circular dependencies.

---

**Q5. Why does `setDependencies()` in `TimerProvider` only update `_remainingSeconds` when the timer isn't running?**

**A:** To prevent the running timer from resetting mid-session. If a user adjusts settings while the timer is active, you don't want the current countdown to jump to a new value. The guard `if (!_isRunning)` plus `_hasDurationsChanged()` ensures the new durations only take effect once the current session is idle.

---

**Q6. What is `context.read()` vs `context.watch()` and when would you use each?**

**A:**
- `context.watch<T>()` — subscribes to changes; the widget rebuilds whenever `T` notifies. Use in `build()`.
- `context.read<T>()` — one-time access, no subscription. Use in callbacks/event handlers where rebuilding isn't needed.

In `Navigation.onItemTapped`, `context.read<AudioProvider>().pauseAudio()` is correct because you only want to call the method, not subscribe to state.

---

## Timer Logic

**Q7. Walk through what happens when a Pomodoro work session ends.**

**A:** When `_remainingSeconds` hits 0 in the `Timer.periodic` callback, `_advancePhase()` is called. It checks if the current round is divisible by `totalRounds` — if so, transitions to `longBreak`; otherwise `shortBreak`. It updates `_phase` and `_remainingSeconds` accordingly, triggers a local notification with `_triggerNotification()`, fires `HapticFeedback.vibrate()`, and if `_isRunning` is still true, restarts the timer and syncs audio to the break sound (`clockTickingSound`).

---

**Q8. What does `_syncAudio()` do and why is it important?**

**A:** It ensures the correct audio plays for the current phase. During `TimerPhase.work`, it calls `_audio?.playSelected()` (user's chosen ambient sound). During any break phase, it calls `_audio?.playBreakSound()` (clock ticking). This keeps the audio experience contextually appropriate without the UI needing to manually manage it.

---

**Q9. What is the `skip()` method doing in `TimerProvider`?**

**A:** It cancels the current timer and immediately calls `_advancePhase()`, jumping to the next phase as if the current one had naturally expired. Useful when a user wants to manually skip ahead to their break or back to work.

---

## Audio (just_audio)

**Q10. How does `AudioProvider` handle the case where the same sound is tapped twice?**

**A:** In `play()`, it checks `if (_currentSound?.id == sound.id)`. If the same sound is already loaded, it just calls `_player.play()` (resume) instead of reloading the asset — avoiding unnecessary I/O and audio stuttering. If a different sound is tapped, it sets the new asset and loops it.

---

**Q11. Why is `LoopMode.one` used for sounds?**

**A:** Ambient focus sounds (rain, white noise, etc.) are meant to play continuously and indefinitely. `LoopMode.one` loops the single track forever without needing to manually restart it when it ends.

---

**Q12. What is the `selectedForFocus` concept vs `currentSound`?**

**A:** `currentSound` is whatever is actively playing in the player at this moment (could be from the Sounds screen preview). `selectedForFocus` is the sound pre-assigned to play automatically when the Focus timer runs. The two can be different — a user might preview rain on the Sounds screen but have white noise selected for focus.

---

## Notifications & Platform

**Q13. Why is `DateTime.now().millisecondsSinceEpoch ~/ 1000` used as the notification `id`?**

**A:** Each notification needs a unique integer ID. Using the current Unix timestamp in seconds gives a practically unique ID for each notification fired (since notifications fire at most once per second in this app — on phase transitions). The `~/` is integer division in Dart.

---

**Q14. What does `isCoreLibraryDesugaringEnabled = true` do in `build.gradle.kts`?**

**A:** Desugaring allows newer Java 8+ API features (like `java.time`, streams, etc.) to be used on older Android versions that don't natively support them. `just_audio` requires this for compatibility with Android API levels below 26. The `desugar_jdk_libs` dependency provides the actual backport implementations.

---

**Q15. Why is `multiDexEnabled = true` set in the Android config?**

**A:** Android DEX files have a 65,536 method reference limit ("64K limit"). Large apps with multiple dependencies (notifications, audio, provider) exceed this. Enabling multidex splits the app into multiple DEX files, bypassing the limit.

---

## Architecture & Design Patterns

**Q16. What architecture pattern does Deep Focus follow?**

**A:** Feature-first MVVM (Model-View-ViewModel). Each feature folder contains `view/` (StatelessWidget screens), `viewmodel/` (ChangeNotifier providers), `widget/` (composable UI components), and `model/` (data classes). The providers act as ViewModels — they hold business logic and state, while views just observe and render.

---

**Q17. The app has no persistence layer. What would you add to save settings between sessions?**

**A:** `SharedPreferences` is the simplest choice for primitive values like durations and round count — `SettingsProvider` would load from prefs in its constructor and call `prefs.setDouble()` in each setter. For more complex data (e.g., session history/stats), a local database like `sqflite` or `Isar` would be appropriate.

---

**Q18. What is `flutter_screenutil` and why is it used here?**

**A:** It's a responsive sizing utility. `ScreenUtilInit` is initialized with a design size of `375×812` (iPhone 8 dimensions). Then `.w`, `.h`, `.sp` extension methods scale sizes proportionally to the actual device screen, so the UI looks consistent across different screen sizes without hardcoding pixel values.

---

## App Lifecycle

**Q19. How does the app handle being backgrounded?**

**A:** `Navigation` implements `WidgetsBindingObserver` and overrides `didChangeAppLifecycleState`. When the state is `AppLifecycleState.paused` (app fully backgrounded), it pauses both audio and the timer. This prevents the clock from counting down silently in the background while audio keeps playing — a deliberate design choice keeping the session fully user-controlled.

---

**Q20. What is `WidgetsBindingObserver` and what other lifecycle states exist?**

**A:** It's a mixin that lets widgets observe app lifecycle changes. The states are:
- `resumed` — app visible and responding
- `inactive` — app partially obscured (e.g., incoming call)
- `paused` — app fully backgrounded
- `detached` — app about to be terminated
- `hidden` — app is hidden but still running (desktop)

---

## Bug / Code Quality

**Q21. There's a bug in `SplashScreen` — can you identify it?**

**A:** The navigation timer is set to `50000` seconds (`Duration(seconds: 50000)`) instead of something like `3` seconds. This means the splash screen effectively never auto-navigates to the main app. Additionally, `SplashScreen` isn't wired into `main.dart` at all — the app starts directly at `Navigation`, so the splash is unreachable.

---

**Q22. What improvement would you make to `TimerProvider.formattedTime`?**

**A:** The current implementation splits the string twice:

```dart
String get minutesPart => formattedTime.split(':')[0];
String get secondsPart => formattedTime.split(':')[1];
```

Each call to `minutesPart` or `secondsPart` re-computes `formattedTime` and splits again. A minor optimization is to compute minutes and seconds directly from `_remainingSeconds`:

```dart
String get minutesPart => (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
String get secondsPart => (_remainingSeconds % 60).toString().padLeft(2, '0');
```

---

*Generated for Deep Focus v1.0.0 — Built with Flutter & Provider*
