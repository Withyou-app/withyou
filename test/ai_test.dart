import 'package:flutter_test/flutter_test.dart';
import 'package:withyou/models/app_user.dart';
import 'package:withyou/services/ai/ai_personas.dart';
import 'package:withyou/services/ai/ai_types.dart';
import 'package:withyou/services/ai/demo_provider.dart';

void main() {
  group('DemoProvider', () {
    final demo = DemoProvider();

    test('슬픔이 감지되면 선물 추천 신호를 낸다', () async {
      final reply = await demo.generate(
        systemPrompt: '',
        history: const [AiMessage(role: AiRole.user, text: '오늘 너무 힘들었어')],
      );
      expect(reply.recommendGift, isTrue);
      expect(reply.text, isNotEmpty);
    });

    test('평범한 대화에는 추천 신호를 내지 않는다', () async {
      final reply = await demo.generate(
        systemPrompt: '',
        history: const [AiMessage(role: AiRole.user, text: '점심 맛있게 먹었어')],
      );
      expect(reply.recommendGift, isFalse);
    });

    test('원격 제공자가 아니다(isLive=false)', () {
      expect(demo.isLive, isFalse);
    });
  });

  group('시스템 프롬프트', () {
    test('페르소나 이름과 프로필이 반영된다', () {
      final prompt = buildSystemPrompt(
        persona: '미리',
        user: const AppUser(email: 'a@b.com', name: '다나', humor: '블랙코미디'),
      );
      expect(prompt, contains('미리'));
      expect(prompt, contains('다나'));
      expect(prompt, contains('블랙코미디'));
      expect(prompt, contains(kGiftMarker)); // 추천 마커 규칙 포함
    });

    test('목록에 없는 페르소나는 기본(구나) 성격을 쓴다', () {
      final prompt = buildSystemPrompt(persona: '없는이름', user: null);
      expect(prompt, contains(kPersonaTraits['구나']!));
    });
  });
}
