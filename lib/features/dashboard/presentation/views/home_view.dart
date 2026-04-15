import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/features/reports/presentation/views/new_report_form_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ReporteEstado { pendiente, aprobado, rechazado }

class _ReporteDisplay {
  final String titulo;
  final String subtitulo;
  final String fecha;
  final String hora;
  final String tiempoTranscurrido;
  final ReporteEstado estado;

  const _ReporteDisplay({
    required this.titulo,
    required this.subtitulo,
    required this.fecha,
    required this.hora,
    required this.tiempoTranscurrido,
    required this.estado,
  });
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  int _total = 0;
  int _pendientes = 0;
  int _completados = 0;
  _ReporteDisplay? _ultimoReporte;
  List<_ReporteDisplay> _recientes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _tiempoTranscurrido(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays}d';
  }

  ReporteEstado _mapEstado(String? status) {
    if (status == 'reviewed' || status == 'closed') return ReporteEstado.aprobado;
    if (status == 'rejected') return ReporteEstado.rechazado;
    return ReporteEstado.pendiente;
  }

  _ReporteDisplay _toDisplay(Map<String, dynamic> r) {
    final dt = DateTime.parse(r['created_at'] as String).toLocal();
    final areaName = (r['areas'] as Map<String, dynamic>?)?['name'] as String? ?? '—';
    return _ReporteDisplay(
      titulo: r['title'] as String? ?? '—',
      subtitulo: areaName,
      fecha: DateFormat('dd/MM/yyyy').format(dt),
      hora: DateFormat('HH:mm').format(dt),
      tiempoTranscurrido: _tiempoTranscurrido(dt),
      estado: _mapEstado(r['status'] as String?),
    );
  }

  Future<void> _loadData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Conteos reales (sin límite)
      final counts = await _supabase
          .from('reports')
          .select('status')
          .eq('reported_by', uid);
      final countList = List<Map<String, dynamic>>.from(counts as List);

      // Solo los últimos 5 para mostrar en pantalla
      final rows = await _supabase
          .from('reports')
          .select('id, title, status, created_at, areas(name)')
          .eq('reported_by', uid)
          .order('created_at', ascending: false)
          .limit(5);

      final display = List<Map<String, dynamic>>.from(rows as List);
      final displays = display.map(_toDisplay).toList();

      setState(() {
        _total      = countList.length;
        _pendientes = countList.where((r) => r['status'] == 'draft').length;
        _completados = countList.where((r) => r['status'] == 'submitted').length;
        _ultimoReporte = displays.isNotEmpty ? displays.first : null;
        _recientes = displays.length > 1 ? displays.sublist(1) : [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _getNombre() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      final partes = user.displayName!.trim().split(' ');
      if (partes.length >= 2) return '${partes[0]} ${partes[1]}';
      return partes[0];
    }
    return user.email?.split('@')[0] ?? '';
  }

  String _getSaludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días 👋';
    if (hora < 18) return 'Buenas tardes 👋';
    return 'Buenas noches 👋';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GreetingSection(
                  greeting: _getSaludo(),
                  name: _getNombre(),
                ),
                const SizedBox(height: 14),
                _loading
                    ? const _MetricsRowSkeleton()
                    : _MetricsRow(
                        total: _total,
                        pendientes: _pendientes,
                        completados: _completados,
                      ),
                const SizedBox(height: 12),
                _NewReportButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewReportFormView(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_loading) ...[
                  const _CardSkeleton(height: 110),
                ] else if (_ultimoReporte != null) ...[
                  const _SectionLabel(label: 'ÚLTIMO REPORTE'),
                  const SizedBox(height: 8),
                  _UltimoReporteCard(reporte: _ultimoReporte!),
                ],
                if (_recientes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel(label: 'RECIENTES'),
                  const SizedBox(height: 8),
                  ..._recientes.map((r) => _ReporteTile(reporte: r)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Saludo ──────────────────────────────────
class _GreetingSection extends StatelessWidget {
  final String greeting;
  final String name;
  const _GreetingSection({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppColors.textoGris,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          name,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.negro,
          ),
        ),
      ],
    );
  }
}

