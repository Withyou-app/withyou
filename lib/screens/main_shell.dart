import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/widgets.dart';
import '../services/shell_nav.dart';
import 'chat/chat_screen.dart';
import 'home/home_screen.dart';
import 'conversations/recent_conversations_screen.dart';
import 'report/report_list_screen.dart';
import 'gift/gift_main_screen.dart';
import 'mypage/my_page_screen.dart';

/// 하단 네비게이션(홈/채팅/리포트/선물/마이)을 소유하는 메인 셸.
///
/// 활성 탭은 [ShellNav.tabIndex] 를 단일 소스로 사용한다. 대화창 등 셸 밖
/// 화면에서도 이 값을 바꿔 특정 탭으로 전환할 수 있다.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _tabs = <Widget>[
    HomeScreen(),
    RecentConversationsScreen(),
    ReportListScreen(),
    GiftMainScreen(),
    MyPageScreen(),
  ];

  bool _openingChat = false;

  @override
  void initState() {
    super.initState();
    ShellNav.instance.tabIndex.value = widget.initialIndex;
    ShellNav.instance.tabIndex.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    ShellNav.instance.tabIndex.removeListener(_onTabChanged);
    super.dispose();
  }

  /// 채팅 탭으로 돌아왔을 때 진행 중인 대화가 있으면 목록 대신 대화창을 다시 연다.
  void _onTabChanged() {
    final active = ShellNav.instance.activeChatPersona;
    if (ShellNav.instance.tabIndex.value != ShellNav.chatTab ||
        active == null ||
        _openingChat) {
      return;
    }
    _openingChat = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _openingChat = false;
        return;
      }
      Navigator.of(context)
          .pushNamed(AppRoutes.chat,
              arguments: ChatArgs(active, resume: true))
          .then((_) => _openingChat = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ShellNav.instance.tabIndex,
      builder: (context, index, _) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: index, children: _tabs),
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: index,
            onTap: (i) => ShellNav.instance.goTo(i),
          ),
        );
      },
    );
  }
}
