import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuoteSection extends StatelessWidget {
  const QuoteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/about_bg.png',
            height: 200.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            height: 200.h,
            width: double.infinity,
            color: Colors.black.withValues(alpha: 0.2),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              '"The quieter you become, the more you are able to hear."',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
