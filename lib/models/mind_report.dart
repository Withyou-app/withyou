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
/// [emotions] 오늘 느낀 감정 태그, [summary] 대화 요약, [memo] 사용자가 덧붙인 한 줄.
class MindReport {
  const MindReport({
    required this.persona,
    required this.emotions,
    required this.summary,
    this.memo = '',
    required this.createdAt,
  });

  final String persona;
  final List<String> emotions;
  final String summary;
  final String memo;

  /// 표시/정렬용 생성 시각 문자열(앱에서 주입 — 예 '2026-07-22 13:05').
  final String createdAt;

  /// 목록 카드 제목: 상대 이름 기반.
  String get title => '$persona와의 대화';

  MindReport copyWith({String? memo}) => MindReport(
        persona: persona,
        emotions: emotions,
        summary: summary,
        memo: memo ?? this.memo,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'persona': persona,
        'emotions': emotions,
        'summary': summary,
        'memo': memo,
        'createdAt': createdAt,
      };

  factory MindReport.fromJson(Map<String, dynamic> json) => MindReport(
        persona: json['persona'] as String? ?? '',
        emotions: (json['emotions'] as List?)?.cast<String>() ?? const [],
        summary: json['summary'] as String? ?? '',
        memo: json['memo'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? '',
      );
}
