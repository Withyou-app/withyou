/// AI 대화에서 주고받는 한 턴. role 은 사용자(user)/AI(model) 둘 중 하나.
enum AiRole { user, model }

class AiMessage {
  const AiMessage({required this.role, required this.text});

  final AiRole role;
  final String text;
}

/// AI 응답 한 건. [recommendGift] 는 AI가 감정 상태를 보고 '선물 추천' 신호를
/// 냈는지 여부, [giftName] 은 추천한 구체적 선물명(예: 케이크, 향초).
class AiReply {
  const AiReply({
    required this.text,
    this.recommendGift = false,
    this.giftName,
  });

  final String text;
  final bool recommendGift;
  final String? giftName;
}

/// 제공자(Gemini/Claude/데모) 공통 인터페이스.
///
/// 새 제공자를 추가하려면 이 인터페이스만 구현하면 되고, [AiService] 의
/// 선택 로직에 한 줄만 추가하면 된다. (대화 UI/화면 코드는 그대로)
abstract class AiProvider {
  /// 실제 원격 호출이 가능한 제공자인지(키가 설정됐는지).
  bool get isLive;

  /// [systemPrompt] 페르소나/맥락 지시 + [history] 이전 대화로 다음 응답 생성.
  Future<AiReply> generate({
    required String systemPrompt,
    required List<AiMessage> history,
  });
}
