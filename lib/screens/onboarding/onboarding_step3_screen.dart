import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';

/// 온보딩 3단계 — 알레르기/선호 향/기타 참고사항 입력.
class OnboardingStep3Screen extends StatelessWidget {
  const OnboardingStep3Screen({super.key});

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
          label: '시작하기',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.shell,
            (r) => false,
          ),
        ),
        children: const [
          LabeledTextField(
            label: '알레르기가 있으신가요?',
            hint: 'ex) 견과류, 새우, 없음',
          ),
          AppGaps.v24,
          LabeledTextField(
            label: '선호하는 향을 입력해주세요',
            hint: 'ex) 우디, 시트러스, 플로럴',
          ),
          AppGaps.v24,
          LabeledTextField(
            label: '기타 참고사항이 있으신가요?',
            hint: 'ex) 고양이를 좋아함, 내성적임',
          ),
        ],
      ),
    );
  }
}
