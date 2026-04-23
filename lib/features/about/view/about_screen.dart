import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'pranesh67@gmail.com',
      query: 'subject=Query about Deep Focus',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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

              SizedBox(height: 40.h),

              // Circular Placeholder/Visual
              Center(
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Philosophy Card
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
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
                      'In an age of constant noise, Focus-Flow was born from a simple realization: the most profound work happens in the quiet gaps between notifications. We design environments that don\'t just track your time, but protect your peace.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // Sub-sections
              _buildTextSection(
                'Intentionality',
                'Every interaction in Focus-Flow is designed to minimize cognitive load. We believe in soft edges, neutral tones, and the power of white space.',
              ),
              SizedBox(height: 32.h),
              _buildTextSection(
                'The Deep Work Habit',
                'Reflection is as important as execution. Our tools are built to help you journal your progress and visualize your mental clarity.',
              ),

              SizedBox(height: 40.h),

              // Image with Quote
              ClipRRect(
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
              ),

              SizedBox(height: 60.h),

              // Legal Section
              Text(
                'Legal & Ethics',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 24.h),
              _buildLegalTile(
                Icons.security_outlined,
                'Privacy Policy',
                'How we safeguard your focus data',
                () => _launchURL('https://your-privacy-link.com'),
              ),
              SizedBox(height: 12.h),
              _buildLegalTile(
                Icons.description_outlined,
                'Terms & Conditions',
                'Our mutual commitment to deep work',
                () => _launchURL('https://your-terms-link.com'),
              ),

              SizedBox(height: 60.h),

              // Queries
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
                onTap: _sendEmail,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mail_outline,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'pranesh67@gmail.com',
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

              SizedBox(height: 80.h),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'Version 1.0.0 — Pomodoro',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Created by Gebede-Flow',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLegalTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
