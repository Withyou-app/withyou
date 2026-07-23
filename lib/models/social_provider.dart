/// 소셜 로그인 제공자.
enum SocialProvider {
  kakao('kakao', '카카오', 'assets/social/kakao.png'),
  google('google', '구글', 'assets/social/google.png'),
  apple('apple', '애플', 'assets/social/apple.png');

  const SocialProvider(this.id, this.label, this.asset);

  /// 저장/식별용 소문자 키
  final String id;

  /// 사용자 노출용 이름
  final String label;

  /// 버튼 이미지 에셋 경로 (원형 로고, plus/간편 로그인.png 에서 분할)
  final String asset;
}
