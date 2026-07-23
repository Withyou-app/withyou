import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 채팅 말풍선. 보낸 메시지(우측 코랄) / 받은 메시지(좌측 베이지) 두 변형.
class ChatBubble extends StatelessWidget {
  const ChatBubble.received(this.text, {super.key, this.time})
      : isSent = false;
  const ChatBubble.sent(this.text, {super.key, this.time}) : isSent = true;

  final String text;
  final String? time;
  final bool isSent;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.68,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSent ? AppColors.bubbleSent : AppColors.bubbleReceived,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: isSent ? AppColors.white : AppColors.textPrimary,
          height: 1.35,
        ),
      ),
    );

    final time = this.time;
    final row = Row(
      mainAxisAlignment:
          isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isSent && time != null) ...[
          Text(time, style: AppTextStyles.caption),
          const SizedBox(width: 6),
        ],
        Flexible(child: bubble),
        if (!isSent && time != null) ...[
          const SizedBox(width: 6),
          Text(time, style: AppTextStyles.caption),
        ],
      ],
    );

    return Padding(padding: const EdgeInsets.only(bottom: 12), child: row);
  }
}
