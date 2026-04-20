import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/Focus/presentation/providers/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RoundIndicator extends StatelessWidget {
  const RoundIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final round = context.select<TimerProvider, int>((p) => p.currentRound);

    return Column(
      children: [
        Text(
          'DEEP WORK SESSION',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: 3.w,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(
                color: AppColors.secondary.withOpacity(0.4),
                thickness: 1,
                endIndent: 12.w,
              ),
            ),
            Text(
              'Round $round of ${TimerProvider.totalRounds}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.secondary.withOpacity(0.4),
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
