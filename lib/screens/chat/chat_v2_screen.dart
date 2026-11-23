import 'package:flutter/material.dart';

/// v2 채팅 화면 (Figma: iPhone 14 & 15 Pro - 86 / 767:691).
///
/// 상단 헤더(뒤로 + 페르소나명 + 크레딧) / 말풍선 목록 / 하단 입력바.
/// 코인·전송 아이콘은 Material 대체.
class ChatV2Screen extends StatelessWidget {
  const ChatV2Screen({super.key});

  static const _bg = Color(0xFFFFF9F2);
  static const _brown = Color(0xFF90796A);
  static const _aiBubble = Color(0xFFF4E9DC);
  static const _aiText = Color(0xFFCCB3A3);
  static const _userBubble = Color(0xFFFFC8C5);
  static const _userText = Color(0xFFF47C76);
  static const _inputBorder = Color(0xFFE8D3B8);
  static const _creditBg = Color(0xFFFCD7D7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Image.asset(
                            'assets/brand/back_icon.png',
                            width: 32,
                            height: 32,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '고미',
                          style: TextStyle(
                            fontFamily: 'HumanBeomseokNeo',
                            fontSize: 28,
                            color: _brown,
                            fontWeight: FontWeight.w700,
                            fontVariations: [FontVariation('wght', 700)],
                          ),
                        ),
                      ],
                    ),
                    // 크레딧 배지
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _creditBg,
                        borderRadius: BorderRadius.circular(200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.monetization_on,
                              size: 26, color: Color(0xFFFFCD8C)),
                          SizedBox(width: 4),
                          Text(
                            '16',
                            style: TextStyle(
                              fontFamily: 'HumanBeomseokNeo',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontVariations: [FontVariation('wght', 700)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 대화 영역 (흰색)
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        children: const [
                          _AiBubble('안녕 나는 구나라고 해.'),
                          SizedBox(height: 16),
                          _AiBubble(
                            '이런 글 늘리기는 이제 나한테 맡겨\n내가 글 진짜 잘 늘려줄 수 있름\n'
                            '우선 오늘 새자 1시 30분까지 하기\n싫어서 12ㄱ시에 조기퇴그ㄴ할거임.',
                          ),
                          _TimeLabel('오후 9:10', right: false),
                          SizedBox(height: 10),
                          _UserBubble('그리고 씻으러갈것'),
                          _TimeLabel('오후 9:10', right: true),
                        ],
                      ),
                    ),
                    // 입력바
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _inputBorder, width: 1.4),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              child: Text(
                                '자유롭게 입력하세요',
                                style: TextStyle(
                                  fontFamily: 'HumanBeomseokNeo',
                                  fontSize: 14,
                                  color: _aiText,
                                  fontWeight: FontWeight.w700,
                                  fontVariations: [FontVariation('wght', 700)],
                                ),
                              ),
                            ),
                            Icon(Icons.send_rounded, size: 24, color: _aiText),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: ChatV2Screen._aiBubble,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'HumanBeomseokNeo',
            fontSize: 14,
            height: 1.3,
            color: ChatV2Screen._aiText,
            fontWeight: FontWeight.w600,
            fontVariations: [FontVariation('wght', 600)],
          ),
        ),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: ChatV2Screen._userBubble,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'HumanBeomseokNeo',
            fontSize: 14,
            color: ChatV2Screen._userText,
            fontVariations: [FontVariation('wght', 400)],
          ),
        ),
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel(this.time, {required this.right});
  final String time;
  final bool right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Align(
        alignment: right ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          time,
          style: const TextStyle(
            fontFamily: 'HumanBeomseokNeo',
            fontSize: 10,
            color: ChatV2Screen._aiText,
            fontWeight: FontWeight.w700,
            fontVariations: [FontVariation('wght', 700)],
          ),
        ),
      ),
    );
  }
}
