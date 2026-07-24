import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/auth/signup_email_screen.dart';
import 'screens/auth/signup_password_screen.dart';
import 'screens/auth/signup_terms_screen.dart';
import 'screens/onboarding/onboarding_step1_screen.dart';
import 'screens/onboarding/onboarding_step2_screen.dart';
import 'screens/persona/persona_select_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/report/mind_report_screen.dart';
import 'screens/gift/gift_detail_screen.dart';
import 'screens/gift/received_gifts_screen.dart';
import 'screens/support/contact_screen.dart';
import 'screens/mypage/profile_edit_screen.dart';

/// 앱 루트 — 테마와 라우트 테이블을 구성한다.
class WithYouApp extends StatelessWidget {
  const WithYouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'withyou+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // 스크롤 시 늘어지는(스트레치) 오버스크롤 효과 제거.
      scrollBehavior: const NoStretchScrollBehavior(),
      // 입력 필드 밖(빈 공간)을 탭하면 키보드를 자동으로 내린다.
      builder: (context, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child,
      ),
      // 이미 로그인된 세션이 있으면 바로 메인 셸로.
      initialRoute:
          AuthService.instance.isLoggedIn ? AppRoutes.shell : AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signupEmail: (_) => const SignupEmailScreen(),
        AppRoutes.signupPassword: (_) => const SignupPasswordScreen(),
        AppRoutes.signupTerms: (_) => const SignupTermsScreen(),
        AppRoutes.onboarding1: (_) => const OnboardingStep1Screen(),
        AppRoutes.onboarding2: (_) => const OnboardingStep2Screen(),
        AppRoutes.shell: (_) => const MainShell(),
        // 채팅 탭(최근 대화)으로 바로 진입
        AppRoutes.conversations: (_) => const MainShell(initialIndex: 1),
        AppRoutes.persona: (_) => const PersonaSelectScreen(),
        AppRoutes.chat: (_) => const ChatScreen(),
        AppRoutes.reportDetail: (_) => const MindReportScreen(),
        AppRoutes.giftDetail: (_) => const GiftDetailScreen(),
        AppRoutes.receivedGifts: (_) => const ReceivedGiftsScreen(),
        AppRoutes.contact: (_) => const ContactScreen(),
        AppRoutes.profileEdit: (_) => const ProfileEditScreen(),
      },
    );
  }
}

/// 스크롤 끝에서 콘텐츠가 늘어나는 스트레치/글로우 오버스크롤을 제거한다.
/// (마우스로 위·아래 스크롤 시 화면이 길게 늘어지는 현상 방지)
class NoStretchScrollBehavior extends MaterialScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    // 인디케이터를 그리지 않고 자식을 그대로 반환.
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
