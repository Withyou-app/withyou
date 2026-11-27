import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

/// 초기 솔루션 화면(솔루션1) — 스플래시 다음 서비스 소개/시작 화면.
///
/// 스플래시와 동일한 선형 그라데이션(위 #FFD6DC → 아래 #FFE9D9) 위에
/// 부제 → withyou+ 로고 → 노란선, 하단에 "시작하기" 버튼. (디자인 에셋 사용)
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  void _start(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.invite);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    // Figma(iPhone 393pt 기준) 좌우 여백 20pt → 비율로 환산.
    final hPad = w * 20 / 393;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // 0%
              Color(0xFFFFEAED), // 40%
              Color(0xFFFFF0D9), // 65%
              Color(0xFFFFFFFF), // 100%
            ],
            stops: [0.0, 0.40, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.16),
                // 부제 (HumanBeomseok Neo, 24pt, #90796A)
                const Text(
                  '필요한 순간 언제든\n편하게 마음을 털어놓을 수 있는',
                  style: TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 24,
                    height: 1.35,
                    color: Color(0xFF90796A),
                    fontWeight: FontWeight.w700,
                    fontVariations: [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(height: 8),
                // withyou+ 로고 (Bagel Fat One) — withyou=메인컬러, +=포인트컬러.
                const Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: 'BagelFatOne',
                      fontSize: 52,
                      height: 1.0,
                    ),
                    children: [
                      TextSpan(
                        text: 'withyou',
                        style: TextStyle(color: Color(0xFFFF8E88)),
                      ),
                      TextSpan(
                        text: '+',
                        style: TextStyle(color: Color(0xFFFFCD8C)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 노란선 포인트
                Image.asset(
                  'assets/brand/sol1_line.png',
                  width: w * 40 / 393,
                  fit: BoxFit.fitWidth,
                ),
                const Spacer(),
                // 시작하기 버튼 (메인컬러 배경 + Neo SemiBold 18pt 흰색)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: Material(
                    color: const Color(0xFFFF8E88),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _start(context),
                      child: const Center(
                        child: Text(
                          '시작하기',
                          style: TextStyle(
                            fontFamily: 'HumanBeomseokNeo',
                            fontSize: 18,
                            color: Colors.white,
                            fontVariations: [FontVariation('wght', 600)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
