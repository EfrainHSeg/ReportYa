import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/core/utils/app_logger.dart';
import 'package:reportya/features/reports/data/pdf/report_pdf_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class ReportPdfViewerView extends StatefulWidget {
  final Map<String, dynamic> report;
  final String areaName;
  final String areaCode;
  final String riskLabel;
  final String riskColorHex;
  final List<String> imageUrls;

  const ReportPdfViewerView({
    super.key,
    required this.report,
    required this.areaName,
    required this.areaCode,
    required this.riskLabel,
    required this.riskColorHex,
    required this.imageUrls,
  });

  @override
  State<ReportPdfViewerView> createState() => _ReportPdfViewerViewState();
}

class _ReportPdfViewerViewState extends State<ReportPdfViewerView> {
  Uint8List? _pdfBytes;
  String? _pdfPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  DateTime get _createdAt =>
      DateTime.parse(widget.report['created_at'] as String).toLocal();

  String get _fechaStr => DateFormat('dd/MM/yyyy').format(_createdAt);
  String get _horaStr => DateFormat('HH:mm').format(_createdAt);

  String get _reportId {
    final dt = _createdAt;
    final seq =
        '${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}-001';
    return 'RPT-${dt.year}-$seq';
  }

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.trim();
    }
    return user?.email?.split('@')[0] ?? 'Inspector';
  }

  String get _userEmail {
    return FirebaseAuth.instance.currentUser?.email ?? '';
  }

  Future<void> _generatePdf() async {
    try {
      logger.i('Generando PDF...');
      final data = ReporteData(
        id: _reportId,
        titulo: widget.report['title'] as String,
        descripcion: widget.report['description'] as String,
        area: widget.areaName,
        areaCodigo: widget.areaCode,
        nivelRiesgoLabel: widget.riskLabel,
        nivelRiesgoColorHex: widget.riskColorHex,
        fecha: _fechaStr,
        hora: _horaStr,
        inspectorNombre: _userName,
        inspectorEmail: _userEmail,
        imageUrls: widget.imageUrls,
      );

      logger.d('Construyendo ReporteData...');
      logger.d('  id: ${data.id}');
      logger.d('  titulo: ${data.titulo}');
      logger.d('  area: ${data.area} (${data.areaCodigo})');
      logger.d('  riesgo: ${data.nivelRiesgoLabel} ${data.nivelRiesgoColorHex}');
      logger.d('  inspector: ${data.inspectorNombre}');
      logger.d('  imageUrls: ${data.imageUrls.length}');

      final bytes = await ReportePdfGenerator.generate(data);
      logger.i('PDF generado — bytes: ${bytes.length}');

      if (bytes.isEmpty) {
        logger.e('PDF vacío — bytes.length == 0');
        if (mounted) setState(() => _loading = false);
        return;
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$_reportId.pdf');
      await file.writeAsBytes(bytes);
      logger.i('PDF guardado en: ${file.path}');

      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _pdfPath = file.path;
        _loading = false;
      });
    } catch (e, stack) {
      logger.e('Error generando PDF', error: e, stackTrace: stack);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _download() async {
    if (_pdfPath == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(_pdfPath!)],
        text: 'Reporte $_reportId — ReportYa',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: Column(
        children: [
          _buildAppBar(context),
          _buildToolbar(),
          Expanded(
            child: _loading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                            color: AppColors.amarilloCat),
                        SizedBox(height: 16),
                        Text('Generando PDF...',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                  )
                : _pdfBytes == null
                    ? Center(
                        child: Text('Error al generar el PDF',
                            style: GoogleFonts.montserrat(
                                color: Colors.white54)),
                      )
                    : PDFView(
                        filePath: _pdfPath!,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        autoSpacing: true,
                        pageFling: false,
                        onError: (e) =>
                            logger.e('PDFView error: $e'),
                        onPageError: (page, e) =>
                            logger.e('PDFView page $page error: $e'),
                      ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.amarilloCat,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DiagPainter())),
          Padding(
            padding: EdgeInsets.fromLTRB(12, top + 10, 12, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _reportId,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (_loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black54),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Text('Página 1 de 1',
              style: GoogleFonts.montserrat(
                  fontSize: 11, color: const Color(0xFF666666))),
          const Spacer(),
          _zoomBtn(Icons.remove_rounded),
          const SizedBox(width: 6),
          Text('100%',
              style: GoogleFonts.montserrat(
                  fontSize: 11, color: const Color(0xFF555555))),
          const SizedBox(width: 6),
          _zoomBtn(Icons.add_rounded),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text('Ajustar',
                style: GoogleFonts.montserrat(
                    fontSize: 10, color: const Color(0xFF555555))),
          ),
        ],
      ),
    );
  }

  Widget _zoomBtn(IconData icon) => Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 12, color: const Color(0xFF666666)),
      );

  Widget _buildBottomBar() {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottom + 10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _loading ? null : _download,
          icon: const Icon(Icons.download_rounded,
              color: Colors.black, size: 18),
          label: Text('Descargar PDF',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amarilloCat,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

// ── Líneas diagonales decorativas ─────────
class _DiagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1A000000)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const spacing = 18.0;
    final total = size.width + size.height;
    for (double i = -total; i < total; i += spacing) {
      canvas.drawLine(
          Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
