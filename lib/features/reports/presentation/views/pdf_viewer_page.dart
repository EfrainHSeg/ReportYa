import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerPage extends StatelessWidget {
  final String path;

  const PdfViewerPage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black87,
      ),
      body: PDFView(
        filePath: path,
      ),
    );
  }
}
