# Deep Focus — Complete App & Code Flow

---

## 1. App Startup Flow

```
main() [main.dart]
  │
  ├─ WidgetsFlutterBinding.ensureInitialized()
  │     └─ Activates Flutter engine bindings (required before any platform calls)
  │
  ├─ NotificationService.init()
  │     ├─ Initializes FlutterLocalNotificationsPlugin
  │     ├─ Sets up Android (notification_icon), iOS (alert/badge/sound), Linux channels
  │     └─ Requests Android 13+ notification permission
  │
  ├─ ScreenUtil.ensureScreenSize()
  │     └─ Captures device screen dimensions before build
  │
  └─ runApp(
        MultiProvider(
          providers: AppProviders.allProviders   ← Registers all global providers
          child: MyApp()
        )
     )
```

---

## 2. Provider Initialization Order

```
AppProviders.allProviders [providers.dart]
  │
  ├─ 1. ChangeNotifierProvider → SettingsProvider
  │         └─ Holds: workDuration(25), shortBreak(5), longBreak(15), rounds(4)
  │
  ├─ 2. ChangeNotifierProvider → AudioProvider
  │         ├─ Creates just_audio AudioPlayer instance
  │         ├─ Listens to: playerStateStream, positionStream, durationStream
  │         └─ Default selectedForFocus = essentialTones.first (White Noise)
  │
  ├─ 3. ChangeNotifierProvider → AboutProvider
  │         └─ Utility: url_launcher + clipboard helpers
  │
  └─ 4. ChangeNotifierProxyProvider2<SettingsProvider, AudioProvider, TimerProvider>
            ├─ create: TimerProvider()  ← Created once
            └─ update: timer!..setDependencies(settings, audio)
                        └─ Called EVERY TIME SettingsProvider OR AudioProvider notifies
```

---

## 3. Widget Tree

```
MyApp (StatelessWidget)
  └─ ScreenUtilInit (designSize: 375×812)
       └─ MaterialApp
            ├─ theme: AppTheme.lightTheme (Inter font, custom button styles)
            └─ home: Navigation()
```

---

## 4. Navigation Shell Flow

```
Navigation (StatefulWidget + WidgetsBindingObserver)
  │
  ├─ State: selectedIndex = 0
  │
  ├─ screens[] = [
  │     [0] PresentationScreen  (Focus)
  │     [1] SoundsScreen        (Sounds)
  │     [2] SettingsScreen      (Settings)
  │     [3] AboutScreen         (About)
  │   ]
  │
  ├─ BottomNavigationBar
  │     └─ onTap(index)
  │           ├─ if index != selectedIndex → AudioProvider.pauseAudio()
  │           └─ setState(selectedIndex = index)
  │
  └─ App Lifecycle Observer
        └─ didChangeAppLifecycleState(paused)
              ├─ AudioProvider.pauseAudio()   ← Stop music when app backgrounds
              └─ TimerProvider.pause()        ← Stop timer when app backgrounds
```

---

## 5. Focus Screen Flow (Tab 0)

```
PresentationScreen
  └─ _DeepWorkSessionView
       └─ Scaffold
            ├─ AppBar (shared widget: title + spa icon + avatar)
            └─ Column
                 ├─ RoundIndicator
                 │     └─ Watches TimerProvider
                 │           ├─ Shows phase chip (PRODUCTIVITY SESSION / QUICK BREAK / FULL BREAK)
                 │           │     └─ Color: primary(work) / lightGreen(short) / indigo(long)
                 │           └─ Shows "Round X of Y" divider row
                 │
                 ├─ TimerDisplay
                 │     └─ Watches TimerProvider
                 │           └─ Shows MM:SS in 96sp font
                 │
                 ├─ TimerAction
                 │     └─ Watches TimerProvider.isRunning
                 │           ├─ ElevatedButton (full width)
                 │           │     ├─ isRunning=true  → "Pause Session"  → togglePause()
                 │           │     └─ isRunning=false → "Resume Session" → togglePause()
                 │           ├─ Reset button → TimerProvider.reset()
                 │           └─ Skip button  → TimerProvider.skip()
                 │
                 └─ FocusSoundPlayer (StatefulWidget)
                       ├─ initState: finds selectedForFocus index in allSounds[]
                       │             creates PageController at that index
                       │             adds listener: _syncPageController (keeps page in sync)
                       │
                       └─ Consumer2<AudioProvider, TimerProvider>
                             ├─ if phase == BREAK → shows clock_ticking card (static)
                             └─ if phase == WORK  → PageView of allSounds[]
                                   ├─ Swipe left/right → selectForFocus(newSound)
                                   │                      if playing → play(newSound) immediately
                                   └─ Play/Pause button → toggleFocusSound()
```

---

## 6. Timer Provider Core Logic

