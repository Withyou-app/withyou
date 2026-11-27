/// v2 선물 카탈로그 단일 소스.
///
/// 선물 목록(81)·구매(96)·받기 모달(90) 화면과 AI 추천(ai_prompts)이 모두
/// 이 목록을 참조한다. (백엔드 `products` 테이블 시드와 slug/값이 일치)
///
/// 사진은 `assets/gifts/<slug>.png` 에 넣으면 자동 표시, 없으면 상품명 placeholder.
/// credit 값은 사용자 제공 확정값. url 은 구매/상세 링크.
class GiftV2 {
  const GiftV2({
    required this.slug,
    required this.name,
    required this.credit,
    required this.tagline,
    required this.desc,
    required this.asset,
    required this.url,
  });

  final String slug;
  final String name;
  final int credit;
  final String tagline; // 카드 노출 감성 한 줄
  final String desc; // 상세 설명(구매/상세용)
  final String asset; // assets/gifts/<slug>.png
  final String url; // 구매/상세 링크

  String get creditLabel => '${_comma(credit)} 크레딧';

  static String _comma(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

/// 앱 v2 선물 카탈로그 (초콜릿 포함, 핫초코 url 은 링크 확보 후 채움).
const List<GiftV2> kGiftsV2 = [
  GiftV2(
    slug: 'hotchoco',
    name: '핫초코',
    credit: 9,
    tagline: '오늘 달콤한 한잔의 여유는 어떨까요?',
    desc: '뜨거운 물이나 우유에 타서 마시는 스틱형 핫초코예요.',
    asset: 'assets/gifts/hotchoco.png',
    url: '', // TODO: 핫초코 실제 구매 링크
  ),
  GiftV2(
    slug: 'decaf_tea',
    name: '디카페인 티백',
    credit: 9,
    tagline: '은은한 향과 함께 짐들을 잠시 내려놓아볼까요?',
    desc: '카페인 없이 우려 마시는 캐모마일 허브차 티백이에요.',
    asset: 'assets/gifts/decaf_tea.png',
    url: 'https://www.imarket.co.kr/p/FD0906',
  ),
  GiftV2(
    slug: 'dripbag_coffee',
    name: '드립백 커피',
    credit: 10,
    tagline: '커피한잔의 여유를 보내봐요',
    desc: '컵에 걸고 뜨거운 물을 부어 내리는 드립백 커피예요.',
    asset: 'assets/gifts/dripbag_coffee.png',
    url: 'https://www.somesomemilmil.com/shop_view/?idx=118',
  ),
  GiftV2(
    slug: 'cookie',
    name: '쿠키',
    credit: 4,
    tagline: '바삭한 한입과 함께 잠시 쉬어가요',
    desc: '캐러멜과 시나몬 풍미의 바삭한 로투스 비스코프예요.',
    asset: 'assets/gifts/cookie.png',
    url: 'https://www.ssg.com/item/itemView.ssg?itemId=1000529666055',
  ),
  GiftV2(
    slug: 'chocolate',
    name: '초콜릿',
    credit: 3,
    tagline: '열심히 한 하루에 달콤한 선물',
    desc: '부드러운 우유 맛의 가나 마일드 초콜릿이에요.',
    asset: 'assets/gifts/chocolate.png',
    url: 'https://m.lottesweetmall.com/product/%EA%B0%80%EB%82%98-%EB%A7%88%EC%9D%BC%EB%93%9C-34g/60/category/77/display/1/',
  ),
  GiftV2(
    slug: 'nuts',
    name: '견과류',
    credit: 12,
    tagline: '바쁜 하루에도 날 챙기는 루틴',
    desc: '견과류와 건포도를 한 봉씩 담은 하루견과예요.',
    asset: 'assets/gifts/nuts.png',
    url: 'https://m.nutsholic.co.kr/product/오리지널/907/',
  ),
  GiftV2(
    slug: 'memo_pad',
    name: '메모지',
    credit: 5,
    tagline: '당신의 시선에서 언제든 기억될 수 있게',
    desc: '짧은 메모나 페이지 표시에 사용하는 메모지예요.',
    asset: 'assets/gifts/memo_pad.png',
    url: 'https://www.alpha.co.kr/product/productView.do?productCode=2192434',
  ),
  GiftV2(
    slug: 'keyring',
    name: '키링',
    credit: 5,
    tagline: '평범했던 하루를 작은 친구와 함께',
    desc: '가방이나 열쇠에 달아 사용하는 아크릴 키링이에요.',
    asset: 'assets/gifts/keyring.png',
    url: 'https://www.10x10.co.kr/shopping/category_prd.asp?itemid=5076674',
  ),
  GiftV2(
    slug: 'wrist_guard',
    name: '손목 보호대',
    credit: 6,
    tagline: '오늘도 고생 많았어요',
    desc: '손목을 감싸 보호하는 손목보호대예요.',
    asset: 'assets/gifts/wrist_guard.png',
    url: 'https://gglindaclip.cafe24.com/m/product/detail.html?product_no=22',
  ),
  GiftV2(
    slug: 'hot_pack',
    name: '핫팩',
    credit: 4,
    tagline: '추운 출근길, 작은 온기를 챙겨가요',
    desc: '주머니에 넣어 손을 데우는 미니 일회용 핫팩이에요.',
    asset: 'assets/gifts/hot_pack.png',
    url: 'https://www.designever.co.kr/goods/goods_view.php?goodsNo=1210755011',
  ),
];

/// AI 추천명(부분 일치) → 카탈로그 상품 매칭. 없으면 null.
GiftV2? giftV2ByName(String? name) {
  if (name == null || name.trim().isEmpty) return null;
  final q = name.trim().replaceAll(' ', '');
  for (final g in kGiftsV2) {
    final gc = g.name.replaceAll(' ', '');
    if (gc.contains(q) || q.contains(gc)) return g;
  }
  return null;
}

GiftV2? giftV2BySlug(String slug) {
  for (final g in kGiftsV2) {
    if (g.slug == slug) return g;
  }
  return null;
}
