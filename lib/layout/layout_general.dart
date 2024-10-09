import 'package:flutter/material.dart';

class LayoutGeneral extends StatelessWidget {
  final Widget child;
  final String title;

  const LayoutGeneral({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: child,
    );
  }
}
