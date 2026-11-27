import 'package:flutter/material.dart';
import '../../models/gift_v2.dart';

/// v2 선물 구매(상세) 화면 (Figma: iPhone 14 & 15 Pro - 96 / 899:2042).
///
/// 뒤로 + "선물 구매" + 보유 크레딧 / 상품 카드(수량) / 배송지(주소 + 주소 변경)
/// / 구매 버튼.
///
/// 상품 사진은 미제공이라 placeholder 박스로 비운다. (asset 채우면 교체)
class GiftPurchaseV2Screen extends StatefulWidget {
  const GiftPurchaseV2Screen({super.key});

  @override
  State<GiftPurchaseV2Screen> createState() => _GiftPurchaseV2ScreenState();
}

class _GiftPurchaseV2ScreenState extends State<GiftPurchaseV2Screen> {
  static const _bg = Color(0xFFFFF9F2);
  static const _brown = Color(0xFF90796A);
  static const _main = Color(0xFFFF8E88);
  static const _point = Color(0xFFFFCD8C);
  static const _gray = Color(0xFFC4A4A4);
  static const _noread = Color(0xFFCBC0B4);
  static const _creditBg = Color(0xFFFCD7D7);

  static const _ownedCredit = 16;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    // 선물 목록에서 넘어온 상품(없으면 첫 상품으로 폴백).
    final product =
        (ModalRoute.of(context)?.settings.arguments as GiftV2?) ??
            kGiftsV2.first;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더: 뒤로 + 선물 구매 + 보유 크레딧
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.chevron_left,
                        size: 32, color: _brown),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '선물 구매',
                    style: TextStyle(
                      fontFamily: 'HumanBeomseokNeo',
                      fontSize: 24,
                      color: _brown,
                      fontWeight: FontWeight.w700,
                      fontVariations: [FontVariation('wght', 700)],
                    ),
                  ),
                  const Spacer(),
                  _CreditBadge(_ownedCredit),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상품 카드
                    _ProductCard(
                      name: product.name,
                      desc: product.desc,
                      credit: product.credit,
                      asset: product.asset,
                      qty: _qty,
                      onMinus: () =>
                          setState(() => _qty > 1 ? _qty-- : null),
                      onPlus: () => setState(() => _qty++),
                    ),
                    const SizedBox(height: 32),
                    // 배송지
                    const Text(
                      '배송지',
                      style: TextStyle(
                        fontFamily: 'HumanBeomseokNeo',
                        fontSize: 18,
                        color: _brown,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _AddressCard(
                      label: '기본 주소지',
                      address: '대전광역시 유성구 가정북로 76',
                      building: '| 대덕소프트웨어마이스터고등학교',
                      onChange: () {},
                    ),
                  ],
                ),
              ),
            ),
            // 구매 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: Material(
                  color: _main,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: const Center(
                      child: Text(
                        '구매하기',
                        style: TextStyle(
                          fontFamily: 'HumanBeomseokNeo',
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontVariations: [FontVariation('wght', 700)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditBadge extends StatelessWidget {
  const _CreditBadge(this.amount);
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _GiftPurchaseV2ScreenState._creditBg,
        borderRadius: BorderRadius.circular(200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '보유 크레딧',
            style: TextStyle(
              fontFamily: 'HumanBeomseokNeo',
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontVariations: [FontVariation('wght', 700)],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.monetization_on,
              size: 20, color: _GiftPurchaseV2ScreenState._point),
          const SizedBox(width: 4),
          Text(
            '$amount',
            style: const TextStyle(
              fontFamily: 'HumanBeomseokNeo',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontVariations: [FontVariation('wght', 700)],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.name,
    required this.desc,
    required this.credit,
    required this.asset,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });
  final String name;
  final String desc;
  final int credit;
  final String asset;
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  String get _priceText => '${credit.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      )} 크레딧';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지 (asset 있으면 표시, 없으면 상품명 placeholder)
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFE7),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image_outlined,
                        size: 30, color: Color(0xFFD4BBA9)),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'HumanBeomseokNeo',
                          fontSize: 12,
                          color: Color(0xFFBBA089),
                          fontWeight: FontWeight.w700,
                          fontVariations: [FontVariation('wght', 700)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 18,
                    color: _GiftPurchaseV2ScreenState._brown,
                    fontWeight: FontWeight.w700,
                    fontVariations: [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 12,
                    color: _GiftPurchaseV2ScreenState._gray,
                    fontWeight: FontWeight.w600,
                    fontVariations: [FontVariation('wght', 600)],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        size: 22, color: _GiftPurchaseV2ScreenState._point),
                    const SizedBox(width: 5),
                    Text(
                      _priceText,
                      style: const TextStyle(
                        fontFamily: 'HumanBeomseokNeo',
                        fontSize: 20,
                        color: _GiftPurchaseV2ScreenState._main,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepButton(icon: Icons.remove, onTap: onMinus),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '$qty',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'HumanBeomseokNeo',
                            fontSize: 18,
                            color: _GiftPurchaseV2ScreenState._brown,
                            fontWeight: FontWeight.w700,
                            fontVariations: [FontVariation('wght', 700)],
                          ),
                        ),
                      ),
                      _StepButton(icon: Icons.add, onTap: onPlus),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: _GiftPurchaseV2ScreenState._main,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.label,
    required this.address,
    required this.building,
    required this.onChange,
  });
  final String label;
  final String address;
  final String building;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 14,
                    color: _GiftPurchaseV2ScreenState._brown,
                    fontWeight: FontWeight.w700,
                    fontVariations: [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  address,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 13,
                    color: _GiftPurchaseV2ScreenState._gray,
                    fontWeight: FontWeight.w600,
                    fontVariations: [FontVariation('wght', 600)],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  building,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 12,
                    color: _GiftPurchaseV2ScreenState._noread,
                    fontWeight: FontWeight.w600,
                    fontVariations: [FontVariation('wght', 600)],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onChange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: _GiftPurchaseV2ScreenState._noread),
              ),
              child: const Text(
                '주소 변경',
                style: TextStyle(
                  fontFamily: 'HumanBeomseokNeo',
                  fontSize: 12,
                  color: _GiftPurchaseV2ScreenState._brown,
                  fontWeight: FontWeight.w700,
                  fontVariations: [FontVariation('wght', 700)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
