import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutFooter extends StatelessWidget {
  const AboutFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Version 1.0.0 ',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 4.h),
          // Text(
          //   'Created by HillStack',
          //   style: TextStyle(
          //     fontSize: 12.sp,
          //     color: AppColors.textSecondary.withValues(alpha: 0.6),
          //   ),
          // ),
        ],
      ),
    );
  }
}
