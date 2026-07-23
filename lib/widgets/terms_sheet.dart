import 'package:flutter/material.dart';
import '../models/consent_term.dart';
import '../theme/theme.dart';
import 'app_buttons.dart';
import 'consent_tag.dart';

/// 약관 본문을 하단에서 올라오는 시트로 보여준다.
/// 동의 항목 글자를 탭하면 호출한다. (마이페이지 / 회원가입 약관 화면 공통)
Future<void> showTermsSheet(BuildContext context, ConsentTerm term) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    barrierColor: AppColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 그래버
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
                AppGaps.v16,
                Row(
                  children: [
                    ConsentTag(required: term.required),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(term.title, style: AppTextStyles.cardTitle),
                    ),
                  ],
                ),
                AppGaps.v16,
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      term.body,
                      style: AppTextStyles.body.copyWith(height: 1.6),
                    ),
                  ),
                ),
                AppGaps.v20,
                PrimaryButton(
                  label: '확인',
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
