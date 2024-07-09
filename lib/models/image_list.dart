import 'package:image_picker/image_picker.dart';

class ImagesList {
  static final ImagesList _instance = ImagesList._internal();
  factory ImagesList() => _instance;
  ImagesList._internal();
  List<XFile> imagePath = [];

  void clearImagesList() {
    imagePath.clear();
  }
}
