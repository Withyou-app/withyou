import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// 긴급 안전 안내(위험 감지) 바텀시트. (안전장치 설계 §2·§3)
///
/// High 위험이 감지되면 자동으로, 또는 사용자가 직접 띄운다.
/// 사용자가 긴급기관에 연락하거나 화면을 벗어나는 것을 막지 않는다.
void showEmergencyAlert(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    barrierColor: AppColors.scrim,
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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppGaps.screenH, AppGaps.sm, AppGaps.screenH, AppGaps.lg),
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
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active,
                    color: AppColors.white, size: 42),
              ),
              AppGaps.v20,
              const Text('잠깐, 지금 당신이 가장 소중해요',
                  style: AppTextStyles.title, textAlign: TextAlign.center),
              AppGaps.v8,
              const Text(
                '많이 힘든 마음이 느껴졌어요.\n혼자 견디지 말고 아래 도움을 받아보세요.',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              AppGaps.v20,
              // 안전 안내(§2)
              _guide('지금 안전한 곳에 있는지 확인해요'),
              _guide('혼자라면 곁에 있는 가족·친구·선생님 등 믿을 수 있는 사람에게 알려요'),
              _guide('즉각적인 위험이 있다면 바로 긴급 기관에 연락해요'),
              AppGaps.v20,
              // 긴급 지원 기관(§2)
              _phoneCard('자살예방 상담전화', '109'),
              AppGaps.v12,
              _phoneCard('청소년 상담전화', '1388'),
              AppGaps.v12,
              _phoneCard('경찰', '112'),
              AppGaps.v12,
              _phoneCard('소방·응급', '119'),
              AppGaps.v20,
              const Text(
                'withyou+는 정서 지원 서비스로, 전문 상담이나 의료를 대체하지 않아요.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _guide(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.check_circle, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }

  /// 탭하면 전화 앱으로 해당 번호를 건다.
  Widget _phoneCard(String label, String number) {
    return InkWell(
      onTap: () => _dial(number),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: AppCard(
        color: AppColors.inputFill,
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.body)),
            Text(
              number,
              style: const TextStyle(
                fontFamily: AppFonts.cocochoitoon,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.call, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _dial(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
