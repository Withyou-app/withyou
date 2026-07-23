/// 입력값 정규식 검증 모음.
class Validators {
  Validators._();

  /// 이메일 형식 (예: name@example.com)
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  /// 비밀번호: 영문자 + 숫자 + 특수문자 포함, 8자 이상.
  static final RegExp _password =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  static bool isValidPassword(String value) => _password.hasMatch(value);

  /// 화면에 안내할 비밀번호 규칙 문구.
  static const String passwordRule = '영문·숫자·특수문자 포함 8자 이상';
}
