import 'package:flutter_test/flutter_test.dart';
import 'package:withyou/services/safety_service.dart';

void main() {
  group('SafetyService.classify', () {
    test('명백한 위험 표현은 high', () {
      expect(SafetyService.classify('나 진짜 죽고 싶어'), SafetyLevel.high);
      expect(SafetyService.classify('자해하고 싶다'), SafetyLevel.high);
      expect(SafetyService.classify('다 끝내고 싶어'), SafetyLevel.high);
    });

    test('심한 무기력/절망은 medium', () {
      expect(SafetyService.classify('이제 살기 싫다'), SafetyLevel.medium);
      expect(SafetyService.classify('희망이 없는 것 같아'), SafetyLevel.medium);
    });

    test('일반 대화는 low', () {
      expect(SafetyService.classify('오늘 점심 맛있게 먹었어'), SafetyLevel.low);
      expect(SafetyService.classify('시험 때문에 좀 피곤해'), SafetyLevel.low);
    });

    test('띄어쓰기 변형도 감지', () {
      expect(SafetyService.classify('죽 고 싶 어'), SafetyLevel.high);
    });
  });
}
