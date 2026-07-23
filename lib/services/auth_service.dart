import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../models/social_provider.dart';
import 'mail_service.dart';

/// 인증 처리 결과. 실패 시 사용자에게 보여줄 [error] 메시지를 담는다.
class AuthResult {
  const AuthResult.success()
      : ok = true,
        error = null;
  const AuthResult.failure(this.error) : ok = false;

  final bool ok;
  final String? error;
}

/// 인증번호 발급 결과. [demoCode] 는 .env 미설정(데모) 시에만 채워진다.
class SendCodeResult {
  const SendCodeResult({required this.ok, this.error, this.demoCode});

  final bool ok;
  final String? error;
  final String? demoCode;
}

/// 회원가입/로그인 백엔드.
///
/// 현재는 기기 로컬 저장(shared_preferences) 기반이다. 공개 API를 이 형태로
/// 유지하면 추후 Firebase/REST 서버 구현으로 교체해도 화면 코드는 그대로 둘 수 있다.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _kAccounts = 'auth_accounts'; // 가입된 계정들
  static const _kSession = 'auth_session'; // 현재 로그인 이메일
  static const _kMarketingPrefix = 'consent_marketing_'; // 계정별 마케팅 수신 동의

  late SharedPreferences _prefs;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // 이메일 인증번호 (email → code). 프로토타입: 앱 메모리에만 보관.
  final Map<String, String> _verificationCodes = {};
  final Random _random = Random();

  /// 인증번호 발급.
  ///
  /// `.env` 에 메일 계정이 설정돼 있으면 실제 이메일을 발송하고,
  /// 없으면 데모 모드로 코드를 [SendCodeResult.demoCode] 에 담아 반환한다.
  Future<SendCodeResult> sendVerificationCode(String email) async {
    final code = (100000 + _random.nextInt(900000)).toString();
    _verificationCodes[email.trim()] = code;

    if (!MailService.instance.isConfigured) {
      return SendCodeResult(ok: true, demoCode: code); // 데모: 화면에 노출
    }
    try {
      await MailService.instance
          .sendVerificationCode(toEmail: email.trim(), code: code);
      return const SendCodeResult(ok: true);
    } catch (e) {
      return SendCodeResult(ok: false, error: '메일 전송에 실패했어요: $e');
    }
  }

  bool verifyEmailCode(String email, String code) {
    final expected = _verificationCodes[email.trim()];
    return expected != null && expected == code.trim();
  }

  /// 이미 가입된 이메일인지 확인. (이메일이 계정 PK이므로 중복 가입 방지용)
  bool isEmailRegistered(String email) => _accounts().containsKey(email.trim());

  /// 앱 시작 시 1회 호출(main). 저장된 세션을 복원한다.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final email = _prefs.getString(_kSession);
    if (email != null) {
      final account = _accounts()[email];
      if (account != null) {
        _currentUser = _userFrom(email, account);
      }
    }
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    email = email.trim();
    if (email.isEmpty) return const AuthResult.failure('이메일을 입력해주세요');
    if (password.isEmpty) return const AuthResult.failure('비밀번호를 입력해주세요');

    final accounts = _accounts();
    if (accounts.containsKey(email)) {
      return const AuthResult.failure('이미 가입된 이메일이에요');
    }
    accounts[email] = {'password': password, 'name': ''};
    await _saveAccounts(accounts);

    _currentUser = AppUser(email: email, name: '');
    await _prefs.setString(_kSession, email);
    return const AuthResult.success();
  }

  Future<AuthResult> logIn({
    required String email,
    required String password,
  }) async {
    email = email.trim();
    if (email.isEmpty) return const AuthResult.failure('이메일을 입력해주세요');
    if (password.isEmpty) return const AuthResult.failure('비밀번호를 입력해주세요');

    final account = _accounts()[email];
    if (account == null) return const AuthResult.failure('가입되지 않은 이메일이에요');
    if (account['password'] != password) {
      return const AuthResult.failure('비밀번호가 일치하지 않아요');
    }
    _currentUser = _userFrom(email, account);
    await _prefs.setString(_kSession, email);
    return const AuthResult.success();
  }

  /// 소셜 로그인(카카오/구글/애플).
  ///
  /// 현재는 프로토타입용으로 제공자별 로컬 세션을 만든다. 실제 연동 시에는
  /// 이 메서드 내부를 각 SDK 호출로 교체하면 된다(setup 문서 참고):
  ///   kakao  → kakao_flutter_sdk_user 의 UserApi.instance.loginWithKakaoTalk()
  ///   google → google_sign_in 의 GoogleSignIn().signIn()
  ///   apple  → sign_in_with_apple 의 SignInWithApple.getAppleIDCredential()
  /// 성공하면 얻은 이메일/이름으로 아래와 동일하게 세션을 세팅한다.
  Future<AuthResult> signInWithSocial(SocialProvider provider) async {
    final email = '${provider.id}@withyou.social';
    final accounts = _accounts();
    accounts.putIfAbsent(email, () => {'password': '', 'name': ''});
    await _saveAccounts(accounts);

    _currentUser = _userFrom(email, accounts[email]!);
    await _prefs.setString(_kSession, email);
    return const AuthResult.success();
  }

  /// 표시 이름(온보딩 호칭) 저장.
  Future<void> setName(String name) async {
    final user = _currentUser;
    if (user == null) return;
    final accounts = _accounts();
    final account = accounts[user.email];
    if (account != null) {
      account['name'] = name;
      accounts[user.email] = account;
      await _saveAccounts(accounts);
    }
    _currentUser = user.copyWith(name: name);
  }

  /// 프로필(호칭 + 자기소개/취향/알레르기/향) 저장.
  Future<void> updateProfile(AppUser profile) async {
    final user = _currentUser;
    if (user == null) return;
    final accounts = _accounts();
    final account = accounts[user.email] ?? <String, String>{};
    account['name'] = profile.name;
    account['bio'] = profile.bio;
    account['humor'] = profile.humor;
    account['giftTaste'] = profile.giftTaste;
    account['allergy'] = profile.allergy;
    account['scent'] = profile.scent;
    accounts[user.email] = account;
    await _saveAccounts(accounts);
    _currentUser = _userFrom(user.email, account);
  }

  Future<void> logOut() async {
    _currentUser = null;
    await _prefs.remove(_kSession);
  }

  /// 회원탈퇴 — 현재 계정과 세션을 완전히 삭제한다(복구 불가).
  Future<void> deleteAccount() async {
    final user = _currentUser;
    if (user == null) return;
    final accounts = _accounts();
    accounts.remove(user.email);
    await _saveAccounts(accounts);
    await _prefs.remove('$_kMarketingPrefix${user.email}');
    _currentUser = null;
    await _prefs.remove(_kSession);
  }

  /// 마케팅 및 알림(정보수신) 동의 — 선택 항목.
  bool get marketingConsent {
    final email = _currentUser?.email;
    if (email == null) return false;
    return _prefs.getBool('$_kMarketingPrefix$email') ?? false;
  }

  Future<void> setMarketingConsent(bool value) async {
    final email = _currentUser?.email;
    if (email == null) return;
    await _prefs.setBool('$_kMarketingPrefix$email', value);
  }

  // --- 내부 저장 헬퍼 ---

  AppUser _userFrom(String email, Map<String, String> account) => AppUser(
        email: email,
        name: account['name'] ?? '',
        bio: account['bio'] ?? '',
        humor: account['humor'] ?? '',
        giftTaste: account['giftTaste'] ?? '',
        allergy: account['allergy'] ?? '',
        scent: account['scent'] ?? '',
      );

  /// { email: { 'password': ..., 'name': ..., 'bio': ..., ... } }
  Map<String, Map<String, String>> _accounts() {
    final raw = _prefs.getString(_kAccounts);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (email, value) => MapEntry(
        email,
        (value as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, v as String),
        ),
      ),
    );
  }

  Future<void> _saveAccounts(Map<String, Map<String, String>> accounts) async {
    await _prefs.setString(_kAccounts, jsonEncode(accounts));
  }
}
