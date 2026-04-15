import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:reportya/core/utils/app_logger.dart';

// ═══════════════════════════════════════════
//  MODELO
// ═══════════════════════════════════════════
class ReporteData {
  final String id;
  final String titulo;
  final String descripcion;
  final String area;
  final String areaCodigo;
  final String nivelRiesgoLabel;
  final String nivelRiesgoColorHex;
  final String fecha;
  final String hora;
  final String inspectorNombre;
  final String inspectorEmail;
  final List<String> imageUrls;

  const ReporteData({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.area,
    required this.areaCodigo,
    required this.nivelRiesgoLabel,
    required this.nivelRiesgoColorHex,
    required this.fecha,
    required this.hora,
    required this.inspectorNombre,
    required this.inspectorEmail,
    required this.imageUrls,
  });

  String get signatureText {
    final parts = inspectorNombre.trim().split(' ');
    if (parts.length >= 2) return '${parts[0]} ${parts[1][0]}.';
    return inspectorNombre;
  }

  String get verificationHash {
    final clean = id.replaceAll('-', '');
    final len = clean.length;
    return '${clean.substring(0, len >= 12 ? 12 : len)}\n'
        '${len >= 24 ? clean.substring(12, 24) : ''}\n'
        '${len >= 32 ? clean.substring(24, 32) : ''}';
  }
}

// ═══════════════════════════════════════════
//  GENERADOR
// ═══════════════════════════════════════════
class ReportePdfGenerator {
  // ── Colores ──────────────────────────────
  static const amarillo  = PdfColor(1.0, 0.820, 0.0);
  static const naranja   = PdfColor(0.961, 0.510, 0.122);
  static const negro     = PdfColor(0.067, 0.067, 0.067);
  static const grisClaro = PdfColor(0.980, 0.980, 0.972);
  static const grisBorde = PdfColor(0.933, 0.933, 0.933);
  static const grisTexto = PdfColor(0.533, 0.533, 0.533);
  static const verde     = PdfColor(0.086, 0.639, 0.290);
  static const azul      = PdfColor(0.388, 0.400, 0.945);
  static const blanco    = PdfColor(1.0, 1.0, 1.0);

