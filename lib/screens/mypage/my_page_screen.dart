import 'package:flutter/material.dart';
import '../../models/consent_term.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/session_data.dart';
import '../../services/conversation_store.dart';

/// 마이페이지 — 탭 화면. 하단 네비는 상위 셸이 담당하므로 넣지 않는다.
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // 이름 인라인 수정 상태
  bool _editingName = false;
  final TextEditingController _nameCtrl = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // 포커스를 잃으면(키보드 내려가거나 다른 곳 탭) 자동 저장.
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus && _editingName) _submitName();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _startEditName() {
    // 'ID' 같은 플레이스홀더가 아니라 실제 저장된 이름에서 시작.
    _nameCtrl.text = AuthService.instance.currentUser?.name ?? '';
    setState(() => _editingName = true);
    // 다음 프레임에 포커스 + 커서를 끝으로.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
      _nameCtrl.selection =
          TextSelection.collapsed(offset: _nameCtrl.text.length);
    });
  }

  Future<void> _submitName() async {
    if (!_editingName) return;
    final next = _nameCtrl.text.trim();
    final user = AuthService.instance.currentUser;
    if (user != null && next.isNotEmpty && next != user.name) {
      await AuthService.instance.updateProfile(user.copyWith(name: next));
    }
    if (!mounted) return;
    setState(() => _editingName = false);
  }

  Future<void> _editProfile() async {
    await Navigator.pushNamed(context, AppRoutes.profileEdit);
    if (mounted) setState(() {}); // 수정 후 반영
  }

  void _openContact() => Navigator.pushNamed(context, AppRoutes.contact);

  /// 페르소나별 저장 메모리 카드.
  Widget _memoryCard(String persona) {
    final preview =
        ConversationStore.instance.lastPreview(persona) ?? '기억을 쌓아가는 중이에요';
    return AppCard(
      onTap: () => _showMemory(persona),
      child: Row(
        children: [
          AppAvatar(size: 44, name: persona),
          const SizedBox(width: AppGaps.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$persona의 기억', style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardBody),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
    );
  }

  /// 이 친구가 기억하고 있는 정보를 하단 시트로 보여준다.
  /// (프롬프트에 반영되는 프로필 + 최근 대화 기반, 대화할수록 갱신)
  void _showMemory(String persona) {
    final user = AuthService.instance.currentUser;
    final facts = <(String, String)>[
      if (user != null && user.name.isNotEmpty) ('호칭', user.name),
      if ((user?.bio ?? '').isNotEmpty) ('자기소개', user!.bio),
      if ((user?.humor ?? '').isNotEmpty) ('유머 취향', user!.humor),
    ];
    final messages = ConversationStore.instance.messagesOf(persona);
    final recentMine = messages
        .where((m) => m.isMe)
        .toList()
        .reversed
        .take(3)
        .toList()
        .reversed
        .toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      barrierColor: AppColors.scrim,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppGaps.screenH, AppGaps.lg, AppGaps.screenH, AppGaps.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppAvatar(size: 44, name: persona),
                    const SizedBox(width: AppGaps.sm),
                    Text('$persona이(가) 기억하는 것',
                        style: AppTextStyles.cardTitle),
                  ],
                ),
                AppGaps.v20,
                const Text('나에 대해', style: AppTextStyles.label),
                AppGaps.v8,
                if (facts.isEmpty)
                  const Text('아직 기억한 정보가 많지 않아요', style: AppTextStyles.body)
                else
                  for (final f in facts) ...[
                    _memoryRow(f.$1, f.$2),
                    AppGaps.v8,
                  ],
                AppGaps.v12,
                const Text('최근 대화에서', style: AppTextStyles.label),
                AppGaps.v8,
                if (recentMine.isEmpty)
                  const Text('대화를 나누면 여기에 쌓여요', style: AppTextStyles.body)
                else
                  for (final m in recentMine) ...[
                    Text('· ${m.text}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body),
                    AppGaps.v8,
                  ],
                AppGaps.v16,
                Text('$persona와 대화를 나눌수록 이 기억은 계속 업데이트돼요.',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _memoryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 72,
            child: Text(label,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary))),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: AppTextStyles.body)),
      ],
    );
  }

  Future<void> _logout() async {
    await AuthService.instance.logOut();
    // 실서버 모드: 로컬 캐시를 비워 다음 사용자에게 데이터가 남지 않게.
    await SessionData.onLogout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final name = (user != null && user.name.isNotEmpty) ? user.name : 'ID';
    final email = user?.email ?? '';

    // 라벨 + 현재 값 (없으면 'ex' 로 표시)
    final info = <(String, String)>[
      ('자기소개', user?.bio ?? ''),
      ('유머 취향', user?.humor ?? ''),
    ];

    return Scaffold(
      floatingActionButton: _ContactFab(onTap: _openContact),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppGaps.screenH,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('마이페이지', style: AppTextStyles.title),
              AppGaps.v24,
              // 프로필 — 앱 로고를 아바타로 사용.
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      // 로고의 크림색 말풍선과 겹치지 않게 연노랑 배경.
                      color: Color(0xFFFFF1C2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset('assets/brand/app_logo.png',
                        fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _nameRow(name),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: AppTextStyles.subtitle
                              .copyWith(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppGaps.v20,
              // 정보 카드
              AppCard(
                color: AppColors.card,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < info.length; i++) ...[
                      if (i > 0) AppGaps.v16,
                      _infoRow(info[i].$1, info[i].$2),
                    ],
                    AppGaps.v20,
                    SecondaryButton(label: '프로필 수정', onPressed: _editProfile),
                  ],
                ),
              ),
              AppGaps.v24,
              // 저장 메모리 — 페르소나별로 나눈 대화를 바탕으로 기억이 쌓인다.
              const Text('저장 메모리', style: AppTextStyles.label),
              AppGaps.v8,
              AnimatedBuilder(
                animation: ConversationStore.instance,
                builder: (context, _) {
                  final personas =
                      ConversationStore.instance.personasWithHistory;
                  if (personas.isEmpty) {
                    return const Text('아직 저장된 기억이 없어요',
                        style: AppTextStyles.body);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${personas.length}명의 친구가 기억을 저장하고 있어요',
                          style: AppTextStyles.body),
                      AppGaps.v16,
                      for (var i = 0; i < personas.length; i++) ...[
                        if (i > 0) AppGaps.v12,
                        _memoryCard(personas[i]),
                      ],
                    ],
                  );
                },
              ),
              AppGaps.v24,
              // 동의 내역 — 각 항목 글자를 누르면 하단에서 약관 본문이 올라온다.
              const Text('동의 내역', style: AppTextStyles.label),
              AppGaps.v16,
              for (final term in kConsentTerms) ...[
                if (term != kConsentTerms.first) AppGaps.v12,
                // 필수: '동의함' 고정 / 선택(마케팅): 동의함·미동의 토글
                term.required ? _consentRow(term) : _marketingRow(term),
              ],
              AppGaps.v24,
              // 로그아웃
              GestureDetector(
                onTap: _logout,
                behavior: HitTestBehavior.opaque,
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              AppGaps.v16,
              // 회원탈퇴 (다음 줄)
              GestureDetector(
                onTap: _deleteAccount,
                behavior: HitTestBehavior.opaque,
                child: const Text(
                  '회원탈퇴',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHint,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textHint,
                  ),
                ),
              ),
              // 우하단 문의 버튼에 가리지 않도록 하단 여백.
              const SizedBox(height: 72),
            ],
          ),
        ),
      ),
    );
  }

  /// 이름 + 수정 아이콘. 탭하면 밑줄이 생기며 그 자리에서 바로 편집한다.
  Widget _nameRow(String name) {
    const nameStyle = TextStyle(
      fontFamily: AppFonts.cocochoitoon,
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    );

    if (_editingName) {
      // 배경/채움 없이, 글씨에 딱 붙는 기본색 밑줄만. 키보드의 완료를 누르거나
      // 포커스를 잃으면 저장된다(별도 확인 버튼 없음).
      return IntrinsicWidth(
        child: TextField(
          controller: _nameCtrl,
          focusNode: _nameFocus,
          style: nameStyle,
          cursorColor: AppColors.textPrimary,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitName(),
          decoration: const InputDecoration(
            filled: false,
            isDense: true,
            isCollapsed: true,
            contentPadding: EdgeInsets.only(bottom: 2),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textPrimary),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textPrimary),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textPrimary),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: nameStyle,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _startEditName,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Image.asset('assets/icons/edit.png', width: 18, height: 18),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    final empty = value.isEmpty;
    return Row(
      children: [
        Text(label, style: AppTextStyles.body),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            empty ? 'ex' : value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              color: empty ? AppColors.textHint : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// 필수 항목: 태그 + (탭하면 약관 시트가 열리는) 항목명 + '동의함' 고정.
  Widget _consentRow(ConsentTerm term) {
    return Row(
      children: [
        ConsentTag(required: term.required),
        const SizedBox(width: 8),
        Expanded(child: _termLabel(term)),
        Text('동의함',
            style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
      ],
    );
  }

  /// 선택 항목: 마케팅 및 알림(정보수신) — '동의함' 탭 시 토글된다.
  /// 미동의(코랄·굵게)를 강조해 동의를 유도하고, 동의함은 회색으로 표시한다.
  Widget _marketingRow(ConsentTerm term) {
    final on = AuthService.instance.marketingConsent;
    return Row(
      children: [
        ConsentTag(required: term.required),
        const SizedBox(width: 8),
        Expanded(child: _termLabel(term)),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            await AuthService.instance.setMarketingConsent(!on);
            if (mounted) setState(() {});
          },
          child: Text(
            on ? '동의함' : '미동의',
            style: AppTextStyles.body.copyWith(
              color: on ? AppColors.textSecondary : AppColors.primary,
              fontWeight: on ? FontWeight.w600 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// 밑줄 친 항목명 — 탭하면 하단에서 약관 본문 시트가 올라온다.
  Widget _termLabel(ConsentTerm term) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showTermsSheet(context, term),
      child: Text(
        term.title,
        style: AppTextStyles.body.copyWith(
          decoration: TextDecoration.underline,
          decorationColor: AppColors.textHint,
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final ok = await ConfirmDialog.show(
      context,
      title: '정말 탈퇴하시겠어요?',
      message: '탈퇴하면 모든 대화와 프로필 정보가 삭제되며\n복구할 수 없어요.',
      cancelLabel: '취소',
      confirmLabel: '탈퇴하기',
    );
    if (ok != true) return;
    await AuthService.instance.deleteAccount();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.login, (route) => false);
  }
}

/// 우측 하단에 상시 떠 있는 문의하기 버튼 (코랄 원형 + 흰색 물음표).
class _ContactFab extends StatelessWidget {
  const _ContactFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset('assets/icons/inquiry.png', fit: BoxFit.cover),
      ),
    );
  }
}
