import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../models/persona.dart';
import '../chat/chat_screen.dart';

/// 페르소나 고르는 창 — 풀스크린. kPersonas 목록으로 카드를 구성한다.
class PersonaSelectScreen extends StatelessWidget {
  const PersonaSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppGaps.screenH),
          child: ListView(
            children: [
              AppGaps.v8,
              const BackHeader(title: '기분에 가장 가까운 친구를 고르세요'),
              AppGaps.v24,
              for (final persona in kPersonas) ...[
                _personaCard(context, persona),
                AppGaps.v16,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _personaCard(BuildContext context, Persona persona) {
    return AppCard(
      // 고른 친구로 '새 대화'를 연다(기존 대화가 있어도 새로 시작).
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.chat,
        arguments: ChatArgs(persona.name, resume: false),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAvatar(size: 64, name: persona.name),
          const SizedBox(width: AppGaps.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(persona.name, style: AppTextStyles.cardTitle),
                    const SizedBox(width: AppGaps.xs),
                    AppBadge(text: persona.type),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  persona.quote,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(persona.description, style: AppTextStyles.cardBody),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
