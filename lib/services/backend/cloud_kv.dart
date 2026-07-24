import 'supabase_service.dart';

/// 로그인 사용자별 JSON 상태를 실서버(Supabase)에 백업/복원하는 간단한 키-값 저장소.
///
/// 테이블 `user_state(user_id uuid, key text, value jsonb, updated_at)` 사용.
/// 각 스토어(대화/리포트 등)는 로컬 저장 후 [set] 으로 서버에 미러링하고,
/// 앱 시작 시 [get] 으로 서버 값을 우선 복원한다. 모든 호출은 방어적이라
/// 서버가 없거나(비활성) 실패해도 예외를 던지지 않아 로컬 흐름을 막지 않는다.
class CloudKV {
  CloudKV._();

  static bool get _on => SupabaseService.instance.enabled &&
      SupabaseService.instance.userId != null;

  /// 서버에 값 저장(로그인+활성 상태에서만). 실패는 조용히 무시.
  static Future<void> set(String key, Object jsonValue) async {
    if (!_on) return;
    final uid = SupabaseService.instance.userId!;
    try {
      await SupabaseService.instance.client.from('user_state').upsert({
        'user_id': uid,
        'key': key,
        'value': jsonValue,
      }, onConflict: 'user_id,key');
    } catch (_) {
      // 오프라인/오류 시 로컬만 유지.
    }
  }

  /// 서버에서 값 조회(없거나 실패하면 null → 호출부가 로컬 값 사용).
  static Future<dynamic> get(String key) async {
    if (!_on) return null;
    final uid = SupabaseService.instance.userId!;
    try {
      final row = await SupabaseService.instance.client
          .from('user_state')
          .select('value')
          .eq('user_id', uid)
          .eq('key', key)
          .maybeSingle();
      return row?['value'];
    } catch (_) {
      return null;
    }
  }

  /// 회원탈퇴 등에서 서버의 사용자 상태 전체 삭제.
  static Future<void> clearAll() async {
    if (!_on) return;
    final uid = SupabaseService.instance.userId!;
    try {
      await SupabaseService.instance.client
          .from('user_state')
          .delete()
          .eq('user_id', uid);
    } catch (_) {}
  }
}
