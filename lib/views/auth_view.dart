import 'package:flutter/material.dart';
import "../utils/utils.dart";
import "./auth/auth_forms.dart";

// TODO: Implement it with the rest of the app.

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GeneralTitle(title: "Iniciar sesión"),
            SizedBox(height: 10),
            AuthForms(),
          ],
        ));
  }
}
