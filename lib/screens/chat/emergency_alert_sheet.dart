import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// 긴급 알림(위험 감지) 바텀시트를 띄운다.
void showEmergencyAlert(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
    ),
    builder: (ctx) => const _EmergencyAlertContent(),
  );
}

class _EmergencyAlertContent extends StatelessWidget {
  const _EmergencyAlertContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppGaps.screenH, AppGaps.md, AppGaps.screenH, AppGaps.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ),
            AppGaps.v8,
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                color: AppColors.white,
                size: 44,
              ),
            ),
            AppGaps.v24,
            const Text('위험 감지', style: AppTextStyles.title),
            AppGaps.v8,
            const Text(
              '위험한 대화의 흐름을 느꼈습니다',
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            AppGaps.v24,
            _phoneCard('자살예방상담전화: 1233-9558'),
            AppGaps.v12,
            _phoneCard('청소년전화: 1233-9558'),
            AppGaps.v12,
            _phoneCard('119: 1233-9558'),
          ],
        ),
      ),
    );
  }

  Widget _phoneCard(String text) {
    return AppCard(
      color: AppColors.inputFill,
      child: Text(text, style: AppTextStyles.body),
    );
  }
}
