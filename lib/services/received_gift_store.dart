import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'backend/cloud_kv.dart';
import 'backend/supabase_service.dart';

/// 사용자가 '선물 받기'로 받은 선물 목록을 영속 보관한다.
/// 각 항목은 선물 id + 받은 시각 문자열.
class ReceivedGift {
  const ReceivedGift({required this.giftId, required this.receivedAt});
  final String giftId;
  final String receivedAt;

  Map<String, dynamic> toJson() => {'id': giftId, 'at': receivedAt};
  factory ReceivedGift.fromJson(Map<String, dynamic> j) =>
      ReceivedGift(giftId: j['id'] as String, receivedAt: j['at'] as String? ?? '');
}

class ReceivedGiftStore extends ChangeNotifier {
  ReceivedGiftStore._();
  static final ReceivedGiftStore instance = ReceivedGiftStore._();

  static const _kReceived = 'received_gifts';

  SharedPreferences? _prefs;
  final List<ReceivedGift> _items = [];

  List<ReceivedGift> get items => List.unmodifiable(_items);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_kReceived);
    if (raw != null && raw.isNotEmpty) {
      _decode(jsonDecode(raw) as List);
    }
    // 실서버가 켜져 있고 값이 있으면 서버 값을 우선 반영.
    final remote = await CloudKV.get(_kReceived);
    if (remote is List) {
      _items.clear();
      _decode(remote);
    }
  }

  void _decode(List list) {
    _items
      ..clear()
      ..addAll(list.map((e) => ReceivedGift.fromJson(e as Map<String, dynamic>)));
  }

  /// 선물 받기 — 최신순으로 추가.
  Future<void> add(String giftId, String receivedAt) async {
    _items.insert(0, ReceivedGift(giftId: giftId, receivedAt: receivedAt));
    notifyListeners();
    await _persist();
  }

  /// 로그인 직후: 서버(현재 사용자)의 받은 선물로 교체. 로컬 모드면 그대로 둔다.
  Future<void> reloadForCurrentUser() async {
    if (!SupabaseService.instance.enabled) return;
    _items.clear();
    final remote = await CloudKV.get(_kReceived);
    if (remote is List) _decode(remote);
    await _writeLocal();
    notifyListeners();
  }

  /// 로그아웃: 메모리 + 로컬 캐시만 비운다(서버 데이터는 보존).
  Future<void> clearForLogout() async {
    if (!SupabaseService.instance.enabled) return;
    _items.clear();
    await _prefs?.remove(_kReceived);
    notifyListeners();
  }

  Future<void> _persist() async {
    final list = await _writeLocal();
    unawaited(CloudKV.set(_kReceived, list));
  }

  Future<List<Map<String, dynamic>>> _writeLocal() async {
    final list = _items.map((e) => e.toJson()).toList();
    await _prefs?.setString(_kReceived, jsonEncode(list));
    return list;
  }
}
