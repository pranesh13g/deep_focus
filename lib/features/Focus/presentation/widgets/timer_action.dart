import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/Focus/presentation/providers/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  isRunning ? 'Pause Session' : 'Resume Session',
                  style: TextStyle(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 80.h,
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<TimerProvider>().restartSession(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.textSecondary,
                        size: 18.sp,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Restart',
                        style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: SizedBox(
                height: 80.h,
                child: ElevatedButton(
                  onPressed: () => {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGray,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.textSecondary,
                        size: 18.sp,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
