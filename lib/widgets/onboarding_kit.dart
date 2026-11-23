import 'package:flutter/material.dart';

/// 온보딩(가입) 플로우 공용 위젯 모음.
/// 디자인 토큰: 배경 #FFFCF9, 제목/라벨 #90796A,
/// 입력창 기본 #F3E6DC·포커스테두리/입력글자 #938072·힌트 #D4BBA9,
/// 버튼 활성 #FF8E88(흰 글자)·비활성 #995552(글자 #999999).

const _kBrown = Color(0xFF90796A);
const _kInputFill = Color(0xFFF3E6DC);
const _kInputFillFocused = Color(0xFFFBF5EE);
const _kInputText = Color(0xFF938072);
const _kHint = Color(0xFFD4BBA9);
const _kFillActive = Color(0xFFFF8E88);
const _kFillDisabled = Color(0xFF995552);
const _kDisabledText = Color(0xFF999999);
const _kTrackFilled = Color(0xFFFF8E88);
const _kTrackEmpty = Color(0xFFDCD9D4);

/// 상단 단계 진행바 — [current](1-based)까지 포인트색으로 채운다.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({super.key, required this.current, this.total = 4});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final segs = <Widget>[];
    for (var i = 0; i < total; i++) {
      segs.add(
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: i < current ? _kTrackFilled : _kTrackEmpty,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
      if (i != total - 1) segs.add(const SizedBox(width: 8));
    }
    return Row(children: segs);
  }
}

/// 이전 아이콘 + 진행바 헤더.
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: Image.asset('assets/brand/back_icon.png', width: 32, height: 32),
        ),
        const SizedBox(width: 13),
        SizedBox(
          width: w * 248 / 393,
          child: StepProgressBar(current: step),
        ),
      ],
    );
  }
}

/// 입력 필드 라벨("아이디", "비밀번호" 등).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'HumanBeomseokNeo',
        fontSize: 14,
        color: _kBrown,
        fontWeight: FontWeight.w600,
        fontVariations: [FontVariation('wght', 600)],
      ),
    );
  }
}

/// 브랜드 입력창 — 기본/포커스/입력됨 상태를 디자인대로 표현한다.
class BrandTextField extends StatefulWidget {
  const BrandTextField({
    super.key,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.onChanged,
  });

  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final ValueChanged<String>? onChanged;

  @override
  State<BrandTextField> createState() => _BrandTextFieldState();
}

class _BrandTextFieldState extends State<BrandTextField> {
  late final FocusNode _node;

  @override
  void initState() {
    super.initState();
    _node = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            c == Colors.transparent ? BorderSide.none : BorderSide(color: c, width: 1.5),
      );

  @override
  Widget build(BuildContext context) {
    final focused = _node.hasFocus;
    return TextField(
      controller: widget.controller,
      focusNode: _node,
      obscureText: widget.obscure,
      onChanged: widget.onChanged,
      cursorColor: _kInputText,
      style: const TextStyle(
        fontFamily: 'HumanBeomseokNeo',
        fontSize: 15,
        color: _kInputText,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(
          fontFamily: 'HumanBeomseokNeo',
          fontSize: 15,
          color: _kHint,
        ),
        filled: true,
        fillColor: focused ? _kInputFillFocused : _kInputFill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: _border(Colors.transparent),
        enabledBorder: _border(Colors.transparent),
        focusedBorder: _border(_kInputText),
      ),
    );
  }
}

/// 주 버튼(다음/시작하기) — 활성/비활성 상태.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: enabled ? _kFillActive : _kFillDisabled,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'HumanBeomseokNeo',
                fontSize: 18,
                color: enabled ? Colors.white : _kDisabledText,
                fontWeight: FontWeight.w600,
                fontVariations: const [FontVariation('wght', 600)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 온보딩 단계 공통 레이아웃 — 헤더 + 제목 + 본문 + 하단 버튼.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.child,
    required this.buttonLabel,
    required this.nextEnabled,
    required this.onNext,
  });

  final int step;
  final String title;
  final Widget child;
  final String buttonLabel;
  final bool nextEnabled;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 20 / 393;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF9),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              OnboardingHeader(step: step),
              const SizedBox(height: 38),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'HumanBeomseokNeo',
                  fontSize: 24,
                  height: 1.4,
                  color: _kBrown,
                  fontWeight: FontWeight.w700,
                  fontVariations: [FontVariation('wght', 700)],
                ),
              ),
              const SizedBox(height: 18),
              child,
              const Spacer(),
              PrimaryButton(
                label: buttonLabel,
                enabled: nextEnabled,
                onTap: onNext,
              ),
              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
