/// 위험 발화 감지/분류. (withyou+ 안전장치 설계 §1~§3)
///
/// 3단계로 분류한다.
/// - low: 일반 대화 유지, 별도 안내 없음
/// - medium: 일반 대화 유지 + 답변 하단에 안전 안내 1문장
/// - high: 일반 대화 중단, 안전 안내 화면(/safety)으로 전환
///
/// 표현 하나로 단정하지 않도록 문맥 판단이 이상적이나, 클라이언트 단계에서는
/// 고신뢰 키워드 기반으로 우선 감지한다.
enum SafetyLevel { low, medium, high }

class SafetyService {
  SafetyService._();

  // High: 명백한 자해/자살/타해/극단적 선택 표현.
  static const _high = [
    '자살', '죽고싶', '죽어버리', '죽어야겠', '목숨을끊', '목숨끊', '자해',
    '손목을긋', '손목긋', '뛰어내리', '목을매', '목매달', '베어버리', '베고싶',
    '사라지고싶', '없어지고싶', '다끝내고싶', '끝내버리고싶', '죽여버리',
    '죽여버릴', '살고싶지않', '죽는게낫', '죽는편이',
  ];

  // Medium: 위험 가능성이 있는 심한 무기력/절망 표현.
  static const _medium = [
    '살기싫', '살기가싫', '희망이없', '희망도없', '다포기', '포기하고싶',
    '버틸수없', '버티기힘들', '못버티겠', '의미가없', '의미없어졌',
    '혼자였으면', '아무도필요없', '다놓고싶',
  ];

  /// 공백을 제거해 비교(띄어쓰기 변형 대응).
  static SafetyLevel classify(String text) {
    final t = text.replaceAll(RegExp(r'\s+'), '');
    for (final k in _high) {
      if (t.contains(k)) return SafetyLevel.high;
    }
    for (final k in _medium) {
      if (t.contains(k)) return SafetyLevel.medium;
    }
    return SafetyLevel.low;
  }

  /// Medium 단계에서 답변 하단에 덧붙이는 안전 안내 1문장.
  static const String mediumNotice =
      '\n\n혹시 많이 힘들다면 혼자 견디지 말고, 자살예방상담전화 109(24시간)에 편하게 이야기해봐도 괜찮아요.';
}
