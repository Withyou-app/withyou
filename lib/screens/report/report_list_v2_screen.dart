import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/v2_bottom_nav.dart';

/// 리포트 목록 화면 (Figma: iPhone 14 & 15 Pro - 94 / 873:1581).
///
/// 제목 "리포트" + 리포트 카드(대화 제목·요약·날짜) + 하단 탭(리포트).
/// 카드색은 design_context 미확보로 토큰 추정 적용.
class ReportListV2Screen extends StatelessWidget {
  const ReportListV2Screen({super.key});

  static const _brown = Color(0xFF90796A);
  static const _gray = Color(0xFFC4A4A4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text(
                '리포트',
                style: TextStyle(
                  fontFamily: 'HumanBeomseokNeo',
                  fontSize: 28,
                  color: _brown,
                  fontWeight: FontWeight.w700,
                  fontVariations: [FontVariation('wght', 700)],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const _ReportCard(
                  title: '대화 제목',
                  summary: '대화 내용 요약',
                  date: '2026.08.08',
                ),
              ),
            ),
            V2BottomNav(
              current: 2,
              onTap: (i) {
                if (i == 0) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.homeV2, (r) => false);
                } else if (i == 1) {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.chatListV2);
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

class _ReportCard extends StatelessWidget {
  const _ReportCard(
      {required this.title, required this.summary, required this.date});
  final String title;
  final String summary;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 16,
                    color: ReportListV2Screen._brown,
                    fontWeight: FontWeight.w700,
                    fontVariations: [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 14,
                    color: ReportListV2Screen._gray,
                    fontWeight: FontWeight.w600,
                    fontVariations: [FontVariation('wght', 600)],
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontFamily: 'HumanBeomseokNeo',
              fontSize: 12,
              color: ReportListV2Screen._gray,
              fontWeight: FontWeight.w600,
              fontVariations: [FontVariation('wght', 600)],
            ),
          ),
        ],
      ),
    );
  }
}
