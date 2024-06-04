import 'dart:io';
import 'package:flutter/material.dart';
import 'package:external_path/external_path.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:open_file/open_file.dart';
import 'package:reportya/navigation/informe/pfd/images_list.dart';
import 'package:reportya/screens/home_screen.dart';

class SelectedImages extends StatefulWidget {
  final Map<String, String> formData;

  const SelectedImages({Key? key, required this.formData}) : super(key: key);

  @override
  State<SelectedImages> createState() => _SelectedImagesState();
}

class _SelectedImagesState extends State<SelectedImages> {
  ImagesList imagesList = ImagesList();
  double progressValue = 0;
  bool isExporting = false;
  int selectedTemplate = 1;
  String? outputFileUrl;
  bool showExportButton = true;
  bool informeCreado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Generar Informes "),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black87,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      size: 80,
                      color: Colors.red,
                    ),
                    Radio(
                      value: 1,
                      groupValue: selectedTemplate,
                      onChanged: (value) {
                        setState(() {
                          selectedTemplate = value!;
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.description,
                      size: 80,
                      color: Colors.blue,
                    ),
                    Radio(
                      value: 2,
                      groupValue: selectedTemplate,
                      onChanged: (value) {
                        setState(() {
                          selectedTemplate = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Seleccione una plantilla de informe',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Divider(thickness: 1, color: Colors.grey.shade700),
            ListTile(
              title: const Text('Mostrar', style: TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navegar a la página de mostrar informes
              },
            ),
            Divider(thickness: 1, color: Colors.grey.shade700),
            ListTile(
              title: const Text('Compartir', style: TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navegar a la página de compartir informes
              },
            ),
            Divider(thickness: 1, color: Colors.grey.shade700),
            ListTile(
              title: const Text('Personalizar', style: TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navegar a la página de personalizar informes
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (imagesList.imagePaths.isNotEmpty) {
                  final fileName = await showFileNameDialog();
                  if (fileName != null && fileName.isNotEmpty) {
                    if (widget.formData.isNotEmpty) {
                      await convertImage(fileName);
                      setState(() {
                        informeCreado = true;
                      });

                      // Navegar a HomeScreen si se ha creado el informe
                      if (informeCreado) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      }
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                informeCreado ? 'Inicio' : 'Crear',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> showFileNameDialog() async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Introduzca el nombre del archivo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nombre del archivo"),
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
    setState(() {
      isExporting = true;
    });

    try {
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Permiso de almacenamiento no concedido');
      }

      final pathToSave = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOCUMENTS);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Informe de Incidente',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text('Fecha: ${widget.formData['fecha']}'),
                pw.Text('Hora: ${widget.formData['hora']}'),
                pw.Text('¿Qué ocurrió?: ${widget.formData['ocurrio']}'),
                pw.Text('Nivel de Riesgo: ${widget.formData['riesgo']}'),
                pw.Text('Sistema: ${widget.formData['sistema']}'),
                pw.Text('Reportado por: ${widget.formData['reportadoPor']}'),
                pw.SizedBox(height: 20),
                pw.Text('Comentarios: ${widget.formData['Comentarios']}'),
                pw.SizedBox(height: 20),
                for (final imagePath in imagesList.imagePaths)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 20),
                    child: pw.Image(pw.MemoryImage(
                      File(imagePath.path).readAsBytesSync(),
                    )),
                  ),
                pw.Spacer(),
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    'Generado por ReportYa',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'www.ReportYa.com',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Página ${context.pageNumber} de ${context.pagesCount}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Doc. Id.: Ff-1',
                      style: pw.TextStyle(fontSize: 12),
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

      MediaScanner.loadMedia(path: outputFile.path);
      setState(() {
        isExporting = false;
        outputFileUrl = outputFile.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El PDF se ha creado exitosamente: $fileName.pdf'),
        ),
      );
    } catch (e) {
      print('Error al acceder al archivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el PDF: $e'),
        ),
      );
    }
  }

  void viewPdf() {
    if (outputFileUrl != null) {
      OpenFile.open(outputFileUrl!);
    }
  }

  void sharePdf() {
    if (outputFileUrl != null) {
      Share.shareFiles([outputFileUrl!], text: 'Informe de Evidencias');
    }
  }
}
