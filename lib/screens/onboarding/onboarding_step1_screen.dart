import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

/// 온보딩 1단계 — 호칭/스타일/자기소개 입력.
/// 입력한 '호칭'을 표시 이름으로 저장한다(홈의 "OO님").
class OnboardingStep1Screen extends StatefulWidget {
  const OnboardingStep1Screen({super.key});

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen> {
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      // 호칭은 필수.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('호칭을 입력해주세요')),
      );
      return;
    }
    await AuthService.instance.setName(nickname);
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.onboarding2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardAwareForm(
        header: const BackHeader(
          title: '반가워요!',
          subtitle: 'ID님에 대해 조금만 더 알려주시면,\n'
              '페르소나에 맞춰 대화할 수 있어요.',
        ),
        action: PrimaryButton(label: '다음', onPressed: _onNext),
        children: [
          LabeledTextField(
            label: '호칭 *',
            hint: '불리고 싶은 호칭을 입력해주세요',
            controller: _nicknameController,
          ),
          AppGaps.v24,
          const Text('어떤 스타일로 불러드릴까요?', style: AppTextStyles.label),
          AppGaps.v8,
          const SegmentedToggle(options: ['반말', '존댓말']),
          AppGaps.v24,
          const LabeledTextField(
            label: '자기소개',
            hint: '자기소개를 간단하게 입력해주세요',
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}
