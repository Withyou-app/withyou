import 'package:flutter/material.dart';
import '../theme/app_gaps.dart';
import '../theme/app_text_styles.dart';

/// 라벨(선택) + 입력 필드. 입력 스타일은 테마(inputDecorationTheme)를 따른다.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.label),
          AppGaps.v8,
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
