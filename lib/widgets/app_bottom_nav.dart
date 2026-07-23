import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 하단 네비게이션 탭 정의. (홈 / 채팅 / 리포트 / 선물 / 마이)
enum AppTab {
  home('홈', Icons.home_outlined),
  chat('채팅', Icons.chat_bubble_outline),
  report('리포트', Icons.receipt_long_outlined),
  gift('선물', Icons.card_giftcard_outlined),
  my('마이', Icons.person_outline);

  const AppTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// 하단 네비게이션 바.
///
/// [currentIndex] 로 활성 탭을 지정하며, 활성/비활성 색이 유동적으로 바뀐다.
/// 탭을 누르면 [onTap] 이 호출된다(상위에서 인덱스 전환 → 활성 상태 갱신).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.track)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (var i = 0; i < AppTab.values.length; i++)
                Expanded(
                  child: _NavItem(
                    tab: AppTab.values[i],
                    active: i == currentIndex,
                    onTap: () => onTap?.call(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final AppTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.navInactive;
    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tab.icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            tab.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
