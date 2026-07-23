import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../theme/app_gaps.dart';

/// 코랄 채움 기본 버튼 (전체 폭). 스타일은 테마 ElevatedButton을 따른다.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed ?? () {}, child: Text(label));
  }
}

/// 베이지(뮤트) 보조 버튼. 더 대화하기 / 취소 / 프로필 수정 등.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.muted,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        minimumSize: Size(expanded ? double.infinity : 0, 52),
        textStyle: const TextStyle(
          fontFamily: AppFonts.cocochoitoon,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
        ),
      ),
      child: Text(label),
    );
  }
}
