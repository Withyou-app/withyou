import 'package:flutter/material.dart';
import '../chat/chat_v2_screen.dart';
import 'gift_received_modal.dart';

/// 선물 받기 화면 (Figma 90): 채팅 위에 선물 받기 모달을 띄운 상태.
///
/// 진입 시 채팅(배경) 위로 모달을 자동 표시한다. 모달을 닫으면 채팅으로 돌아간다.
class GiftReceivedV2Screen extends StatefulWidget {
  const GiftReceivedV2Screen({super.key});

  @override
  State<GiftReceivedV2Screen> createState() => _GiftReceivedV2ScreenState();
}

class _GiftReceivedV2ScreenState extends State<GiftReceivedV2Screen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showGiftReceivedModal(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 배경은 채팅 화면.
    return const ChatV2Screen();
  }
}
