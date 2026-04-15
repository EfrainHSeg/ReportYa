import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reportya/features/reports/data/models/report_display.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Filtro ─────────────────────────────────────
enum ReportFilter { todos, pendiente, aprobado, rechazado }

extension ReportFilterExt on ReportFilter {
  String get label => switch (this) {
        ReportFilter.todos      => 'Todos',
        ReportFilter.pendiente  => 'Pendiente',
        ReportFilter.aprobado   => 'Aprobado',
        ReportFilter.rechazado  => 'Rechazado',
      };

  String? get statusValue => switch (this) {
        ReportFilter.todos      => null,
        ReportFilter.pendiente  => 'draft',
        ReportFilter.aprobado   => 'submitted',
        ReportFilter.rechazado  => 'rejected',
      };
}

// ── ViewModel ──────────────────────────────────
class MyReportsViewModel extends ChangeNotifier {
  static const _pageSize = 15;
  static const _selectStr =
      'id, title, status, created_at, '
      'areas(name, code), '
      'risk_levels(label, color_hex), '
      'report_images(id, url)';

  final _supabase = Supabase.instance.client;

  bool loading     = false;
  bool loadingMore = false;
  bool hasMore     = true;
  String? error;

  // Conteos globales (sin paginación)
  int totalCount    = 0;
  int pendingCount  = 0;
  int approvedCount = 0;
  int rejectedCount = 0;

  List<ReportDisplay> reports = [];
  ReportFilter filter   = ReportFilter.todos;
  String searchQuery    = '';

  int _offset = 0;

  int countForFilter(ReportFilter f) => switch (f) {
        ReportFilter.todos      => totalCount,
        ReportFilter.pendiente  => pendingCount,
        ReportFilter.aprobado   => approvedCount,
        ReportFilter.rechazado  => rejectedCount,
      };

  // ── Lista agrupada por fecha ─────────────────
  List<dynamic> get groupedList {
    final result   = <dynamic>[];
    String? lastHeader;

    for (final r in reports) {
      final header = _dateHeader(r.createdAt);
      if (header != lastHeader) {
        result.add(header);
        lastHeader = header;
      }
      result.add(r);
    }
    return result;
  }

  String _dateHeader(DateTime date) {
    final now       = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d         = DateTime(date.year, date.month, date.day);

    if (d == today)     return 'HOY';
    if (d == yesterday) return 'AYER';

    final diff = today.difference(d).inDays;
    if (diff < 7) {
      const days = ['LUNES','MARTES','MIÉRCOLES','JUEVES','VIERNES','SÁBADO','DOMINGO'];
      return days[date.weekday - 1];
    }
    return '${date.day.toString().padLeft(2,'0')}/'
        '${date.month.toString().padLeft(2,'0')}/'
        '${date.year}';
  }

  // ── Públicos ────────────────────────────────
  void setFilter(ReportFilter f) {
    if (filter == f) return;
    filter = f;
    _reset();
    load();
  }

  void setSearch(String q) {
    searchQuery = q;
    _reset();
    load();
  }

  Future<void> refresh() async {
    _reset();
    await load();
  }

  // ── Carga inicial ──────────────────────────
  Future<void> load() async {
    loading = true;
    error   = null;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) { loading = false; notifyListeners(); return; }

      await Future.wait([
        _loadCounts(uid),
        _fetchPage(uid, 0).then((rows) {
          _offset = rows.length;
          reports = rows.map(ReportDisplay.fromRow).toList();
          hasMore = rows.length == _pageSize;
        }),
      ]);
    } catch (e) {
      error = e.toString();
      debugPrint('[MyReportsVM] load error: $e');
    }

    loading = false;
    notifyListeners();
  }

  // ── Carga siguiente página ─────────────────
  Future<void> loadMore() async {
    if (loadingMore || !hasMore) return;
    loadingMore = true;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) { loadingMore = false; notifyListeners(); return; }

      final rows = await _fetchPage(uid, _offset);
      _offset += rows.length;
      reports  = [...reports, ...rows.map(ReportDisplay.fromRow)];
      hasMore  = rows.length == _pageSize;
    } catch (e) {
      debugPrint('[MyReportsVM] loadMore error: $e');
    }

    loadingMore = false;
    notifyListeners();
  }

  // ── Eliminar ───────────────────────────────
  Future<bool> deleteReport(String id) async {
    try {
      await _supabase.from('report_images').delete().eq('report_id', id);
      await _supabase.from('reports').delete().eq('id', id);
      reports = reports.where((r) => r.id != id).toList();
      totalCount = (totalCount - 1).clamp(0, 9999);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[MyReportsVM] deleteReport error: $e');
      return false;
    }
  }

  // ── Detalle completo para PDF viewer ───────
  Future<Map<String, dynamic>?> fetchFullReport(String id) async {
    try {
      final report = await _supabase.from('reports').select().eq('id', id).single();
      final area   = await _supabase.from('areas')
          .select('name, code').eq('id', report['area_id']).single();
      final risk   = await _supabase.from('risk_levels')
          .select('label, color_hex').eq('id', report['risk_level_id']).single();
      final images = await _supabase.from('report_images')
          .select('url').eq('report_id', id);

      return {
        'report':       report,
        'areaName':     area['name']      as String,
        'areaCode':     area['code']      as String? ?? '',
        'riskLabel':    risk['label']     as String,
        'riskColorHex': risk['color_hex'] as String,
        'imageUrls':    (images as List).map((i) => i['url'] as String).toList(),
      };
    } catch (e) {
      debugPrint('[MyReportsVM] fetchFullReport error: $e');
      return null;
    }
  }

  // ── Conteos globales ───────────────────────
  Future<void> _loadCounts(String uid) async {
    final data = await _supabase
        .from('reports')
        .select('status')
        .eq('reported_by', uid);
    final list = List<Map<String, dynamic>>.from(data as List);
    totalCount    = list.length;
    pendingCount  = list.where((r) => r['status'] == 'draft').length;
    approvedCount = list.where((r) => r['status'] == 'submitted').length;
    rejectedCount = list.where((r) => r['status'] == 'rejected').length;
  }

  // ── Query con filtros ──────────────────────
  Future<List<Map<String, dynamic>>> _fetchPage(String uid, int offset) async {
    final hasStatus = filter.statusValue != null;
    final hasSearch = searchQuery.isNotEmpty;

    dynamic q = _supabase
        .from('reports')
        .select(_selectStr)
        .eq('reported_by', uid);

    if (hasStatus) q = q.eq('status', filter.statusValue!);
    if (hasSearch) q = q.ilike('title', '%$searchQuery%');

    q = q
        .order('created_at', ascending: false)
        .range(offset, offset + _pageSize - 1);

    return List<Map<String, dynamic>>.from(await q as List);
  }

  void _reset() {
    _offset = 0;
    reports = [];
    hasMore = true;
    error   = null;
  }
}