```
TimerProvider.togglePause()
  │
  ├─ _isRunning = !_isRunning
  │
  ├─ if now RUNNING:
  │     ├─ _startTimer()  ← Timer.periodic every 1 second
  │     └─ _syncAudio()
  │           ├─ phase==work  → AudioProvider.playSelected()
  │           └─ phase==break → AudioProvider.playBreakSound() (clock ticking)
  │
  └─ if now PAUSED:
        ├─ _timer?.cancel()
        ├─ AudioProvider.pauseAudio()
        └─ notifyListeners()


Timer.periodic tick:
  │
  ├─ _remainingSeconds > 0 → _remainingSeconds-- → notifyListeners()
  │
  └─ _remainingSeconds == 0 → _advancePhase()
          │
          ├─ if phase == WORK:
          │     ├─ round % totalRounds == 0 → phase = LONG BREAK
          │     └─ else                     → phase = SHORT BREAK
          │
          ├─ if phase == SHORT/LONG BREAK:
          │     ├─ round < totalRounds → currentRound++ → phase = WORK
          │     └─ round == totalRounds (all cycles done):
          │           ├─ currentRound = 1
          │           ├─ phase = WORK
          │           ├─ _isRunning = false  ← Session complete, auto-stop
          │           └─ AudioProvider.pauseAudio()
          │
          ├─ _triggerNotification(title, body)
          │     ├─ HapticFeedback.vibrate()
          │     └─ NotificationService.showNotification(id, title, body)
          │
          └─ if still running → _startTimer() again + _syncAudio()


TimerProvider.reset():
  ├─ cancel timer
  ├─ _isRunning = false
  ├─ _currentRound = 1
  ├─ _phase = work
  ├─ _remainingSeconds = workDurationSeconds
  └─ AudioProvider.pauseAudio()

TimerProvider.skip():
  ├─ cancel timer
  └─ _advancePhase()  ← jumps to next phase immediately
```

---

## 7. Settings → Timer Reactivity Flow

```
User drags a slider (SettingsScreen)
  │
  ├─ settings.setWorkDuration(v)      ← notifyListeners() fires
  │     │
  │     └─ ProxyProvider2.update() triggered
  │           └─ TimerProvider.setDependencies(settings, audio)
  │                 ├─ if !_isRunning && durationsChanged:
  │                 │     └─ _remainingSeconds = new work duration
  │                 └─ notifyListeners()  ← TimerDisplay rebuilds with new time
  │
  └─ context.read<TimerProvider>().reset()   ← SettingsScreen also calls this explicitly
        └─ Ensures timer snaps back to round 1
```

---

## 8. Sounds Screen Flow (Tab 1)

```
SoundsScreen
  └─ Scaffold
       ├─ CustomScrollView
       │     ├─ Header: "Sound Library" title
       │     │
       │     ├─ _SelectedForFocusBanner
       │     │     └─ Watches AudioProvider.selectedForFocus
       │     │           └─ Shows "Focus sound: White Noise" banner
       │     │
       │     ├─ "Essential Tones" section (3 sounds)
       │     │     └─ SoundTile (per sound)
       │     │           ├─ Tap → AudioProvider.togglePlay(sound)
       │     │           │         ├─ same sound playing → togglePlayPause()
       │     │           │         └─ different sound   → play(newSound)
       │     │           ├─ Long press / select → AudioProvider.selectForFocus(sound)
       │     │           └─ Shows "FOR FOCUS" badge if isSelectedForFocus
       │     │
       │     └─ "Nature Sounds" section (4 sounds)
       │           └─ Same SoundTile behavior
       │
       └─ MiniPlayer (persistent bottom bar)
             ├─ Watches AudioProvider
             ├─ Shows: track name, progress bar, position/duration
             └─ Controls:
                   ├─ Previous → AudioProvider.playPrevious()
                   ├─ Play/Pause → AudioProvider.togglePlayPause()
                   └─ Next → AudioProvider.playNext()
```

---

## 9. Audio Provider Internal Flow

```
AudioProvider.play(sound)
  │
  ├─ if same sound already loaded:
  │     └─ _player.play()  ← just resume, no reload
  │
  └─ if different sound:
        ├─ _currentSound = sound
        ├─ _isLoading = true → notifyListeners()
        ├─ _player.setAsset(sound.assetPath)
        ├─ _player.setLoopMode(LoopMode.one)   ← infinite loop
        └─ _player.play()


AudioProvider.toggleFocusSound()
  ├─ _isFocusSoundEnabled = !_isFocusSoundEnabled
  ├─ if enabled  → playSelected()   ← plays selectedForFocus sound
  └─ if disabled → pauseAudio()


AudioProvider.playSelected()  [called by TimerProvider._syncAudio()]
  ├─ if !_isFocusSoundEnabled → pauseAudio() (respect user toggle)
  └─ else → play(_selectedForFocus)


Streams (real-time updates to UI):
  ├─ playerStateStream → _isPlaying, _isLoading → notifyListeners()
  ├─ positionStream    → _position              → notifyListeners()
  └─ durationStream    → _duration              → notifyListeners()
```

