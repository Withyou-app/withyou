import 'package:flutter_test/flutter_test.dart';
import 'package:withyou/models/mind_report.dart';

void main() {
  MindReport sample() => const MindReport(
        persona: '구나',
        emotions: ['평온', '뿌듯함'],
        summary: '오늘은 발표를 잘 마쳤어요.',
        needNow: '휴식',
        smallAction: '물 한 잔',
        mission: '산책',
        memo: '수고했어',
        createdAt: '2026-08-01 13:05',
      );

  test('toJson→fromJson 왕복이 값을 보존한다', () {
    final r = sample();
    final back = MindReport.fromJson(r.toJson());
    expect(back.persona, r.persona);
    expect(back.emotions, r.emotions);
    expect(back.summary, r.summary);
    expect(back.needNow, r.needNow);
    expect(back.smallAction, r.smallAction);
    expect(back.mission, r.mission);
    expect(back.memo, r.memo);
    expect(back.createdAt, r.createdAt);
  });

  test('fromJson 은 누락 필드를 기본값으로 채운다', () {
    final r = MindReport.fromJson({'persona': '리미'});
    expect(r.persona, '리미');
    expect(r.emotions, isEmpty);
    expect(r.summary, '');
    expect(r.caution, MindReport.kDefaultCaution); // 주의문구 기본값
  });

  test('copyWith 는 메모만 바꾸고 나머지는 유지한다', () {
    final r = sample().copyWith(memo: '바뀐 메모');
    expect(r.memo, '바뀐 메모');
    expect(r.summary, sample().summary);
    expect(r.emotions, sample().emotions);
  });

  test('title 은 페르소나 기반이다', () {
    expect(sample().title, '구나와의 대화');
  });
}
