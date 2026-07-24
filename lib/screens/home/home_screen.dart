import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/conversation_store.dart';
import '../chat/chat_screen.dart';

/// 메인화면 — 탭 화면(콘텐츠 전용). 하단 네비는 상위 셸이 얹는다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// 홈에 표시할 사용자 이름. 온보딩 호칭 → 없으면 이메일 아이디 → 없으면 'ID'.
  String _displayName() {
    final user = AuthService.instance.currentUser;
    if (user == null) return 'ID';
    if (user.name.isNotEmpty) return user.name;
    final id = user.email.split('@').first;
    return id.isNotEmpty ? id : 'ID';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppGaps.screenH),
        child: ListView(
          children: [
            AppGaps.v24,
            const Text('안녕하세요', style: AppTextStyles.subtitle),
            AppGaps.v8,
            Text('${_displayName()}님 오늘도 함께해요', style: AppTextStyles.title),
            AppGaps.v36,
            PrimaryButton(
              label: '새 대화 시작하기',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.persona),
            ),
            AppGaps.v36,
            // 실제 진행 중 대화를 최근 세션으로 표시(마지막 문장 포함).
            AnimatedBuilder(
              animation: ConversationStore.instance,
              builder: (context, _) {
                final personas =
                    ConversationStore.instance.personasWithHistory;
                if (personas.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('최근 세션', style: AppTextStyles.label),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.conversations),
                          child: Text('전체보기',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    AppGaps.v16,
                    for (var i = 0; i < personas.length && i < 3; i++) ...[
                      if (i > 0) AppGaps.v12,
                      _sessionCard(context, personas[i]),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(BuildContext context, String name) {
    final preview =
        ConversationStore.instance.lastPreview(name) ?? '대화를 이어가 볼까요?';
    return AppCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.chat,
          arguments: ChatArgs(name, resume: true)),
      child: Row(
        children: [
          AppAvatar(size: 48, name: name),
          const SizedBox(width: AppGaps.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name와의 대화', style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardBody,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
