import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/sounds/model/sound_model.dart';
import 'package:deep_focus/features/sounds/viewmodel/audio_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SoundTile extends StatelessWidget {
  final SoundModel sound;

  const SoundTile({super.key, required this.sound});

  Widget _buildIcon(String iconPath) {
    final Map<String, IconData> iconMap = {
      'white': Icons.graphic_eq,
      'calm': Icons.spa,
      'chill': Icons.nightlife,
      'rain': Icons.beach_access,
      'ocean': Icons.waves,
      'forest': Icons.park,
      'thunder': Icons.flash_on,
    };
    final Map<String, Color> colorMap = {
      'white': const Color(0xFF78909C),
      'calm': const Color(0xFF81C784),
      'chill': const Color(0xFFBA68C8),
      'rain': const Color(0xFF4FC3F7),
      'ocean': const Color(0xFF4DB6AC),
      'forest': const Color(0xFFAED581),
      'thunder': const Color(0xFFFFB74D),
    };

    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: (colorMap[iconPath] ?? AppColors.primary).withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconMap[iconPath] ?? Icons.music_note,
        color: colorMap[iconPath] ?? AppColors.primary,
        size: 22,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        final isCurrent = audioProvider.isCurrent(sound.id);
        final isPlaying = audioProvider.isCurrentlyPlaying(sound.id);
        final isLoading = isCurrent && audioProvider.isLoading;
        final isSelectedForFocus = audioProvider.isSelectedForFocus(sound.id);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.primary.withValues(alpha: 0.07)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.lightGray,
              width: 1.2,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              _buildIcon(sound.iconPath),
              SizedBox(width: 14.w),
              // Tapping the text area selects for focus and plays
              Expanded(
                child: GestureDetector(
                  onTap: () => audioProvider.selectAndToggle(sound),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with "For Focus" badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              sound.title,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: isCurrent
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (isSelectedForFocus) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'FOR FOCUS',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sound.subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Play/Pause button — standalone, does NOT bubble to a parent GestureDetector
              GestureDetector(
                onTap: () => audioProvider.selectAndToggle(sound),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.primary : AppColors.tertiary,
                    shape: BoxShape.circle,
                  ),
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isCurrent ? Colors.white : AppColors.primary,
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: isCurrent ? Colors.white : AppColors.primary,
                          size: 20,
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
