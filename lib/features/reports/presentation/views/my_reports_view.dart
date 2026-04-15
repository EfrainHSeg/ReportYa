import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/features/reports/data/models/report_display.dart';
import 'package:reportya/features/reports/presentation/viewmodels/my_reports_viewmodel.dart';
import 'package:reportya/features/reports/presentation/views/report_pdf_viewer_view.dart';
import 'package:reportya/features/reports/presentation/views/report_preview_view.dart';

class MyReportsView extends StatefulWidget {
  const MyReportsView({super.key});

  @override
  State<MyReportsView> createState() => _MyReportsViewState();
}

class _MyReportsViewState extends State<MyReportsView> {
  final _vm          = MyReportsViewModel();
  final _searchCtrl  = TextEditingController();
  final _scrollCtrl  = ScrollController();
  Timer? _debounce;
  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    _vm.load();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _vm.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _vm.loadMore();
    }
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(
        const Duration(milliseconds: 400), () => _vm.setSearch(q));
  }

  Future<Map<String, dynamic>?> _fetchDetail(String id) async {
    setState(() => _loadingDetail = true);
    final detail = await _vm.fetchFullReport(id);
    if (mounted) setState(() => _loadingDetail = false);
    if (detail == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error cargando reporte')),
      );
    }
    return detail;
  }

  Future<void> _openPreview(ReportDisplay report) async {
    final detail = await _fetchDetail(report.id);
    if (detail == null || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportPreviewView(
          report:       detail['report']       as Map<String, dynamic>,
          areaName:     detail['areaName']     as String,
          areaCode:     detail['areaCode']     as String,
          riskLabel:    detail['riskLabel']    as String,
          riskColorHex: detail['riskColorHex'] as String,
          imageUrls:    detail['imageUrls']    as List<String>,
        ),
      ),
    );
  }

  Future<void> _openPdf(ReportDisplay report) async {
    final detail = await _fetchDetail(report.id);
    if (detail == null || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportPdfViewerView(
          report:       detail['report']       as Map<String, dynamic>,
          areaName:     detail['areaName']     as String,
          areaCode:     detail['areaCode']     as String,
          riskLabel:    detail['riskLabel']    as String,
          riskColorHex: detail['riskColorHex'] as String,
          imageUrls:    detail['imageUrls']    as List<String>,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String id, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar reporte',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w800)),
        content: Text('¿Eliminar "$title"? Esta acción no se puede deshacer.',
            style: GoogleFonts.montserrat(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: GoogleFonts.montserrat(color: AppColors.textoGris)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar',
                style: GoogleFonts.montserrat(
                    color: AppColors.rechazado,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) {
      final success = await _vm.deleteReport(id);
      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el reporte')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // ── Header amarillo: buscador ──
            _buildSearchHeader(),
            // ── Stats + Tabs (reactivo) ────
            ListenableBuilder(
              listenable: _vm,
              builder: (_, __) => Column(
                children: [
                  _StatsRow(vm: _vm),
                  _FilterTabs(vm: _vm),
                ],
              ),
            ),
            // ── Lista ──────────────────────
            Expanded(
              child: ListenableBuilder(
                listenable: _vm,
                builder: (_, __) => _buildBody(),
              ),
            ),
          ],
        ),
        if (_loadingDetail)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(
                  color: AppColors.naranjaFerreyros),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: AppColors.amarilloCat,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: _onSearchChanged,
          style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.negro),
          decoration: InputDecoration(
            hintText: 'Buscar reporte...',
            hintStyle: GoogleFonts.montserrat(
                fontSize: 13, color: AppColors.textoGris),
            prefixIcon: const Icon(Icons.search_rounded,
                size: 18, color: AppColors.textoGris),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_vm.loading) return _buildSkeletons();
    if (_vm.error != null) return _ErrorState(onRetry: _vm.load);
    if (_vm.reports.isEmpty) {
      return _EmptyState(
          filter: _vm.filter, search: _vm.searchQuery);
    }

    final items = _vm.groupedList;

    return RefreshIndicator(
      color: AppColors.naranjaFerreyros,
      onRefresh: _vm.refresh,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length + (_vm.loadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.naranjaFerreyros),
                ),
              ),
            );
          }

          final item = items[i];

          // Header de fecha
          if (item is String) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Text(item,
                  style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoGris,
                      letterSpacing: 1.4)),
            );
          }

          final r = item as ReportDisplay;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ReportCard(
              report:   r,
              onTap:    () => _openPreview(r),
              onDelete: () => _confirmDelete(r.id, r.title),
              onPdf:    () => _openPdf(r),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletons() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const _CardSkeleton(),
    );
  }
}

