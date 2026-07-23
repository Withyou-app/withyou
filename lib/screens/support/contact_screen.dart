import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// 문의하기 — 풀스크린. 관리자와의 채팅형 화면.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppGaps.screenH, vertical: AppGaps.sm),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: AppGaps.xs),
                  const Text(
                    '문의하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppGaps.screenH, vertical: AppGaps.lg),
              children: [
                Text('관리자',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                AppGaps.v8,
                const ChatBubble.received('뭐 저는 관리자입니다,'),
                const ChatBubble.received(
                  '편하게 문의할 사항을 입력해주세요',
                  time: '오후 9:10',
                ),
                const ChatBubble.sent('우와 안녕 ㅠㅠ', time: '오후 9:10'),
              ],
            ),
          ),
          // 입력 바를 body 안에 두어 키보드가 올라올 때 그 위로 올라오게 한다.
          const ChatInputBar(hint: '자유롭게 입력하세요'),
        ],
      ),
    );
  }
}
