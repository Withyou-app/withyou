/// 선물 상품 데이터. 화면에 하드코딩하지 않고 [kGifts] 카탈로그를 참조한다.
class Gift {
  const Gift({
    required this.id,
    required this.name,
    required this.image,
    required this.desc1,
    required this.desc2,
    required this.composition,
    required this.price,
  });

  final String id;
  final String name;
  final String image; // 에셋 경로
  final String desc1; // 설명 1줄
  final String desc2; // 설명 2줄
  final String composition; // 구성
  final int price; // 금액(원)

  /// '1,000원' 형태.
  String get priceLabel => '${_comma(price)}원';

  static String _comma(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// 앱의 선물 카탈로그(맞춤형 설명·금액). 배송은 전 상품 공통 안내.
const List<Gift> kGifts = [
  Gift(
    id: 'chupachups',
    name: '딸기 츄파춥스',
    image: 'assets/gifts/chupachups.jpg',
    desc1: '달달함이 필요한 순간을 위한 딸기맛 막대사탕이에요.',
    desc2: '뭐 힘든 일 있을 땐 당 충전이 필수죠!',
    composition: '딸기 츄파춥스 1개',
    price: 1000,
  ),
  Gift(
    id: 'cloud_cushion',
    name: '구름 쿠션',
    image: 'assets/gifts/cloud_cushion.jpg',
    desc1: '폭신한 구름을 안고 포근하게 쉬어가요.',
    desc2: '지친 마음을 부드럽게 받쳐줄 거예요.',
    composition: '구름 쿠션 1개',
    price: 24000,
  ),
  Gift(
    id: 'bouquet',
    name: '미니 꽃다발',
    image: 'assets/gifts/bouquet.jpg',
    desc1: '오늘 하루 고생한 당신에게 건네는 작은 꽃다발.',
    desc2: '향긋한 위로가 되어줄 거예요.',
    composition: '미니 꽃다발 1속',
    price: 18000,
  ),
  Gift(
    id: 'clover',
    name: '행운의 네잎클로버',
    image: 'assets/gifts/clover.jpeg',
    desc1: '당신에게 작은 행운이 찾아오길 바라요.',
    desc2: '마음속에 늘 품고 다니세요.',
    composition: '네잎클로버 압화 1개',
    price: 6500,
  ),
  Gift(
    id: 'star_candy',
    name: '별사탕',
    image: 'assets/gifts/star_candy.jpeg',
    desc1: '입안에서 반짝이는 작은 별들.',
    desc2: '반짝이는 기분을 선물할게요.',
    composition: '별사탕 1봉',
    price: 3500,
  ),
  Gift(
    id: 'bungeoppang',
    name: '붕어빵',
    image: 'assets/gifts/bungeoppang.jpg',
    desc1: '따끈따끈 갓 구운 붕어빵이에요.',
    desc2: '추운 마음까지 따뜻하게 데워줘요.',
    composition: '붕어빵 3마리',
    price: 3000,
  ),
  Gift(
    id: 'sleep_mask',
    name: '포근 수면안대',
    image: 'assets/gifts/sleep_mask.jpg',
    desc1: '눈을 감으면 스르륵, 깊은 잠으로.',
    desc2: '오늘 밤은 푹 쉬어가세요.',
    composition: '수면안대 1개',
    price: 12000,
  ),
  Gift(
    id: 'icecream',
    name: '아이스크림',
    image: 'assets/gifts/icecream.jpg',
    desc1: '달콤하고 시원한 한 스쿱.',
    desc2: '기분까지 사르르 녹여줄 거예요.',
    composition: '아이스크림 1컵',
    price: 4500,
  ),
  Gift(
    id: 'stamp',
    name: '감성 우표',
    image: 'assets/gifts/stamp.jpg',
    desc1: '마음을 담아 편지를 부쳐보세요.',
    desc2: '느리게 전하는 진심이 담겨요.',
    composition: '감성 우표 5매',
    price: 5000,
  ),
  Gift(
    id: 'marble',
    name: '유리구슬',
    image: 'assets/gifts/marble.jpg',
    desc1: '햇빛에 비추면 영롱하게 빛나요.',
    desc2: '맑은 마음을 담아 선물해요.',
    composition: '유리구슬 1개',
    price: 7000,
  ),
  Gift(
    id: 'bath_bomb',
    name: '라벤더 입욕제',
    image: 'assets/gifts/bath_bomb.jpeg',
    desc1: '따뜻한 물에 톡, 향긋하게 녹여보세요.',
    desc2: '하루의 피로를 부드럽게 풀어줘요.',
    composition: '라벤더 입욕제 2개',
    price: 9000,
  ),
  Gift(
    id: 'jelly',
    name: '말랑 젤리',
    image: 'assets/gifts/jelly.jpg',
    desc1: '쫄깃하고 달콤한 과일 젤리.',
    desc2: '심심한 입과 마음을 달래줘요.',
    composition: '과일 젤리 1봉',
    price: 3000,
  ),
  Gift(
    id: 'tea',
    name: '따뜻한 티백',
    image: 'assets/gifts/tea.png',
    desc1: '김이 모락모락 나는 따뜻한 차 한 잔.',
    desc2: '잠시 숨을 고르며 쉬어가요.',
    composition: '캐모마일 티백 10개',
    price: 8500,
  ),
  Gift(
    id: 'chocolate',
    name: '수제 초콜릿',
    image: 'assets/gifts/chocolate.jpeg',
    desc1: '진한 달콤함이 마음을 감싸요.',
    desc2: '지친 하루의 작은 보상이 되어줄게요.',
    composition: '수제 초콜릿 6구',
    price: 11000,
  ),
  Gift(
    id: 'cocoa',
    name: '따뜻한 코코아',
    image: 'assets/gifts/cocoa.jpg',
    desc1: '달콤하고 진한 코코아 한 잔.',
    desc2: '몸도 마음도 사르르 녹여줘요.',
    composition: '핫코코아 파우더 5스틱',
    price: 6000,
  ),
];

/// 이름 문자열로 카탈로그 선물을 찾는다(부분 일치). AI 추천명 → 카탈로그 매칭.
Gift? giftByName(String? name) {
  if (name == null || name.trim().isEmpty) return null;
  final q = name.trim();
  // 이름 전체/부분 일치
  for (final g in kGifts) {
    if (g.name.contains(q) || q.contains(g.name)) return g;
  }
  // 핵심 키워드 일치(공백 제거 후 서로 포함 여부)
  final qc = q.replaceAll(' ', '');
  for (final g in kGifts) {
    final gc = g.name.replaceAll(' ', '');
    if (gc.contains(qc) || qc.contains(gc)) return g;
  }
  return null;
}

Gift? giftById(String id) {
  for (final g in kGifts) {
    if (g.id == id) return g;
  }
  return null;
}
