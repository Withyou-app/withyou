import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';

/// 앱 진입 스플래시 (Figma: iPhone 14 & 15 Pro - 70 / 535:2971).
///
/// 그라데이션(위 #FFD6DC → 아래 #FFE9D9) 위, 흰색 글로우 뒤에
/// 3캐릭터 일러스트 + withyou+ 로고(Bagel 40px). 잠시 뒤 분기.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final next = AuthService.instance.isLoggedIn
        ? AppRoutes.shell
        : AppRoutes.intro;
    Navigator.of(context).pushReplacementNamed(next);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD6DC), Color(0xFFFFE9D9)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 흰색 글로우
            Image.asset(
              'assets/brand/splash_glow.png',
              width: w * 0.62,
              fit: BoxFit.contain,
            ),
            // 3캐릭터 일러스트 + withyou+ 로고
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/brand/sol5_characters.png',
                  width: w * 356 / 393,
                  fit: BoxFit.contain,
                ),
                const Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: 'BagelFatOne',
                      fontSize: 40,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
