import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/v2_bottom_nav.dart';

/// v2 마이페이지 화면 (Figma: iPhone 14 & 15 Pro - 91 / 817:1845).
///
/// 프로필(사진·ID·이메일·편집) / 저장 메모리(기억 개수 + 세션 목록) /
/// 동의 내역 / 로그아웃 / 하단 탭(마이).
///
/// 프로필 사진은 미제공이라 원형 placeholder 로 비워둔다. (asset 채우면 교체)
class MypageV2Screen extends StatelessWidget {
  const MypageV2Screen({super.key});

  static const _bg = Color(0xFFFFF9F2);
  static const _brown = Color(0xFF90796A);
  static const _main = Color(0xFFFF8E88);
  static const _gray = Color(0xFFC4A4A4);
  static const _hint = Color(0xFFD4BBA9);

  // 임시 표시값.
  static const _email = 'dlapdlf@gamil.com';
  static const _memoryCount = 2;
  static const _sessions = ['Session #1 (구나)', 'Session #2 (라미)'];
  static const _consents = ['개인정보 수집 이용', '뭐 또다른 어떤 내역'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    const Text(
                      '마이페이지',
                      style: TextStyle(
                        fontFamily: 'HumanBeomseokNeo',
                        fontSize: 28,
                        color: _brown,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 프로필
                    Row(
                      children: [
                        _Avatar(),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  'ID',
                                  style: TextStyle(
                                    fontFamily: 'HumanBeomseokNeo',
                                    fontSize: 18,
                                    color: _brown,
                                    fontWeight: FontWeight.w700,
                                    fontVariations: [FontVariation('wght', 700)],
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.edit, size: 15, color: _gray),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              _email,
                              style: TextStyle(
                                fontFamily: 'HumanBeomseokNeo',
                                fontSize: 15,
                                color: _gray,
                                fontWeight: FontWeight.w600,
                                fontVariations: [FontVariation('wght', 600)],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 저장 메모리
                    const Text(
                      '저장 메모리',
                      style: TextStyle(
                        fontFamily: 'HumanBeomseokNeo',
                        fontSize: 16,
                        color: _brown,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '$_memoryCount개의 기억을 저장하고 있습니다',
                      style: TextStyle(
                        fontFamily: 'HumanBeomseokNeo',
                        fontSize: 13,
                        color: _gray,
                        fontWeight: FontWeight.w600,
                        fontVariations: [FontVariation('wght', 600)],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final s in _sessions) ...[
                      _SessionRow(label: s),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 6),
                    // 동의 내역
                    const Text(
                      '동의 내역',
                      style: TextStyle(
                        fontFamily: 'HumanBeomseokNeo',
                        fontSize: 16,
                        color: _brown,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final c in _consents) ...[
                      _ConsentRow(label: c),
                      const SizedBox(height: 14),
                    ],
                    const SizedBox(height: 10),
                    // 로그아웃
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(
                          fontFamily: 'HumanBeomseokNeo',
                          fontSize: 15,
                          color: _hint,
                          fontWeight: FontWeight.w700,
                          fontVariations: [FontVariation('wght', 700)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            V2BottomNav(
              current: 4,
              onTap: (i) {
                switch (i) {
                  case 0:
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.homeV2, (r) => false);
                    break;
                  case 1:
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.chatListV2);
                    break;
                  case 2:
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.reportListV2);
                    break;
                  case 3:
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.giftV2);
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 프로필 사진 placeholder (98×98 원형). asset 채우면 교체.
class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 98,
      height: 98,
      decoration: const BoxDecoration(
        color: Color(0xFFF7EFE7),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: const Icon(Icons.person, size: 46, color: Color(0xFFD4BBA9)),
    );
  }
}

/// 저장 메모리 세션 행.
class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'HumanBeomseokNeo',
              fontSize: 15,
              color: MypageV2Screen._brown,
              fontWeight: FontWeight.w600,
              fontVariations: [FontVariation('wght', 600)],
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right,
              size: 20, color: MypageV2Screen._hint),
        ],
      ),
    );
  }
}

/// 동의 내역 행: 항목명 + 동의함.
class _ConsentRow extends StatelessWidget {
  const _ConsentRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'HumanBeomseokNeo',
            fontSize: 14,
            color: MypageV2Screen._brown,
            fontWeight: FontWeight.w600,
            fontVariations: [FontVariation('wght', 600)],
          ),
        ),
        const Text(
          '동의함',
          style: TextStyle(
            fontFamily: 'HumanBeomseokNeo',
            fontSize: 14,
            color: MypageV2Screen._main,
            fontWeight: FontWeight.w700,
            fontVariations: [FontVariation('wght', 700)],
          ),
        ),
      ],
    );
  }
}
