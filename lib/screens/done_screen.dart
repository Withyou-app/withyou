import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/onboarding_kit.dart';

/// 가입 완료 화면(솔루션5 / iPhone 14 & 15 Pro - 79) — 온보딩 마지막 단계.
class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key});

  void _done(BuildContext context) {
    // 가입 완료 → 메인 앱(홈)으로. (v1 로그인 화면으로 가지 않는다)
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.shell, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 20 / 393;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF9),
      body: Stack(
        children: [
          // 중앙 캐릭터 일러스트 — 화면 수직 중앙(Figma image25 = 50%).
          Center(
            child: Image.asset(
              'assets/brand/sol5_characters.png',
              width: size.width * 356 / 393,
              fit: BoxFit.contain,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const OnboardingHeader(step: 4),
                  const SizedBox(height: 38),
              // 제목: "이제 withyou+를\n이용할 준비가 다 되었어요!"
              // (withyou+는 Bagel 52px, withyou=#FF8E88 / +=흰색)
              const Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 24,
                    height: 2.0,
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
                        fontSize: 52,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFF8E88),
                      ),
                    ),
                    TextSpan(
                      text: '+',
                      style: TextStyle(
                        fontFamily: 'BagelFatOne',
                        fontSize: 52,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFFCD8C),
                      ),
                    ),
                    TextSpan(text: '를\n이용할 준비가 다 되었어요!'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // 부제
              const Text(
                '지금바로 시작해볼까요?',
                style: TextStyle(
                  fontFamily: 'HumanBeomseokNeo',
                  fontSize: 18,
                  color: Color(0xFF90796A),
                  fontWeight: FontWeight.w700,
                  fontVariations: [FontVariation('wght', 700)],
                ),
              ),
                  const Spacer(),
                  PrimaryButton(
                    label: '완료',
                    enabled: true,
                    onTap: () => _done(context),
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
