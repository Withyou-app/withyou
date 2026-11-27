import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/mind_report.dart';
import '../../routes/app_routes.dart';
import '../../widgets/v2_bottom_nav.dart';

/// v2 리포트 상세 / 마음기록 화면 (Figma: iPhone 14 & 15 Pro - 95 / 876:887).
///
/// 뒤로 + 대화 제목 / 감정 도넛(행복 36%) + 요약 / 주요 감정 변화(감정 라인차트)
/// / 오늘 내 마음 기록(입력) / 저장 버튼 / 하단 탭.
///
/// 색은 figma 변수(primary read/main, Gray/100, primary noread) 기준.
class ReportDetailV2Screen extends StatelessWidget {
  const ReportDetailV2Screen({super.key});

  static const _bg = Color(0xFFFFF9F2); // primary/10
  static const _brown = Color(0xFF90796A); // primary/read
  static const _main = Color(0xFFFF8E88); // primary/main
  static const _track = Color(0xFFEDEBEB); // Gray/100
  static const _noread = Color(0xFFCBC0B4); // primary/noread

  // 감정 도넛: 대표 감정/비율.
  static const _topEmotion = '행복';
  static const _topPercent = 36;

  // 감정 변화 라인차트 (0=행복 top ~ 1=슬픔 bottom).
  static const _moodPoints = [0.44, 0.21, 0.56, 0.75, 0.43];

  @override
  Widget build(BuildContext context) {
    // 리포트 목록/대화 종료에서 넘어온 실제 리포트(없으면 샘플 표시).
    final report = ModalRoute.of(context)?.settings.arguments as MindReport?;
    final title = report?.title ?? '대화 제목';
    final emotion = (report != null && report.emotions.isNotEmpty)
        ? report.emotions.first
        : _topEmotion;
    final summary = (report != null && report.summary.isNotEmpty)
        ? report.summary
        : '오늘은 일상 속 소소한 즐거움과 만족감을 통해 행복을 느꼈으며, 긍정적이고 활기찬 하루를 보냈다.';
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 뒤로가기
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(Icons.chevron_left,
                          size: 32, color: _brown),
                    ),
                    const SizedBox(height: 16),
                    // 대화 제목
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'HumanBeomseokNeo',
                        fontSize: 24,
                        color: _brown,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // 도넛 + 요약
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 156,
                          height: 156,
                          child: _EmotionDonut(
                            percent: _topPercent,
                            label: emotion,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 36),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '요약',
                                  style: TextStyle(
                                    fontFamily: 'HumanBeomseokNeo',
                                    fontSize: 16,
                                    color: _brown,
                                    fontWeight: FontWeight.w700,
                                    fontVariations: [FontVariation('wght', 700)],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  summary,
                                  style: const TextStyle(
                                    fontFamily: 'HumanBeomseokNeo',
                                    fontSize: 12,
                                    height: 1.45,
                                    color: _noread,
                                    fontWeight: FontWeight.w600,
                                    fontVariations: [FontVariation('wght', 600)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // 주요 감정 변화
                    const Text(
                      '주요 감정 변화',
                      style: TextStyle(
                        fontFamily: 'HumanBeomseokNeo',
                        fontSize: 18,
                        color: _brown,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // y축 감정 얼굴
                          const SizedBox(
                            width: 24,
                            height: 112,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.sentiment_satisfied_alt,
                                    size: 24, color: _noread),
                                Icon(Icons.sentiment_neutral,
                                    size: 24, color: _noread),
                                Icon(Icons.sentiment_dissatisfied,
                                    size: 24, color: _noread),
                              ],
                            ),
                          ),
                          const SizedBox(width: 25),
                          // 라인차트
                          Expanded(
                            child: CustomPaint(
                              painter: _MoodLinePainter(_moodPoints),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // 오늘 내 마음 기록
                    const Text(
                      '오늘 내 마음을 기록해보세요',
                      style: TextStyle(
                        fontFamily: 'HumanBeomseokNeo',
                        fontSize: 18,
                        color: _brown,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 195,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _track),
                      ),
                      child: const Text(
                        '간단하게 작성해보세요 (선택)',
                        style: TextStyle(
                          fontFamily: 'HumanBeomseokNeo',
                          fontSize: 13,
                          color: _noread,
                          fontWeight: FontWeight.w600,
                          fontVariations: [FontVariation('wght', 600)],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Material(
                        color: _main,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {},
                          child: const Center(
                            child: Text(
                              '저장',
                              style: TextStyle(
                                fontFamily: 'HumanBeomseokNeo',
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontVariations: [FontVariation('wght', 700)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            V2BottomNav(
              current: 2,
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
                  case 4:
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.mypageV2);
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

/// 감정 도넛 차트: 대표 감정 비율을 main 색 호(arc)로, 나머지는 track.
class _EmotionDonut extends StatelessWidget {
  const _EmotionDonut({required this.percent, required this.label});
  final int percent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(156, 156),
          painter: _DonutPainter(percent / 100),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'HumanBeomseokNeo',
                fontSize: 20,
                color: ReportDetailV2Screen._brown,
                fontWeight: FontWeight.w700,
                fontVariations: [FontVariation('wght', 700)],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$percent%',
              style: const TextStyle(
                fontFamily: 'HumanBeomseokNeo',
                fontSize: 20,
                color: ReportDetailV2Screen._main,
                fontWeight: FontWeight.w700,
                fontVariations: [FontVariation('wght', 700)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.ratio);
  final double ratio;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 18.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = ReportDetailV2Screen._track;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = ReportDetailV2Screen._main;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * ratio,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.ratio != ratio;
}

/// 감정 변화 라인차트: 0(위=행복) ~ 1(아래=슬픔) 정규화 포인트를 부드러운 곡선으로.
class _MoodLinePainter extends CustomPainter {
  _MoodLinePainter(this.points);
  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final dx = size.width / (points.length - 1);
    final pts = <Offset>[
      for (var i = 0; i < points.length; i++)
        Offset(i * dx, points[i] * size.height),
    ];

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReportDetailV2Screen._main;

    // 부드러운 곡선 (간단한 중점 기반 쿼드라틱).
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final mid = Offset(
        (pts[i].dx + pts[i + 1].dx) / 2,
        (pts[i].dy + pts[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    canvas.drawPath(path, line);

    // 점.
    final dotFill = Paint()..color = ReportDetailV2Screen._main;
    final dotRing = Paint()..color = Colors.white;
    for (final p in pts) {
      canvas.drawCircle(p, 6, dotFill);
      canvas.drawCircle(p, 2.5, dotRing);
    }
  }

  @override
  bool shouldRepaint(_MoodLinePainter old) => old.points != points;
}
