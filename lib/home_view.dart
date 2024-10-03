import 'package:flutter/material.dart';

import "./utils/utils.dart";

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeneralTitle(title: 'Hola Andrés, ¿Qué deseas donar?'),
          SizedBox(height: 20),
          // Additional content for the home view...
        ],
      ),
    );
  }
}
