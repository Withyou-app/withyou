import 'package:flutter/material.dart';
import '../../models/gift_v2.dart';

/// 선물 받기 모달 (Figma: iPhone 14 & 15 Pro - 90 / 817:1784).
///
/// 채팅 위에 어둡게 깔리는 오버레이 + 흰 카드(상품 사진/이름/설명/"선물 받기")
/// + 카드 아래 원형 닫기(X) 버튼.
///
/// 실제 사용: 선물을 받았을 때 `showGiftReceivedModal(context)` 로 띄운다.
/// 상품 사진은 미제공이라 placeholder 박스로 비운다. (asset 채우면 교체)
Future<void> showGiftReceivedModal(
  BuildContext context, {
  GiftV2? gift,
  VoidCallback? onReceive,
}) {
  final g = gift ?? kGiftsV2.first;
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '선물 받기',
    barrierColor: const Color(0x73000000), // 어두운 오버레이
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) => _GiftReceivedModal(
      name: g.name,
      desc: g.desc,
      imageAsset: g.asset,
      onReceive: onReceive,
    ),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: child,
    ),
  );
}

class _GiftReceivedModal extends StatelessWidget {
  const _GiftReceivedModal({
    required this.name,
    required this.desc,
    required this.imageAsset,
    required this.onReceive,
  });
  final String name;
  final String desc;
  final String? imageAsset;
  final VoidCallback? onReceive;

  static const _brown = Color(0xFF90796A);
  static const _main = Color(0xFFFF8E88);
  static const _gray = Color(0xFFC4A4A4);

  @override
  Widget build(BuildContext context) {
    final img = imageAsset;
    return Material(
      type: MaterialType.transparency,
      child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 카드
          Container(
            width: 353,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 상품 사진 (placeholder)
                Container(
                  width: double.infinity,
                  height: 231,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: img == null
                      ? _imgPlaceholder(name)
                      : Image.asset(
                          img,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgPlaceholder(name),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 24,
                    color: _brown,
                    fontWeight: FontWeight.w700,
                    fontVariations: [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 13,
                    color: _gray,
                    fontWeight: FontWeight.w600,
                    fontVariations: [FontVariation('wght', 600)],
                  ),
                ),
                const SizedBox(height: 18),
                // 선물 받기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Material(
                    color: _main,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onReceive ?? () => Navigator.of(context).pop(),
                      child: const Center(
                        child: Text(
                          '선물 받기',
                          style: TextStyle(
                            fontFamily: 'HumanBeomseokNeo',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontVariations: [FontVariation('wght', 700)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          // 닫기(X)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.close, size: 30, color: _gray),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// 상품 사진이 아직 없을 때 상품명을 보여주는 placeholder.
Widget _imgPlaceholder(String label) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_outlined, size: 34, color: Color(0xFFD4BBA9)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'HumanBeomseokNeo',
                fontSize: 13,
                color: Color(0xFFBBA089),
                fontWeight: FontWeight.w700,
                fontVariations: [FontVariation('wght', 700)],
              ),
            ),
          ),
        ],
      ),
    );
