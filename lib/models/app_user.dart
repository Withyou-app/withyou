/// 로그인한 사용자 정보 + 프로필.
class AppUser {
  const AppUser({
    required this.email,
    this.name = '',
    this.bio = '',
    this.humor = '',
    this.speechStyle = kBanmal,
    this.giftTaste = '',
    this.allergy = '',
    this.scent = '',
  });

  /// 말투 설정 값(회원가입/온보딩에서 선택).
  static const String kBanmal = '반말';
  static const String kJondaetmal = '존댓말';

  final String email;

  /// 표시 이름(호칭). 비어 있으면 화면에서 대체 문구를 쓴다.
  final String name;

  final String bio; // 자기소개
  final String humor; // 유머 취향
  final String speechStyle; // AI 말투: '반말' | '존댓말'
  final String giftTaste; // 선물 취향
  final String allergy; // 알레르기
  final String scent; // 선호하는 향

  bool get useJondaetmal => speechStyle == kJondaetmal;

  AppUser copyWith({
    String? name,
    String? bio,
    String? humor,
    String? speechStyle,
    String? giftTaste,
    String? allergy,
    String? scent,
  }) {
    return AppUser(
      email: email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      humor: humor ?? this.humor,
      speechStyle: speechStyle ?? this.speechStyle,
      giftTaste: giftTaste ?? this.giftTaste,
      allergy: allergy ?? this.allergy,
      scent: scent ?? this.scent,
    );
  }
}