// ── Stats row ───────────────────────────────────
class _StatsRow extends StatelessWidget {
  final MyReportsViewModel vm;
  const _StatsRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          _StatItem(value: vm.totalCount,    label: 'TOTAL',     color: AppColors.naranjaFerreyros),
          _Divider(),
          _StatItem(value: vm.pendingCount,  label: 'PENDIENTE', color: AppColors.pendiente),
          _Divider(),
          _StatItem(value: vm.approvedCount, label: 'APROBADO',  color: AppColors.aprobado),
          _Divider(),
          _StatItem(value: vm.rejectedCount, label: 'RECHAZADO', color: AppColors.rechazado),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  const _StatItem({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value',
              style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoGris,
                  letterSpacing: 0.8)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: const Color(0xFFEEEEEE));
}

// ── Tabs de filtro ──────────────────────────────
class _FilterTabs extends StatelessWidget {
  final MyReportsViewModel vm;
  const _FilterTabs({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ReportFilter.values.map((f) {
                final sel = f == vm.filter;
                final count = vm.countForFilter(f);
                return GestureDetector(
                  onTap: () => vm.setFilter(f),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: sel
                              ? AppColors.naranjaFerreyros
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(f.label,
                            style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: sel
                                    ? AppColors.naranjaFerreyros
                                    : AppColors.textoGris)),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.naranjaFerreyros
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$count',
                              style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: sel
                                      ? Colors.white
                                      : AppColors.textoGris)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de reporte ──────────────────────────
class _ReportCard extends StatelessWidget {
  final ReportDisplay report;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPdf;
  const _ReportCard({
    required this.report,
    required this.onTap,
    required this.onDelete,
    required this.onPdf,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final isRejected  = report.status == 'rejected';

    return Dismissible(
      key: Key(report.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async { onDelete(); return false; },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.rechazado,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded,
            color: Colors.white, size: 22),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cardBorde),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra lateral de color
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                // Contenido
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila principal
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ícono estado
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_statusIcon(),
                                  color: statusColor, size: 20),
                            ),
                            const SizedBox(width: 10),
                            // Título + meta
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(report.title,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.negro),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 3),
                                  Row(children: [
                                    Text(_formatTime(),
                                        style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            color: AppColors.textoGris)),
                                    const SizedBox(width: 6),
                                    Container(
                                        width: 3, height: 3,
                                        decoration: const BoxDecoration(
                                            color: AppColors.textoGris,
                                            shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text(report.area,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            color: AppColors.textoGris)),
                                  ]),
                                  const SizedBox(height: 3),
                                  Text(report.riskLabel,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _riskColor())),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Badge estado
                            _StatusBadge(status: report.status),
                          ],
                        ),

