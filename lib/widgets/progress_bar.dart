import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 코랄 진행 바. [value] 는 0.0 ~ 1.0.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value, this.height = 6});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: AppColors.track,
        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
      ),
    );
  }
}
