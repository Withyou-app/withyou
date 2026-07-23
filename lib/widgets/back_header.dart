import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_gaps.dart';
import '../theme/app_text_styles.dart';

/// 좌측 뒤로가기(<) 아이콘 버튼. 기본 동작은 Navigator.maybePop.
/// 아이콘 글리프가 콘텐츠 좌측선에 맞도록 살짝 왼쪽으로 보정한다.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkResponse(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        radius: 24,
        child: Transform.translate(
          offset: const Offset(-8, 0),
          child: const Icon(Icons.chevron_left,
              size: 32, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// 뒤로가기 + 대제목(+보조설명)으로 이루어진 화면 상단 헤더.
/// 인트로/회원가입/페르소나/리포트/선물/마이 등에서 공통 사용.
class BackHeader extends StatelessWidget {
  const BackHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBack) ...[
          const SizedBox(height: 12), // 상태바 아래 여백
          AppBackButton(onTap: onBack),
          AppGaps.v16,
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(title, style: AppTextStyles.title)),
            ?trailing,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.subtitle),
        ],
      ],
    );
  }
}
