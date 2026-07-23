import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';

/// 온보딩 2단계 — 유머 취향/받고 싶은 선물 입력.
class OnboardingStep2Screen extends StatelessWidget {
  const OnboardingStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardAwareForm(
        header: const BackHeader(
          title: '반가워요!',
          subtitle: 'ID님에 대해 조금만 더 알려주시면,\n'
              '페르소나에 맞춰 대화할 수 있어요.',
        ),
        action: PrimaryButton(
          label: '다음',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.onboarding3),
        ),
        children: const [
          LabeledTextField(
            label: '유머 취향을 입력해주세요',
            hint: 'ex) 아이러니, 블랙 코미디, 슬랩스틱',
          ),
          AppGaps.v24,
          LabeledTextField(
            label: '받고 싶은 선물을 입력해주세요',
            hint: 'ex) 소품, 향초, 디저트',
          ),
        ],
      ),
    );
  }
}
