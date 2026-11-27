import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/v2_bottom_nav.dart';

/// v2 홈 화면 (Figma: iPhone 14 & 15 Pro - 88 / 817:1511).
///
/// 탭 아이콘은 Material 아이콘으로 대체, 중앙 캐릭터는 임시 placeholder.
/// (실제 캐릭터 일러스트 에셋 확정 후 교체)
class HomeV2Screen extends StatelessWidget {
  const HomeV2Screen({super.key});

  static const _brown = Color(0xFF90796A);
  static const _main = Color(0xFFFF8E88);
  static const _point = Color(0xFFFFCD8C);
  static const _cardBg = Color(0xFFFFEBEB);
  static const _msgGray = Color(0xFFC4A4A4);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFDEDA), Color(0xFFFFF0EF), Colors.white],
            stops: [0.0, 0.192, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 배경 장식 블롭 (우 노랑 / 좌 핑크) — 캐릭터 뒤.
            Positioned(
              top: size.height * 0.11,
              right: -size.width * 0.06,
              width: size.width * 0.52,
              child: Image.asset('assets/brand/home_blob_right.png'),
            ),
            Positioned(
              top: size.height * 0.22,
              left: -size.width * 0.12,
              width: size.width * 0.56,
              child: Image.asset('assets/brand/home_blob_left.png'),
            ),
            SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // withyou+ 로고 (작게)
                      const Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: 'BagelFatOne',
                            fontSize: 24,
                          ),
                          children: [
                            TextSpan(text: 'withyou', style: TextStyle(color: _main)),
                            TextSpan(text: '+', style: TextStyle(color: _point)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // 제목
                      const Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: 'HumanBeomseokNeo',
                            fontSize: 24,
                            height: 1.3,
                            color: _brown,
                            fontWeight: FontWeight.w700,
                            fontVariations: [FontVariation('wght', 700)],
                          ),
                          children: [
                            TextSpan(text: '오늘의 고민', style: TextStyle(color: _main)),
                            TextSpan(text: '을\n망설이지 말고 말씀해주세요'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 중앙 캐릭터 (임시 placeholder)
                      Center(
                        child: Image.asset(
                          'assets/brand/char_rimi.png',
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 시작하기 버튼 (pill)
                      Center(
                        child: _StartButton(
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.personaSelect),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 최근 한 대화 헤더
                      Row(
                        children: [
                          const Text(
                            '최근 한 대화',
                            style: TextStyle(
                              fontFamily: 'HumanBeomseokNeo',
                              fontSize: 18,
                              color: _brown,
                              fontWeight: FontWeight.w700,
                              fontVariations: [FontVariation('wght', 700)],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: const [
                              Text(
                                '전체보기',
                                style: TextStyle(
                                  fontFamily: 'HumanBeomseokNeo',
                                  fontSize: 12,
                                  color: _main,
                                  fontWeight: FontWeight.w700,
                                  fontVariations: [FontVariation('wght', 700)],
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 17, color: _main),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _ConvCard(
                        name: '리미',
                        message: '와 드ㅇ디어 나도 폰트를 설치 했습니닫ㅇ..\n'
                            '이제 나는 여기에 내가 원하는대로 글을 씋겁니다.ㅋ',
                      ),
                      const SizedBox(height: 12),
                      _ConvCard(
                        name: '리미',
                        message: '앙 야르 재밋네우유유~~\n'
                            '아 진짜 오늘따라 기분이 좋습니다. 사실 아님',
                      ),
                      const SizedBox(height: 12),
                      _ConvCard(
                        name: '리미',
                        message: '걍 얼른 크리스마스가 도ㅇㅣ엇으면 좋겟습니다!!\n'
                            '곧 배구를 할 생각에 신이 나지만 이제 ㅇ호연쌤 수업이라 조금 별로.',
                      ),
                    ],
                  ),
                ),
              ),
              V2BottomNav(
                current: 0,
                onTap: (i) {
                  if (i == 1) {
                    Navigator.of(context).pushNamed(AppRoutes.chatListV2);
                  } else if (i == 2) {
                    Navigator.of(context).pushNamed(AppRoutes.reportListV2);
                  }
                },
              ),
            ],
          ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF8E88),
      borderRadius: BorderRadius.circular(54),
      child: InkWell(
        borderRadius: BorderRadius.circular(54),
        onTap: onTap,
        child: Container(
          width: 264,
          height: 56,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '시작하기',
                style: TextStyle(
                  fontFamily: 'HumanBeomseokNeo',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontVariations: [FontVariation('wght', 700)],
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward, size: 22, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConvCard extends StatelessWidget {
  const _ConvCard({required this.name, required this.message});
  final String name;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: HomeV2Screen._cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/brand/char_rimi.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 16,
                    height: 1.4,
                    color: HomeV2Screen._brown,
                    fontWeight: FontWeight.w700,
                    fontVariations: [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 10,
                    height: 1.4,
                    color: HomeV2Screen._msgGray,
                    fontWeight: FontWeight.w700,
                    fontVariations: [FontVariation('wght', 700)],
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
