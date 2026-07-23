import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// 이메일 발송(SMTP). 설정은 `.env` 에서 읽는다.
///
/// MAIL_USERNAME / MAIL_PASSWORD 가 채워져 있으면 실제 메일을 보내고,
/// 비어 있으면 [isConfigured] 가 false → 호출부에서 데모 모드로 처리한다.
class MailService {
  MailService._();
  static final MailService instance = MailService._();

  String? _env(String key) =>
      dotenv.isInitialized ? dotenv.env[key] : null;

  bool get isConfigured =>
      (_env('MAIL_USERNAME')?.isNotEmpty ?? false) &&
      (_env('MAIL_PASSWORD')?.isNotEmpty ?? false);

  Future<void> sendVerificationCode({
    required String toEmail,
    required String code,
  }) async {
    final host = _env('MAIL_HOST') ?? 'smtp.gmail.com';
    final port = int.tryParse(_env('MAIL_PORT') ?? '') ?? 587;
    final username = _env('MAIL_USERNAME')!;
    final password = _env('MAIL_PASSWORD')!;
    final fromName = _env('MAIL_FROM_NAME') ?? 'withyou+';

    final server = SmtpServer(
      host,
      port: port,
      username: username,
      password: password,
      ssl: port == 465, // 465=SSL, 587=STARTTLS
    );

    final message = Message()
      ..from = Address(username, fromName)
      ..recipients.add(toEmail)
      ..subject = 'withyou+ 이메일 인증번호'
      ..text = '인증번호는 [$code] 입니다.\n앱에 입력해 이메일 인증을 완료해주세요.'
      ..html = '<p>withyou+ 이메일 인증번호입니다.</p>'
          '<h2 style="letter-spacing:4px">$code</h2>'
          '<p>앱에 입력해 인증을 완료해주세요.</p>';

    await send(message, server);
  }
}
