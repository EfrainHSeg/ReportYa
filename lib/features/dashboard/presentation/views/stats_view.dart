import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/features/dashboard/presentation/viewmodels/stats_viewmodel.dart';

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  final _vm = StatsViewModel();

  @override
  void initState() {
    super.initState();
    _vm.load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeriodFilter(
              selected: _vm.periodo,
              onSelected: _vm.setPeriodo,
            ),
            const SizedBox(height: 16),
            if (_vm.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: CircularProgressIndicator(color: AppColors.naranjaFerreyros),
                ),
              )
            else ...[
              _MetricGrid(vm: _vm),
              const SizedBox(height: 16),
              _BarCard(vm: _vm),
              const SizedBox(height: 16),
              _DonutCard(vm: _vm),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Filtro período ─────────────────────────────
class _PeriodFilter extends StatelessWidget {
  final StatsPeriodo selected;
  final ValueChanged<StatsPeriodo> onSelected;
  const _PeriodFilter({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StatsPeriodo.values.map((p) {
          final sel = p == selected;
          return GestureDetector(
            onTap: () => onSelected(p),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.negro : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(p.label,
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppColors.textoGris)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Grid 2x2 métricas ──────────────────────────
class _MetricGrid extends StatelessWidget {
  final StatsViewModel vm;
  const _MetricGrid({required this.vm});

  @override
  Widget build(BuildContext context) {
    final avgDiff = vm.avgSemana - vm.avgSemanaPrev;
    return Column(
      children: [
        Row(children: [
          Expanded(child: _MetricCard(
            icon: Icons.description_rounded,
            iconColor: AppColors.naranjaFerreyros,
            iconBg: const Color(0xFFFFF3E0),
            value: '${vm.total}',
            label: 'Reportes totales',
            trend: '${vm.diffStr(vm.total, vm.totalPrev)} vs período anterior',
            trendUp: vm.total >= vm.totalPrev,
          )),
          const SizedBox(width: 12),
          Expanded(child: _MetricCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppColors.aprobado,
            iconBg: AppColors.aprobadoFondo,
            value: '${vm.tasaAprobacion.toStringAsFixed(0)}%',
            valueColor: AppColors.aprobado,
            label: 'Tasa aprobación',
            trend: vm.totalPrev == 0
                ? 'Sin período anterior'
                : '${vm.tasaAprobacion >= vm.tasaAprobacionPrev ? '+' : ''}${(vm.tasaAprobacion - vm.tasaAprobacionPrev).toStringAsFixed(0)}% vs anterior',
            trendUp: vm.tasaAprobacion >= vm.tasaAprobacionPrev,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _MetricCard(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.pendiente,
            iconBg: AppColors.pendienteFondo,
            value: '${vm.pendientes}',
            valueColor: AppColors.pendiente,
            label: 'Pendientes',
            trend: '${vm.diffStr(vm.pendientes, vm.pendientesPrev)} vs anterior',
            trendUp: vm.pendientes <= vm.pendientesPrev,
          )),
          const SizedBox(width: 12),
          Expanded(child: _MetricCard(
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.naranjaFerreyros,
            iconBg: const Color(0xFFFFF3E0),
            value: vm.avgSemana.toStringAsFixed(1),
            label: 'Promedio / semana',
            trend: avgDiff >= 0 ? '↑ vs período anterior' : '↓ vs período anterior',
            trendUp: avgDiff >= 0,
          )),
        ]),
      ],
    );
  }
}

// ── Gráfica barras ─────────────────────────────
class _BarCard extends StatelessWidget {
  final StatsViewModel vm;
  const _BarCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.barras.isEmpty || vm.barras.every((b) => b.creados == 0)) {
      return const _EmptyCard(title: 'Reportes por período', msg: 'Sin datos en este período');
    }
    final maxY = vm.barras.map((b) => b.creados).reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorde),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Reportes por período',
                    style: GoogleFonts.montserrat(
                        fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.negro)),
                Text(vm.periodo.barLabel,
                    style: GoogleFonts.montserrat(fontSize: 10, color: AppColors.textoGris)),
              ]),
              const Row(children: [
                _LegendDot(color: AppColors.amarilloCat, label: 'Creados'),
                SizedBox(width: 10),
                _LegendDot(color: AppColors.aprobado, label: 'Aprobados'),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: BarChart(BarChartData(
              maxY: (maxY + 2).ceilToDouble(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= vm.barras.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('${vm.barras[i].creados}',
                            style: GoogleFonts.montserrat(fontSize: 9, color: AppColors.textoGris)),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= vm.barras.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(vm.barras[i].label,
                            style: GoogleFonts.montserrat(
                                fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textoGris)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(vm.barras.length, (i) {
                final b = vm.barras[i];
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: b.creados.toDouble(),
                    color: AppColors.amarilloCat,
                    width: 10,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  BarChartRodData(
                    toY: b.aprobados.toDouble(),
                    color: AppColors.aprobado,
                    width: 10,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ]);
              }),
              barTouchData: BarTouchData(enabled: false),
            )),
          ),
        ],
      ),
    );
  }
}

