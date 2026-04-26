import 'package:deep_focus/core/widgets/app_bar.dart';
import 'package:deep_focus/features/focus/widget/round_indicator.dart';
import 'package:deep_focus/features/focus/widget/focus_sound_player.dart';
import 'package:deep_focus/features/focus/widget/time_display.dart';
import 'package:deep_focus/features/focus/widget/timer_action.dart';
import 'package:deep_focus/features/focus/viewmodel/timer_provider.dart';
import 'package:deep_focus/features/settings/viewmodel/settings_provider.dart';
import 'package:deep_focus/features/sounds/viewmodel/audio_provider.dart';
import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:provider/provider.dart';

class PresentationScreen extends StatelessWidget {
  const PresentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TimerProvider is now global — no local ChangeNotifierProvider needed
    return const _DeepWorkSessionView();
  }
}

class _DeepWorkSessionView extends StatefulWidget {
  const _DeepWorkSessionView();

  @override
  State<_DeepWorkSessionView> createState() => _DeepWorkSessionViewState();
}

class _DeepWorkSessionViewState extends State<_DeepWorkSessionView> {
  TimerPhase? _lastPhase;
  bool? _lastRunning;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final timer = context.watch<TimerProvider>();
    final audio = context.read<AudioProvider>();

    // Sync settings
    timer.syncSettings(settings);

    // Sync Audio with Timer state/phase changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lastPhase != timer.phase || _lastRunning != timer.isRunning) {
        if (timer.isRunning) {
          if (timer.phase == TimerPhase.work) {
            audio.playSelected();
          } else {
            audio.playBreakSound();
          }
        } else {
          audio.pauseAudio();
        }
        _lastPhase = timer.phase;
        _lastRunning = timer.isRunning;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.neutral,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              AppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 25.h),
                      const RoundIndicator(),
                      SizedBox(height: 25.h),
                      const TimerDisplay(),
                      SizedBox(height: 24.h),
                      const TimerAction(),
                      SizedBox(height: 24.h),
                      const FocusSoundPlayer(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
