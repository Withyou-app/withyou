import 'package:flutter/material.dart';
import '../models/social_provider.dart';

/// 원형 소셜 로그인 버튼 (카카오/구글/애플).
/// 실제 로고 에셋(assets/social/*.png, plus/간편 로그인.png에서 분할)을 사용한다.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({super.key, required this.provider, this.onTap});

  final SocialProvider provider;
  final VoidCallback? onTap;

  static const double _size = 58;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${provider.label} 로그인',
      child: InkResponse(
        onTap: onTap,
        radius: _size / 2 + 6,
        child: Image.asset(
          provider.asset,
          width: _size,
          height: _size,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
