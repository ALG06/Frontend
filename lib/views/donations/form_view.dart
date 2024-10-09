import 'package:flutter/material.dart';

import "../../utils/utils.dart";

class FormDonationView extends StatelessWidget {
  const FormDonationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeneralTitle(title: 'Formulario de donacion'),
          SizedBox(height: 20),
          // Additional content for the home view...
        ],
      ),
    );
  }
}
