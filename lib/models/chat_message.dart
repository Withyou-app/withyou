/// 대화창에 표시되는 한 메시지.
///
/// [giftRecommendation] 이 true 인 partner 메시지는 말풍선 대신
/// '선물 추천' 버튼(칩)으로 렌더링된다.
enum ChatSender { me, partner }

class ChatMessage {
  const ChatMessage.me(this.text, {this.time})
      : sender = ChatSender.me,
        giftRecommendation = false;

  const ChatMessage.partner(
    this.text, {
    this.time,
    this.giftRecommendation = false,
  }) : sender = ChatSender.partner;

  const ChatMessage._({
    required this.sender,
    required this.text,
    this.time,
    this.giftRecommendation = false,
  });

  final ChatSender sender;
  final String text;
  final String? time;
  final bool giftRecommendation;

  bool get isMe => sender == ChatSender.me;

  Map<String, dynamic> toJson() => {
        'sender': sender.name,
        'text': text,
        if (time != null) 'time': time,
        if (giftRecommendation) 'gift': true,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage._(
        sender: json['sender'] == 'me' ? ChatSender.me : ChatSender.partner,
        text: json['text'] as String? ?? '',
        time: json['time'] as String?,
        giftRecommendation: json['gift'] == true,
      );
}
