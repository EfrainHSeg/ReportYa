import 'dart:convert';

import 'package:reportya/features/reports/data/models/report.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportsRepository {
  static const _storageKey = 'reportes';
  static List<Report> reports = [];

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      reports = [];
      return;
    }

    final jsonList = json.decode(jsonString) as List<dynamic>;
    reports = jsonList
        .map((item) => Report.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(reports.map((report) => report.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
