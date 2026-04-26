import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/settings/viewmodel/settings_provider.dart';
import 'package:deep_focus/features/settings/widget/slider_row.dart';
import 'package:deep_focus/features/focus/viewmodel/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          backgroundColor: AppColors.tertiary,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    'CONFIGURATION',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Title
                  Text(
                    'Your Rhythm',
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Subtitle
                  Text(
                    'Customize your focus flow to match your natural cognitive cycles. Soft transitions for deep immersion.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Section header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Focus Intervals',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Icon(
                        Icons.timer_outlined,
                        size: 22.sp,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // Work Duration
                  SliderRow(
                    label: 'Productivity Time',
                    value: settings.workDuration,
                    min: 5,
                    max: 90,
                    unit: 'MIN',
                    onChanged: (v) {
                      settings.setWorkDuration(v);
                      // Reset timer to paused state so display updates
                      context.read<TimerProvider>().reset();
                    },
                  ),

                  SizedBox(height: 28.h),

                  SliderRow(
                    label: 'Quick Break',
                    value: settings.shortBreak,
                    min: 1,
                    max: 30,
                    unit: 'MIN',
                    onChanged: (v) => settings.setShortBreak(v),
                  ),

                  SizedBox(height: 28.h),

                  SliderRow(
                    label: 'Full Break',
                    value: settings.longBreak,
                    min: 5,
                    max: 60,
                    unit: 'MIN',
                    onChanged: (v) => settings.setLongBreak(v),
                  ),

                  SizedBox(height: 28.h),

                  SliderRow(
                    label: 'Focus Cycles',
                    value: settings.sessionRounds,
                    min: 1,
                    max: 10,
                    unit: 'CYCLES',
                    onChanged: (v) => settings.setSessionRounds(v),
                  ),

                  SizedBox(height: 40.h),

                  // Reset button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGray,
                        side: BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        settings.resetToDefaults();
                        context.read<TimerProvider>().reset();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Reset to Defaults',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
