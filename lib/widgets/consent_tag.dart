import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../theme/app_gaps.dart';

/// 동의 항목의 필수(코랄)/선택(회색) 태그.
class ConsentTag extends StatelessWidget {
  const ConsentTag({super.key, required this.required});

  final bool required;

  @override
  Widget build(BuildContext context) {
    final color = required ? AppColors.primary : AppColors.navInactive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        required ? '필수' : '선택',
        style: TextStyle(
          fontFamily: AppFonts.cocochoitoon,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
