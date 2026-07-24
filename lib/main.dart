import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/ai/ai_service.dart';
import 'services/backend/supabase_service.dart';
import 'services/conversation_store.dart';
import 'services/report_store.dart';
import 'services/received_gift_store.dart';
import 'services/safety_log_store.dart';
import 'services/session_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env 로드(없어도 앱은 데모 모드로 동작).
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  // 실서버(Supabase) 연결 — .env 에 설정이 있으면 켜지고, 없으면 로컬로 동작.
  await SupabaseService.instance.init();
  await AuthService.instance.init();
  await ConversationStore.instance.init(); // 진행 중 대화 복원(중간저장)
  await ReportStore.instance.init(); // 저장된 마음 리포트 복원
  await ReceivedGiftStore.instance.init(); // 받은 선물 복원
  await SafetyLogStore.instance.init(); // 안전 로그 복원
  // 실서버 세션이 복원돼 로그인 상태면, 현재 사용자의 서버 데이터를 확실히 로드.
  // (세션 복원 타이밍 때문에 각 스토어 init 에서 놓칠 수 있어 여기서 한 번 더 동기화)
  if (SupabaseService.instance.enabled &&
      AuthService.instance.currentUser != null) {
    await SessionData.onLogin();
  }
  AiService.instance.init(); // AI 제공자 선택(.env 기반, 키 없으면 데모)
  runApp(const WithYouApp());
}
