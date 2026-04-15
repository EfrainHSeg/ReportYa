import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/core/utils/app_logger.dart';
import 'package:reportya/features/reports/data/pdf/report_pdf_generator.dart';
import 'package:reportya/features/reports/presentation/views/report_pdf_viewer_view.dart';
import 'package:reportya/features/reports/presentation/views/report_preview_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportSuccessView extends StatefulWidget {
  final String reportId;
  const ReportSuccessView({super.key, required this.reportId});

  @override
  State<ReportSuccessView> createState() => _ReportSuccessViewState();
}

class _ReportSuccessViewState extends State<ReportSuccessView> {
  final _supabase = Supabase.instance.client;

  Map<String, dynamic>? _report;
  String _areaName = '';
  String _areaCode = '';
  String _riskLabel = '';
  String _riskColorHex = '#F59E0B';
  int _photoCount = 0;
  List<String> _imageUrls = [];
  bool _loading = true;
  String? _pdfPath;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      logger.i('Cargando datos del reporte: ${widget.reportId}');

      final report = await _supabase
          .from('reports')
          .select()
          .eq('id', widget.reportId)
          .single();

      final area = await _supabase
          .from('areas')
          .select('name, code')
          .eq('id', report['area_id'])
          .single();

      final risk = await _supabase
          .from('risk_levels')
          .select('label, color_hex')
          .eq('id', report['risk_level_id'])
          .single();

      final images = await _supabase
          .from('report_images')
          .select('url')
          .eq('report_id', widget.reportId);

      setState(() {
        _report = report;
        _areaName = area['name'] as String;
        _areaCode = area['code'] as String? ?? '';
        _riskLabel = risk['label'] as String;
        _riskColorHex = risk['color_hex'] as String;
        _imageUrls =
            (images as List).map((i) => i['url'] as String).toList();
        _photoCount = _imageUrls.length;
        _loading = false;
      });

