import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

/// 회원가입 1단계 — 이메일 입력 + 이메일 인증.
/// 이메일 필드 안 작은 버튼으로 인증번호 요청 → 아래 칸에 인증번호 입력 →
/// 하단 "다음" 이 인증 확인 + 다음 단계 이동을 겸한다.
class SignupEmailScreen extends StatefulWidget {
  const SignupEmailScreen({super.key});

  @override
  State<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends State<SignupEmailScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  bool _sending = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendCode() async {
    if (_sending) return;
    final email = _emailController.text.trim();
    if (!Validators.isValidEmail(email)) {
      _toast('올바른 이메일 형식이 아니에요');
      return;
    }
    // 이메일은 계정 PK — 이미 가입된 이메일이면 인증을 진행하지 않는다.
    if (AuthService.instance.isEmailRegistered(email)) {
      _toast('이미 가입된 이메일이에요');
      return;
    }
    setState(() => _sending = true);
    final result = await AuthService.instance.sendVerificationCode(email);
    if (!mounted) return;
    setState(() => _sending = false);

    if (!result.ok) {
      _toast(result.error ?? '인증번호 전송에 실패했어요');
      return;
    }
    _toast(result.demoCode != null
        ? '인증번호를 전송했어요 (데모: ${result.demoCode})'
        : '인증번호를 이메일로 보냈어요');
  }

  /// "다음" = 인증번호 확인 + 다음 단계 이동.
  void _onNext() {
    // 이메일 중복 방지(방어적 재확인).
    if (AuthService.instance.isEmailRegistered(_emailController.text.trim())) {
      _toast('이미 가입된 이메일이에요');
      return;
    }
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _toast('인증번호를 입력해주세요');
      return;
    }
    final ok =
        AuthService.instance.verifyEmailCode(_emailController.text, code);
    if (!ok) {
      _toast('인증번호가 일치하지 않아요');
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.signupPassword,
      arguments: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardAwareForm(
        headerGap: AppGaps.v36,
        header: const BackHeader(
          title: '회원가입',
          subtitle: 'withyou+와 함께 시작해요',
        ),
        action: PrimaryButton(label: '다음', onPressed: _onNext),
        children: [
          // 이메일 (필드 안에 작은 인증 버튼)
          const Text('이메일', style: AppTextStyles.label),
          AppGaps.v8,
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'email@example.com',
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _sendChip(),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
                maxHeight: 48,
              ),
            ),
          ),
          AppGaps.v20,

          // 인증번호 (라벨 없이 입력칸만)
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '인증번호를 입력해주세요'),
          ),
        ],
      ),
    );
  }

  /// 이메일 필드 안에 들어가는 작은 코랄 칩 버튼.
  Widget _sendChip() {
    final enabled = !_sending;
    return Material(
      color: enabled
          ? AppColors.primary
          : AppColors.primary.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? _sendCode : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            _sending ? '전송중' : '인증',
            style: const TextStyle(
              fontFamily: AppFonts.cocochoitoon,
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
