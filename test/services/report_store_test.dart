import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withyou/models/mind_report.dart';
import 'package:withyou/services/report_store.dart';

void main() {
  final store = ReportStore.instance;

  MindReport report(String createdAt,
          {String persona = '구나', String memo = ''}) =>
      MindReport(
        persona: persona,
        emotions: const ['평온'],
        summary: '요약',
        memo: memo,
        createdAt: createdAt,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.init();
    // 싱글턴이라 이전 테스트의 잔여 리포트를 비운다.
    while (store.reports.isNotEmpty) {
      await store.removeAt(0);
    }
  });

  test('add 하면 최신 리포트가 맨 앞에 온다', () async {
    await store.add(report('2026-08-01 10:00'));
    await store.add(report('2026-08-02 10:00'));
    expect(store.reports.length, 2);
    expect(store.reports.first.createdAt, '2026-08-02 10:00'); // 최신 먼저
  });

  test('updateMemo 는 생성시각+페르소나로 리포트를 찾아 메모를 갱신한다', () async {
    final r = report('2026-08-01 10:00', persona: '리미');
    await store.add(r);
    await store.updateMemo(r, '오늘은 좀 나았어');
    expect(store.reports.single.memo, '오늘은 좀 나았어');
  });

  test('removeAt 로 리포트를 삭제한다', () async {
    await store.add(report('2026-08-01 10:00'));
    await store.add(report('2026-08-02 10:00'));
    await store.removeAt(0); // 맨 앞(최신) 삭제
    expect(store.reports.length, 1);
    expect(store.reports.single.createdAt, '2026-08-01 10:00');
  });

  test('추가한 리포트는 영속화되어 재시작(init) 후에도 남는다', () async {
    await store.add(report('2026-08-01 10:00'));
    await store.init(); // 앱 재시작 시뮬레이션(prefs 값 유지)
    expect(store.reports.any((r) => r.createdAt == '2026-08-01 10:00'), isTrue);
  });

  test('reports 는 수정 불가(unmodifiable) 리스트다', () {
    expect(() => store.reports.add(report('2026-08-01 10:00')),
        throwsUnsupportedError);
  });
}
