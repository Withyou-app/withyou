import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/v2_bottom_nav.dart';

/// v2 선물(기프트 스토어) 화면 (Figma: iPhone 14 & 15 Pro - 81 / 740:652).
///
/// 제목 "선물" + 보유 크레딧 배지 + 상품 카드 목록(이미지/이름/설명/필요 크레딧
/// + 수량 스테퍼) + 하단 탭(선물).
///
/// 상품 사진은 아직 미제공이므로 이미지 자리는 "상품 사진" placeholder 박스로
/// 비워둔다. (asset 경로가 채워지면 해당 이미지를 표시)
class GiftV2Screen extends StatefulWidget {
  const GiftV2Screen({super.key});

  @override
  State<GiftV2Screen> createState() => _GiftV2ScreenState();
}

class _GiftV2ScreenState extends State<GiftV2Screen> {
  static const _bg = Color(0xFFFFF9F2);
  static const _brown = Color(0xFF90796A);
  static const _point = Color(0xFFFFCD8C);
  static const _main = Color(0xFFFF8E88);
  static const _creditBg = Color(0xFFFCD7D7);

  // 보유 크레딧 (스펙상 Credit 소유주는 기업, 여기선 표시값만 임시).
  static const _ownedCredit = 16;

  // 실제 상품 목록(사용자 제공 링크). 사진은 assets/gifts/<파일명> 에 넣으면
  // 자동 표시, 없으면 상품명 placeholder 박스가 뜬다.
  // 카드엔 감성 한 줄(tagline)을 노출, 상세 설명(desc)은 구매/상세에서 사용.
  // ※ 핫초코 링크 미확보(기존 product_no=60 은 초콜릿이었음) — 링크 필요.
  static const _products = [
    _Product(
      name: '핫초코',
      credit: 9,
      tagline: '오늘 달콤한 한잔의 여유는 어떨까요?',
      desc: '뜨거운 물이나 우유에 타서 마시는 스틱형 핫초코예요.',
      asset: 'assets/gifts/hotchoco.png',
      url: '', // TODO: 핫초코 실제 구매 링크 필요
    ),
    _Product(
      name: '디카페인 티백',
      credit: 9,
      tagline: '은은한 향과 함께 짐들을 잠시 내려놓아볼까요?',
      desc: '카페인 없이 우려 마시는 캐모마일 허브차 티백이에요.',
      asset: 'assets/gifts/decaf_tea.png',
      url: 'https://www.imarket.co.kr/p/FD0906',
    ),
    _Product(
      name: '드립백 커피',
      credit: 10,
      tagline: '커피한잔의 여유를 보내봐요',
      desc: '컵에 걸고 뜨거운 물을 부어 내리는 드립백 커피예요.',
      asset: 'assets/gifts/dripbag_coffee.png',
      url: 'https://www.somesomemilmil.com/shop_view/?idx=118',
    ),
    _Product(
      name: '쿠키',
      credit: 4,
      tagline: '바삭한 한입과 함께 잠시 쉬어가요',
      desc: '캐러멜과 시나몬 풍미의 바삭한 로투스 비스코프예요.',
      asset: 'assets/gifts/cookie.png',
      url: 'https://www.ssg.com/item/itemView.ssg?itemId=1000529666055',
    ),
    _Product(
      name: '초콜릿',
      credit: 3,
      tagline: '열심히 한 하루에 달콤한 선물',
      desc: '부드러운 우유 맛의 가나 마일드 초콜릿이에요.',
      asset: 'assets/gifts/chocolate.png',
      url: 'https://m.lottesweetmall.com/product/%EA%B0%80%EB%82%98-%EB%A7%88%EC%9D%BC%EB%93%9C-34g/60/category/77/display/1/',
    ),
    _Product(
      name: '견과류',
      credit: 12,
      tagline: '바쁜 하루에도 날 챙기는 루틴',
      desc: '견과류와 건포도를 한 봉씩 담은 하루견과예요.',
      asset: 'assets/gifts/nuts.png',
      url: 'https://m.nutsholic.co.kr/product/오리지널/907/',
    ),
    _Product(
      name: '메모지',
      credit: 5,
      tagline: '당신의 시선에서 언제든 기억될 수 있게',
      desc: '짧은 메모나 페이지 표시에 사용하는 메모지예요.',
      asset: 'assets/gifts/memo_pad.png',
      url: 'https://www.alpha.co.kr/product/productView.do?productCode=2192434',
    ),
    _Product(
      name: '키링',
      credit: 5,
      tagline: '평범했던 하루를 작은 친구와 함께',
      desc: '가방이나 열쇠에 달아 사용하는 아크릴 키링이에요.',
      asset: 'assets/gifts/keyring.png',
      url: 'https://www.10x10.co.kr/shopping/category_prd.asp?itemid=5076674',
    ),
    _Product(
      name: '손목 보호대',
      credit: 6,
      tagline: '오늘도 고생 많았어요',
      desc: '손목을 감싸 보호하는 손목보호대예요.',
      asset: 'assets/gifts/wrist_guard.png',
      url: 'https://gglindaclip.cafe24.com/m/product/detail.html?product_no=22',
    ),
    _Product(
      name: '핫팩',
      credit: 4,
      tagline: '추운 출근길, 작은 온기를 챙겨가요',
      desc: '주머니에 넣어 손을 데우는 미니 일회용 핫팩이에요.',
      asset: 'assets/gifts/hot_pack.png',
      url: 'https://www.designever.co.kr/goods/goods_view.php?goodsNo=1210755011',
    ),
  ];

