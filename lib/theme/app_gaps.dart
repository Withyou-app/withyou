import 'package:flutter/widgets.dart';

/// 간격/여백 상수. 화면 전반의 리듬을 일관되게 유지한다.
class AppGaps {
  AppGaps._();

  /// 화면 좌우 기본 패딩
  static const double screenH = 24;

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 36;

  // 자주 쓰는 세로 간격 위젯
  static const SizedBox v8 = SizedBox(height: 8);
  static const SizedBox v12 = SizedBox(height: 12);
  static const SizedBox v16 = SizedBox(height: 16);
  static const SizedBox v20 = SizedBox(height: 20);
  static const SizedBox v24 = SizedBox(height: 24);
  static const SizedBox v36 = SizedBox(height: 36);
}

/// 공통 라운드 반경.
class AppRadii {
  AppRadii._();

  static const double field = 14; // 입력/버튼
  static const double card = 16; // 카드
  static const double modal = 20; // 모달
  static const double pill = 999; // 알약형
}
