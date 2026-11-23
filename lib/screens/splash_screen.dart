import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';

/// 앱 진입 스플래시.
///
/// 선형 그라데이션(위 #FFD6DC → 아래 #FFE9D9) 배경 위에 캐릭터+로고(withyou+)를
/// 올린다. 잠시 보여준 뒤 로그인 상태에 따라 메인 셸 / 로그인으로 전환한다.
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
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.82,
            child: AspectRatio(
              aspectRatio: 356 / 343, // 캐릭터+로고 이미지 비율
              child: Stack(
                children: [
                  // 캐릭터 뒤 흰색 글로우(원) — 캐릭터 영역에 맞춰 살짝 위로.
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0, -0.22),
                      child: FractionallySizedBox(
                        widthFactor: 1.0,
                        child: Image.asset(
                          'assets/brand/splash_glow.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // 캐릭터 3종 + withyou+ 로고.
                  Image.asset(
                    'assets/brand/splash.png',
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
