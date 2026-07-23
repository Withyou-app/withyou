import 'package:flutter/material.dart';
import '../theme/app_gaps.dart';

/// 입력 폼 표준 레이아웃.
///
/// 키보드가 올라오면 포커스된 입력 필드가 그 위로 자동 스크롤되도록
/// 필드 영역을 스크롤 가능하게 감싼다. 상단 [header] 는 고정, 하단 [action]
/// (주로 버튼)은 키보드 바로 위에 고정된다. 좌우 화면 패딩을 일관되게 적용한다.
class KeyboardAwareForm extends StatelessWidget {
  const KeyboardAwareForm({
    super.key,
    this.header,
    this.headerGap = AppGaps.v24,
    required this.children,
    this.action,
  });

  /// 상단 고정 영역(예: BackHeader).
  final Widget? header;

  /// header 와 필드 사이 간격.
  final Widget headerGap;

  /// 스크롤되는 입력 필드들.
  final List<Widget> children;

  /// 하단 고정 액션(예: PrimaryButton).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppGaps.screenH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) ...[AppGaps.v8, header!, headerGap],
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
            if (action != null) ...[action!, AppGaps.v36],
          ],
        ),
      ),
    );
  }
}
