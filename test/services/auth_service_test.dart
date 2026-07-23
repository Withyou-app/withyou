import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withyou/services/auth_service.dart';
import 'package:withyou/models/social_provider.dart';

void main() {
  final auth = AuthService.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await auth.init();
    await auth.logOut(); // 싱글턴이므로 이전 테스트 상태 초기화
  });

  test('회원가입하면 로그인 상태가 되고 이메일이 저장된다', () async {
    final r = await auth.signUp(email: 'a@b.com', password: 'pw');
    expect(r.ok, isTrue);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.currentUser?.email, 'a@b.com');
  });

  test('이미 가입된 이메일은 재가입할 수 없다', () async {
    await auth.signUp(email: 'a@b.com', password: 'pw');
    final r = await auth.signUp(email: 'a@b.com', password: 'pw2');
    expect(r.ok, isFalse);
    expect(r.error, contains('이미 가입'));
  });

  test('호칭 저장 후, 로그아웃했다가 로그인하면 이름이 유지된다', () async {
    await auth.signUp(email: 'a@b.com', password: 'pw');
    await auth.setName('탐이');
    await auth.logOut();
    expect(auth.isLoggedIn, isFalse);

    final wrong = await auth.logIn(email: 'a@b.com', password: 'nope');
    expect(wrong.ok, isFalse);

    final ok = await auth.logIn(email: 'a@b.com', password: 'pw');
    expect(ok.ok, isTrue);
    expect(auth.currentUser?.name, '탐이');
  });

  test('가입되지 않은 이메일 로그인은 실패한다', () async {
    final r = await auth.logIn(email: 'x@y.com', password: 'pw');
    expect(r.ok, isFalse);
    expect(r.error, contains('가입되지 않은'));
  });

  test('이메일 인증번호 발급/검증 (미설정 시 데모 코드 반환)', () async {
    final result = await auth.sendVerificationCode('a@b.com');
    expect(result.ok, isTrue);
    final code = result.demoCode!; // .env 미설정 → 데모 코드
    expect(auth.verifyEmailCode('a@b.com', code), isTrue);
    expect(auth.verifyEmailCode('a@b.com', '000000'), isFalse);
    expect(auth.verifyEmailCode('x@y.com', code), isFalse); // 다른 이메일
  });

  test('소셜 로그인은 제공자별 세션을 만들고 이름을 유지한다', () async {
    final r = await auth.signInWithSocial(SocialProvider.kakao);
    expect(r.ok, isTrue);
    expect(auth.currentUser?.email, contains('kakao'));

    await auth.setName('카톡이');
    await auth.logOut();
    await auth.signInWithSocial(SocialProvider.kakao);
    expect(auth.currentUser?.name, '카톡이'); // 재로그인 시 이름 유지
  });
}
