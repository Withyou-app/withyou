import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/onboarding_kit.dart';

/// 가입 완료 화면(솔루션5) — 온보딩 마지막 단계.
///
/// 중앙 캐릭터 일러스트 자리는 비워 둔다(에셋 확정 후 교체).
class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key});

  void _start(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 20 / 393;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF9),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const OnboardingHeader(step: 4),
              const SizedBox(height: 38),
              // 제목: "이제 withyou+를\n이용할 준비가 다 되었어요!"
              const Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 24,
                    height: 1.4,
                    color: Color(0xFF90796A),
                    fontWeight: FontWeight.w700,
                    fontVariations: [FontVariation('wght', 700)],
                  ),
                  children: [
                    TextSpan(text: '이제 '),
                    TextSpan(
                      text: 'withyou',
                      style: TextStyle(
                        fontFamily: 'BagelFatOne',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFF8E88),
                      ),
                    ),
                    TextSpan(
                      text: '+',
                      style: TextStyle(
                        fontFamily: 'BagelFatOne',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFFCD8C),
                      ),
                    ),
                    TextSpan(text: '를\n이용할 준비가 다 되었어요!'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // 부제
              const Text(
                '지금바로 시작해볼까요?',
                style: TextStyle(
                  fontFamily: 'HumanBeomseokNeo',
                  fontSize: 15,
                  color: Color(0xFFB9AA9F),
                  fontWeight: FontWeight.w600,
                  fontVariations: [FontVariation('wght', 600)],
                ),
              ),
              // 중앙 캐릭터 일러스트 자리 — 비워 둠(에셋 확정 후 삽입).
              const Spacer(),
              PrimaryButton(
                label: '시작하기',
                enabled: true,
                onTap: () => _start(context),
              ),
              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
