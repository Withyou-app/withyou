/// 대화 상대(페르소나) 데이터 모델.
/// 화면에 하드코딩하지 않고 이 목록을 참조해 카드/대화창을 구성한다.
class Persona {
  const Persona({
    required this.name,
    required this.type,
    required this.quote,
    required this.description,
  });

  /// 이름 (예: 구나, 리미, 고미)
  final String name;

  /// 유형 뱃지 (예: 공감형)
  final String type;

  /// 대표 한마디 (카드 인용구)
  final String quote;

  /// 한 줄 설명
  final String description;
}

/// 페르소나 선택 화면에서 고를 수 있는 친구들.
const List<Persona> kPersonas = [
  Persona(
    name: '구나',
    type: '공감형',
    quote: '"그랬구나, 많이 속상했겠다"',
    description: '먼저 마음부터 알아주는 친구',
  ),
  Persona(
    name: '리미',
    type: '현실형',
    quote: '"야, 그건 네 잘못이 아니야"',
    description: '툭툭하지만 챙기는 든든한 친구',
  ),
  Persona(
    name: '고미',
    type: '복합형',
    quote: '공감과 현실 조언을 오가는',
    description: '담백하고 차분한 친구',
  ),
];
