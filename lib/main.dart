import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/services.dart';

import 'navigation/app.dart';

const platform = MethodChannel('com.example.app/environment');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'env');
  final apiKey = dotenv.env['MAPS_API_KEY'];

  if (kIsWeb) {
    if (html.document.querySelector('script[src*="maps.googleapis.com"]') ==
        null) {
      final script = html.ScriptElement()
        ..src =
            'https://maps.googleapis.com/maps/api/js?key=${dotenv.env['MAPS_API_KEY']}&loading=async';

      html.document.head!.append(script);
    }
  } else if (!kIsWeb) {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'getApiKey') {
        return apiKey;
      }
      throw PlatformException(code: 'UNIMPLEMENTED');
    });

    try {
      final result = await platform.invokeMethod('initGoogleMaps', apiKey);
      if (kDebugMode) {
        print('Google Maps initialization result: $result');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Google Maps: ${e.message}');
      }
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
