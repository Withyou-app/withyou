import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/session_data.dart';
import '../models/social_provider.dart';
import '../widgets/widgets.dart';

/// 메인 로그인 화면.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final result = await AuthService.instance.logIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (result.ok) {
      _goAfterAuth();
    } else {
      _showError(result.error ?? '로그인에 실패했어요');
    }
  }

  Future<void> _onSocial(SocialProvider provider) async {
    final result = await AuthService.instance.signInWithSocial(provider);
    if (!mounted) return;
    if (result.ok) {
      _goAfterAuth();
    } else {
      _showError(result.error ?? '${provider.label} 로그인에 실패했어요');
    }
  }

  /// 인증 후 이동: 호칭(이름)이 없으면 온보딩(호칭 필수)으로, 있으면 메인 셸로.
  Future<void> _goAfterAuth() async {
    // 실서버 모드: 로그인한 사용자의 대화·리포트를 서버에서 다시 불러온다.
    await SessionData.onLogin();
    if (!mounted) return;
    final name = AuthService.instance.currentUser?.name ?? '';
    final route = name.isEmpty ? AppRoutes.onboarding1 : AppRoutes.shell;
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // 브랜드 타이틀
                  const Text(
                    'withyou+',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '당신만의 AI 감정친구',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 이메일
                  _label('이메일'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(hintText: 'email@example.com'),
                    validator: (v) => (v == null || v.isEmpty)
                        ? '이메일을 입력해주세요'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // 비밀번호
                  _label('비밀번호'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: '비밀번호를 입력해주세요'),
                    validator: (v) => (v == null || v.isEmpty)
                        ? '비밀번호를 입력해주세요'
                        : null,
                  ),
                  const SizedBox(height: 36),

                  // 로그인 버튼
                  ElevatedButton(
                    onPressed: _onLogin,
                    child: const Text('로그인'),
                  ),
                  const SizedBox(height: 20),

                  // 회원가입
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '계정이 없으신가요? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.signupEmail),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          child: Text(
                            '회원가입',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 소셜 로그인 (카카오 / 구글 / 애플)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final provider in SocialProvider.values) ...[
                        SocialLoginButton(
                          provider: provider,
                          onTap: () => _onSocial(provider),
                        ),
                        if (provider != SocialProvider.values.last)
                          const SizedBox(width: 28),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      );
}