  static PdfColor _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    final v = int.parse('FF$h', radix: 16);
    return PdfColor(
      ((v >> 16) & 0xFF) / 255.0,
      ((v >> 8) & 0xFF) / 255.0,
      (v & 0xFF) / 255.0,
    );
  }

  // ── Genera el PDF y retorna bytes ────────
  static Future<Uint8List> generate(ReporteData data) async {
    logger.i('ReportePdfGenerator.generate() iniciado');
    final pdf = pw.Document();

    // Cargar logo del app
    pw.ImageProvider? appLogo;
    try {
      final byteData = await rootBundle.load('assets/icons/reportya_icon_1024.png');
      appLogo = pw.MemoryImage(byteData.buffer.asUint8List());
    } catch (e) {
      logger.w('No se pudo cargar logo: $e');
    }

    // Descargar fotos
    final List<pw.ImageProvider> photos = [];
    for (final url in data.imageUrls) {
      try {
        logger.d('Descargando imagen: $url');
        final res = await http.get(Uri.parse(url));
        logger.d('  status: ${res.statusCode} — bytes: ${res.bodyBytes.length}');
        if (res.statusCode == 200) photos.add(pw.MemoryImage(res.bodyBytes));
      } catch (e) {
        logger.w('No se pudo descargar imagen: $url — $e');
      }
    }
    logger.i('Fotos cargadas: ${photos.length}');

    final riesgoColor = _hexColor(data.nivelRiesgoColorHex);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildTitleBand(data),
          ],
        ),
        footer: (ctx) => _buildFooter(data, ctx.pageNumber, ctx.pagesCount),
        build: (ctx) => [
          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: naranja, width: 5),
              ),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _sec('INFORMACIÓN GENERAL'),
                  _buildTablaGeneral(data, riesgoColor),
                  pw.SizedBox(height: 8),

                  _sec('DESCRIPCIÓN DEL EVENTO'),
                  _buildTablaDescripcion(data),
                  pw.SizedBox(height: 3),
                  _buildDescripcionBox(data),
                  pw.SizedBox(height: 8),

                  if (photos.isNotEmpty) ...[
                    _sec('EVIDENCIA FOTOGRÁFICA (${photos.length} FOTOS)'),
                    _buildFotos(photos),
                    pw.SizedBox(height: 8),
                  ],

                  _sec('INSPECTOR RESPONSABLE'),
                  _buildInspector(data, appLogo),
                  pw.SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    logger.i('pdf.save() completado — bytes: ${bytes.length}');
    return bytes;
  }

  // ── HEADER ───────────────────────────────
  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(20, 12, 16, 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: negro, width: 2),
          left: pw.BorderSide(color: naranja, width: 5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 22,
                    height: 22,
                    decoration: const pw.BoxDecoration(
                      color: negro,
                      borderRadius:
                          pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text('RY',
                        style: pw.TextStyle(
                            color: amarillo,
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(width: 6),
                  pw.RichText(
                    text: pw.TextSpan(children: [
                      pw.TextSpan(
                          text: 'Report',
                          style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: negro)),
                      pw.TextSpan(
                          text: 'Ya',
                          style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: naranja)),
                    ]),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Text('SISTEMA DE GESTIÓN DE REPORTES',
                  style: const pw.TextStyle(
                      fontSize: 7, color: grisTexto, letterSpacing: 1)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 13,
                    height: 13,
                    color: naranja,
                    alignment: pw.Alignment.center,
                    child: pw.Text('+',
                        style: pw.TextStyle(
                            color: blanco,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(width: 2),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    color: naranja,
                    child: pw.Text('Ferreyros',
                        style: pw.TextStyle(
                            color: blanco,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(width: 2),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    color: negro,
                    child: pw.Text('CAT',
                        style: pw.TextStyle(
                            color: amarillo,
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1)),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Text('DOCUMENTO OFICIAL',
                  style: const pw.TextStyle(
                      fontSize: 7, color: grisTexto, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  // ── BANDA TÍTULO ─────────────────────────
  static pw.Widget _buildTitleBand(ReporteData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: negro,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('REPORTE DE INSPECCIÓN',
              style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: blanco,
                  letterSpacing: 1)),
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: naranja,
            child: pw.Text(data.id,
                style: pw.TextStyle(
                    color: blanco,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── LABEL SECCIÓN ────────────────────────
  static pw.Widget _sec(String label) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: naranja,
                  letterSpacing: 2)),
          pw.SizedBox(width: 6),
          pw.Expanded(child: pw.Divider(color: grisBorde, thickness: 1)),
        ],
      ),
    );
  }

  // ── TABLA GENERAL ────────────────────────
  static pw.Widget _buildTablaGeneral(
      ReporteData data, PdfColor riesgoColor) {
    return pw.Table(
      border: pw.TableBorder.all(color: grisBorde, width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(2.5),
      },
      children: [
        _tableRow('FECHA', data.fecha),
        _tableRow('HORA', '${data.hora} hrs'),
        _tableRow('ÁREA', data.area),
        pw.TableRow(children: [
          _cellLabel('NIVEL DE RIESGO'),
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            child: pw.Row(children: [
              pw.Container(
                  width: 6,
                  height: 6,
                  decoration: pw.BoxDecoration(
                      color: riesgoColor, shape: pw.BoxShape.circle)),
              pw.SizedBox(width: 4),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                color: const PdfColor(1.0, 0.952, 0.878),
                child: pw.Text(data.nivelRiesgoLabel.toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: riesgoColor)),
              ),
            ]),
          ),
        ]),
        pw.TableRow(children: [
          _cellLabel('ESTADO'),
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            child: pw.Text('Enviado y registrado',
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: negro)),
          ),
        ]),
      ],
    );
  }

  // ── TABLA DESCRIPCIÓN ────────────────────
  static pw.Widget _buildTablaDescripcion(ReporteData data) {
    return pw.Table(
      border: pw.TableBorder.all(color: grisBorde, width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(2.5),
      },
      children: [
        pw.TableRow(children: [
          _cellLabel('TÍTULO'),
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            child: pw.Text(data.titulo,
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: negro)),
          ),
        ]),
      ],
    );
  }

  static pw.Widget _buildDescripcionBox(ReporteData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(
        color: grisClaro,
        border: pw.Border(
            left: pw.BorderSide(color: amarillo, width: 3)),
      ),
      child: pw.Text(data.descripcion,
          style: const pw.TextStyle(
              fontSize: 8.5,
              color: PdfColor(0.267, 0.267, 0.267),
              lineSpacing: 2)),
    );
  }

  // ── FOTOS ────────────────────────────────
  static pw.Widget _buildFotos(List<pw.ImageProvider> photos) {
    final total = photos.length;
    return pw.Row(
      children: List.generate(total, (i) {
        return pw.Expanded(
          child: pw.Padding(
            padding: pw.EdgeInsets.only(right: i < total - 1 ? 5 : 0),
            child: pw.Container(
              height: 150,
              color: blanco,
              child: pw.ClipRRect(
                horizontalRadius: 3,
                verticalRadius: 3,
                child: pw.Image(photos[i], fit: pw.BoxFit.contain),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── INSPECTOR ────────────────────────────
  static pw.Widget _buildInspector(ReporteData data, pw.ImageProvider? logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: pw.BoxDecoration(
        color: grisClaro,
        border: pw.Border.all(color: grisBorde),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 48,
            height: 48,
            decoration: const pw.BoxDecoration(
                color: negro, shape: pw.BoxShape.circle),
            alignment: pw.Alignment.center,
            child: logo != null
                ? pw.ClipOval(
                    child: pw.Image(logo,
                        width: 48, height: 48, fit: pw.BoxFit.cover))
                : pw.Text(
                    data.inspectorNombre.isNotEmpty
                        ? data.inspectorNombre[0].toUpperCase()
                        : 'I',
                    style: pw.TextStyle(
                        color: blanco,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 8),
          pw.Text(data.inspectorNombre,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: negro)),
          pw.SizedBox(height: 2),
          pw.Text('Inspector de campo · Ferreyros S.A.',
              style: const pw.TextStyle(fontSize: 8, color: grisTexto)),
          pw.SizedBox(height: 2),
          pw.Text('Firmado: ${data.fecha} · ${data.hora} hrs',
              style: const pw.TextStyle(fontSize: 8, color: grisTexto)),
        ],
      ),
    );
  }

  // ── FOOTER ───────────────────────────────
  static pw.Widget _buildFooter(ReporteData data, int pageNumber, int pagesCount) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      color: negro,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(
                  text: 'Report',
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: blanco)),
              pw.TextSpan(
                  text: 'Ya',
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: amarillo)),
            ]),
          ),
          pw.Text('Ferreyros S.A. · Documento Confidencial',
              style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColor(0.333, 0.333, 0.333))),
          pw.Text('Pág. $pageNumber / $pagesCount',
              style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColor(0.333, 0.333, 0.333))),
        ],
      ),
    );
  }

  // ── HELPERS ──────────────────────────────
  static pw.TableRow _tableRow(String label, String value) {
    return pw.TableRow(children: [
      _cellLabel(label),
      pw.Container(
        padding:
            const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: pw.Text(value,
            style: const pw.TextStyle(
                fontSize: 9, color: PdfColor(0.0, 0.0, 0.0))),
      ),
    ]);
  }

  static pw.Widget _cellLabel(String label) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      color: grisClaro,
      child: pw.Text(label,
          style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
              color: grisTexto,
              letterSpacing: 0.5)),
    );
  }
}
