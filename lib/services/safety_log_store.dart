import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'backend/cloud_kv.dart';
import 'backend/supabase_service.dart';
import 'safety_service.dart';

/// 위험 대응 기록(safety_logs). (안전장치 설계 §6)
///
/// medium/high 단계만 기록하며, 대화 원문 등 PII 는 저장하지 않고
/// 위험 단계 + 수행 조치 + 시각만 남긴다.
class SafetyLog {
  const SafetyLog({
    required this.level,
    required this.action,
    required this.at,
    this.text = '',
  });
  final SafetyLevel level;
  final String action; // 수행 조치(예: '안전 화면 전환', '안내 문구 추가')
  final String at;
  final String text; // 로그를 촉발한 사용자 문장(관리자 모니터링용)

  Map<String, dynamic> toJson() => {
        'level': level.name,
        'action': action,
        'at': at,
        if (text.isNotEmpty) 'text': text,
      };
  factory SafetyLog.fromJson(Map<String, dynamic> j) => SafetyLog(
        level: SafetyLevel.values.firstWhere(
          (e) => e.name == j['level'],
          orElse: () => SafetyLevel.medium,
        ),
        action: j['action'] as String? ?? '',
        at: j['at'] as String? ?? '',
        text: j['text'] as String? ?? '',
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
    if (raw != null && raw.isNotEmpty) {
      _logs
        ..clear()
        ..addAll((jsonDecode(raw) as List)
            .map((e) => SafetyLog.fromJson(e as Map<String, dynamic>)));
    }
    // 실서버가 켜져 있고 값이 있으면 서버 값을 우선 반영.
    final remote = await CloudKV.get(_kLogs);
    if (remote is List) {
      _logs
        ..clear()
        ..addAll(
            remote.map((e) => SafetyLog.fromJson(e as Map<String, dynamic>)));
    }
  }

  /// medium/high 만 기록(low 는 기록하지 않음).
  Future<void> log(SafetyLevel level, String action, {String text = ''}) async {
    if (level == SafetyLevel.low) return;
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final at =
        '${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}';
    _logs.insert(0, SafetyLog(level: level, action: action, at: at, text: text));
    notifyListeners();
    final list = await _writeLocal();
    // 실서버 백업(켜져 있을 때만) — 관리자 페이지에서 위험 로그 모니터링.
    unawaited(CloudKV.set(_kLogs, list));
  }

  /// 로그인 직후: 서버(현재 사용자)의 안전로그로 교체. 로컬 모드면 그대로 둔다.
  Future<void> reloadForCurrentUser() async {
    if (!SupabaseService.instance.enabled) return;
    _logs.clear();
    final remote = await CloudKV.get(_kLogs);
    if (remote is List) {
      _logs.addAll(
          remote.map((e) => SafetyLog.fromJson(e as Map<String, dynamic>)));
    }
    await _writeLocal();
    notifyListeners();
  }

  /// 로그아웃: 메모리 + 로컬 캐시만 비운다(서버 데이터는 보존).
  Future<void> clearForLogout() async {
    if (!SupabaseService.instance.enabled) return;
    _logs.clear();
    await _prefs?.remove(_kLogs);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> _writeLocal() async {
    final list = _logs.map((e) => e.toJson()).toList();
    if (_prefs != null) {
      await _prefs!.setString(_kLogs, jsonEncode(list));
    }
    return list;
  }
}
