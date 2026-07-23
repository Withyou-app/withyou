import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../theme/app_gaps.dart';
import '../theme/app_text_styles.dart';

/// 두 개의 액션(취소/확인)을 가진 흰색 라운드 모달.
/// 예: "대화를 종료할까요?", "정말 대화를 삭제하시겠습니까?"
///
/// [confirmDanger] 가 true면 확인 버튼이 코랄, false면 좌우 강조가 반대가 된다.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    this.onCancel,
    this.onConfirm,
  });

  final String title;
  final String? message;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  /// 화면 위에 모달을 띄운다. 확인 시 true, 취소 시 false 를 반환.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? message,
    required String cancelLabel,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        onCancel: () => Navigator.of(ctx).pop(false),
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.modal),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(fontSize: 19)),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(message!,
                  textAlign: TextAlign.center, style: AppTextStyles.subtitle),
            ],
            AppGaps.v24,
            Row(
              children: [
                Expanded(child: _button(cancelLabel, false)),
                const SizedBox(width: AppGaps.sm),
                Expanded(child: _button(confirmLabel, true)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(String label, bool primary) {
    return ElevatedButton(
      onPressed: primary ? onConfirm : onCancel,
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? AppColors.primary : AppColors.muted,
        foregroundColor: primary ? AppColors.white : AppColors.textPrimary,
        elevation: 0,
        minimumSize: const Size.fromHeight(50),
        textStyle: const TextStyle(
          fontFamily: AppFonts.cocochoitoon,
          fontSize: 15,
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
