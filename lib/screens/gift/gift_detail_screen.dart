import 'package:flutter/material.dart';
import '../../models/gift.dart';
import '../../services/received_gift_store.dart';
import '../../services/shell_nav.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// 선물 상세 — 시안(선물 상세)과 동일 구성. 이미지 + 제목 + 2줄 설명 +
/// 구성/배송 카드 + 금액 + [이번엔 넘어가기]/[선물 받기] + 하단 네비.
///
/// 진입: 채팅의 페르소나 추천 칩, 또는 선물 탭 목록에서 선택.
/// 라우트 인자로 [Gift] 를 전달받는다.
class GiftDetailScreen extends StatelessWidget {
  const GiftDetailScreen({super.key, this.gift});

  final Gift? gift;

  void _leaveToTab(BuildContext context, int index) {
    ShellNav.instance.goTo(index);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _receive(BuildContext context, Gift g) async {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    await ReceivedGiftStore.instance
        .add(g.id, '${now.year}-${two(now.month)}-${two(now.day)}');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${g.name} 선물을 받았어요! "받은 선물"에서 볼 수 있어요')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final g = gift ??
        (ModalRoute.of(context)?.settings.arguments as Gift?) ??
        kGifts.first;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _image(g),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppGaps.screenH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppGaps.v24,
                        Text(g.name, style: AppTextStyles.title),
                        AppGaps.v12,
                        Text('${g.desc1}\n${g.desc2}',
                            style: AppTextStyles.subtitle
                                .copyWith(height: 1.5)),
                        AppGaps.v24,
                        _infoCard(g),
                        AppGaps.v24,
                        Row(
                          children: [
                            const Text('금액', style: AppTextStyles.label),
                            const Spacer(),
                            Text(
                              g.priceLabel,
                              style: const TextStyle(
                                fontFamily: AppFonts.cocochoitoon,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        AppGaps.v24,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 버튼 — '이번엔 넘어가기'와 '선물 받기'를 시각적으로 동등하게 배치.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppGaps.screenH, 0, AppGaps.screenH, AppGaps.md),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: '이번엔 넘어가기',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppGaps.sm),
                  Expanded(
                    child: PrimaryButton(
                      label: '선물 받기',
                      onPressed: () => _receive(context, g),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: ShellNav.giftTab,
        onTap: (i) => _leaveToTab(context, i),
      ),
    );
  }

  Widget _image(Gift g) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          color: AppColors.inputFill,
          child: Image.asset(g.image, fit: BoxFit.cover),
        ),
        // 뒤로가기(상세 → 이전)
        Positioned(
          top: 8,
          left: 8,
          child: Builder(
            builder: (context) => Material(
              color: AppColors.background,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).maybePop(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.chevron_left,
                      size: 26, color: AppColors.textPrimary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(Gift g) {
    return AppCard(
      color: AppColors.inputFill,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _row('구성', g.composition),
          AppGaps.v16,
          _row('배송', '입금 확인 후 2~3일 내 발송'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.body),
        const SizedBox(width: 16),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.right, style: AppTextStyles.body),
        ),
      ],
    );
  }
}
