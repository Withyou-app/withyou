import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

/// 앱 전역 테마.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.cocochoitoon,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
    );

    return base.copyWith(
      // 모든 텍스트를 코코초이툰으로 강제 (textTheme/primaryTextTheme 전체).
      textTheme: base.textTheme.apply(
        fontFamily: AppFonts.cocochoitoon,
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      primaryTextTheme: base.primaryTextTheme.apply(
        fontFamily: AppFonts.cocochoitoon,
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      // 스낵바 텍스트도 앱 폰트로.
      snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(
          fontFamily: AppFonts.cocochoitoon,
          color: AppColors.white,
        ),
      ),
      // 다이얼로그 제목/본문도 앱 폰트로.
      dialogTheme: const DialogThemeData(
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.cocochoitoon,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: AppFonts.cocochoitoon,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        hintStyle: const TextStyle(
          fontFamily: AppFonts.cocochoitoon,
          color: AppColors.textHint,
          fontSize: 15,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(
            fontFamily: AppFonts.cocochoitoon,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
