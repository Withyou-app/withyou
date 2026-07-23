import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/ai/ai_service.dart';
import 'services/conversation_store.dart';
import 'services/report_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env 로드(없어도 앱은 데모 모드로 동작).
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  await AuthService.instance.init();
  await ConversationStore.instance.init(); // 진행 중 대화 복원(중간저장)
  await ReportStore.instance.init(); // 저장된 마음 리포트 복원
  AiService.instance.init(); // AI 제공자 선택(.env 기반, 키 없으면 데모)
  runApp(const WithYouApp());
}
