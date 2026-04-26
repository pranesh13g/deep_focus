import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhilosophyCard extends StatelessWidget {
  const PhilosophyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: AppColors.primary, size: 24.sp),
          SizedBox(height: 16.h),
          Text(
            'Our Philosophy',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'In an age of constant noise, Deep Focus was born from a simple realization: the most profound work happens in the quiet gaps between notifications. We design environments that don\'t just track your time, but protect your peace.',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
