import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_gaps.dart';

/// 두 개 이상의 선택지를 나란히 두는 토글. (예: 반말 / 존댓말)
/// 선택 상태는 내부에서 관리하며, 선택 시 [onChanged] 콜백을 호출한다.
class SegmentedToggle extends StatefulWidget {
  const SegmentedToggle({
    super.key,
    required this.options,
    this.initialIndex,
    this.onChanged,
  });

  final List<String> options;
  final int? initialIndex;
  final ValueChanged<int>? onChanged;

  @override
  State<SegmentedToggle> createState() => _SegmentedToggleState();
}

class _SegmentedToggleState extends State<SegmentedToggle> {
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < widget.options.length; i++) ...[
          if (i > 0) const SizedBox(width: AppGaps.md),
          Expanded(child: _segment(i)),
        ],
      ],
    );
  }

  Widget _segment(int i) {
    final selected = _selected == i;
    return GestureDetector(
      onTap: () {
        setState(() => _selected = i);
        widget.onChanged?.call(i);
      },
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.muted,
          borderRadius: BorderRadius.circular(AppRadii.field),
        ),
        child: Text(
          widget.options[i],
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
