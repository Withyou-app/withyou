import 'package:flutter/material.dart';
import '../../models/consent_term.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/session_data.dart';

/// 회원가입 3단계 — 약관 동의.
/// 이전 단계에서 (이메일, 비밀번호)를 라우트 인자로 전달받는다.
/// 필수 항목에 모두 동의해야 계정이 생성되고 온보딩으로 넘어간다.
/// 각 항목 글자를 누르면 하단에서 약관 본문 시트가 올라온다.
class SignupTermsScreen extends StatefulWidget {
  const SignupTermsScreen({super.key});

  @override
  State<SignupTermsScreen> createState() => _SignupTermsScreenState();
}

class _SignupTermsScreenState extends State<SignupTermsScreen> {
  // 항목 key → 동의 여부
  final Map<String, bool> _agreed = {
    for (final t in kConsentTerms) t.key: false,
  };

  bool get _allChecked => _agreed.values.every((v) => v);
  bool get _requiredChecked =>
      kConsentTerms.where((t) => t.required).every((t) => _agreed[t.key]!);

  void _toggleAll() {
    final next = !_allChecked;
    setState(() {
      for (final t in kConsentTerms) {
        _agreed[t.key] = next;
      }
    });
  }

  void _toggle(String key) => setState(() => _agreed[key] = !_agreed[key]!);

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onSubmit() async {
    if (!_requiredChecked) {
      _toast('필수 약관에 모두 동의해주세요');
      return;
    }
    final args =
        ModalRoute.of(context)?.settings.arguments as (String, String)?;
    if (args == null) return;
    final (email, password) = args;

    final result =
        await AuthService.instance.signUp(email: email, password: password);
    if (!mounted) return;
    if (!result.ok) {
      _toast(result.error ?? '회원가입에 실패했어요');
      return;
    }
    // 마케팅(선택) 동의 여부 저장.
    await AuthService.instance.setMarketingConsent(_agreed['marketing'] ?? false);
    // 실서버 모드: 새 계정 기준으로 로컬 캐시 정리/동기화.
    await SessionData.onLogin();
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.onboarding1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardAwareForm(
        headerGap: AppGaps.v24,
        header: const BackHeader(
          title: '약관 동의',
          subtitle: '서비스 이용을 위해 약관에 동의해주세요',
        ),
        action: PrimaryButton(label: '동의하고 계속하기', onPressed: _onSubmit),
        children: [
          // 전체 동의
          _AgreeRow(
            checked: _allChecked,
            emphasize: true,
            onToggle: _toggleAll,
            child: const Text('전체 동의', style: AppTextStyles.cardTitle),
          ),
          AppGaps.v8,
          const Divider(color: AppColors.muted, height: 24),
          for (final term in kConsentTerms) ...[
            _AgreeRow(
              checked: _agreed[term.key]!,
              onToggle: () => _toggle(term.key),
              child: Row(
                children: [
                  ConsentTag(required: term.required),
                  const SizedBox(width: 8),
                  Expanded(
                    // 글자를 누르면 약관 본문 시트가 하단에서 올라온다.
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => showTermsSheet(context, term),
                      child: Text(
                        term.title,
                        style: AppTextStyles.body.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppGaps.v8,
          ],
        ],
      ),
    );
  }
}

/// 체크 동그라미 + 내용 한 줄. 동그라미/내용 모두 탭하면 토글된다.
class _AgreeRow extends StatelessWidget {
  const _AgreeRow({
    required this.checked,
    required this.child,
    required this.onToggle,
    this.emphasize = false,
  });

  final bool checked;
  final Widget child;
  final VoidCallback onToggle;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onToggle,
          child: Icon(
            checked ? Icons.check_circle : Icons.check_circle_outline,
            color: checked ? AppColors.primary : AppColors.textHint,
            size: emphasize ? 28 : 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }
}