  // 상품별 선택 수량.
  late final List<int> _qty = List<int>.filled(_products.length, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 제목 + 보유 크레딧 배지
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '선물',
                    style: TextStyle(
                      fontFamily: 'HumanBeomseokNeo',
                      fontSize: 28,
                      color: _brown,
                      fontWeight: FontWeight.w700,
                      fontVariations: [FontVariation('wght', 700)],
                    ),
                  ),
                  _CreditBadge(_ownedCredit),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                itemCount: _products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.giftPurchaseV2),
                  child: _ProductCard(
                    product: _products[i],
                    qty: _qty[i],
                    onMinus: () => setState(() {
                      if (_qty[i] > 1) _qty[i]--;
                    }),
                    onPlus: () => setState(() => _qty[i]++),
                  ),
                ),
              ),
            ),
            V2BottomNav(
              current: 3,
              onTap: (i) {
                switch (i) {
                  case 0:
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.homeV2, (r) => false);
                    break;
                  case 1:
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.chatListV2);
                    break;
                  case 2:
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.reportListV2);
                    break;
                  case 4:
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.mypageV2);
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 보유 크레딧 배지: "보유 크레딧" 라벨 + 코인 + 수치.
class _CreditBadge extends StatelessWidget {
  const _CreditBadge(this.amount);
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _GiftV2ScreenState._creditBg,
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
              size: 20, color: _GiftV2ScreenState._point),
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

class _Product {
  const _Product({
    required this.name,
    required this.credit,
    required this.tagline,
    required this.desc,
    required this.asset,
    required this.url,
  });
  final String name;
  final int credit;
  final String tagline; // 카드에 노출하는 감성 한 줄
  final String desc; // 상품 설명(구매/상세용)
  final String asset; // assets/gifts/<파일>.png (없으면 placeholder)
  final String url; // 상품 상세/구매 링크
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });
  final _Product product;
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  String get _priceText => '${product.credit.toString().replaceAllMapped(
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지 (placeholder)
          _ProductImage(asset: product.asset, label: product.name),
          const SizedBox(width: 14),
          // 텍스트 + 스테퍼
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 18,
                    color: _GiftV2ScreenState._brown,
                    fontWeight: FontWeight.w700,
                    fontVariations: [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.tagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'HumanBeomseokNeo',
                    fontSize: 12,
                    height: 1.3,
                    color: Color(0xFFC4A4A4),
                    fontWeight: FontWeight.w600,
                    fontVariations: [FontVariation('wght', 600)],
                  ),
                ),
                const SizedBox(height: 10),
                // 필요 크레딧
                Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        size: 22, color: _GiftV2ScreenState._point),
                    const SizedBox(width: 5),
                    Text(
                      _priceText,
                      style: const TextStyle(
                        fontFamily: 'HumanBeomseokNeo',
                        fontSize: 20,
                        color: _GiftV2ScreenState._main,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // 수량 스테퍼
                Align(
                  alignment: Alignment.centerRight,
                  child: _QtyStepper(qty: qty, onMinus: onMinus, onPlus: onPlus),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 상품 사진 (148×148). asset(assets/gifts/<파일>.png) 이 있으면 이미지,
/// 아직 없으면 상품명 placeholder 박스. → 해당 경로에 사진을 넣으면 자동 표시.
class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.asset, required this.label});
  final String asset;
  final String label;

  Widget _placeholder() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_outlined, size: 28, color: Color(0xFFD4BBA9)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label,
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
      );

  @override
  Widget build(BuildContext context) {
    return Container(
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
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper(
      {required this.qty, required this.onMinus, required this.onPlus});
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              color: _GiftV2ScreenState._brown,
              fontWeight: FontWeight.w700,
              fontVariations: [FontVariation('wght', 700)],
            ),
          ),
        ),
        _StepButton(icon: Icons.add, onTap: onPlus),
      ],
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
          color: _GiftV2ScreenState._main,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
