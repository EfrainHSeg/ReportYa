import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:reportya/core/config/app_config.dart';
import 'package:reportya/features/dashboard/presentation/views/dashboard_view.dart';
import 'package:reportya/features/reports/data/models/report.dart';
import 'package:reportya/features/reports/data/repositories/reports_repository.dart';
import 'package:reportya/features/reports/presentation/viewmodels/report_images_store.dart';
import 'package:reportya/features/reports/presentation/views/pdf_viewer_page.dart';
import 'package:share_plus/share_plus.dart';

class ReportPdfExportView extends StatefulWidget {
  final Map<String, String> formData;

  const ReportPdfExportView({super.key, required this.formData});

  @override
  State<ReportPdfExportView> createState() => _ReportPdfExportViewState();
}

class _ReportPdfExportViewState extends State<ReportPdfExportView> {
  final ReportImagesStore imagesStore = ReportImagesStore();
  int selectedTemplate = 1;
  String? outputFileUrl;
  bool reportCreated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Generar informes'),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black87,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RadioGroup<int>(
              groupValue: selectedTemplate,
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedTemplate = value);
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
                      Radio<int>(value: 1),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.description, size: 80, color: Colors.blue),
                      Radio<int>(value: 2),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Selecciona una plantilla de informe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Divider(thickness: 1, color: Colors.grey.shade700),
            ListTile(
              title: const Text('Mostrar', style: TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (outputFileUrl != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewerPage(path: outputFileUrl!),
                    ),
                  );
                }
              },
            ),
            Divider(thickness: 1, color: Colors.grey.shade700),
            ListTile(
              title: const Text('Compartir', style: TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: sharePdf,
            ),
            Divider(thickness: 1, color: Colors.grey.shade700),
            const ListTile(
              title: Text('Personalizar', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (imagesStore.imagePaths.isNotEmpty) {
                  final fileName = await showFileNameDialog();
                  if (fileName != null &&
                      fileName.isNotEmpty &&
                      widget.formData.isNotEmpty) {
                    await convertImage(fileName);
                    setState(() {
                      reportCreated = true;
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Crear',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            const Spacer(),
            if (reportCreated)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Inicio',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<String?> showFileNameDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Introduce el nombre del archivo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nombre del archivo'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> convertImage(String fileName) async {
    try {
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Permiso de almacenamiento no concedido');
      }

      final pathToSave = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOCUMENTS);
      final directory = Directory(pathToSave);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final pdf = pw.Document();
      final fecha = widget.formData['fecha']!;
      final hora = widget.formData['hora']!;
      final docId = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Informe de incidente',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text('Fecha: $fecha'),
                pw.Text('Hora: $hora'),
                pw.Text('Que ocurrio?: ${widget.formData['ocurrio']}'),
                pw.Text('Nivel de riesgo: ${widget.formData['riesgo']}'),
                pw.Text('Sistema: ${widget.formData['sistema']}'),
                pw.Text('Reportado por: ${widget.formData['reportadoPor']}'),
                if ((widget.formData['comments'] ?? '').isNotEmpty)
                  pw.Text('Comentarios: ${widget.formData['comments']}'),
                pw.SizedBox(height: 20),
                for (final imagePath in imagesStore.imagePaths)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 20),
                    child: pw.Image(
                      pw.MemoryImage(File(imagePath.path).readAsBytesSync()),
                    ),
                  ),
                pw.Spacer(),
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    'Generado por ${AppConfig.appName}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    AppConfig.websiteUrl,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Pagina ${context.pageNumber} de ${context.pagesCount}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Doc. Id.: $docId',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final outputFile = File('$pathToSave/$fileName.pdf');
      await outputFile.writeAsBytes(await pdf.save());
      outputFileUrl = outputFile.path;

      MediaScanner.loadMedia(path: outputFile.path);

      ReportsRepository.reports.add(
        Report(
          name: fileName,
          time: hora,
          description: widget.formData['ocurrio']!,
          riskLevel: widget.formData['riesgo']!,
          reportedBy: widget.formData['reportadoPor']!,
        ),
      );
      await ReportsRepository.save();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El PDF se ha creado exitosamente: $fileName.pdf'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el PDF: $e'),
        ),
      );
    }
  }

  void sharePdf() {
    if (outputFileUrl != null) {
      SharePlus.instance.share(
        ShareParams(
          files: [XFile(outputFileUrl!)],
          text: 'Informe de evidencias',
        ),
      );
    }
  }
}
