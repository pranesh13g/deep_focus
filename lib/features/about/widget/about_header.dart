import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutHeader extends StatelessWidget {
  const AboutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE SANCTUARY',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Crafting space\nfor quiet\nbrilliance.',
          style: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.w300,
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
