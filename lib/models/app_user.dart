/// 로그인한 사용자 정보 + 프로필.
class AppUser {
  const AppUser({
    required this.email,
    this.name = '',
    this.bio = '',
    this.humor = '',
    this.giftTaste = '',
    this.allergy = '',
    this.scent = '',
  });

  final String email;

  /// 표시 이름(호칭). 비어 있으면 화면에서 대체 문구를 쓴다.
  final String name;

  final String bio; // 자기소개
  final String humor; // 유머 취향
  final String giftTaste; // 선물 취향
  final String allergy; // 알레르기
  final String scent; // 선호하는 향

  AppUser copyWith({
    String? name,
    String? bio,
    String? humor,
    String? giftTaste,
    String? allergy,
    String? scent,
  }) {
    return AppUser(
      email: email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      humor: humor ?? this.humor,
      giftTaste: giftTaste ?? this.giftTaste,
      allergy: allergy ?? this.allergy,
      scent: scent ?? this.scent,
    );
  }
}
