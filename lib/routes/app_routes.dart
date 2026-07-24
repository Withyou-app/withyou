/// 앱 라우트 이름 상수. 문자열 하드코딩 대신 이 상수를 사용한다.
/// 라우트 테이블은 `lib/app.dart` 에 정의된다.
class AppRoutes {
  AppRoutes._();

  // 인증 / 온보딩 (풀스크린, 하단 네비 없음)
  static const login = '/login';
  static const signupEmail = '/signup/email';
  static const signupPassword = '/signup/password';
  static const signupTerms = '/signup/terms';
  static const onboarding1 = '/onboarding/1';
  static const onboarding2 = '/onboarding/2';

  // 메인 셸 (하단 네비 유동 활성화) — 탭 인덱스로 진입
  static const shell = '/shell';

  // 셸 밖에서 push 되는 풀스크린 화면
  static const persona = '/persona';
  static const chat = '/chat';
  static const conversations = '/conversations';
  static const reportDetail = '/report/detail';
  static const giftDetail = '/gift/detail';
  static const receivedGifts = '/gift/received';
  static const contact = '/contact';
  static const profileEdit = '/profile/edit';
}
