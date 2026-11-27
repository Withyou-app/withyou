import 'package:flutter/material.dart';

/// v2 하단 탭바 (홈/채팅/리포트/선물/마이). 아이콘은 Material 대체.
class V2BottomNav extends StatelessWidget {
  const V2BottomNav({super.key, required this.current, this.onTap});

  final int current;
  final ValueChanged<int>? onTap;

  static const _main = Color(0xFFFF8E88);
  static const _inactive = Color(0xFFC7B9B0);

  static const _items = [
    (Icons.home_rounded, '홈'),
    (Icons.chat_bubble_outline, '채팅'),
    (Icons.article_outlined, '리포트'),
    (Icons.card_giftcard, '선물'),
    (Icons.person_outline, '마이'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < _items.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap == null ? null : () => onTap!(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _items[i].$1,
                    size: 28,
                    color: i == current ? _main : _inactive,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _items[i].$2,
                    style: TextStyle(
                      fontFamily: 'HumanBeomseokNeo',
                      fontSize: 14,
                      color: i == current ? _main : _inactive,
                      fontWeight: FontWeight.w700,
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