// ── Gráfica dona ───────────────────────────────
class _DonutCard extends StatelessWidget {
  final StatsViewModel vm;
  const _DonutCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.total == 0) return const _EmptyCard(title: 'Distribución', msg: 'Sin datos en este período');

    final rechazados = vm.total - vm.aprobados - vm.pendientes;
    final sections = <PieChartSectionData>[
      if (vm.aprobados > 0)
        PieChartSectionData(value: vm.aprobados.toDouble(), color: AppColors.aprobado, radius: 40, showTitle: false),
      if (vm.pendientes > 0)
        PieChartSectionData(value: vm.pendientes.toDouble(), color: AppColors.pendiente, radius: 40, showTitle: false),
      if (rechazados > 0)
        PieChartSectionData(value: rechazados.toDouble(), color: AppColors.rechazado, radius: 40, showTitle: false),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorde),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribución',
              style: GoogleFonts.montserrat(
                  fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.negro)),
          const SizedBox(height: 16),
          Row(children: [
            SizedBox(
              width: 120,
              height: 120,
              child: PieChart(PieChartData(
                sections: sections,
                centerSpaceRadius: 35,
                sectionsSpace: 2,
                startDegreeOffset: -90,
              )),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _DonutRow('Aprobados', vm.aprobados, AppColors.aprobado),
                const SizedBox(height: 10),
                _DonutRow('Pendientes', vm.pendientes, AppColors.pendiente),
                if (rechazados > 0) ...[
                  const SizedBox(height: 10),
                  _DonutRow('Rechazados', rechazados, AppColors.rechazado),
                ],
                const SizedBox(height: 10),
                const Divider(color: AppColors.cardBorde, height: 1),
                const SizedBox(height: 10),
                _DonutRow('Total', vm.total, AppColors.negro),
              ]),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final Color? valueColor;
  final String label;
  final String trend;
  final bool trendUp;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendUp,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorde),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.montserrat(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.negro)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.montserrat(fontSize: 10, color: AppColors.textoGris)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(
              trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              size: 12,
              color: trendUp ? AppColors.aprobado : AppColors.rechazado,
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(trend,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: trendUp ? AppColors.aprobado : AppColors.rechazado)),
            ),
          ]),
        ],
      ),
    );
  }
}

class _DonutRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _DonutRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Text(label,
          style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textoGris))),
      Text('$value',
          style: GoogleFonts.montserrat(
              fontSize: 12, fontWeight: FontWeight.w800, color: color)),
    ]);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.montserrat(fontSize: 9, color: AppColors.textoGris)),
    ]);
  }
}

class _EmptyCard extends StatelessWidget {
  final String title;
  final String msg;
  const _EmptyCard({required this.title, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorde),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.montserrat(
            fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.negro)),
        const SizedBox(height: 20),
        Center(child: Text(msg, style: GoogleFonts.montserrat(
            fontSize: 12, color: AppColors.textoGris))),
        const SizedBox(height: 8),
      ]),
    );
  }
}
