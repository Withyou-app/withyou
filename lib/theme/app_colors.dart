import 'package:flutter/material.dart';

/// withyou+ 컬러 팔레트.
///
/// 앱 전체 색은 이 파일 한 곳에서만 정의한다. (디자인 지정 값)
/// - 배경        : #FFF9F2
/// - 입력필드/카드 : #F4E9DC
/// - 예시(힌트)글자 : #CBC0B4
/// - 포인트(버튼)  : #FF8E88
class AppColors {
  AppColors._();

  // ── 브랜드 포인트(다홍) ────────────────────────────────
  static const Color primary = Color(0xFFFF8E88); // 버튼/강조
  static const Color primaryPressed = Color(0xFFF07D76);

  // ── 배경 / 표면 ───────────────────────────────────────
  static const Color background = Color(0xFFFFF9F2); // 화면 배경
  static const Color inputFill = Color(0xFFF4E9DC); // 입력 필드
  static const Color card = Color(0xFFF4E9DC); // 카드/리스트 아이템

  /// 뮤트(보조) 버튼/토글 배경 (베이지) — 더 대화하기, 취소, 프로필 수정 등
  static const Color muted = Color(0xFFE7DBCF);

  // ── 채팅 말풍선 ──────────────────────────────────────
  static const Color bubbleReceived = Color(0xFFEFE3DB); // 상대 (좌측)
  static const Color bubbleSent = Color(0xFFFFB0AB); // 나 (우측, 코랄)

  // ── 뱃지 / 감정칩 ────────────────────────────────────
  static const Color badgePinkBg = Color(0xFFF9D2CD);
  static const Color badgePinkText = Color(0xFFE8776E);
  static const Color emotionOrangeBg = Color(0xFFFBE3C6);
  static const Color emotionOrangeText = Color(0xFFC9974F);
  static const Color emotionGreenBg = Color(0xFFD8EBD3);
  static const Color emotionGreenText = Color(0xFF6FA36A);
  static const Color emotionBlueBg = Color(0xFFD3E4F0);
  static const Color emotionBlueText = Color(0xFF5B87A8);
  static const Color emotionPurpleBg = Color(0xFFE5DAF2);
  static const Color emotionPurpleText = Color(0xFF8A73B0);

  // ── 라인 / 트랙 ──────────────────────────────────────
  static const Color track = Color(0xFFECE0D7); // 진행바 트랙 / 구분선

  // ── 텍스트 ───────────────────────────────────────────
  static const Color textPrimary = Color(0xFF321D10); // 기본 글자
  static const Color textSecondary = Color(0xFF90796A); // 부제목/보조
  static const Color textHint = Color(0xFFCBC0B4); // 입력 예시(힌트) 글자

  /// 하단 네비게이션 비활성 아이콘/라벨
  static const Color navInactive = Color(0xFFB8ACA3);

  /// 모달 뒤 스크림(반투명 오버레이)
  static const Color scrim = Color(0x59000000); // black 35%

  static const Color white = Color(0xFFFFFFFF);
}
