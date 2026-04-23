import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/Focus/viewmodel/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RoundIndicator extends StatelessWidget {
  const RoundIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();
    final round = timerProvider.currentRound;
    final total = timerProvider.totalRounds;
    final phaseLabel = timerProvider.phaseLabel;
    final phase = timerProvider.phase;

    final Color phaseColor = switch (phase) {
      TimerPhase.work => AppColors.primary,
      TimerPhase.shortBreak => AppColors.lightGreen,
      TimerPhase.longBreak => AppColors.lightindigo,
    };

    return Column(
      children: [
        // Phase chip
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: phaseColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: phaseColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            phaseLabel,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.w,
              color: phaseColor,
            ),
          ),
        ),

        SizedBox(height: 14.h),

        // Round divider row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(
                color: AppColors.secondary.withValues(alpha: 0.4),
                thickness: 1,
                endIndent: 12.w,
              ),
            ),
            Text(
              'Round $round of $total',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.secondary.withValues(alpha: 0.4),
                thickness: 1,
                indent: 12.w,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
