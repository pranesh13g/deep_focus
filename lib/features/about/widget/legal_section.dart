import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal & Ethics',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 24.h),
        _LegalTile(
          icon: Icons.security_outlined,
          title: 'Privacy Policy',
          subtitle: 'How we safeguard your focus data',
          onTap: () => launchUrl(
            Uri.parse('https://pranesh13g.github.io/deep-focus-privacy/'),
            mode: LaunchMode.externalApplication,
          ),
        ),
        SizedBox(height: 12.h),
        _LegalTile(
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
          subtitle: 'Our mutual commitment to deep work',
          onTap: () =>{}
           
        
        ),
      ],
    );
  }
}

class _LegalTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LegalTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
