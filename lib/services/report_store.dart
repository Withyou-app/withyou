import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mind_report.dart';

/// 생성된 마음 리포트들을 영속 보관한다. 리포트 탭이 이 목록을 보여준다.
class ReportStore extends ChangeNotifier {
  ReportStore._();
  static final ReportStore instance = ReportStore._();

  static const _kReports = 'mind_reports';

  late SharedPreferences _prefs;
  final List<MindReport> _reports = [];

  List<MindReport> get reports => List.unmodifiable(_reports);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_kReports);
    if (raw == null || raw.isEmpty) return;
    final list = jsonDecode(raw) as List;
    _reports
      ..clear()
      ..addAll(list.map((e) => MindReport.fromJson(e as Map<String, dynamic>)));
  }

  /// 최신 리포트를 맨 앞에 추가.
  Future<void> add(MindReport report) async {
    _reports.insert(0, report);
    notifyListeners();
    await _persist();
  }

  /// 기존 리포트의 메모를 갱신한다(생성시각+페르소나로 식별).
  Future<void> updateMemo(MindReport target, String memo) async {
    final i = _reports.indexWhere((r) =>
        r.createdAt == target.createdAt && r.persona == target.persona);
    if (i < 0) return;
    _reports[i] = _reports[i].copyWith(memo: memo);
    notifyListeners();
    await _persist();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _reports.length) return;
    _reports.removeAt(index);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    await _prefs.setString(
        _kReports, jsonEncode(_reports.map((r) => r.toJson()).toList()));
  }
}
