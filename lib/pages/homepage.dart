import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:pdfmaker/models/image_list.dart';
import 'package:pdfmaker/models/crop_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ImagesList imagesList = ImagesList();

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.storage,
      Permission.camera,
    ].request();
  }

  Future<void> pickGalleryImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        imagesList.imagePath.addAll(images);
      });
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImagePage(
            images: imagesList.imagePath.map((e) => File(e.path)).toList(),
            currentIndex: 0,
          ),
        ),
      );
    }
  }

  Future<void> captureCameraImages() async {
    PermissionStatus cameraPermission = await Permission.camera.status;
    if (cameraPermission.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          imagesList.imagePath.add(image);
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CropImagePage(
              images: imagesList.imagePath.map((e) => File(e.path)).toList(),
              currentIndex: 0,
            ),
          ),
        );
      }
    } else {
      PermissionStatus newStatus = await Permission.camera.request();
      if (newStatus.isGranted) {
        captureCameraImages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: captureCameraImages,
              color: Colors.black,
              textColor: Colors.white,
              child: const Text("Open Camera"),
            ),
            const SizedBox(height: 50),
            MaterialButton(
              onPressed: pickGalleryImage,
              color: Colors.black,
              textColor: Colors.white,
              child: const Text("Open Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}
