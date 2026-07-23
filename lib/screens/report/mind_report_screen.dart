import 'package:flutter/material.dart';
import '../../models/mind_report.dart';
import '../../services/conversation_store.dart';
import '../../services/report_store.dart';
import '../../services/shell_nav.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// 마음 리포트 — 대화 종료로 생성됐거나(리포트 저장), 리포트 목록에서 조회한다.
/// 진입 인자는 [MindReportArgs]. 없으면 기본(예시) 화면.
class MindReportScreen extends StatefulWidget {
  const MindReportScreen({super.key});

  @override
  State<MindReportScreen> createState() => _MindReportScreenState();
}

class _MindReportScreenState extends State<MindReportScreen> {
  final _memoController = TextEditingController();
  MindReportArgs? _args;
  bool _saving = false;
  String _originalMemo = '';

  @override
  void initState() {
    super.initState();
    // 메모가 바뀌면 버튼(닫기↔저장)이 갱신되도록 리스닝.
    _memoController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null) {
      _args = ModalRoute.of(context)?.settings.arguments as MindReportArgs?;
      _originalMemo = _args?.report.memo ?? '';
      _memoController.text = _originalMemo;
    }
  }

  bool get _memoChanged => _memoController.text.trim() != _originalMemo.trim();

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  MindReport? get _report => _args?.report;
  bool get _isNew => _args?.isNew ?? false;

  /// 새 리포트: 저장 → 영속화 + 대화 비움 + 리포트 탭으로.
  /// 기존 조회: 메모를 바꿨으면 저장, 아니면 그냥 닫기.
  Future<void> _onSave() async {
    if (_saving) return;
    // 새 리포트(대화 종료 직후) — 항상 저장.
    if (_isNew && _report != null) {
      setState(() => _saving = true);
      final saved = _report!.copyWith(memo: _memoController.text.trim());
      await ReportStore.instance.add(saved);
      final persona = _args?.persona;
      if (persona != null) await ConversationStore.instance.clear(persona);
      if (!mounted) return;
      ShellNav.instance.goTo(ShellNav.reportTab);
      Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }
    // 기존 리포트 — 메모 변경분만 저장.
    if (_report != null && _memoChanged) {
      await ReportStore.instance
          .updateMemo(_report!, _memoController.text.trim());
    }
    if (mounted) Navigator.of(context).pop();
  }

  /// 버튼 라벨: 새 리포트는 '리포트 저장', 기존은 변경 시 '저장' 아니면 '닫기'.
  String get _saveLabel {
    if (_isNew) return '리포트 저장';
    return _memoChanged ? '저장' : '닫기';
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    final emotions = report?.emotions ?? const ['서운함', '불안', '안도'];
    final summary = report?.summary ??
        '대화 내용 요약 대화 내용 요약\n대화 내용 요약 대화 내용 요약';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppGaps.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppGaps.v8,
              const BackHeader(title: '마음 리포트'),
              if ((report?.createdAt ?? '').isNotEmpty) ...[
                AppGaps.v8,
                Text(_prettyDate(report!.createdAt),
                    style: AppTextStyles.caption),
              ],
              AppGaps.v24,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('오늘 느낀 감정', style: AppTextStyles.label),
                      AppGaps.v12,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < emotions.length; i++)
                            _emotionBadge(emotions[i], i),
                        ],
                      ),
                      AppGaps.v16,
                      AppCard(
                        color: AppColors.inputFill,
                        padding: const EdgeInsets.all(20),
                        child: Text(summary,
                            style: AppTextStyles.body.copyWith(height: 1.5)),
                      ),
                      // AI 제안 섹션(값이 있을 때만).
                      _section('💛 지금 필요한 것', report?.needNow),
                      _section('🌱 작은 행동 제안', report?.smallAction),
                      _section('🎯 추천 미션', report?.mission),
                      _caution(report?.caution ?? MindReport.kDefaultCaution),
                      AppGaps.v24,
                      const Text('나는 오늘 이런 하루였어',
                          style: AppTextStyles.label),
                      AppGaps.v12,
                      LabeledTextField(
                        hint: '간단하게 작성해보세요 (선택)',
                        controller: _memoController,
                        maxLines: 3,
                      ),
                      AppGaps.v24,
                      PrimaryButton(
                        label: _saveLabel,
                        onPressed: _saving ? null : _onSave,
                      ),
                      AppGaps.v36,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// createdAt('2026-07-22 13:05')을 '2026년 7월 22일 13:05'로 표시.
  /// 형식이 예상과 다르면 원본을 그대로 보여준다.
  String _prettyDate(String raw) {
    final dt = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (dt == null) return raw;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}년 ${dt.month}월 ${dt.day}일 $hh:$mm';
  }

  /// 제목 + 내용 섹션(내용이 있을 때만 렌더).
  Widget _section(String title, String? body) {
    if (body == null || body.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label),
          AppGaps.v8,
          Text(body, style: AppTextStyles.body.copyWith(height: 1.4)),
        ],
      ),
    );
  }

  /// 주의 문구(의료행위 오인 방지).
  Widget _caution(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline, size: 16, color: AppColors.textHint),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: AppTextStyles.caption.copyWith(height: 1.4)),
          ),
        ],
      ),
    );
  }

  // 감정 뱃지 색을 다양하게 순환.
  static const _badgePalette = [
    (AppColors.emotionOrangeBg, AppColors.emotionOrangeText),
    (AppColors.badgePinkBg, AppColors.badgePinkText),
    (AppColors.emotionGreenBg, AppColors.emotionGreenText),
    (AppColors.emotionBlueBg, AppColors.emotionBlueText),
    (AppColors.emotionPurpleBg, AppColors.emotionPurpleText),
  ];

  Widget _emotionBadge(String text, int index) {
    final (bg, fg) = _badgePalette[index % _badgePalette.length];
    return AppBadge(text: text, background: bg, foreground: fg);
  }
}
