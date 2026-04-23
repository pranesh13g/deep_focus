import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/focus/viewmodel/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();
    final minutes = timerProvider.minutesPart;
    final seconds = timerProvider.secondsPart;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              minutes,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 96.sp,
                fontWeight: FontWeight.w300,
                color: AppColors.primary,
                height: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                '·',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 72.sp,
                  fontWeight: FontWeight.w300,
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
            ),
            Text(
              seconds,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 96.sp,
                fontWeight: FontWeight.w300,
                color: AppColors.primary,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
