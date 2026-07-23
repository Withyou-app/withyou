import 'ai_personas.dart';
import 'ai_types.dart';

/// 키가 없을 때 쓰는 오프라인 데모 제공자. (메일의 데모 모드와 같은 개념)
///
/// 실제 LLM 대신 간단한 규칙으로 페르소나다운 위로 문구를 돌려준다.
/// 슬픔이 감지되면 선물 추천 신호([kGiftMarker])를 붙인다.
class DemoProvider implements AiProvider {
  @override
  bool get isLive => false;

  static const _sadWords = [
    '힘들', '지쳐', '지침', '슬퍼', '슬프', '우울', '외로', '속상',
    '눈물', '울', '불안', '걱정', '무서', '화나', '짜증', '답답',
  ];

  @override
  Future<AiReply> generate({
    required String systemPrompt,
    required List<AiMessage> history,
  }) async {
    final last =
        history.isNotEmpty ? history.last.text.trim() : '';
    final isSad = _sadWords.any(last.contains);

    // 응답이 매번 똑같지 않도록 마지막 메시지 길이로 변형을 준다.
    final variant = last.runes.length % 3;

    String text;
    if (isSad) {
      text = const [
        '많이 힘들었겠다… 얘기해줘서 고마워. 지금 마음이 어때?',
        '그랬구나, 속상했겠다. 나한테 더 얘기해도 괜찮아.',
        '오늘 정말 애썼어. 잠깐 숨 돌려도 돼, 내가 옆에 있을게.',
      ][variant];
      final gift = const ['따뜻한 코코아', '미니 꽃다발', '붕어빵'][variant];
      return AiReply(text: text, recommendGift: true, giftName: gift);
    }

    if (last.isEmpty) {
      text = '안녕! 오늘 하루는 어땠어?';
    } else {
      text = const [
        '그랬구나! 좀 더 들려줄래?',
        '오 좋다. 그때 기분은 어땠어?',
        '응응, 듣고 있어. 계속 얘기해줘!',
      ][variant];
    }
    return AiReply(text: text);
  }
}
