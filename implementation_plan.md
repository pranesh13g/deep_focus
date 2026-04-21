# Deep Focus – Full Feature Implementation Plan

## Summary

Wire up the three screens (Focus, Sounds, Settings) so they are fully interconnected with real state:

| Feature | Current state | Target state |
|---|---|---|
| Timer – no auto-start on first visit | Auto-starts on creation | Starts **paused** |
| Pause/Resume button | Works (togglePause) | ✅ Keep, fix initial state |
| Reset button | Calls `restartSession()` which auto-starts | Resets timer to 00:00, **stays paused** |
| Skip button | No-op | Advances to next work round (or break), skips rest/break too |
| Break phase | Not implemented | After each work round → break phase (short/long), skip skips it |
| Music auto-start on Resume | Not implemented | When user presses Resume, AudioProvider auto-plays selected sound |
| Focus screen SoundPlayer widget | Hard-coded title/state | Reads from `AudioProvider`, shows selected sound, play/pause works |
| Sounds screen → set sound for Focus | Works for sounds page only | Selecting a sound marks it as "selected for Focus"; Focus screen reflects this |
| Settings → SettingsProvider | Local `setState` only, no effect on other screens | Introduce `SettingsProvider` (work, shortBreak, longBreak, rounds, reset to defaults) |
| TimerProvider reads settings | Hard-coded 25 min / 4 rounds | Reads from `SettingsProvider` |
| Round indicator | Shows hard-coded `TimerProvider.totalRounds` | Reads totalRounds from provider |

---

## Open Questions

> [!IMPORTANT]
> **Break behaviour on skip**: When user presses Skip during a **work** round, should it go straight to the next work round (skipping the break entirely)? Or should it enter the break phase and then skip from there?
>
> **Decision taken (your request)**: Pressing Skip simply moves on — if in work it skips to break, if in break it skips to next work round. Both are a single Skip press to the next phase.

---

## Proposed Changes

### 1. New: `SettingsProvider`

#### [NEW] `lib/features/settings/providers/settings_provider.dart`
- `workDuration` (default 25 min), `shortBreak` (5), `longBreak` (15), `sessionRounds` (4)
- `resetToDefaults()` restores those defaults
- `ChangeNotifier` so other providers/screens rebuild

---

### 2. Modify: `TimerProvider`

#### [MODIFY] `lib/features/Focus/presentation/providers/timer_provider.dart`
- Remove `static const` hardcoded values
- Accept `SettingsProvider` reference (passed in constructor or via `update()`)
- **Do NOT auto-start** on construction (`_isRunning = false`)
- `togglePause()` — if resuming, also calls `AudioProvider.playSelected()` (inject via constructor or a callback)
- `reset()` — resets time, stays paused, stops audio
- `skip()` — advances phase (work→break or break→next work round); if on last round + break done → session complete
- Phase tracking: `TimerPhase { work, shortBreak, longBreak }`
- On natural expiry (timer hits 0): advance phase automatically
- Expose: `currentPhase`, `currentRound`, `totalRounds`, `isRunning`, `remainingSeconds`, formatted parts

---

### 3. Modify: `AudioProvider`

#### [MODIFY] `lib/features/sounds/providers/audio_provider.dart`
- Add `SoundModel? _selectedForFocus` — the sound chosen from Sounds screen to play on Focus
- `selectForFocus(SoundModel)` — stores selection, does NOT auto-play
- `playSelected()` — plays `_selectedForFocus` (called by TimerProvider when resuming)
- Default selected sound = `essentialTones[0]` (White Noise)
- Expose `selectedForFocus`

---

### 4. Modify: `providers.dart`

#### [MODIFY] `lib/providers.dart`
- Register `SettingsProvider` in `allProviders`
- `TimerProvider` needs `SettingsProvider` — use `ProxyProvider` so settings changes propagate

---

### 5. Modify: Focus Screen & Widgets

#### [MODIFY] `lib/features/Focus/presentation/screens/presentation_screen.dart`
- Remove local `ChangeNotifierProvider(create: (_) => TimerProvider())` — TimerProvider is now global
- `SoundPlayer` widget reads from `AudioProvider` (selected sound, isPlaying)

#### [MODIFY] `lib/features/Focus/presentation/widgets/timer_action.dart`
- Skip button → calls `context.read<TimerProvider>().skip()`
- Reset button → calls `context.read<TimerProvider>().reset()`

#### [MODIFY] `lib/features/Focus/presentation/widgets/round_indicator.dart`
- Show current phase label ("WORK SESSION" / "SHORT BREAK" / "LONG BREAK")
- `totalRounds` from provider (not static const)

#### [MODIFY] `lib/features/Focus/presentation/widgets/sound_player.dart`
- Make it a `Consumer<AudioProvider>` widget (no external props needed)
- Shows `selectedForFocus` sound name and play/pause state
- Tapping play/pause calls `audioProvider.togglePlayPause()`

---

### 6. Modify: Sounds Screen

#### [MODIFY] `lib/features/sounds/presentation/widgets/sound_title.dart`
- After tapping a sound tile → call `audioProvider.selectForFocus(sound)` in addition to `play()`
- Show "Selected for Focus" badge on the tile that matches `selectedForFocus`

#### [MODIFY] `lib/features/sounds/presentation/screens/sounds_screen.dart`
- Show currently-selected-for-focus sound at the top (small banner/chip)

---

### 7. Modify: Settings Screen

#### [MODIFY] `lib/features/settings/presentation/screens/settings_screen.dart`
- Convert from local `setState` to `Consumer<SettingsProvider>`
- Sliders update `SettingsProvider`
- Reset button calls `settingsProvider.resetToDefaults()`

---

## Verification Plan

### Automated
- `flutter analyze` — no errors

### Manual (via DevicePreview)
1. Open Focus tab → timer shows at paused state (not counting)
2. Press Resume → timer starts counting down, audio plays
3. Press Pause → timer stops, audio pauses
4. Press Reset → timer back to work duration, paused, audio stops
5. Press Skip → advances phase (work→break or break→work), audio continues
6. Let timer run to 0 → auto-advances phase
7. Go to Sounds → tap a different sound → it shows "Selected for Focus"
8. Return to Focus → SoundPlayer shows new sound name
9. Go to Settings → change work duration → Focus timer shows new duration
10. Settings Reset → values revert to defaults, Focus timer updates
