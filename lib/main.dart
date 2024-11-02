import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:universal_html/html.dart' as html;

import 'navigation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'env');
  final apiKey = dotenv.env['MAPS_API_KEY'];

  if (kIsWeb) {
    if (html.document.querySelector('script[src*="maps.googleapis.com"]') ==
        null) {
      final script = html.ScriptElement()
        ..src =
            'https://maps.googleapis.com/maps/api/js?key=$apiKey&loading=async';
      html.document.head!.append(script);
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punto Donativo',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const App(),
    );
  }
}
