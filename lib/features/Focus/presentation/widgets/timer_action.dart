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
    final isRunning =
        context.select<TimerProvider, bool>((p) => p.isRunning);

    return Column(
      children: [
        // ── Pause / Resume ──────────────────────────────────────────
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
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 6.w),
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

        SizedBox(height: 12.h),

        // ── Reset + Skip ────────────────────────────────────────────
        Row(
          children: [
            // Reset
            Expanded(
              child: SizedBox(
                height: 72.h,
                child: ElevatedButton(
                  onPressed: () => context.read<TimerProvider>().reset(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.textSecondary,
                        size: 20.sp,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Reset',
                        style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Skip
            Expanded(
              child: SizedBox(
                height: 72.h,
                child: ElevatedButton(
                  onPressed: () => context.read<TimerProvider>().skip(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGray,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.textSecondary,
                        size: 20.sp,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontSize: 11.sp,
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
