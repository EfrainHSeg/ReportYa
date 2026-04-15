import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reportya/core/theme/app_colors.dart';

class ReportPreviewView extends StatelessWidget {
  final Map<String, dynamic> report;
  final String areaName;
  final String areaCode;
  final String riskLabel;
  final String riskColorHex;
  final List<String> imageUrls;

  const ReportPreviewView({
    super.key,
    required this.report,
    required this.areaName,
    required this.areaCode,
    required this.riskLabel,
    required this.riskColorHex,
    required this.imageUrls,
  });

  Color get _riskColor {
    final h = riskColorHex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  DateTime get _createdAt =>
      DateTime.parse(report['created_at'] as String).toLocal();

  String get _fechaStr => DateFormat('dd/MM/yyyy').format(_createdAt);
  String get _horaStr => DateFormat('HH:mm').format(_createdAt);

  String get _reportNumber {
    final dt = _createdAt;
    final seq =
        '${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}-001';
    return 'RPT-${dt.year}-$seq';
  }

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      final parts = user.displayName!.trim().split(' ');
      if (parts.length >= 2) return '${parts[0]} ${parts[1][0]}.';
      return parts[0];
    }
    return user?.email?.split('@')[0] ?? 'Inspector';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header tarjeta ──
            _card(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.amarilloCat,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description_rounded,
                        size: 18, color: AppColors.negro),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reporte de Inspección',
                            style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.negro)),
                        Text('ID: $_reportNumber',
                            style: GoogleFonts.montserrat(
                                fontSize: 10,
                                color: AppColors.textoGris)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.aprobadoFondo,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Enviado',
                        style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.aprobado)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Fecha / Hora ──
            Row(
              children: [
                Expanded(
                  child: _infoBox(
                    label: 'FECHA',
                    value: _fechaStr,
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoBox(
                    label: 'HORA',
                    value: _horaStr,
                    icon: Icons.access_time_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Área / Riesgo ──
            Row(
              children: [
                Expanded(
                  child: _infoBox(
                    label: 'ÁREA',
                    value: areaName,
                    valueColor: AppColors.naranjaFerreyros,
                    icon: Icons.factory_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoBox(
                    label: 'NIVEL DE RIESGO',
                    value: riskLabel.toUpperCase(),
                    valueColor: _riskColor,
                    dot: _riskColor,
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Detalle ──
            _sectionLabel('DETALLE DEL REPORTE'),
            const SizedBox(height: 8),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TÍTULO',
                      style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textoGris,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  Text(report['title'] as String,
                      style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.negro)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _card(
              color: const Color(0xFFF5F5F5),
              child: Text(
                report['description'] as String,
                style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppColors.textoGrisOscuro,
                    height: 1.5),
              ),
            ),
            const SizedBox(height: 16),

            // ── Fotos ──
            if (imageUrls.isNotEmpty) ...[
              _sectionLabel(
                  'EVIDENCIA FOTOGRÁFICA (${imageUrls.length} FOTOS)'),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: imageUrls.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              color: AppColors.cardBorde,
                              child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.naranjaFerreyros),
                              ),
                            ),
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardBorde,
                        child: const Icon(Icons.broken_image_rounded,
                            color: AppColors.textoGris),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // ── Firma digital ──
            _sectionLabel('INSPECTOR RESPONSABLE'),
            const SizedBox(height: 8),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FIRMA DIGITAL',
                      style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textoGris,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  Text(
                    _userName,
                    style: GoogleFonts.dancingScript(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.negro,
                    ),
                  ),
                  const Divider(
                      height: 16, thickness: 1, color: Color(0xFFDDDDDD)),
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 14, color: AppColors.aprobado),
                      const SizedBox(width: 6),
                      Text('Firmado digitalmente · ReportYa',
                          style: GoogleFonts.montserrat(
                              fontSize: 11, color: AppColors.textoGris)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Footer oficial ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.naranjaFerreyros, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.naranjaFerreyros,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.star_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FERREYROS S.A. • OFICIAL',
                            style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.naranjaFerreyros)),
                        Text(
                            'Documento generado y validado por ReportYa',
                            style: GoogleFonts.montserrat(
                                fontSize: 10,
                                color: AppColors.textoGris)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        color: AppColors.amarilloCat,
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.negro, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Vista previa',
                    style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.negro)),
                const Spacer(),
                Text('Paso 3 de 3',
                    style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.negro.withValues(alpha: 0.55))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child, Color? color}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          border:
              color == null ? Border.all(color: AppColors.cardBorde) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );

  Widget _sectionLabel(String text) => Text(text,
      style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textoGris,
          letterSpacing: 1.4));

  Widget _infoBox({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    Color? dot,
  }) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorde),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoGris,
                    letterSpacing: 0.8)),
            const SizedBox(height: 4),
            Row(
              children: [
                if (dot != null) ...[
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: dot, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(value,
                      style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: valueColor ?? AppColors.negro),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      );
}
