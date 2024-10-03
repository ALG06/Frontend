import 'package:flutter/material.dart';

import "./utils/utils.dart";

class DonateView extends StatelessWidget {
  const DonateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(children: [
          GeneralTitle(title: '¿Qué vamos a donar hoy?'),
          SizedBox(height: 20), // Add some spac
        ]));
  }
}
