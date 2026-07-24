import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 실서버(Supabase) 연결의 단일 진입점.
///
/// `.env` 의 `BACKEND=supabase` 이고 `SUPABASE_URL`/`SUPABASE_ANON_KEY` 가 채워져
/// 있을 때만 활성화된다. 그렇지 않으면 [enabled]=false → 앱은 기존처럼 로컬
/// (shared_preferences) 로 동작한다. 덕분에 키가 없어도 앱은 그대로 돌아간다.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _enabled = false;

  /// 실서버 연결이 켜졌는지. false 면 로컬 백엔드로 동작.
  bool get enabled => _enabled;

  String? _env(String k) => dotenv.isInitialized ? dotenv.env[k] : null;

  /// main() 에서 다른 서비스보다 먼저 1회 호출.
  Future<void> init() async {
    final backend = (_env('BACKEND') ?? 'local').trim();
    final url = (_env('SUPABASE_URL') ?? '').trim();
    final anonKey = (_env('SUPABASE_ANON_KEY') ?? '').trim();
    if (backend != 'supabase' || url.isEmpty || anonKey.isEmpty) {
      return; // 로컬 모드 유지.
    }
    try {
      // anon public key 를 그대로 사용(대시보드에서 복사하는 값). 신형 명칭
      // publishableKey 로의 전환은 후속 과제.
      // ignore: deprecated_member_use
      await Supabase.initialize(url: url, anonKey: anonKey);
      _enabled = true;
    } catch (_) {
      _enabled = false; // 초기화 실패 시 안전하게 로컬로 폴백.
    }
  }

  SupabaseClient get client => Supabase.instance.client;

  /// 로그인된 사용자 uid(없으면 null).
  String? get userId => _enabled ? client.auth.currentUser?.id : null;
}
