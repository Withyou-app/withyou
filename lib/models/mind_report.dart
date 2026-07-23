/// 마음 리포트 화면 진입 인자.
/// [isNew] true = 대화 종료로 갓 생성됨(저장 시 영속화 + 대화 비움),
/// false = 리포트 목록에서 기존 리포트 조회.
class MindReportArgs {
  const MindReportArgs({
    required this.report,
    this.isNew = false,
    this.persona,
  });

  final MindReport report;
  final bool isNew;
  final String? persona; // 대화 종료 시 비울 대화의 페르소나
}

/// 대화 종료 시 생성되는 마음 리포트.
/// [emotions] 오늘 느낀 감정 태그, [summary] 사건 중심 요약,
/// [needNow] 지금 필요한 것, [smallAction] 작은 행동 제안, [mission] 추천 미션,
/// [caution] 주의 문구, [memo] 사용자가 덧붙인 한 줄.
class MindReport {
  const MindReport({
    required this.persona,
    required this.emotions,
    required this.summary,
    this.needNow = '',
    this.smallAction = '',
    this.mission = '',
    this.caution = kDefaultCaution,
    this.memo = '',
    required this.createdAt,
  });

  /// 의료행위 오인 방지(§4) — 기본 주의 문구.
  static const String kDefaultCaution =
      '이 리포트는 대화를 바탕으로 한 정서 지원용 참고예요. 의학적 진단이 아니며, '
      '많이 힘들 땐 가족·친구나 전문 상담의 도움을 받아보세요.';

  final String persona;
  final List<String> emotions;
  final String summary;
  final String needNow;
  final String smallAction;
  final String mission;
  final String caution;
  final String memo;

  /// 표시/정렬용 생성 시각 문자열(앱에서 주입 — 예 '2026-07-22 13:05').
  final String createdAt;

  /// 목록 카드 제목: 상대 이름 기반.
  String get title => '$persona와의 대화';

  MindReport copyWith({String? memo}) => MindReport(
        persona: persona,
        emotions: emotions,
        summary: summary,
        needNow: needNow,
        smallAction: smallAction,
        mission: mission,
        caution: caution,
        memo: memo ?? this.memo,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'persona': persona,
        'emotions': emotions,
        'summary': summary,
        'needNow': needNow,
        'smallAction': smallAction,
        'mission': mission,
        'caution': caution,
        'memo': memo,
        'createdAt': createdAt,
      };

  factory MindReport.fromJson(Map<String, dynamic> json) => MindReport(
        persona: json['persona'] as String? ?? '',
        emotions: (json['emotions'] as List?)?.cast<String>() ?? const [],
        summary: json['summary'] as String? ?? '',
        needNow: json['needNow'] as String? ?? '',
        smallAction: json['smallAction'] as String? ?? '',
        mission: json['mission'] as String? ?? '',
        caution: json['caution'] as String? ?? kDefaultCaution,
        memo: json['memo'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? '',
      );
}
