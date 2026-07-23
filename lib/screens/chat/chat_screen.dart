import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../models/gift.dart';
import '../../models/mind_report.dart';
import '../../routes/app_routes.dart';
import '../../services/ai/ai_service.dart';
import '../../services/ai/ai_types.dart';
import '../../services/auth_service.dart';
import '../../services/conversation_store.dart';
import '../../services/shell_nav.dart';
import '../../utils/korean.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'emergency_alert_sheet.dart';

/// 대화창 — 상단 바 + 메시지 리스트 + 입력바 + 하단 네비.
///
/// 대화는 [ConversationStore] 에 자동 저장(중간저장)되어, 다른 탭을 보다
/// 돌아오거나 앱을 껐다 켜도 이어진다. '대화 종료' 시 마음 리포트를 만든다.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.partnerName});

  final String? partnerName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _sending = false;
  bool _seeded = false;
  late String _name;

  @override
  void initState() {
    super.initState();
    // 키보드가 오르내릴 때 최근 메시지가 가려지지 않게 맨 아래로 스크롤.
    WidgetsBinding.instance.addObserver(this);
    _inputFocus.addListener(() {
      if (_inputFocus.hasFocus) _scrollToBottom();
    });
  }

  @override
  void didChangeMetrics() {
    // 키보드 높이 변화(등장/사라짐) 시 하단 고정.
    _scrollToBottom();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    _name = widget.partnerName ??
        (ModalRoute.of(context)?.settings.arguments as String?) ??
        '구나';
    // 저장된 대화 복원(이어하기). 없으면 첫 인사만 로컬로 표시.
    // (인사만 있고 대화를 진행하지 않으면 기록하지 않는다 → 첫 전송 때 저장)
    final saved = ConversationStore.instance.messagesOf(_name);
    if (saved.isNotEmpty) {
      _messages.addAll(saved);
    } else {
      _messages.add(ChatMessage.partner(
          '안녕! 나는 $_name${Korean.iya(_name)}. 오늘 하루는 어땠어?',
          time: _now()));
    }
    _scrollToBottom();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inputController.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _persist() => ConversationStore.instance.setMessages(_name, _messages);

  String _now() {
    final t = TimeOfDay.now();
    final isAm = t.hour < 12;
    final h12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final mm = t.minute.toString().padLeft(2, '0');
    return '${isAm ? '오전' : '오후'} $h12:$mm';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// 대화 UI 메시지를 AI 히스토리로 변환(선물 칩 제외, 첫 model 턴 제거).
  List<AiMessage> _buildHistory() {
    final turns = <AiMessage>[
      for (final m in _messages)
        if (!m.giftRecommendation)
          AiMessage(role: m.isMe ? AiRole.user : AiRole.model, text: m.text),
    ];
    final firstUser = turns.indexWhere((t) => t.role == AiRole.user);
    return firstUser <= 0 ? turns : turns.sublist(firstUser);
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(ChatMessage.me(text, time: _now()));
      _sending = true;
    });
    _inputController.clear();
    _persist();
    _inputFocus.requestFocus(); // 키보드 유지
    _scrollToBottom();

    try {
      final reply = await AiService.instance
          .reply(persona: _name, history: _buildHistory());
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage.partner(reply.text, time: _now()));
        if (reply.recommendGift) {
          // AI 추천명을 카탈로그 선물로 매칭(없으면 기본값) → 칩이 상세로 이동.
          final gift = giftByName(reply.giftName) ?? kGifts.first;
          _messages.add(ChatMessage.partner(
            _giftLabel(gift.name),
            giftRecommendation: true,
            giftId: gift.id,
          ));
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage.partner(
          '앗, 지금은 답하기가 어려워… 잠시 후 다시 말 걸어줄래?',
          time: _now(),
        ));
      });
    } finally {
      if (mounted) setState(() => _sending = false);
      _persist();
      _scrollToBottom();
    }
  }

  /// 대화 종료 → 리포트 생성 → 마음 리포트 화면으로.
  Future<void> _endChat() async {
    final end = await ConfirmDialog.show(
      context,
      title: '대화를 종료할까요?',
      message: '지금까지 나눈 대화로 마음 리포트를 만들어드려요.',
      cancelLabel: '더 대화하기',
      confirmLabel: '종료하고 리포트 보기',
    );
    if (end != true || !mounted) return;

    _showLoading();
    final now = DateTime.now();
    final createdAt =
        '${now.year}-${_two(now.month)}-${_two(now.day)} ${_two(now.hour)}:${_two(now.minute)}';
    final report = await AiService.instance.generateReport(
      persona: _name,
      history: _buildHistory(),
      createdAt: createdAt,
    );
    if (!mounted) return;
    Navigator.of(context).pop(); // 로딩 닫기
    Navigator.pushNamed(
      context,
      AppRoutes.reportDetail,
      arguments: MindReportArgs(report: report, isNew: true, persona: _name),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  /// 선물 추천 칩 문구: "{이름}를 위해 {선물} 선물을 준비했어요!"
  String _giftLabel(String? gift) {
    final user = AuthService.instance.currentUser;
    final name = (user != null && user.name.isNotEmpty) ? user.name : '당신';
    final item = (gift == null || gift.isEmpty) ? '작은 선물' : gift;
    return '$name를 위해 $item 선물을 준비했어요!';
  }

  void _showLoading() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.scrim,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  /// 하단 네비 탭 → 대화창을 떠나 해당 탭으로.(대화는 저장돼 있어 나중에 이어짐)
  void _leaveToTab(int index) {
    ShellNav.instance.goTo(index);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _topBar(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppGaps.screenH, vertical: AppGaps.lg),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) return const _TypingBubble();
                return _messageItem(_messages[i]);
              },
            ),
          ),
          ChatInputBar(
            hint: '자유롭게 입력하세요',
            controller: _inputController,
            focusNode: _inputFocus,
            onSend: _send,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: ShellNav.chatTab,
        onTap: _leaveToTab,
      ),
    );
  }

  Widget _topBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.inputFill,
        padding: const EdgeInsets.symmetric(
            horizontal: AppGaps.screenH, vertical: AppGaps.sm),
        child: Row(
          children: [
            const AppBackButton(),
            const SizedBox(width: AppGaps.xs),
            GestureDetector(
              onTap: () => showEmergencyAlert(context),
              child: AppAvatar(size: 40, name: _name),
            ),
            const SizedBox(width: AppGaps.sm),
            Text(
              _name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            _EndChatBadge(onTap: _endChat),
          ],
        ),
      ),
    );
  }

  Widget _messageItem(ChatMessage m) {
    if (m.giftRecommendation) {
      return _GiftRecommendChip(
        label: m.text,
        // 추천한 그 선물의 상세로 바로 이동.
        onTap: () {
          final gift = m.giftId != null ? giftById(m.giftId!) : null;
          Navigator.pushNamed(context, AppRoutes.giftDetail,
              arguments: gift ?? kGifts.first);
        },
      );
    }
    if (m.isMe) return ChatBubble.sent(m.text, time: m.time);
    return ChatBubble.received(m.text, time: m.time);
  }
}