// ── 3 Métricas ──────────────────────────────
class _MetricsRow extends StatelessWidget {
  final int total;
  final int pendientes;
  final int completados;
  const _MetricsRow({
    required this.total,
    required this.pendientes,
    required this.completados,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetricCard(
            value: '$total', label: 'TOTAL', color: AppColors.naranjaFerreyros),
        const SizedBox(width: 8),
        _MetricCard(
            value: '$pendientes',
            label: 'PENDIENTE',
            color: AppColors.pendiente),
        const SizedBox(width: 8),
        _MetricCard(
            value: '$completados',
            label: 'COMPLETADO',
            color: AppColors.aprobado),
      ],
    );
  }
}

class _MetricsRowSkeleton extends StatelessWidget {
  const _MetricsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (_) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.cardBorde,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  final double height;
  const _CardSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBorde,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MetricCard(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: AppColors.cardBlanco,
          border: Border.all(color: AppColors.cardBorde),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 8,
                color: AppColors.textoGris,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Botón Nuevo Reporte ──────────────────────
class _NewReportButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _NewReportButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amarilloCat,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '+ Nuevo reporte',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.negro,
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.naranjaFerreyros,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Label sección ────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.montserrat(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textoGris,
        letterSpacing: 1.5,
      ),
    );
  }
}

// ── Card último reporte ──────────────────────
class _UltimoReporteCard extends StatelessWidget {
  final _ReporteDisplay reporte;
  const _UltimoReporteCard({required this.reporte});

  Color get _estadoColor => switch (reporte.estado) {
        ReporteEstado.pendiente => AppColors.pendiente,
        ReporteEstado.aprobado  => AppColors.aprobado,
        ReporteEstado.rechazado => AppColors.rechazado,
      };

  Color get _estadoFondo => switch (reporte.estado) {
        ReporteEstado.pendiente => AppColors.pendienteFondo,
        ReporteEstado.aprobado  => AppColors.aprobadoFondo,
        ReporteEstado.rechazado => AppColors.rechazadoFondo,
      };

  String get _estadoLabel => switch (reporte.estado) {
        ReporteEstado.pendiente => 'Pendiente',
        ReporteEstado.aprobado  => 'Enviado',
        ReporteEstado.rechazado => 'Rechazado',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBlanco,
        border: Border.all(color: AppColors.cardBorde),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${reporte.fecha} · ${reporte.hora}',
                style: GoogleFonts.montserrat(
                    fontSize: 10, color: AppColors.textoGris),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _estadoFondo,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _estadoLabel,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _estadoColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reporte.titulo,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.negro,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            reporte.subtitulo,
            style: GoogleFonts.montserrat(
                fontSize: 11, color: AppColors.textoGris),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MetaChip(
                  icon: Icons.access_time_rounded,
                  label: reporte.tiempoTranscurrido),
              const SizedBox(width: 14),
              _MetaChip(
                  icon: Icons.factory_rounded,
                  label: reporte.subtitulo),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textoGris),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.montserrat(
              fontSize: 10, color: AppColors.textoGris),
        ),
      ],
    );
  }
}

// ── Tile reporte reciente ────────────────────
class _ReporteTile extends StatelessWidget {
  final _ReporteDisplay reporte;
  const _ReporteTile({required this.reporte});

  Color get _color => switch (reporte.estado) {
        ReporteEstado.pendiente => AppColors.pendiente,
        ReporteEstado.aprobado  => AppColors.aprobado,
        ReporteEstado.rechazado => AppColors.rechazado,
      };

  Color get _fondo => switch (reporte.estado) {
        ReporteEstado.pendiente => AppColors.pendienteFondo,
        ReporteEstado.aprobado  => AppColors.aprobadoFondo,
        ReporteEstado.rechazado => AppColors.rechazadoFondo,
      };

  String get _label => switch (reporte.estado) {
        ReporteEstado.pendiente => 'Pendiente',
        ReporteEstado.aprobado  => 'Enviado',
        ReporteEstado.rechazado => 'Rechazado',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBlanco,
        border: Border.all(color: AppColors.cardBorde),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.description_rounded,
                size: 18, color: AppColors.naranjaFerreyros),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reporte.titulo,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.negro,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${reporte.subtitulo} · ${reporte.tiempoTranscurrido}',
                  style: GoogleFonts.montserrat(
                      fontSize: 11, color: AppColors.textoGris),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _fondo,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
