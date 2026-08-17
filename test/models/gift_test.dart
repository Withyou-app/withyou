import 'package:flutter_test/flutter_test.dart';
import 'package:withyou/models/gift.dart';

void main() {
  test('priceLabel 은 천단위 콤마를 붙인다', () {
    expect(giftById('cloud_cushion')!.priceLabel, '24,000원');
    expect(giftById('chupachups')!.priceLabel, '1,000원');
  });

  test('giftByName 은 정확한 이름을 찾는다', () {
    expect(giftByName('따뜻한 코코아')?.id, 'cocoa');
  });

  test('giftByName 은 부분/공백무시 일치도 찾는다', () {
    expect(giftByName('코코아')?.id, 'cocoa'); // 부분 일치
    expect(giftByName('따뜻한코코아')?.id, 'cocoa'); // 공백 제거 일치
  });

  test('giftByName 은 없는 선물/빈 값에 null 을 준다', () {
    expect(giftByName('존재하지않는선물'), isNull);
    expect(giftByName(''), isNull);
    expect(giftByName(null), isNull);
  });

  test('giftById 는 없는 id 에 null 을 준다', () {
    expect(giftById('nope'), isNull);
  });

  test('카탈로그의 모든 선물은 고유 id 를 가진다', () {
    final ids = kGifts.map((g) => g.id).toSet();
    expect(ids.length, kGifts.length);
  });
}
