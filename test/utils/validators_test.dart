import 'package:flutter_test/flutter_test.dart';
import 'package:withyou/utils/validators.dart';

void main() {
  test('이메일 형식 정규식 검증', () {
    expect(Validators.isValidEmail('a@b.com'), isTrue);
    expect(Validators.isValidEmail('name.tag+1@sub.domain.co'), isTrue);
    expect(Validators.isValidEmail('a@b'), isFalse); // 도메인 . 없음
    expect(Validators.isValidEmail('ab.com'), isFalse); // @ 없음
    expect(Validators.isValidEmail(''), isFalse);
  });

  test('비밀번호 정규식: 영문+숫자+특수문자 포함 8자 이상', () {
    expect(Validators.isValidPassword('abc123!@'), isTrue);
    expect(Validators.isValidPassword('abcd1234'), isFalse); // 특수문자 없음
    expect(Validators.isValidPassword('abcd!@#e'), isFalse); // 숫자 없음
    expect(Validators.isValidPassword('1234!@#5'), isFalse); // 영문 없음
    expect(Validators.isValidPassword('ab1!'), isFalse); // 8자 미만
  });
}
