import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'safety_service.dart';

/// 위험 대응 기록(safety_logs). (안전장치 설계 §6)
///
/// medium/high 단계만 기록하며, 대화 원문 등 PII 는 저장하지 않고
/// 위험 단계 + 수행 조치 + 시각만 남긴다.
class SafetyLog {
  const SafetyLog({required this.level, required this.action, required this.at});
  final SafetyLevel level;
  final String action; // 수행 조치(예: '안전 화면 전환', '안내 문구 추가')
  final String at;

  Map<String, dynamic> toJson() =>
      {'level': level.name, 'action': action, 'at': at};
  factory SafetyLog.fromJson(Map<String, dynamic> j) => SafetyLog(
        level: SafetyLevel.values.firstWhere(
          (e) => e.name == j['level'],
          orElse: () => SafetyLevel.medium,
        ),
        action: j['action'] as String? ?? '',
        at: j['at'] as String? ?? '',
      );
}

class SafetyLogStore extends ChangeNotifier {
  SafetyLogStore._();
  static final SafetyLogStore instance = SafetyLogStore._();

  static const _kLogs = 'safety_logs';

  SharedPreferences? _prefs;
  final List<SafetyLog> _logs = [];

  List<SafetyLog> get logs => List.unmodifiable(_logs);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_kLogs);
    if (raw == null || raw.isEmpty) return;
    _logs
      ..clear()
      ..addAll((jsonDecode(raw) as List)
          .map((e) => SafetyLog.fromJson(e as Map<String, dynamic>)));
  }

  /// medium/high 만 기록(low 는 기록하지 않음).
  Future<void> log(SafetyLevel level, String action) async {
    if (level == SafetyLevel.low) return;
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final at =
        '${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}';
    _logs.insert(0, SafetyLog(level: level, action: action, at: at));
    notifyListeners();
    if (_prefs != null) {
      await _prefs!
          .setString(_kLogs, jsonEncode(_logs.map((e) => e.toJson()).toList()));
    }
  }
}
