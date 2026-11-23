import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/onboarding_kit.dart';

/// 회원가입 아이디 입력 화면(솔루션3) — 온보딩 2단계.
class IdSetupScreen extends StatefulWidget {
  const IdSetupScreen({super.key});

  @override
  State<IdSetupScreen> createState() => _IdSetupScreenState();
}

class _IdSetupScreenState extends State<IdSetupScreen> {
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
      step: 2,
      title: '회원가입을 위한\n아이디를 입력해주세요',
      buttonLabel: '다음',
      nextEnabled: _canNext,
      onNext: () => Navigator.of(context).pushNamed(AppRoutes.signupPw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('아이디'),
          const SizedBox(height: 8),
          BrandTextField(
            hint: '아이디 입력',
            controller: _controller,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
