import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../services/conversation_store.dart';
import '../chat/chat_screen.dart';
import 'delete_conversation_dialog.dart';

/// 최근 대화 창 — 탭 화면(콘텐츠 전용). 하단 네비는 상위 셸이 얹는다.
///
/// 진행 중(저장된) 대화 목록을 [ConversationStore] 에서 읽어 보여준다.
/// 삭제(휴지통) → 체크 다중 선택 → 선택 삭제.
class RecentConversationsScreen extends StatefulWidget {
  const RecentConversationsScreen({super.key});

  @override
  State<RecentConversationsScreen> createState() =>
      _RecentConversationsScreenState();
}

class _RecentConversationsScreenState
    extends State<RecentConversationsScreen> {
  bool _selectionMode = false;
  final Set<String> _selected = {};

  void _enterSelection() => setState(() {
        _selectionMode = true;
        _selected.clear();
      });

  void _cancelSelection() => setState(() {
        _selectionMode = false;
        _selected.clear();
      });

  void _toggle(String persona) => setState(() {
        if (!_selected.add(persona)) _selected.remove(persona);
      });

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    final ok = await showDeleteConversationDialog(context);
    if (ok != true || !mounted) return;
    for (final persona in _selected) {
      await ConversationStore.instance.clear(persona);
    }
    setState(() {
      _selected.clear();
      _selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppGaps.screenH),
        child: AnimatedBuilder(
          animation: ConversationStore.instance,
          builder: (context, _) {
            final personas = ConversationStore.instance.personasWithHistory;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppGaps.v8,
                _header(personas.isNotEmpty),
                AppGaps.v16,
                Expanded(
                  child: personas.isEmpty
                      ? _empty()
                      : ListView.separated(
                          itemCount: personas.length,
                          separatorBuilder: (_, _) => AppGaps.v12,
                          itemBuilder: (context, i) =>
                              _conversationCard(personas[i]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(bool hasItems) {
    return Row(
      children: [
        const Text('최근 대화', style: AppTextStyles.title),
        const Spacer(),
        if (_selectionMode) ...[
          TextButton(
            onPressed: _cancelSelection,
            child: Text('취소',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: _selected.isEmpty ? null : _deleteSelected,
            child: Text(
              '삭제${_selected.isEmpty ? '' : ' ${_selected.length}'}',
              style: AppTextStyles.label.copyWith(
                color:
                    _selected.isEmpty ? AppColors.textHint : AppColors.primary,
              ),
            ),
          ),
        ] else if (hasItems)
          IconButton(
            onPressed: _enterSelection,
            icon: const Icon(Icons.delete_outline, color: AppColors.primary),
          ),
      ],
    );
  }

  Widget _empty() {
    return const Center(
      child: Text('아직 진행 중인 대화가 없어요\n홈에서 새 대화를 시작해보세요',
          textAlign: TextAlign.center, style: AppTextStyles.body),
    );
  }

  Widget _conversationCard(String persona) {
    final selected = _selected.contains(persona);
    final preview =
        ConversationStore.instance.lastPreview(persona) ?? '대화를 이어가 볼까요?';
    return AppCard(
      onTap: () {
        if (_selectionMode) {
          _toggle(persona);
        } else {
          Navigator.pushNamed(context, AppRoutes.chat,
              arguments: ChatArgs(persona, resume: true));
        }
      },
      child: Row(
        children: [
          if (_selectionMode) ...[
            _checkCircle(selected),
            const SizedBox(width: AppGaps.sm),
          ],
          AppAvatar(size: 52, name: persona),
          const SizedBox(width: AppGaps.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$persona와의 대화', style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardBody,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkCircle(bool selected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.textHint,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 16, color: AppColors.white)
          : null,
    );
  }
}
