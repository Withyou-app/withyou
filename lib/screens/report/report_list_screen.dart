import 'package:flutter/material.dart';
import '../../models/mind_report.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../services/report_store.dart';

/// 리포트 목록 — 탭 화면. 대화 종료로 저장된 마음 리포트들을 보여준다.
///
/// 최근 대화와 동일하게 삭제(휴지통) → 체크 다중 선택 → 삭제를 지원한다.
class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  bool _selectionMode = false;
  final Set<int> _selected = {};

  void _enterSelection() => setState(() {
        _selectionMode = true;
        _selected.clear();
      });

  void _cancelSelection() => setState(() {
        _selectionMode = false;
        _selected.clear();
      });

  void _toggle(int index) => setState(() {
        if (!_selected.add(index)) _selected.remove(index);
      });

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    final ok = await ConfirmDialog.show(
      context,
      title: '정말 리포트를 삭제하시겠습니까?',
      message: '다시는 복구할 수 없어요.',
      cancelLabel: '취소',
      confirmLabel: '삭제',
    );
    if (ok != true || !mounted) return;
    // 인덱스 큰 것부터 제거.
    final indexes = _selected.toList()..sort((a, b) => b.compareTo(a));
    for (final i in indexes) {
      await ReportStore.instance.removeAt(i);
    }
    setState(() {
      _selected.clear();
      _selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppGaps.screenH),
          child: AnimatedBuilder(
            animation: ReportStore.instance,
            builder: (context, _) {
              final reports = ReportStore.instance.reports;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppGaps.v16,
                  _header(reports.isNotEmpty),
                  AppGaps.v16,
                  Expanded(
                    child: reports.isEmpty
                        ? _empty()
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: reports.length,
                            separatorBuilder: (_, _) => AppGaps.v16,
                            itemBuilder: (context, i) =>
                                _reportCard(reports[i], i),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _header(bool hasItems) {
    return Row(
      children: [
        const Text('리포트', style: AppTextStyles.title),
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
      child: Text('아직 저장된 리포트가 없어요\n대화를 종료하면 마음 리포트가 만들어져요',
          textAlign: TextAlign.center, style: AppTextStyles.body),
    );
  }

  Widget _reportCard(MindReport report, int index) {
    final selected = _selected.contains(index);
    return AppCard(
      onTap: () {
        if (_selectionMode) {
          _toggle(index);
        } else {
          Navigator.pushNamed(context, AppRoutes.reportDetail,
              arguments: MindReportArgs(report: report));
        }
      },
      child: Row(
        children: [
          if (_selectionMode) ...[
            _checkCircle(selected),
            const SizedBox(width: AppGaps.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 6),
                Text(
                  report.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardBody,
                ),
                if (report.createdAt.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(report.createdAt, style: AppTextStyles.caption),
                ],
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
