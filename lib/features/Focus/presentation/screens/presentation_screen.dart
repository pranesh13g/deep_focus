import 'package:deep_focus/core/widgets/app_bar.dart';
import 'package:deep_focus/core/widgets/round_indicator.dart';
import 'package:deep_focus/core/widgets/time_display.dart';
import 'package:deep_focus/features/Focus/presentation/providers/timer_provider.dart';
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

  static const String _userName = 'Arthur';

  void _showEndSessionDialog(BuildContext context) {
    final provider = context.read<TimerProvider>();
    final elapsed =
        (TimerProvider.sessionDurationSeconds - provider.remainingSeconds) ~/
        60;

    provider.endSession();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.neutral,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Session Ended',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Great work, $_userName! You completed $elapsed minutes of focus.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Done',
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundIndicator(),
                    SizedBox(height: 72.h),
                    TimerDisplay(),
                  ],
                ),
              ),
              _BottomActions(
                onEndSession: () => _showEndSessionDialog(context),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final VoidCallback onEndSession;

  const _BottomActions({required this.onEndSession});

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
              onTap: onEndSession,
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
