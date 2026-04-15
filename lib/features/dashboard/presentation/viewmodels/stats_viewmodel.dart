import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reportya/features/dashboard/data/models/bar_data.dart';
import 'package:reportya/features/dashboard/data/repositories/stats_repository.dart';

// ── Período ────────────────────────────────────
enum StatsPeriodo { dias7, esteMes, meses3, esteAno }

extension StatsPeriodoExt on StatsPeriodo {
  String get label => switch (this) {
        StatsPeriodo.dias7    => '7 días',
        StatsPeriodo.esteMes  => 'Este mes',
        StatsPeriodo.meses3   => '3 meses',
        StatsPeriodo.esteAno  => 'Este año',
      };

  String get barLabel => switch (this) {
        StatsPeriodo.dias7    => 'Últimos 7 días',
        StatsPeriodo.esteMes  => 'Mes actual',
        StatsPeriodo.meses3   => 'Últimos 3 meses',
        StatsPeriodo.esteAno  => 'Año actual',
      };

  DateTime get start {
    final now = DateTime.now();
    return switch (this) {
      StatsPeriodo.dias7    => DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6)),
      StatsPeriodo.esteMes  => DateTime(now.year, now.month, 1),
      StatsPeriodo.meses3   => DateTime(now.year, now.month - 2, 1),
      StatsPeriodo.esteAno  => DateTime(now.year, 1, 1),
    };
  }

  DateTime get prevStart {
    final s = start;
    final diff = DateTime.now().difference(s);
    return s.subtract(diff);
  }
}

// ── ViewModel ──────────────────────────────────
class StatsViewModel extends ChangeNotifier {
  final _repo = StatsRepository();

  StatsPeriodo _periodo = StatsPeriodo.esteMes;
  StatsPeriodo get periodo => _periodo;

  bool loading = false;
  int total = 0;
  int totalPrev = 0;
  int aprobados = 0;
  int aprobadosPrev = 0;
  int pendientes = 0;
  int pendientesPrev = 0;
  double avgSemana = 0;
  double avgSemanaPrev = 0;
  List<BarData> barras = [];

  double get tasaAprobacion => total == 0 ? 0 : (aprobados / total * 100);
  double get tasaAprobacionPrev => totalPrev == 0 ? 0 : (aprobadosPrev / totalPrev * 100);

  String diffStr(int curr, int prev) {
    final d = curr - prev;
    return d >= 0 ? '+$d' : '$d';
  }

  void setPeriodo(StatsPeriodo p) {
    _periodo = p;
    notifyListeners();
    load();
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) { loading = false; notifyListeners(); return; }

      final now      = DateTime.now();
      final start    = _periodo.start;
      final prevStart = _periodo.prevStart;

      debugPrint('[Stats] periodo=$_periodo');
      debugPrint('[Stats] now(local)=$now  now(utc)=${now.toUtc().toIso8601String()}');
      debugPrint('[Stats] start(local)=$start  start(utc)=${start.toUtc().toIso8601String()}');
      debugPrint('[Stats] prevStart(local)=$prevStart  prevStart(utc)=${prevStart.toUtc().toIso8601String()}');

      final currList = await _repo.fetchReports(uid: uid, from: start, to: now);
      final prevList = await _repo.fetchReports(uid: uid, from: prevStart, to: start.subtract(const Duration(seconds: 1)));

      debugPrint('[Stats] currList(${currList.length}): ${currList.map((r) => "${r['created_at']} status=${r['status']}").join(' | ')}');
      debugPrint('[Stats] prevList(${prevList.length})');

      final semanas = (now.difference(start).inDays / 7).clamp(1, 52).toDouble();
      debugPrint('[Stats] semanas=$semanas  inDays=${now.difference(start).inDays}');

      total          = currList.length;
      totalPrev      = prevList.length;
      aprobados      = currList.where((r) => r['status'] == 'submitted').length;
      aprobadosPrev  = prevList.where((r) => r['status'] == 'submitted').length;
      pendientes     = currList.where((r) => r['status'] == 'draft').length;
      pendientesPrev = prevList.where((r) => r['status'] == 'draft').length;
      avgSemana      = currList.length / semanas;
      avgSemanaPrev  = prevList.isEmpty ? 0 : prevList.length / semanas;
      barras         = _calcBarras(currList, start, now);

      debugPrint('[Stats] result → total=$total aprobados=$aprobados pendientes=$pendientes');
      debugPrint('[Stats] barras: ${barras.map((b) => "${b.label}:${b.creados}").join(", ")}');
    } catch (e) {
      debugPrint('[StatsViewModel] Error: $e');
    }

    loading = false;
    notifyListeners();
  }

  List<BarData> _calcBarras(
      List<Map<String, dynamic>> rows, DateTime start, DateTime now) {
    switch (_periodo) {
      case StatsPeriodo.dias7:
        return List.generate(7, (i) {
          final day = start.add(Duration(days: i));
          final label = ['L','M','X','J','V','S','D'][day.weekday - 1];
          final f = rows.where((r) {
            final d = DateTime.parse(r['created_at'] as String).toLocal();
            return d.year == day.year && d.month == day.month && d.day == day.day;
          }).toList();
          return BarData(label, f.length, f.where((r) => r['status'] == 'submitted').length);
        });

      case StatsPeriodo.esteMes:
        return List.generate(4, (i) {
          final ws = start.add(Duration(days: i * 7));
          final we = ws.add(const Duration(days: 7));
          final f  = rows.where((r) {
            final d = DateTime.parse(r['created_at'] as String).toLocal();
            return d.isAfter(ws.subtract(const Duration(seconds: 1))) && d.isBefore(we);
          }).toList();
          return BarData('S${i + 1}', f.length, f.where((r) => r['status'] == 'submitted').length);
        });

      case StatsPeriodo.meses3:
        return List.generate(3, (i) {
          final mes    = DateTime(start.year, start.month + i, 1);
          final mesFin = DateTime(mes.year, mes.month + 1, 1);
          final f = rows.where((r) {
            final d = DateTime.parse(r['created_at'] as String).toLocal();
            return d.isAfter(mes.subtract(const Duration(seconds: 1))) && d.isBefore(mesFin);
          }).toList();
          const labels = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
          return BarData(labels[mes.month - 1], f.length, f.where((r) => r['status'] == 'submitted').length);
        });

      case StatsPeriodo.esteAno:
        return List.generate(12, (i) {
          final mes    = DateTime(start.year, i + 1, 1);
          final mesFin = DateTime(start.year, i + 2, 1);
          final f = rows.where((r) {
            final d = DateTime.parse(r['created_at'] as String).toLocal();
            return d.isAfter(mes.subtract(const Duration(seconds: 1))) && d.isBefore(mesFin);
          }).toList();
          const labels = ['E','F','M','A','My','J','Jl','A','S','O','N','D'];
          return BarData(labels[i], f.length, f.where((r) => r['status'] == 'submitted').length);
        });
    }
  }
}
