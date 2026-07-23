import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:withyou/theme/app_theme.dart';
import 'package:withyou/widgets/app_bottom_nav.dart';
import 'package:withyou/widgets/social_login_button.dart';
import 'package:withyou/screens/main_shell.dart';
import 'package:withyou/screens/login_screen.dart';
import 'package:withyou/screens/auth/signup_email_screen.dart';
import 'package:withyou/screens/auth/signup_password_screen.dart';
import 'package:withyou/screens/onboarding/onboarding_step1_screen.dart';
import 'package:withyou/screens/onboarding/onboarding_step2_screen.dart';
import 'package:withyou/screens/onboarding/onboarding_step3_screen.dart';
import 'package:withyou/screens/persona/persona_select_screen.dart';
import 'package:withyou/screens/chat/chat_screen.dart';
import 'package:withyou/screens/conversations/recent_conversations_screen.dart';
import 'package:withyou/screens/report/report_list_screen.dart';
import 'package:withyou/screens/report/mind_report_screen.dart';
import 'package:withyou/screens/gift/gift_main_screen.dart';
import 'package:withyou/screens/mypage/my_page_screen.dart';
import 'package:withyou/screens/support/contact_screen.dart';
import 'package:withyou/services/conversation_store.dart';
import 'package:withyou/models/chat_message.dart';

/// 각 화면이 렌더 예외 없이 그려지는지 확인하는 스모크 테스트.
/// (퍼블리싱 단계에서 레이아웃 오버플로/언바운드 리스트 등 런타임 오류를 잡는다.)
Future<void> _pump(WidgetTester tester, Widget screen) async {
  // 실기기 세로 화면 크기로 고정해 오버플로를 현실적으로 검증.
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
}

void main() {
  final screens = <String, Widget>{
    'login': const LoginScreen(),
    'signupEmail': const SignupEmailScreen(),
    'signupPassword': const SignupPasswordScreen(),
    'onboarding1': const OnboardingStep1Screen(),
    'onboarding2': const OnboardingStep2Screen(),
    'onboarding3': const OnboardingStep3Screen(),
    'shell': const MainShell(),
    'persona': const PersonaSelectScreen(),
    'chat': const ChatScreen(),
    'conversations': const RecentConversationsScreen(),
    'reportList': const ReportListScreen(),
    'mindReport': const MindReportScreen(),
    'giftMain': const GiftMainScreen(),
    'giftMainDone': const GiftMainScreen(completed: true),
    'mypage': const MyPageScreen(),
    'contact': const ContactScreen(),
  };

  screens.forEach((name, widget) {
    testWidgets('$name 화면이 예외 없이 렌더된다', (tester) async {
      await _pump(tester, widget);
    });
  });

  testWidgets('로그인 화면에 소셜 버튼(카카오/구글/애플) 3개가 있다', (tester) async {
    await _pump(tester, const LoginScreen());
    expect(find.byType(SocialLoginButton), findsNWidgets(3));
  });

  testWidgets('선물 메인 두 상태의 문구가 시안과 일치한다', (tester) async {
    await _pump(tester, const GiftMainScreen());
    expect(find.text('선물까지 이정도 남았어요!'), findsOneWidget);
    await _pump(tester, const GiftMainScreen(completed: true));
    expect(find.text('선물을 받으러 가실까요?'), findsOneWidget);
  });

  testWidgets('대화창은 전달된 상대 이름을 반영한다 (미리 → 미리 대화창)', (tester) async {
    await _pump(tester, const ChatScreen(partnerName: '미리'));
    // 상단 바 이름 + AI 첫 인사말에 '미리'가 반영된다.
    expect(find.text('미리'), findsWidgets);
    expect(find.text('안녕! 나는 미리야. 오늘 하루는 어땠어?'), findsOneWidget);
    expect(find.textContaining('구나'), findsNothing);
  });

  testWidgets('최근 대화: 삭제 버튼 → 체크 선택 → 선택 삭제', (tester) async {
    // 진행 중 대화 시드(저장소는 테스트에서 메모리에만 유지).
    for (final p in ['구나', '리미', '고미']) {
      await ConversationStore.instance.setMessages(p, const [
        ChatMessage.partner('안녕', time: '오전 9:00'),
        ChatMessage.me('응 안녕', time: '오전 9:01'),
      ]);
    }
    addTearDown(() async {
      for (final p in ['구나', '리미', '고미']) {
        await ConversationStore.instance.clear(p);
      }
    });

    await _pump(tester, const RecentConversationsScreen());
    expect(find.text('구나와의 대화'), findsOneWidget);
    expect(find.text('리미와의 대화'), findsOneWidget);

    // 휴지통 → 선택 모드 진입
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    // 구나 대화 체크
    await tester.tap(find.text('구나와의 대화'));
    await tester.pump();
    expect(find.text('삭제 1'), findsOneWidget);

    // 삭제 → 확인 다이얼로그의 '삭제'
    await tester.tap(find.text('삭제 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, '삭제'));
    await tester.pumpAndSettle();

    // 구나만 삭제되고 나머지는 남는다
    expect(find.text('구나와의 대화'), findsNothing);
    expect(find.text('리미와의 대화'), findsOneWidget);
    expect(find.text('고미와의 대화'), findsOneWidget);
  });

  testWidgets('하단 네비 탭을 누르면 활성 상태가 유동적으로 바뀐다', (tester) async {
    await _pump(tester, const MainShell());

    Color labelColor(String label) {
      // 하단 네비 안의 라벨만 대상으로 한다(화면 제목 '리포트' 등과 충돌 방지).
      final text = tester.widget<Text>(find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text(label),
      ));
      return text.style!.color!;
    }

    // 초기: 홈 활성(코랄), 리포트 비활성(회색)
    final activeHome = labelColor('홈');
    final inactiveReport = labelColor('리포트');
    expect(activeHome, isNot(inactiveReport));

    // 리포트 탭 탭 → 리포트가 활성색으로, 홈은 비활성색으로 전환
    await tester.tap(find.descendant(
      of: find.byType(AppBottomNav),
      matching: find.text('리포트'),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(labelColor('리포트'), activeHome); // 이제 리포트가 활성(코랄)
    expect(labelColor('홈'), inactiveReport); // 홈은 비활성(회색)
  });
}
