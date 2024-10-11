import 'package:flutter/material.dart';

class AuthForms extends StatelessWidget {
  const AuthForms({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Column(
      children: [
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter your username',
          ),
        ),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter your password',
          ),
        )
      ],
    ));
  }
}
