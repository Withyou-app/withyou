import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_gaps.dart';

/// 알약형 뱃지/칩. 페르소나 유형(공감형 등), 감정칩(서운함/불안/안도) 등에 사용.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.text,
    this.background = AppColors.badgePinkBg,
    this.foreground = AppColors.badgePinkText,
  });

  const AppBadge.orange(this.text, {super.key})
      : background = AppColors.emotionOrangeBg,
        foreground = AppColors.emotionOrangeText;

  const AppBadge.green(this.text, {super.key})
      : background = AppColors.emotionGreenBg,
        foreground = AppColors.emotionGreenText;

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