---

## 10. Settings Screen Flow (Tab 2)

```
SettingsScreen
  └─ Consumer<SettingsProvider>
       └─ Scaffold
            └─ Column of SliderRow widgets
                 ├─ "Productivity Time"  [5–90 min]
                 │     └─ onChanged → settings.setWorkDuration(v) + timer.reset()
                 ├─ "Quick Break"        [1–30 min]
                 │     └─ onChanged → settings.setShortBreak(v)
                 ├─ "Full Break"         [5–60 min]
                 │     └─ onChanged → settings.setLongBreak(v)
                 ├─ "Focus Cycles"       [1–10 cycles]
                 │     └─ onChanged → settings.setSessionRounds(v)
                 └─ "Reset to Defaults" button
                       └─ settings.resetToDefaults() + timer.reset()
```

---

## 11. About Screen Flow (Tab 3)

```
AboutScreen
  └─ Scrollable Column of composable widgets:
       ├─ AboutHeader      → "THE SANCTUARY" + headline
       ├─ QuoteSection     → full-bleed image with italic overlay quote
       ├─ PhilosophyCard   → app philosophy text
       ├─ AboutSubSection  → "Intentionality" + "The Deep Work Habit" blocks
       ├─ LegalSection
       │     ├─ Privacy Policy tile → AboutProvider.launchLink(url)
       │     └─ Terms of Service tile → AboutProvider.launchLink(url)
       ├─ QueriesSection
       │     └─ Copy email button → AboutProvider.copyEmail()
       │           └─ Clipboard.setData("praneshck7@gmail.com")
       │                 └─ Shows SnackBar "Email copied"
       └─ AboutFooter      → "Version 1.0.0 · Created by HillStack"
```

---

## 12. Notification Flow

```
Phase transition occurs (work → break or break → work)
  │
  └─ TimerProvider._triggerNotification(title, body)
        ├─ HapticFeedback.vibrate()   ← immediate device vibration
        └─ NotificationService.showNotification(id, title, body)
              └─ _notificationsPlugin.show(
                    id: Unix timestamp (unique per second),
                    androidDetails: channel "deep_focus_timer"
                                    importance: max, priority: high
                                    vibrationPattern: [0, 500, 200, 500]
                                    icon: notification_icon (drawable)
                    iosDetails: alert + badge + sound
                 )
```

---

## 13. Complete Data Flow Summary

```
User Action
    │
    ▼
View (StatelessWidget)
    │  context.read<Provider>().method()
    ▼
ViewModel (ChangeNotifier)
    │  internal logic runs
    │  notifyListeners()
    ▼
Provider rebuilds all watching widgets
    │
    ▼
UI updates

──────────────────────────────────────────────
Cross-provider reactivity (ProxyProvider):

SettingsProvider.notifyListeners()
    │
    ▼
ProxyProvider2.update() fires
    │
    ▼
TimerProvider.setDependencies(settings, audio)
    │
    ▼
TimerProvider.notifyListeners()
    │
    ▼
Focus screen rebuilds (TimerDisplay, RoundIndicator, etc.)
```

---

## 14. File → Responsibility Map

```
main.dart               → App entry, provider setup, ScreenUtil init
navigation.dart         → Bottom nav shell, lifecycle observer
providers.dart          → Centralized provider registration

core/
  app_colors.dart       → Single color palette source
  app_theme.dart        → MaterialApp ThemeData (Inter font)
  app_bar.dart          → Shared top bar widget
  notification_service  → flutter_local_notifications wrapper

features/focus/
  presentation_screen   → Focus tab scaffold (assembles widgets)
  timer_provider        → Pomodoro engine (phases, rounds, tick, advance)
  time_display          → MM:SS countdown widget
  round_indicator       → Phase chip + "Round X of Y" row
  timer_action          → Pause/Resume/Reset/Skip buttons
  focus_sound_player    → Swipeable sound card on focus screen

features/sounds/
  sound_model           → SoundModel class + hardcoded sound lists
  audio_provider        → just_audio wrapper (play/pause/loop/stream)
  sounds_screen         → Sound library list + selected banner
  sound_tile            → Individual sound list item
  mini_player           → Persistent bottom player with progress bar

features/settings/
  settings_provider     → Timer config state (durations + rounds)
  settings_screen       → Slider UI for all 4 config values
  slider_row            → Reusable labeled slider widget

features/about/
  about_provider        → url_launcher + clipboard helpers
  about_screen          → Assembles all about widgets
  (7 widgets)           → Header, footer, philosophy, legal, queries, quote
```

---

*Deep Focus v1.0.0 — Built with Flutter + Provider (MVVM, feature-first architecture)*
