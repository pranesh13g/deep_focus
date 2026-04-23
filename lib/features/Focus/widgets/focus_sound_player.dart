import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/sounds/providers/audio_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// A self-contained sound player card for the Focus screen.
/// Shows the sound currently selected-for-focus and its play/pause state.
class FocusSoundPlayer extends StatelessWidget {
  const FocusSoundPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        final sound = audio.selectedForFocus;
        final isPlaying =
            audio.isPlaying && (audio.currentSound?.id == sound?.id);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.neutral,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail / icon
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 56.w,
                  height: 56.w,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.graphic_eq,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
              ),

              SizedBox(width: 14.w),

              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CURRENT SOUNDSCAPE',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      sound?.title ?? 'No sound selected',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              // Play/Pause button
              GestureDetector(
                onTap: () {
                  if (sound != null) {
                    if (audio.currentSound?.id == sound.id) {
                      audio.togglePlayPause();
                    } else {
                      audio.playSelected();
                    }
                  }
                },
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: audio.isLoading && audio.currentSound?.id == sound?.id
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 22.sp,
                          color: AppColors.textPrimary,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
