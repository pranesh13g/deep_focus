import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/Focus/presentation/providers/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TimerAction extends StatelessWidget {
  const TimerAction({super.key});

  @override
  Widget build(BuildContext context) {
    final isRunning = context.select<TimerProvider, bool>((p) => p.isRunning);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64.h,
          child: ElevatedButton(
            onPressed: () => context.read<TimerProvider>().togglePause(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.r),
              ),
            ),
            child: Text(
              isRunning ? 'Pause Session' : 'Resume Session',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => context.read<TimerProvider>().restartSession(),
              child: Row(
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    color: AppColors.textSecondary,
                    size: 18.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Restart Session',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'End Session',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB85C5C),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
