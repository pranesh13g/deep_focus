import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBar extends StatelessWidget {
  const AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.spa_outlined, color: AppColors.primary, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                'Deep Focus',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontStyle: FontStyle.italic,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary, width: 1.5),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: AppColors.secondary,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}