/// 상단 바 우측의 작은 '대화 종료' 뱃지 (시안 스타일).
class _EndChatBadge extends StatelessWidget {
  const _EndChatBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.muted,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            '대화 종료',
            style: TextStyle(
              fontFamily: AppFonts.cocochoitoon,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// AI가 답변을 생성하는 동안 보여주는 말풍선 — 점 3개가 파도타기하듯 오르내린다.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.bubbleReceived,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (var i = 0; i < 3; i++) _dot(i)],
          ),
        ),
      ),
    );
  }

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // 각 점마다 위상차를 줘서 파도처럼 순차로 튀어오른다.
        final phase = (_controller.value - index * 0.2) % 1.0;
        final lift = (phase < 0.5) ? (0.5 - (phase - 0.25).abs() * 4) : 0.0;
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 5),
          child: Transform.translate(
            offset: Offset(0, -3 * lift.clamp(0.0, 1.0)),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textSecondary.withValues(
                    alpha: 0.4 + 0.6 * lift.clamp(0.0, 1.0)),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// AI가 감정 상태를 보고 낸 '선물 추천' 신호 버튼.
class _GiftRecommendChip extends StatelessWidget {
  const _GiftRecommendChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.card),
            onTap: onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.card_giftcard,
                      size: 18, color: AppColors.white),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
