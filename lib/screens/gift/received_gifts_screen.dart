import 'package:flutter/material.dart';
import '../../models/gift.dart';
import '../../services/received_gift_store.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// 받은 선물 — 사용자가 '선물 받기'로 받은 선물들을 모아 보여준다.
class ReceivedGiftsScreen extends StatelessWidget {
  const ReceivedGiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppGaps.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppGaps.v8,
              const BackHeader(title: '받은 선물'),
              AppGaps.v20,
              Expanded(
                child: AnimatedBuilder(
                  animation: ReceivedGiftStore.instance,
                  builder: (context, _) {
                    final items = ReceivedGiftStore.instance.items;
                    if (items.isEmpty) return _empty();
                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final gift = giftById(items[i].giftId);
                        if (gift == null) return const SizedBox.shrink();
                        return _giftTile(gift, items[i].receivedAt);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Text('아직 받은 선물이 없어요\n선물 상세에서 마음에 드는 선물을 받아보세요',
          textAlign: TextAlign.center, style: AppTextStyles.body),
    );
  }

  Widget _giftTile(Gift gift, String receivedAt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Container(
              color: AppColors.inputFill,
              width: double.infinity,
              child: Image.asset(gift.image, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(gift.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle),
        const SizedBox(height: 2),
        Text(receivedAt, style: AppTextStyles.caption),
      ],
    );
  }
}
