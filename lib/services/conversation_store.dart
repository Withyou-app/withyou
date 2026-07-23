import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

/// 진행 중인 대화를 페르소나별로 보관/영속화한다. (중간저장 → 이어하기)
///
/// 메시지를 shared_preferences 에 JSON 으로 저장하므로, 다른 탭/화면을 보다
/// 돌아오거나 앱을 껐다 켜도 대화가 이어진다. 대화 종료 시 [clear] 로 비운다.
class ConversationStore extends ChangeNotifier {
  ConversationStore._();
  static final ConversationStore instance = ConversationStore._();

  static const _kConversations = 'chat_conversations';

  SharedPreferences? _prefs;
  final Map<String, List<ChatMessage>> _byPersona = {};

  /// 앱 시작 시 1회.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_kConversations);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    decoded.forEach((persona, list) {
      _byPersona[persona] = (list as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    });
    // 마이그레이션: 인사말만 있고 진행 안 한 대화는 정리(기록하지 않음).
    final orphans =
        _byPersona.keys.where((p) => !_byPersona[p]!.any((m) => m.isMe)).toList();
    if (orphans.isNotEmpty) {
      for (final p in orphans) {
        _byPersona.remove(p);
      }
      await _persist();
    }
  }

  /// 최근 대화 목록에 쓸 페르소나들 — 사용자가 실제로 메시지를 보낸 대화만.
  /// (인사말만 있고 대화를 진행하지 않은 건 기록/표시하지 않는다)
  /// 최근에 활동한 대화가 앞에 오도록 역순으로 반환한다.
  /// (setMessages 가 갱신된 대화를 맵의 끝으로 옮기므로, 뒤에서부터가 최신)
  List<String> get personasWithHistory => _byPersona.entries
      .where((e) => e.value.any((m) => m.isMe))
      .map((e) => e.key)
      .toList()
      .reversed
      .toList();

  List<ChatMessage> messagesOf(String persona) =>
      List.of(_byPersona[persona] ?? const []);

  bool hasConversation(String persona) =>
      (_byPersona[persona] ?? const []).any((m) => m.isMe);

  /// 마지막 메시지 미리보기(최근 대화 목록 부제).
  String? lastPreview(String persona) {
    final msgs = _byPersona[persona];
    if (msgs == null || msgs.isEmpty) return null;
    return msgs
        .lastWhere((m) => !m.giftRecommendation, orElse: () => msgs.last)
        .text;
  }

  /// 대화 전체를 저장(메시지가 추가/변경될 때마다 호출).
  /// 갱신된 대화를 맵의 끝으로 다시 넣어 '최근 활동' 순서를 유지한다.
  Future<void> setMessages(String persona, List<ChatMessage> messages) async {
    _byPersona.remove(persona);
    _byPersona[persona] = List.of(messages);
    notifyListeners();
    await _persist();
  }

  /// 대화 종료 등으로 특정 페르소나의 대화를 비운다.
  Future<void> clear(String persona) async {
    _byPersona.remove(persona);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    if (_prefs == null) return; // 초기화 전(테스트 등)에는 메모리에만.
    final map = _byPersona.map(
      (persona, msgs) => MapEntry(persona, msgs.map((m) => m.toJson()).toList()),
    );
    await _prefs!.setString(_kConversations, jsonEncode(map));
  }
}
