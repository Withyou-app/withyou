import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 페르소나 이름 → 프로필 이미지 에셋. 목록에 없으면 빈 원형으로.
const Map<String, String> _personaAsset = {
  '구나': 'assets/personas/guna.png',
  '리미': 'assets/personas/rimi.png',
  '고미': 'assets/personas/gomi.png',
};

/// 원형 아바타. [name] 이 페르소나면 해당 프로필 이미지를 원형으로 표시하고,
/// 아니면 단색 원형(플레이스홀더)을 그린다.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, this.size = 52, this.color, this.name});

  final double size;
  final Color? color;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final asset = name == null ? null : _personaAsset[name];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: asset == null
          ? null
          : Image.asset(asset, fit: BoxFit.cover, width: size, height: size),
    );
  }
}
