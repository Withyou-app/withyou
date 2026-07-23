import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_gaps.dart';
import '../theme/app_text_styles.dart';

/// 하단 채팅 입력 바 — 코랄 테두리 알약형 + 종이비행기 전송 아이콘.
/// 대화창/문의하기에서 공통 사용.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    this.hint = '자유롭게 입력하세요',
    this.controller,
    this.focusNode,
    this.onSend,
  });

  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppGaps.screenH, AppGaps.sm, AppGaps.screenH, AppGaps.sm),
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.primary, width: 1.4),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  // 가로로 밀리지 않고 위로 쌓이도록 자동 줄바꿈(최대 6줄 후 내부 스크롤).
                  minLines: 1,
                  maxLines: 6,
                  // 멀티라인이어도 엔터(전송) 키로 바로 전송.
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend?.call(),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.body
                        .copyWith(color: AppColors.textHint),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
