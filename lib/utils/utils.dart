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
      padding: const EdgeInsets.all(8.0), // Added padding value
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
          ),
          Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w700, // Very bold
            ),
          ),
        ],
      ),
    );
  }
}
