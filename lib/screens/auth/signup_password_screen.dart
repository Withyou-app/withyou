import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../utils/validators.dart';

/// 회원가입 2단계 — 비밀번호 입력/확인 후 계정 생성.
/// 이메일은 이전 단계에서 라우트 인자(String)로 전달받는다.
class SignupPasswordScreen extends StatefulWidget {
  const SignupPasswordScreen({super.key});

  @override
  State<SignupPasswordScreen> createState() => _SignupPasswordScreenState();
}

class _SignupPasswordScreenState extends State<SignupPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onNext() {
    final email =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? '';
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty) return _showError('비밀번호를 입력해주세요');
    if (!Validators.isValidPassword(password)) {
      return _showError('비밀번호는 ${Validators.passwordRule}이어야 해요');
    }
    if (password != confirm) return _showError('비밀번호가 일치하지 않아요');

    // 약관 동의 단계로 이동. 실제 계정 생성은 약관 동의 후 진행한다.
    Navigator.pushNamed(
      context,
      AppRoutes.signupTerms,
      arguments: (email, password),
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
          LabeledTextField(
            label: '비밀번호',
            hint: Validators.passwordRule,
            controller: _passwordController,
            obscureText: true,
          ),
          AppGaps.v24,
          LabeledTextField(
            label: '비밀번호 확인',
            hint: '비밀번호를 입력해주세요',
            controller: _confirmController,
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
