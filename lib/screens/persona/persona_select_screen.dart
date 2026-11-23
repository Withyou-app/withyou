import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/v2_bottom_nav.dart';

/// 페르소나 선택 화면 (Figma: iPhone 14 & 15 Pro - 83 / 714:668).
///
/// 캐릭터 카드 캐러셀(좌우 화살표로 전환) + 대화하기 버튼.
class PersonaSelectScreen extends StatefulWidget {
  const PersonaSelectScreen({super.key});

  @override
  State<PersonaSelectScreen> createState() => _PersonaSelectScreenState();
}

class _Persona {
  const _Persona(this.name, this.type, this.asset, this.desc);
  final String name;
  final String type;
  final String asset;
  final String desc;
}

class _PersonaSelectScreenState extends State<PersonaSelectScreen> {
  static const _brown = Color(0xFF90796A);
  static const _main = Color(0xFFFF8E88);
  static const _point = Color(0xFFFFCD8C);
  static const _sub = Color(0xFFCBC0B4);
  static const _descColor = Color(0xFFC4A07E);
  static const _underline = Color(0xFFFEECD3);

  // 고미 설명은 Figma 원문. 구나/리미는 유형에 맞춘 안내문.
  static const _personas = [
    _Persona('구나', '공감형', 'assets/brand/char_guna.png',
        '공감형인 구나는\nID님의 마음을 먼저\n따뜻하게 안아줘요.'),
    _Persona('고미', '복합형', 'assets/brand/char_gomi.png',
        '복합형인 고미는\nID님에게 공감과 현실적인\n접근을 함께 제공해요.'),
    _Persona('리미', '현실형', 'assets/brand/char_rimi.png',
        '현실형인 리미는\nID님에게 지금 필요한 것을\n분명하게 짚어줘요.'),
  ];

  int _index = 1; // 고미부터(Figma 기준)

  void _prev() => setState(() => _index = (_index - 1 + _personas.length) % _personas.length);
  void _next() => setState(() => _index = (_index + 1) % _personas.length);

  @override
  Widget build(BuildContext context) {
    final p = _personas[_index];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text.rich(
                    TextSpan(
                      style: TextStyle(fontFamily: 'BagelFatOne', fontSize: 24),
                      children: [
                        TextSpan(text: 'withyou', style: TextStyle(color: _main)),
                        TextSpan(text: '+', style: TextStyle(color: _point)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '오늘은 어떤 이야기를\n나누고 싶으세요?',
                    style: TextStyle(
                      fontFamily: 'HumanBeomseokNeo',
                      fontSize: 28,
                      height: 1.25,
                      color: _brown,
                      fontWeight: FontWeight.w700,
                      fontVariations: [FontVariation('wght', 700)],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '대화할 친구를 골라보세요. 편하게 고르세요 언제든 바꿀 수 있어요',
                    style: TextStyle(
                      fontFamily: 'HumanBeomseokNeo',
                      fontSize: 12,
                      color: _sub,
                      fontWeight: FontWeight.w600,
                      fontVariations: [FontVariation('wght', 600)],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _arrow(Icons.chevron_left, _prev),
                    _card(p),
                    _arrow(Icons.chevron_right, _next),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: Material(
                  color: _main,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: const Center(
                      child: Text(
                        '대화하기',
                        style: TextStyle(
                          fontFamily: 'HumanBeomseokNeo',
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontVariations: [FontVariation('wght', 600)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            V2BottomNav(
              current: 1,
              onTap: (i) {
                if (i == 0) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.homeV2, (r) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _arrow(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Icon(icon, size: 28, color: _brown),
    );
  }

  Widget _card(_Persona p) {
    return Container(
      width: 251,
      height: 363,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40FF8080),
            offset: Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 17),
          SizedBox(
            height: 165,
            width: 181,
            child: Image.asset(p.asset, fit: BoxFit.contain),
          ),
          const SizedBox(height: 6),
          Stack(
            alignment: Alignment.center,
            children: [
              // 이름 밑 하이라이트 바
              Positioned(
                bottom: 2,
                child: Container(width: 52, height: 9, color: _underline),
              ),
              Text(
                p.name,
                style: const TextStyle(
                  fontFamily: 'HumanBeomseokNeo',
                  fontSize: 28,
                  color: _brown,
                  fontWeight: FontWeight.w700,
                  fontVariations: [FontVariation('wght', 700)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            p.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'HumanBeomseokNeo',
              fontSize: 16,
              height: 1.25,
              color: _descColor,
              fontWeight: FontWeight.w700,
              fontVariations: [FontVariation('wght', 700)],
            ),
          ),
        ],
      ),
    );
  }
}
