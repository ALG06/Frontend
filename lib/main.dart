import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:universal_html/html.dart' as html;
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'views/auth/auth_start_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punto Donativo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(8, 66, 130, 1),
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(8, 66, 130, 1),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(8, 66, 130, 1)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(8, 66, 130, 1),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const AuthStartView(),
    );
  }
}
