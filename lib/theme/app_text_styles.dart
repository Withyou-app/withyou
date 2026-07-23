import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

/// 화면 전반에서 재사용하는 텍스트 스타일.
/// 앱 전체를 코코초이툰으로 강제하기 위해 각 스타일에 폰트를 명시한다.
class AppTextStyles {
  AppTextStyles._();

  static const String _font = AppFonts.cocochoitoon;

  /// 화면 대제목 (예: "반가워요!", "마음 리포트")
  static const TextStyle title = TextStyle(
    fontFamily: _font,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// 대제목 아래 보조 설명
  static const TextStyle subtitle = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.35,
  );

  /// 입력 필드 라벨, 섹션 라벨
  static const TextStyle label = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 카드 제목
  static const TextStyle cardTitle = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 카드 부제/본문 (뮤트)
  static const TextStyle cardBody = TextStyle(
    fontFamily: _font,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  /// 본문 기본
  static const TextStyle body = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// 타임스탬프 등 미세 텍스트
  static const TextStyle caption = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );
}
