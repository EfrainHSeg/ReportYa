import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reportya/navigation/informe/pfd/images_list.dart';
import 'package:reportya/navigation/informe/pfd/select_images.dart';

class EvidenciaPage extends StatefulWidget {
  final Map<String, String> formData;

  const EvidenciaPage({Key? key, required this.formData}) : super(key: key);
  @override
  _EvidenciaPageState createState() => _EvidenciaPageState();
}

class _EvidenciaPageState extends State<EvidenciaPage> {
  ImagesList imagesList = ImagesList();
  TextEditingController commentController = TextEditingController();

  Future<PermissionStatus> storagePermissionStatus() async {
    PermissionStatus storagePermissionStatus = await Permission.storage.status;

    if (!storagePermissionStatus.isGranted) {
      await Permission.storage.request();
    }

    storagePermissionStatus = await Permission.storage.status;

    return storagePermissionStatus;
  }

  Future<PermissionStatus> cameraPermissionStatus() async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;

    if (!cameraPermissionStatus.isGranted) {
      await Permission.camera.request();
    }

    cameraPermissionStatus = await Permission.camera.status;

    return cameraPermissionStatus;
  }

  void pickGalleryImage() async {
    PermissionStatus status = await storagePermissionStatus();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        imagesList.clearImagesList();
        imagesList.imagePaths.addAll(images);

        if (!mounted) return;
        setState(() {});
      }
    }
  }

  void captureCameraImages() async {
    PermissionStatus status = await cameraPermissionStatus();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        imagesList.clearImagesList();
        imagesList.imagePaths.add(image);

        if (!mounted) return;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Seleccionar Evidencia"),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imagesList.imagePaths.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: imagesList.imagePaths.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            File(imagesList.imagePaths[index].path),
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
                  icon: Icon(Icons.arrow_back),
                  iconSize: 40,
                ),
                IconButton(
                  onPressed: pickGalleryImage,
                  icon: Icon(Icons.photo_library),
                  iconSize: 40,
                ),
                IconButton(
                  onPressed: captureCameraImages,
                  icon: Icon(Icons.camera_alt),
                  iconSize: 40,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SelectedImages(formData: widget.formData),
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
