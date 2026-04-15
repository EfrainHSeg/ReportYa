import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reportya/features/reports/presentation/viewmodels/report_images_store.dart';
import 'package:reportya/features/reports/presentation/views/report_pdf_export_view.dart';

class ReportEvidenceView extends StatefulWidget {
  final Map<String, String> formData;

  const ReportEvidenceView({super.key, required this.formData});

  @override
  State<ReportEvidenceView> createState() => _ReportEvidenceViewState();
}

class _ReportEvidenceViewState extends State<ReportEvidenceView> {
  final ReportImagesStore imagesStore = ReportImagesStore();
  final TextEditingController commentController = TextEditingController();

  Future<PermissionStatus> requestPermission(Permission permission) async {
    var status = await permission.status;
    if (!status.isGranted) {
      status = await permission.request();
    }
    return status;
  }

  void pickGalleryImage() async {
    final status = await requestPermission(Permission.storage);

    if (status.isGranted) {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        imagesStore.clear();
        imagesStore.imagePaths.addAll(images);

        if (!mounted) return;
        setState(() {});
      }
    }
  }

  void captureCameraImage() async {
    final status = await requestPermission(Permission.camera);

    if (status.isGranted) {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        imagesStore.imagePaths.add(image);

        if (!mounted) return;
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Seleccionar evidencia'),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imagesStore.imagePaths.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: imagesStore.imagePaths.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            File(imagesStore.imagePaths[index].path),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 20),
            TextFormField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Comentarios',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 40,
                ),
                IconButton(
                  onPressed: pickGalleryImage,
                  icon: const Icon(Icons.photo_library),
                  iconSize: 40,
                ),
                IconButton(
                  onPressed: captureCameraImage,
                  icon: const Icon(Icons.camera_alt),
                  iconSize: 40,
                ),
                IconButton(
                  onPressed: () {
                    widget.formData['comments'] = commentController.text;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReportPdfExportView(formData: widget.formData),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 40,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
