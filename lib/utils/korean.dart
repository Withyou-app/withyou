/// 한글 조사 처리 유틸.
class Korean {
  Korean._();

  /// 받침 유무에 따라 '이야'/'야' 를 고른다.
  /// 예: 구나 → 구나야, 리미 → 리미야, 하리봄 → 하리봄이야.
  /// 한글이 아닌 이름(영문 등)은 '야' 로 자연스럽게 붙인다.
  static String iya(String word) {
    if (word.isEmpty) return '야';
    final code = word.codeUnitAt(word.length - 1);
    // 한글 음절 영역: 받침이 있으면 (code-0xAC00) % 28 != 0
    if (code >= 0xAC00 && code <= 0xD7A3) {
      return (code - 0xAC00) % 28 == 0 ? '야' : '이야';
    }
    return '야';
  }
}
