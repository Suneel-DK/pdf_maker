import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdfmaker/models/crop_image.dart';
import 'package:pdfmaker/models/image_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PdfListScreen extends StatefulWidget {
  @override
  State<PdfListScreen> createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  late Box pdfBox;
  ImagesList imagesList = ImagesList();

  @override
  void initState() {
    super.initState();
    pdfBox = Hive.box('pdfBox');
    requestPermissions();
  }

  Future<void> deletePdf(String key) async {
    await pdfBox.delete(key);
    setState(() {});
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImagePage(
            images: images.map((e) => File(e.path)).toList(),
            currentIndex: 0,
          ),
        ),
      ).then((croppedImages) {
        if (croppedImages != null && croppedImages.isNotEmpty) {
          setState(() {
            imagesList.imagePath.addAll(
              croppedImages.map((file) => XFile(file.path)).toList(),
            );
          });
        }
      });
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
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.red.withOpacity(0.8),
        foregroundColor: Colors.black,
        activeBackgroundColor: Colors.red.withOpacity(0.8),
        activeForegroundColor: Colors.white,
        childrenButtonSize: const Size(60, 60),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera, color: Colors.black),
            backgroundColor: Colors.red.withOpacity(0.8),
            label: 'Add Image from Camera',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: captureCameraImages,
          ),
          SpeedDialChild(
            child: const Icon(Icons.image, color: Colors.black),
            backgroundColor: Colors.red.withOpacity(0.8),
            label: 'Add Image from Gallery',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: pickGalleryImage,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: pdfBox.listenable(),
        builder: (context, Box box, widget) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/Vector.png'),
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "No PDF's found",
                    style: GoogleFonts.kadwa(fontSize: 20, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index) as String;
              final pdfBytes = box.get(key) as List<int>;

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.black),
                  ),
                  child: ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.edit_document),
                    title: Text(key),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () async {
                            // Create a temporary file to share
                            final tempDir = await getTemporaryDirectory();
                            final tempFile = File('${tempDir.path}/$key.pdf');
                            await tempFile.writeAsBytes(pdfBytes);

                            // Share the PDF file with the correct MIME type
                            await Share.shareXFiles(
                              [
                                XFile(tempFile.path,
                                    mimeType: 'application/pdf')
                              ],
                              text: 'Sharing $key.pdf',
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deletePdf(key),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
