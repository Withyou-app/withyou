import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/onboarding_kit.dart';

/// 초대링크 입력 화면(솔루션2) — 온보딩 1단계.
class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
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
      step: 1,
      title: '기업으로부터 받은\n초대링크를 통해 시작할 수 있어요',
      buttonLabel: '다음',
      nextEnabled: _canNext,
      onNext: () => Navigator.of(context).pushNamed(AppRoutes.signupId),
      child: BrandTextField(
        hint: '초대링크를 입력해주세요',
        controller: _controller,
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
