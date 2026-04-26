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

class _DeepWorkSessionView extends StatelessWidget {
  const _DeepWorkSessionView();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final timer = context.watch<TimerProvider>();
    final audio = context.read<AudioProvider>();

    // Inject dependencies (View acting as Coordinator)
    timer.setDependencies(settings, audio);

    return Scaffold(
      backgroundColor: AppColors.neutral,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const AppBar(),
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
