/// 앱 라우트 이름 상수. 문자열 하드코딩 대신 이 상수를 사용한다.
/// 라우트 테이블은 `lib/app.dart` 에 정의된다.
class AppRoutes {
  AppRoutes._();

  // 진입 스플래시
  static const splash = '/splash';

  // 서비스 소개/시작 (솔루션1)
  static const intro = '/intro';

  // 초대링크 입력 (솔루션2)
  static const invite = '/invite';

  // 회원가입 아이디/비밀번호/완료 (솔루션3/4/5 — v2 온보딩)
  static const signupId = '/signup-id';
  static const signupPw = '/signup-pw';
  static const signupDone = '/signup-done';

  // 인증 / 온보딩 (풀스크린, 하단 네비 없음)
  static const login = '/login';
  static const signupEmail = '/signup/email';
  static const signupPassword = '/signup/password';
  static const signupTerms = '/signup/terms';
  static const onboarding1 = '/onboarding/1';
  static const onboarding2 = '/onboarding/2';

  // v2 메인 앱 화면 (Section 2)
  static const homeV2 = '/v2/home';

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
