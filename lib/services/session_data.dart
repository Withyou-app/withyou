import 'conversation_store.dart';
import 'received_gift_store.dart';
import 'report_store.dart';
import 'safety_log_store.dart';

/// 로그인/로그아웃 시 사용자별 데이터(대화·리포트·안전로그)를 서버 기준으로
/// 새로고침/정리하는 코디네이터.
///
/// 실서버 모드에서 스토어는 앱 시작 때 1회만 로드되므로, 세션 도중 로그인하면
/// 그 사용자의 서버 데이터를 다시 불러와야 한다. 로그아웃 시에는 로컬 캐시를
/// 비워 다음 사용자에게 이전 사용자 데이터가 남지 않게 한다.
class SessionData {
  const SessionData._();

  /// 로그인/회원가입 성공 직후 호출 — 현재 사용자의 서버 데이터로 교체.
  static Future<void> onLogin() async {
    await ConversationStore.instance.reloadForCurrentUser();
    await ReportStore.instance.reloadForCurrentUser();
    await ReceivedGiftStore.instance.reloadForCurrentUser();
    await SafetyLogStore.instance.reloadForCurrentUser();
  }

  /// 로그아웃 직후 호출 — 로컬 캐시 정리(서버 데이터는 보존).
  static Future<void> onLogout() async {
    await ConversationStore.instance.clearForLogout();
    await ReportStore.instance.clearForLogout();
    await ReceivedGiftStore.instance.clearForLogout();
    await SafetyLogStore.instance.clearForLogout();
  }
}
