import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

/// 최근 대화 삭제 확인 모달. 삭제 시 true, 취소 시 false 를 반환.
Future<bool?> showDeleteConversationDialog(BuildContext context) {
  return ConfirmDialog.show(
    context,
    title: '정말 대화를 삭제하시겠습니까?',
    message: '다시는 복구할 수 없어요.',
    cancelLabel: '취소',
    confirmLabel: '삭제',
  );
}
