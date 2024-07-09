// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdfmaker/pages/homepage.dart';
import 'package:pdfmaker/pages/landing.dart';
import 'package:pdfmaker/pages/pdf_list.dart';
import 'package:pdfmaker/pages/selected_image.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pdfmaker/pages/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox('pdfBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const Home(),
        '/selectedimage': (context) => const SelectedImages(),
        '/pdfList': (context) => PdfListScreen(),
        '/landing': (context) => const HomePage()
      },
    );
  }
}
