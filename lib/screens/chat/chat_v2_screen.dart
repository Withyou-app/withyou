import 'package:flutter/material.dart';
import '../../models/gift_v2.dart';
import '../../routes/app_routes.dart';
import '../../services/ai/ai_service.dart';
import '../../services/ai/ai_types.dart';
import '../../services/report_store.dart';

/// v2 채팅 화면 (Figma: iPhone 14 & 15 Pro - 86 / 767:691).
///
/// 상단 헤더(뒤로 + 페르소나명 + 크레딧) / 말풍선 목록 / 하단 입력바.
/// 선택한 페르소나로 [AiService] 와 실제 대화한다(키 없으면 데모 응답).
/// AI가 선물을 추천하면 말풍선 아래에 "🎁 선물하기" 칩이 떠 구매 화면으로 연결된다.
class ChatV2Screen extends StatefulWidget {
  const ChatV2Screen({super.key, this.persona = '고미'});

  /// 진입 시 페르소나. persona_select 에서 라우트 arguments(String) 로도 전달 가능.
  final String persona;

  @override
  State<ChatV2Screen> createState() => _ChatV2ScreenState();
}

class _ChatV2ScreenState extends State<ChatV2Screen> {
  static const _bg = Color(0xFFFFF9F2);
  static const _brown = Color(0xFF90796A);
  static const _aiBubble = Color(0xFFF4E9DC);
  static const _aiText = Color(0xFFCCB3A3);
  static const _userBubble = Color(0xFFFFC8C5);
  static const _userText = Color(0xFFF47C76);
  static const _inputBorder = Color(0xFFE8D3B8);
  static const _creditBg = Color(0xFFFCD7D7);

  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<AiMessage> _history = []; // AI 전달용
  final List<_Msg> _msgs = []; // 화면 표시용
  bool _sending = false;
  bool _ending = false;
  bool _seeded = false;
  String _persona = '고미';
  final int _credit = 16; // 표시용(실제 차감은 백엔드)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    _persona = (arg is String && arg.isNotEmpty) ? arg : widget.persona;
    // 첫 인사(페르소나별).
    _msgs.add(_Msg(fromUser: false, text: _greeting(_persona)));
    _seeded = true;
  }

  String _greeting(String p) {
    switch (p) {
      case '구나':
        return '안녕, 나는 구나야. 오늘 하루 마음은 어땠어? 편하게 들려줘.';
      case '리미':
        return '안녕, 나는 리미야. 무슨 일이든 같이 들여다보자. 오늘 어땠어?';
      case '고미':
      default:
        return '안녕, 나는 고미야. 오늘 어떤 고민이 있어? 차분히 들어볼게.';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    _controller.clear();
    setState(() {
      _msgs.add(_Msg(fromUser: true, text: text));
      _history.add(AiMessage(role: AiRole.user, text: text));
      _sending = true;
    });
    _scrollToBottom();
    try {
      final reply =
          await AiService.instance.reply(persona: _persona, history: _history);
      final gift = reply.recommendGift ? giftV2ByName(reply.giftName) : null;
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg(fromUser: false, text: reply.text, gift: gift));
        _history.add(AiMessage(role: AiRole.model, text: reply.text));
        _sending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg(
            fromUser: false, text: '지금은 답하기가 조금 어려워. 잠시 뒤 다시 말 걸어줄래?'));
        _sending = false;
      });
    }
    _scrollToBottom();
  }

  /// 뒤로가기: 사용자가 대화한 적 있으면 마음 리포트를 생성·저장하고 상세로 이동,
  /// 아니면 그냥 닫는다. (세션 완료 시 리포트 — 스펙 §4)
  Future<void> _onBack() async {
    if (_ending) return;
    final hasUserMsg = _history.any((m) => m.role == AiRole.user);
    if (!hasUserMsg) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _ending = true);
    try {
      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      final createdAt = '${now.year}.${two(now.month)}.${two(now.day)}';
      final report = await AiService.instance.generateReport(
        persona: _persona,
        history: _history,
        createdAt: createdAt,
      );
      await ReportStore.instance.add(report);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.reportDetailV2,
        arguments: report,
      );
    } catch (_) {
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
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
                          onTap: _onBack,
                          child: Image.asset('assets/brand/back_icon.png',
                              width: 32, height: 32),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _persona,
                          style: const TextStyle(
                            fontFamily: 'HumanBeomseokNeo',
                            fontSize: 28,
                            color: _brown,
                            fontWeight: FontWeight.w700,
                            fontVariations: [FontVariation('wght', 700)],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _creditBg,
                        borderRadius: BorderRadius.circular(200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on,
                              size: 26, color: Color(0xFFFFCD8C)),
                          const SizedBox(width: 4),
                          Text(
                            '$_credit',
                            style: const TextStyle(
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
            // 대화 영역
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        itemCount: _msgs.length + (_sending ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (_sending && i == _msgs.length) {
                            return const _TypingBubble();
                          }
                          final m = _msgs[i];
                          if (m.fromUser) return _UserBubble(m.text);
                          return _AiBubble(
                            text: m.text,
                            gift: m.gift,
                            onGiftTap: m.gift == null
                                ? null
                                : () => Navigator.of(context).pushNamed(
                                    AppRoutes.giftPurchaseV2,
                                    arguments: m.gift),
                          );
                        },
                      ),
                    ),
                    // 입력바
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.only(left: 24, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _inputBorder, width: 1.4),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                minLines: 1,
                                maxLines: 1,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _send(),
                                style: const TextStyle(
                                  fontFamily: 'HumanBeomseokNeo',
                                  fontSize: 14,
                                  color: _brown,
                                  fontWeight: FontWeight.w600,
                                  fontVariations: [FontVariation('wght', 600)],
                                ),
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText: '자유롭게 입력하세요',
                                  hintStyle: TextStyle(
                                    fontFamily: 'HumanBeomseokNeo',
                                    fontSize: 14,
                                    color: _aiText,
                                    fontWeight: FontWeight.w700,
                                    fontVariations: [FontVariation('wght', 700)],
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _sending ? null : _send,
                              icon: Icon(Icons.send_rounded,
                                  size: 24,
                                  color: _sending ? _aiText : _userText),
                            ),
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

/// 화면 표시용 메시지(+ AI가 추천한 선물).
class _Msg {
  _Msg({required this.fromUser, required this.text, this.gift});
  final bool fromUser;
  final String text;
  final GiftV2? gift;
}

class _AiBubble extends StatelessWidget {
  const _AiBubble({required this.text, this.gift, this.onGiftTap});
  final String text;
  final GiftV2? gift;
  final VoidCallback? onGiftTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: _ChatV2ScreenState._aiBubble,
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
                  color: _ChatV2ScreenState._aiText,
                  fontWeight: FontWeight.w600,
                  fontVariations: [FontVariation('wght', 600)],
                ),
              ),
            ),
          ),
          if (gift != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onGiftTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFC8C5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.card_giftcard,
                        size: 18, color: Color(0xFFFF8E88)),
                    const SizedBox(width: 8),
                    Text(
                      '${gift!.name} 선물하기',
                      style: const TextStyle(
                        fontFamily: 'HumanBeomseokNeo',
                        fontSize: 13,
                        color: Color(0xFFF47C76),
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right,
                        size: 18, color: Color(0xFFF47C76)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: _ChatV2ScreenState._userBubble,
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
              height: 1.3,
              color: _ChatV2ScreenState._userText,
              fontVariations: [FontVariation('wght', 400)],
            ),
          ),
        ),
      ),
    );
  }
}

/// AI가 응답을 만드는 동안 보여주는 "…" 말풍선.
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            '…',
            style: TextStyle(
              fontFamily: 'HumanBeomseokNeo',
              fontSize: 20,
              color: _ChatV2ScreenState._aiText,
              fontWeight: FontWeight.w700,
              fontVariations: [FontVariation('wght', 700)],
            ),
          ),
        ),
      ),
    );
  }
}