      logger.i('Datos cargados. Fotos: $_photoCount');
      _generatePdfInBackground(report, area, risk, imageUrls: (images as List).map((i) => i['url'] as String).toList());
    } catch (e, stack) {
      logger.e('Error cargando datos', error: e, stackTrace: stack);
      setState(() => _loading = false);
    }
  }

  Future<void> _generatePdfInBackground(
    Map<String, dynamic> report,
    Map<String, dynamic> area,
    Map<String, dynamic> risk, {
    required List<String> imageUrls,
  }) async {
    try {
      final dt = DateTime.parse(report['created_at'] as String).toLocal();
      final seq = '${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}-001';
      final id = 'RPT-${dt.year}-$seq';
      final user = FirebaseAuth.instance.currentUser;
      final nombre = user?.displayName?.trim().isNotEmpty == true
          ? user!.displayName!
          : user?.email?.split('@')[0] ?? 'Inspector';

      final data = ReporteData(
        id: id,
        titulo: report['title'] as String,
        descripcion: report['description'] as String,
        area: area['name'] as String,
        areaCodigo: area['code'] as String? ?? '',
        nivelRiesgoLabel: risk['label'] as String,
        nivelRiesgoColorHex: risk['color_hex'] as String,
        fecha: DateFormat('dd/MM/yyyy').format(dt),
        hora: DateFormat('HH:mm').format(dt),
        inspectorNombre: nombre,
        inspectorEmail: user?.email ?? '',
        imageUrls: imageUrls,
      );

      final bytes = await ReportePdfGenerator.generate(data);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$id.pdf');
      await file.writeAsBytes(bytes);
      if (mounted) setState(() => _pdfPath = file.path);
      logger.i('PDF listo en background: ${file.path}');
    } catch (e) {
      logger.w('PDF background error: $e');
    }
  }

  Future<void> _shareWhatsApp() async {
    logger.i('[WhatsApp] _pdfPath=$_pdfPath');
    final text = '¡Hola! Te comparto el reporte *$_reportNumber* generado en ReportYa.\n'
        '📋 *${_report?['title'] ?? ''}*\n'
        '📍 Área: $_areaName\n'
        '⚠️ Riesgo: $_riskLabel';

    if (_pdfPath != null) {
      logger.i('[WhatsApp] Compartiendo con archivo PDF');
      try {
        final result = await SharePlus.instance.share(ShareParams(
          files: [XFile(_pdfPath!)],
          text: text,
        ));
        logger.i('[WhatsApp] share result: ${result.status}');
      } catch (e, s) {
        logger.e('[WhatsApp] Error share_plus', error: e, stackTrace: s);
      }
      return;
    }

    logger.w('[WhatsApp] PDF aún no listo, intentando url_launcher');
    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    final canLaunch = await canLaunchUrl(uri);
    logger.i('[WhatsApp] canLaunchUrl=$canLaunch  uri=$uri');
    if (canLaunch) {
      await launchUrl(uri);
    } else {
      logger.e('[WhatsApp] No se puede abrir WhatsApp ni compartir PDF');
    }
  }

  Future<void> _shareGmail() async {
    logger.i('[Gmail] _pdfPath=$_pdfPath');
    if (_pdfPath != null) {
      logger.i('[Gmail] Compartiendo con archivo PDF via share_plus');
      try {
        final result = await SharePlus.instance.share(ShareParams(
          files: [XFile(_pdfPath!)],
          subject: 'Reporte $_reportNumber — ReportYa',
          text: 'Adjunto el reporte $_reportNumber generado con ReportYa.\n'
              'Título: ${_report?['title'] ?? ''}\n'
              'Área: $_areaName  |  Riesgo: $_riskLabel',
        ));
        logger.i('[Gmail] share result: ${result.status}');
      } catch (e, s) {
        logger.e('[Gmail] Error share_plus', error: e, stackTrace: s);
      }
      return;
    }

    logger.w('[Gmail] PDF no listo, intentando mailto');
    final subject = Uri.encodeComponent('Reporte $_reportNumber — ReportYa');
    final body = Uri.encodeComponent(
        'Estimado,\n\nAdjunto el reporte $_reportNumber generado con ReportYa.\n\n'
        'Título: ${_report?['title'] ?? ''}\n'
        'Área: $_areaName\n'
        'Nivel de riesgo: $_riskLabel\n\nSaludos.');
    final uri = Uri.parse('mailto:?subject=$subject&body=$body');
    final canLaunch = await canLaunchUrl(uri);
    logger.i('[Gmail] canLaunchUrl=$canLaunch  uri=$uri');
    if (canLaunch) {
      await launchUrl(uri);
    } else {
      logger.e('[Gmail] No se puede abrir email client');
    }
  }

  Future<void> _shareMore() async {
    logger.i('[Más] _pdfPath=$_pdfPath');
    if (_pdfPath != null) {
      try {
        final result = await SharePlus.instance.share(ShareParams(
          files: [XFile(_pdfPath!)],
          text: 'Reporte $_reportNumber — ReportYa',
        ));
        logger.i('[Más] share result: ${result.status}');
      } catch (e, s) {
        logger.e('[Más] Error share_plus', error: e, stackTrace: s);
      }
    } else {
      logger.w('[Más] PDF no listo, abriendo visor');
      _openPdfViewer();
    }
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  String get _reportNumber {
    final dt = _report != null
        ? DateTime.parse(_report!['created_at'] as String).toLocal()
        : DateTime.now();
    final seq =
        '${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}-001';
    return 'RPT-${dt.year}-$seq';
  }

  String get _pdfFileName =>
      '$_reportNumber-${(_report?['title'] ?? '').toString().replaceAll(' ', '-')}.pdf';

  void _openPreview() {
    if (_report == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportPreviewView(
          report: _report!,
          areaName: _areaName,
          areaCode: _areaCode,
          riskLabel: _riskLabel,
          riskColorHex: _riskColorHex,
          imageUrls: _imageUrls,
        ),
      ),
    );
  }

  void _openPdfViewer() {
    if (_report == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportPdfViewerView(
          report: _report!,
          areaName: _areaName,
          areaCode: _areaCode,
          riskLabel: _riskLabel,
          riskColorHex: _riskColorHex,
          imageUrls: _imageUrls,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.naranjaFerreyros))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.aprobado,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.aprobado
                                    .withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 38),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '¡Reporte enviado!',
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.negro,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tu reporte fue registrado correctamente.\nPuedes ver o descargar el PDF.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: AppColors.textoGris,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSummaryCard(),
                        const SizedBox(height: 20),
                        _buildSectionLabel('DOCUMENTO PDF'),
                        const SizedBox(height: 10),
                        _buildPdfCard(),
                        const SizedBox(height: 20),
                        _buildSectionLabel('COMPARTIR CON'),
                        const SizedBox(height: 10),
                        _buildShareButtons(),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildSummaryCard() {
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
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_rounded,
                    size: 20, color: AppColors.naranjaFerreyros),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _report?['title'] ?? '',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.negro,
                  ),
                ),
              ),
              Text(
                '#${widget.reportId.substring(0, 6).toUpperCase()}',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppColors.textoGris,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryMeta('ÁREA', _areaName, AppColors.negro),
              _summaryMeta('RIESGO', _riskLabel, _hexColor(_riskColorHex)),
              _summaryMeta('FOTOS', '$_photoCount', AppColors.negro),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMeta(String label, String value, Color valueColor) =>
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoGris,
                    letterSpacing: 0.8)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: valueColor)),
          ],
        ),
      );

  // Card naranja — abre vista previa Flutter
  Widget _buildPdfCard() {
    return GestureDetector(
      onTap: _openPreview,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.naranjaFerreyros,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _pdfFileName,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.visibility_rounded,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  // Botones compartir — abren visor PDF con opciones
  Widget _buildShareButtons() {
    final options = [
      _ShareOption(
          faIcon: FontAwesomeIcons.whatsapp,
          label: 'WhatsApp',
          color: const Color(0xFF25D366),
          onTap: _shareWhatsApp),
      _ShareOption(
          faIcon: FontAwesomeIcons.envelope,
          label: 'Gmail',
          color: const Color(0xFFEA4335),
          onTap: _shareGmail),
      _ShareOption(
          faIcon: FontAwesomeIcons.shareNodes,
          label: 'Más',
          color: AppColors.textoGris,
          onTap: _shareMore),
    ];
    return Row(
      children: options.asMap().entries.map((entry) {
        final i = entry.key;
        final o = entry.value;
        return Expanded(
          child: GestureDetector(
            onTap: o.onTap,
            child: Container(
              margin: EdgeInsets.only(right: i < options.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: o.color.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  FaIcon(o.faIcon, color: o.color, size: 26),
                  const SizedBox(height: 6),
                  Text(o.label,
                      style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: o.color)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textoGris,
                letterSpacing: 1.4)),
      );

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        color: AppColors.amarilloCat,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text('Report',
                        style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.negro)),
                    Text('Ya',
                        style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.naranjaFerreyros)),
                    const Spacer(),
                    Text('Ferreyros S.A.',
                        style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.negro.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _bar(0.7),
                    const SizedBox(width: 4),
                    _bar(0.7),
                    const SizedBox(width: 4),
                    _bar(0.7),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(double opacity) => Expanded(
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.negro.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      color: const Color(0xFFF7F7F7),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _openPdfViewer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amarilloCat,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Descargar PDF',
                      style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.negro)),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                        color: AppColors.naranjaFerreyros,
                        shape: BoxShape.circle),
                    child: const Icon(Icons.download_rounded,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.cardBorde),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Ir al inicio →',
                  style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoGris)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareOption {
  final IconData faIcon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ShareOption(
      {required this.faIcon, required this.label, required this.color, required this.onTap});
}
