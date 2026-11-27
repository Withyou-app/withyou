import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/onboarding_kit.dart';

/// 회원가입 비밀번호 입력 화면(솔루션4) — 온보딩 3단계.
class PasswordSetupScreen extends StatefulWidget {
  const PasswordSetupScreen({super.key});

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> {
  final _controller = TextEditingController();

  bool get _canNext => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 3,
      title: '회원가입을 위한\n비밀번호를 입력해주세요',
      buttonLabel: '다음',
      nextEnabled: _canNext,
      onNext: () => Navigator.of(context).pushNamed(AppRoutes.signupDone),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('비밀번호'),
          const SizedBox(height: 8),
          BrandTextField(
            hint: '비밀번호 입력',
            controller: _controller,
            obscure: true,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
