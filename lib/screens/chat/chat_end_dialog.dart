import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

/// 대화 종료 확인 모달. 종료 시 true, 더 대화하기 시 false 를 반환.
Future<bool?> showChatEndDialog(BuildContext context) {
  return ConfirmDialog.show(
    context,
    title: '대화를 종료할까요?',
    message: '지금까지 나눈 대화로 리포트를 만들 수 있어요.',
    cancelLabel: '더 대화하기',
    confirmLabel: '종료하기',
  );
}
