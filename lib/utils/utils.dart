import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GeneralTitle extends StatefulWidget {
  final String title;
  const GeneralTitle({super.key, required this.title});

  @override
  State<GeneralTitle> createState() => _GeneralTitleState();
}

class _GeneralTitleState extends State<GeneralTitle> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Punto Donativo',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
}
