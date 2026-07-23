import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// 선물 메인 — 탭 화면. 하단 네비는 상위 셸이 담당하므로 넣지 않는다.
/// [completed] 로 진행 중(선물 메인1)/완료(선물 메인2) 두 상태를 지원.
class GiftMainScreen extends StatelessWidget {
  const GiftMainScreen({super.key, this.completed = false});

  final bool completed;

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
              if (completed) ...[
                Row(
                  children: const [
                    Expanded(
                      child:
                          Text('선물을 받으러 가실까요?', style: AppTextStyles.title),
                    ),
                    Icon(Icons.arrow_forward, color: AppColors.primary),
                  ],
                ),
                AppGaps.v20,
                const AppProgressBar(value: 1.0),
                AppGaps.v8,
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('14/14', style: AppTextStyles.caption),
                ),
              ] else ...[
                const Text('선물까지 이정도 남았어요!',
                    style: AppTextStyles.title),
                AppGaps.v20,
                const AppProgressBar(value: 2 / 14),
                AppGaps.v8,
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('2/14', style: AppTextStyles.caption),
                ),
              ],
              AppGaps.v36,
              const Text('추천하는 선물들이에요', style: AppTextStyles.title),
              AppGaps.v20,
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: 4,
                  separatorBuilder: (context, index) => AppGaps.v20,
                  itemBuilder: (context, index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 90,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius:
                                BorderRadius.circular(AppRadii.card),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('추천 제품 이름',
                                  style: AppTextStyles.cardTitle),
                              SizedBox(height: 6),
                              Text('제품 설명 제품 설명 제품 설명',
                                  style: AppTextStyles.cardBody),
                            ],
                          ),
                        ),
                      ],
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
}
