import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withyou/models/chat_message.dart';
import 'package:withyou/services/conversation_store.dart';

void main() {
  final store = ConversationStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.init();
    // 싱글턴 잔여 상태 제거(init 의 orphan 정리 후 남는 건 me-메시지 대화뿐).
    for (final p in List.of(store.personasWithHistory)) {
      await store.clear(p);
    }
  });

  test('setMessages 후 messagesOf 로 대화를 돌려준다', () async {
    await store.setMessages('구나', const [
      ChatMessage.partner('안녕!'),
      ChatMessage.me('안녕 구나'),
    ]);
    final msgs = store.messagesOf('구나');
    expect(msgs.length, 2);
    expect(msgs.last.isMe, isTrue);
  });

  test('인사말(partner)만 있는 대화는 진행 중으로 치지 않는다', () async {
    await store.setMessages('리미', const [ChatMessage.partner('왔어?')]);
    expect(store.hasConversation('리미'), isFalse);
    expect(store.personasWithHistory, isEmpty);

    await store.setMessages('리미', const [
      ChatMessage.partner('왔어?'),
      ChatMessage.me('응 왔어'),
    ]);
    expect(store.hasConversation('리미'), isTrue);
    expect(store.personasWithHistory, contains('리미'));
  });

  test('personasWithHistory 는 최근 활동 대화를 앞에 둔다', () async {
    await store.setMessages('구나', const [ChatMessage.me('하이')]);
    await store.setMessages('고미', const [ChatMessage.me('안녕')]);
    await store.setMessages('구나', const [ChatMessage.me('또 왔어')]); // 구나 갱신→최신
    expect(store.personasWithHistory.first, '구나');
  });

  test('lastPreview 는 선물 추천 칩이 아닌 마지막 메시지를 준다', () async {
    await store.setMessages('구나', const [
      ChatMessage.me('오늘 힘들어'),
      ChatMessage.partner('많이 힘들었구나'),
      ChatMessage.partner('선물', giftRecommendation: true, giftId: 'cocoa'),
    ]);
    expect(store.lastPreview('구나'), '많이 힘들었구나');
  });

  test('clear 하면 해당 페르소나 대화가 비워진다', () async {
    await store.setMessages('구나', const [ChatMessage.me('하이')]);
    await store.clear('구나');
    expect(store.messagesOf('구나'), isEmpty);
    expect(store.hasConversation('구나'), isFalse);
  });
}
