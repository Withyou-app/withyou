import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    if (raw == null || raw.isEmpty) return;
    _items
      ..clear()
      ..addAll((jsonDecode(raw) as List)
          .map((e) => ReceivedGift.fromJson(e as Map<String, dynamic>)));
  }

  /// 선물 받기 — 최신순으로 추가.
  Future<void> add(String giftId, String receivedAt) async {
    _items.insert(0, ReceivedGift(giftId: giftId, receivedAt: receivedAt));
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    await _prefs!
        .setString(_kReceived, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }
}
