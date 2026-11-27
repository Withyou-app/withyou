import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/v2_bottom_nav.dart';

/// 채팅(대화) 목록 화면 (Figma: iPhone 14 & 15 Pro - 89 / 817:1638).
///
/// 제목 "채팅" + 필터(전체/구나/고미/리미) + 대화 카드 목록 + 하단 탭(채팅).
/// 카드색은 design_context 미확보로 홈 토큰(#ffebeb) 추정 적용.
class ChatListV2Screen extends StatefulWidget {
  const ChatListV2Screen({super.key});

  @override
  State<ChatListV2Screen> createState() => _ChatListV2ScreenState();
}

class _ChatListV2ScreenState extends State<ChatListV2Screen> {
  static const _brown = Color(0xFF90796A);
  static const _main = Color(0xFFFF8E88);
  static const _cardBg = Color(0xFFFFEBEB);
  static const _msgGray = Color(0xFFC4A4A4);

  static const _filters = ['전체', '구나', '고미', '리미'];
  int _filter = 0;

  // 임시 목록 데이터. (아바타 에셋은 char_*.png 재사용)
  static const _items = [
    ('리미', 'assets/brand/char_rimi.png', '대화 요약 대화 요약'),
    ('고미', 'assets/brand/char_gomi.png', '대화 요약 대화 요약'),
    ('구나', 'assets/brand/char_guna.png', '대화 요약 대화 요약'),
    ('리미', 'assets/brand/char_rimi.png',
        '걍 얼른 크리스마스가 도ㅇㅣ엇으면 좋겟습니다!! 곧 배구를 할 생각에 신이 나지만 이제 ㅇ호연쌤 수업이라 조금 별로.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                '채팅',
                style: TextStyle(
                  fontFamily: 'HumanBeomseokNeo',
                  fontSize: 28,
                  color: _brown,
                  fontWeight: FontWeight.w700,
                  fontVariations: [FontVariation('wght', 700)],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 필터 칩
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final on = i == _filter;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: on ? _main : Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: on ? _main : const Color(0xFFEADFD3)),
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          fontFamily: 'HumanBeomseokNeo',
                          fontSize: 14,
                          color: on ? Colors.white : _brown,
                          fontWeight: FontWeight.w700,
                          fontVariations: const [FontVariation('wght', 700)],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // 대화 카드 목록
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final (name, asset, summary) = _items[i];
                  return _ConvCard(name: name, asset: asset, summary: summary);
                },
              ),
            ),
            V2BottomNav(
              current: 1,
              onTap: (i) {
                if (i == 0) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.homeV2, (r) => false);
                } else if (i == 2) {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.reportListV2);
                } else if (i == 3) {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.giftV2);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConvCard extends StatelessWidget {
  const _ConvCard(
      {required this.name, required this.asset, required this.summary});
  final String name;
  final String asset;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: _ChatListV2ScreenState._cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(asset, fit: BoxFit.cover),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 16,
                    color: _ChatListV2ScreenState._brown,
                    fontWeight: FontWeight.w700,
                    fontVariations: [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 10,
                    height: 1.4,
                    color: _ChatListV2ScreenState._msgGray,
                    fontWeight: FontWeight.w700,
                    fontVariations: [FontVariation('wght', 700)],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.star_rounded, size: 19, color: Color(0xFFFFCD8C)),
        ],
      ),
    );
  }
}
