import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/about/viewmodel/about_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class QueriesSection extends StatelessWidget {
  const QueriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Queries',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Need assistance or have thoughts to share? Our team is dedicated to preserving your peace of mind.',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24.h),
        GestureDetector(
          onTap: () {
            context.read<AboutProvider>().copyEmail();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.lightGreen,
                content: const Text('Email copied !'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mail_outline, color: Colors.white, size: 18.sp),
                SizedBox(width: 10.w),
                Text(
                  'praneshck7@gmail.com',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
