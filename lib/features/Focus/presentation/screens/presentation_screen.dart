import 'package:deep_focus/core/widgets/app_bar.dart';
import 'package:deep_focus/features/Focus/presentation/widgets/round_indicator.dart';
import 'package:deep_focus/features/Focus/presentation/widgets/sound_player.dart';
import 'package:deep_focus/features/Focus/presentation/widgets/time_display.dart';
import 'package:deep_focus/features/Focus/presentation/providers/timer_provider.dart';
import 'package:deep_focus/features/Focus/presentation/widgets/timer_action.dart';
import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:deep_focus/core/constant/app_colors.dart';

class PresentationScreen extends StatelessWidget {
  const PresentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerProvider(),
      child: const _DeepWorkSessionView(),
    );
  }
}

class _DeepWorkSessionView extends StatelessWidget {
  const _DeepWorkSessionView();

  @override
  Widget build(BuildContext context) {
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
                      SizedBox(height: 50.h),
                      RoundIndicator(),
                      SizedBox(height: 50.h),
                      TimerDisplay(),
                      SizedBox(height: 24.h),
                      TimerAction(),
                      SizedBox(height: 24.h),
                      SoundPlayer(
                        label: 'Current Soundscape',
                        title: 'Midnight Forest',
                        isPlaying: true,
                        onPlayPause: () {
                          // toggle play/pause
                        },
                      ),
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
