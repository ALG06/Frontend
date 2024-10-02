import 'package:flutter/material.dart';

import "./main.dart";

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Column(
      children: [PuntoDonativoHeader(), GeneralTitle(title: "Configuración")],
    ));
  }
}
