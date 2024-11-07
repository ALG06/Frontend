import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;
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

  http.Client client = http.Client();
  try {
  var response = await client.get(Uri.parse('http://127.0.0.1:5000/sample'));
      
  if (kDebugMode) {
    print(response.body);
  }
  }
  catch (e) {
    print(e);
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
        primaryColor: const Color.fromRGBO(8, 66, 130, 1),
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(8, 66, 130, 1)),
        useMaterial3: true,
      ),
      home: const App(),
    );
  }
}
