import 'package:deep_focus/core/constant/app_colors.dart';
import 'package:deep_focus/features/about/widget/about_footer.dart';
import 'package:deep_focus/features/about/widget/about_header.dart';
import 'package:deep_focus/features/about/widget/about_sub_section.dart';
import 'package:deep_focus/features/about/widget/legal_section.dart';
import 'package:deep_focus/features/about/widget/philosophy_card.dart';
import 'package:deep_focus/features/about/widget/queries_section.dart';
import 'package:deep_focus/features/about/widget/quote_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
              const AboutHeader(),
              SizedBox(height: 40.h),
              const PhilosophyCard(),
              SizedBox(height: 40.h),
              const AboutSubSection(
                title: 'Intentionality',
                content:
                    'Every interaction in Focus-Flow is designed to minimize cognitive load. We believe in soft edges, neutral tones, and the power of white space.',
              ),
              SizedBox(height: 32.h),
              const AboutSubSection(
                title: 'The Deep Work Habit',
                content:
                    'Reflection is as important as execution. Our tools are built to help you journal your progress and visualize your mental clarity.',
              ),
              SizedBox(height: 40.h),
              const QuoteSection(),
              SizedBox(height: 40.h),
              const LegalSection(),
              SizedBox(height: 40.h),
              const QueriesSection(),
              SizedBox(height: 40.h),
              const AboutFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
