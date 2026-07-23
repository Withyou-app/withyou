import 'package:flutter/material.dart';
import '../../models/gift.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme.dart';

/// 선물 메인 — 탭 화면. 추천 선물 목록에서 고르면 상세로 이동한다.
class GiftMainScreen extends StatelessWidget {
  const GiftMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppGaps.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppGaps.v16,
              // 상단: '받은 선물' 진입
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.receivedGifts),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.redeem,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('받은 선물',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
              AppGaps.v24,
              const Text('추천하는 선물들이에요', style: AppTextStyles.title),
              AppGaps.v20,
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: kGifts.length,
                  separatorBuilder: (_, _) => AppGaps.v20,
                  itemBuilder: (context, i) => _giftRow(context, kGifts[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _giftRow(BuildContext context, Gift gift) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pushNamed(context, AppRoutes.giftDetail,
          arguments: gift),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Container(
              width: 90,
              height: 72,
              color: AppColors.inputFill,
              child: Image.asset(gift.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gift.name, style: AppTextStyles.cardTitle),
                const SizedBox(height: 6),
                Text(
                  gift.desc1,
                  maxLines: 2,
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
}
