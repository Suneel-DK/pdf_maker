import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfmaker/models/bottom_nav.dart';

import 'package:pdfmaker/pages/merger.dart';
import 'package:pdfmaker/pages/pdf_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return PdfListScreen();
      case 1:
        return const Merger();

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Maker", style: GoogleFonts.kadwa(fontSize: 22)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: _getPage(_currentIndex),
      ),
      bottomNavigationBar: MyBottomNavBar(
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
