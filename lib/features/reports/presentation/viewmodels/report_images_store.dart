import 'package:image_picker/image_picker.dart';

class ReportImagesStore {
  static final ReportImagesStore _instance = ReportImagesStore._internal();
  factory ReportImagesStore() => _instance;

  ReportImagesStore._internal();

  List<XFile> imagePaths = [];

  void clear() {
    imagePaths.clear();
  }
}
