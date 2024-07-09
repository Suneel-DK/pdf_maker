import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:pdfmaker/models/image_list.dart';
import 'package:pdfmaker/models/crop_image.dart';
import 'package:permission_handler/permission_handler.dart';

class SelectedImages extends StatefulWidget {
  const SelectedImages({super.key});

  @override
  State<SelectedImages> createState() => _SelectedImagesState();
}

class _SelectedImagesState extends State<SelectedImages> {
  ImagesList imagesList = ImagesList();

  late double progressValue = 0;
  late bool isExporting = false;
  late int convertedImage = 0;
  TextEditingController pdfNameController =
      TextEditingController(text: "TestPdf");

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as List<File>?;
    if (args != null) {
      imagesList.imagePath
          .addAll(args.map((file) => XFile(file.path)).toList());
    }
  }

  Future<img.Image?> compressImage(File file) async {
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image != null) {
      final resizedImage =
          img.copyResize(image, width: 800); // Resize the image
      return resizedImage;
    }
    return null;
  }

  void convertImage() async {
    setState(() {
      isExporting = true;
    });

    final pdf = pw.Document();
    for (final imagePath in imagesList.imagePath) {
      final compressedImage = await compressImage(File(imagePath.path));
      if (compressedImage != null) {
        final pdfImage = pw.MemoryImage(img.encodeJpg(compressedImage));
        pdf.addPage(pw.Page(build: (pw.Context context) {
          return pw.Center(child: pw.Image(pdfImage));
        }));
      }
      setState(() {
        convertedImage++;
        progressValue = convertedImage / imagesList.imagePath.length;
      });
    }

    final pdfName = pdfNameController.text;
    final pdfBytes = await pdf.save();

    // Save the PDF in Hive
    final pdfBox = Hive.box('pdfBox');
    pdfBox.put(pdfName, pdfBytes);

    setState(() {
      isExporting = false;
      convertedImage = 0;
      progressValue = 0;
      imagesList.imagePath.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved as $pdfName.pdf')),
    );

    // Navigate to the PDF list screen
    Navigator.pushNamed(context, '/landing');
  }

  Future<void> addImagesFromGallery() async {
    PermissionStatus storagePermission = await Permission.storage.status;
    if (storagePermission.isGranted) {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CropImagePage(
              images: images.map((xFile) => File(xFile.path)).toList(),
              currentIndex: 0,
            ),
          ),
        ).then((croppedImages) {
          if (croppedImages != null) {
            setState(() {
              imagesList.imagePath.addAll(
                  croppedImages.map((file) => XFile(file.path)).toList());
            });
          }
        });
      }
    } else {
      PermissionStatus newStatus = await Permission.storage.request();
      if (newStatus.isGranted) {
        addImagesFromGallery();
      }
    }
  }

  Future<void> addImagesFromCamera() async {
    PermissionStatus cameraPermission = await Permission.camera.status;
    if (cameraPermission.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CropImagePage(
              images: [File(image.path)],
              currentIndex: 0,
            ),
          ),
        ).then((croppedImages) {
          if (croppedImages != null) {
            setState(() {
              imagesList.imagePath.addAll(
                  croppedImages.map((file) => XFile(file.path)).toList());
            });
          }
        });
      }
    } else {
      PermissionStatus newStatus = await Permission.camera.request();
      if (newStatus.isGranted) {
        addImagesFromCamera();
      }
    }
  }

  void removeImage(int index) {
    setState(() {
      imagesList.imagePath.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selected Images"),
        centerTitle: true,
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.black,
        activeForegroundColor: Colors.white,
        childrenButtonSize: const Size(60, 60),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera, color: Colors.white),
            backgroundColor: Colors.black,
            label: 'Add Image from Camera',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: addImagesFromCamera,
          ),
          SpeedDialChild(
            child: const Icon(Icons.image, color: Colors.white),
            backgroundColor: Colors.black,
            label: 'Add Image from Gallery',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: addImagesFromGallery,
          ),
        ],
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.black,
        textColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        onPressed: isExporting ? null : convertImage,
        child: const Text(
          "Convert",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: pdfNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'PDF Name',
                ),
              ),
            ),
            Visibility(
              visible: isExporting,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: LinearProgressIndicator(
                  minHeight: 25,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  value: progressValue,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: !isExporting,
              child: SizedBox(
                height: 600,
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: imagesList.imagePath.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        Card(
                          child: Image(
                            image: FileImage(
                                File(imagesList.imagePath[index].path)),
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () => removeImage(index),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
