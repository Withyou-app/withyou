import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';

/// 온보딩 1단계 — 호칭/말투(반말·존댓말)/자기소개 입력.
/// 입력값을 프로필로 저장한다(말투는 AI 대화에 그대로 적용됨).
class OnboardingStep1Screen extends StatefulWidget {
  const OnboardingStep1Screen({super.key});

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen> {
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  int _speechIndex = 0; // 0 = 반말(기본), 1 = 존댓말
  static const _styles = [AppUser.kBanmal, AppUser.kJondaetmal];

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('호칭을 입력해주세요')),
      );
      return;
    }
    // 호칭 + 말투 + 자기소개를 한 번에 저장.
    final base = AuthService.instance.currentUser;
    if (base != null) {
      await AuthService.instance.updateProfile(base.copyWith(
        name: nickname,
        speechStyle: _styles[_speechIndex],
        bio: _bioController.text.trim(),
      ));
    } else {
      await AuthService.instance.setName(nickname);
    }
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
          const Text('어떤 말투로 대화할까요?', style: AppTextStyles.label),
          AppGaps.v8,
          SegmentedToggle(
            options: const ['반말', '존댓말'],
            initialIndex: _speechIndex,
            onChanged: (i) => _speechIndex = i,
          ),
          AppGaps.v24,
          LabeledTextField(
            label: '자기소개',
            hint: '자기소개를 간단하게 입력해주세요',
            controller: _bioController,
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}
