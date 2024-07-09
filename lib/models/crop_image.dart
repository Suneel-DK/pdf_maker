import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class CropImagePage extends StatefulWidget {
  final List<File> images;
  final int currentIndex;

  const CropImagePage(
      {super.key, required this.images, required this.currentIndex});

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  late File _imageFile;

  @override
  void initState() {
    super.initState();
    _imageFile = widget.images[widget.currentIndex];
    _cropImage(_imageFile.path);
  }

  Future<void> _cropImage(String path) async {
    CroppedFile? croppedFile =
        await ImageCropper().cropImage(sourcePath: path, uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: false,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
        ],
      ),
    ]);

    if (croppedFile != null) {
      setState(() {
        _imageFile = File(croppedFile.path);
      });
    }
  }

  void _navigateToNextPage() {
    widget.images[widget.currentIndex] = _imageFile;

    if (widget.currentIndex < widget.images.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CropImagePage(
            images: widget.images,
            currentIndex: widget.currentIndex + 1,
          ),
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/selectedimage',
          arguments: widget.images);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _navigateToNextPage,
          ),
        ],
      ),
      body: Center(
        // ignore: unnecessary_null_comparison
        child: _imageFile != null ? Image.file(_imageFile) : Container(),
      ),
    );
  }
}