                        // Banner rechazado
                        if (isRejected) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.rechazado
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(children: [
                              const Icon(Icons.warning_amber_rounded,
                                  size: 14,
                                  color: AppColors.rechazado),
                              const SizedBox(width: 6),
                              Text('Datos incompletos — ver motivo',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.rechazado)),
                            ]),
                          ),
                        ],

                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 8),

                        // Fila inferior: fotos + botones
                        Row(
                          children: [
                            // Miniaturas fotos
                            ...report.imageUrls.map((url) => Container(
                                  width: 26,
                                  height: 26,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEEEEE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox()),
                                )),
                            if (report.imageCount > 3)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  '+${report.imageCount - 3} fotos',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      color: AppColors.textoGris),
                                ),
                              )
                            else if (report.imageCount > 0 &&
                                report.imageCount <= 3)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  '${report.imageCount} foto${report.imageCount > 1 ? 's' : ''}',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      color: AppColors.textoGris),
                                ),
                              ),
                            const Spacer(),
                            // Botón ver reporte
                            GestureDetector(
                              onTap: onTap,
                              child: Text('Ver reporte',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.naranjaFerreyros)),
                            ),
                            const SizedBox(width: 12),
                            // Botón PDF
                            GestureDetector(
                              onTap: onPdf,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.download_rounded,
                                      size: 12,
                                      color: AppColors.textoGrisOscuro),
                                  const SizedBox(width: 3),
                                  Text('PDF',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textoGrisOscuro)),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor() => switch (report.status) {
        'submitted' => AppColors.aprobado,
        'rejected'  => AppColors.rechazado,
        _           => AppColors.pendiente,
      };

  IconData _statusIcon() => switch (report.status) {
        'submitted' => Icons.check_circle_outline_rounded,
        'rejected'  => Icons.cancel_outlined,
        _           => Icons.description_outlined,
      };

  Color _riskColor() {
    final h = report.riskColorHex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  String _formatTime() {
    final d   = report.createdAt;
    final now = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final day       = DateTime(d.year, d.month, d.day);
    final hhmm =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    if (day == today)     return 'Hoy $hhmm';
    if (day == yesterday) return 'Ayer $hhmm';
    const days = ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];
    if (today.difference(day).inDays < 7) return '${days[d.weekday - 1]} $hhmm';
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')} $hhmm';
  }
}

// ── Badge estado ────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      'submitted' => ('Aprobado',  AppColors.aprobado,  AppColors.aprobadoFondo),
      'rejected'  => ('Rechazado', AppColors.rechazado, const Color(0xFFFFEBEE)),
      _           => ('Pendiente', AppColors.pendiente, AppColors.pendienteFondo),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.montserrat(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

// ── Estado vacío ────────────────────────────────
class _EmptyState extends StatelessWidget {
  final ReportFilter filter;
  final String search;
  const _EmptyState({required this.filter, required this.search});

  @override
  Widget build(BuildContext context) {
    final msg = search.isNotEmpty
        ? 'Sin resultados para "$search"'
        : switch (filter) {
            ReportFilter.pendiente  => 'No tienes reportes pendientes',
            ReportFilter.aprobado   => 'No tienes reportes aprobados',
            ReportFilter.rechazado  => 'No tienes reportes rechazados',
            ReportFilter.todos      => 'Aún no tienes reportes',
          };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.description_outlined,
                  size: 34, color: AppColors.textoGris),
            ),
            const SizedBox(height: 16),
            Text(msg,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                    fontSize: 13, color: AppColors.textoGris)),
          ],
        ),
      ),
    );
  }
}

// ── Error state ─────────────────────────────────
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 40, color: AppColors.textoGris),
          const SizedBox(height: 12),
          Text('Error al cargar los reportes',
              style: GoogleFonts.montserrat(
                  fontSize: 13, color: AppColors.textoGris)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                  color: AppColors.negro,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Reintentar',
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton ────────────────────────────────────
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorde),
          borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 4,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(10))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 12, color: const Color(0xFFF0F0F0)),
                            const SizedBox(height: 6),
                            Container(height: 10, width: 120, color: const Color(0xFFF0F0F0)),
                          ]),
                    ),
                  ]),
                  const Spacer(),
                  Container(height: 1, color: const Color(0xFFEEEEEE)),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 160, color: const Color(0xFFF0F0F0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
