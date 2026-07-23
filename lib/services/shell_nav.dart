import 'package:flutter/foundation.dart';

/// 하단 네비 셸의 탭 전환을 앱 어디서든 요청할 수 있게 하는 작은 컨트롤러.
/// (예: 대화창의 하단 네비를 눌러 다른 탭으로 이동)
class ShellNav {
  ShellNav._();
  static final ShellNav instance = ShellNav._();

  static const int homeTab = 0;
  static const int chatTab = 1;
  static const int reportTab = 2;
  static const int giftTab = 3;
  static const int myTab = 4;

  /// MainShell 이 이 값을 구독해 IndexedStack 인덱스를 바꾼다.
  final ValueNotifier<int> tabIndex = ValueNotifier<int>(homeTab);

  void goTo(int index) => tabIndex.value = index;
}
