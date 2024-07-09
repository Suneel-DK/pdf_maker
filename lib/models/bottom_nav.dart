import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const MyBottomNavBar({
    required this.currentIndex,
    required this.onIndexChanged,
    super.key,
  });

  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: Colors.red.withOpacity(0.8),
      backgroundColor: Colors.transparent,
      index: widget.currentIndex,
      onTap: (index) {
        widget.onIndexChanged(index);
      },
      items: const <Widget>[
        Icon(CupertinoIcons.doc),
        Icon(Icons.merge),
      ],
    );
  }
}
