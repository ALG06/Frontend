import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'donate_view.dart';
import 'home_view.dart';
import 'locations_view.dart';
import 'settings_view.dart';

void main() {
  runApp(const MyApp());
}

class GeneralTitle extends StatefulWidget {
  final String title; // Parameter to hold the text

  const GeneralTitle({super.key, required this.title}); // Constructor

  @override
  State<GeneralTitle> createState() => _GeneralTitleState(); // Create state
}

class _GeneralTitleState extends State<GeneralTitle> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.title, // Use the title passed to the widget
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class PuntoDonativoHeader extends StatelessWidget {
  const PuntoDonativoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Punto Donativo',
      style: TextStyle(
        fontSize: 20,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
  }
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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Track the current tab

  final List<Widget> _views = [
    const HomeView(),
    const DonateView(),
    const LocationsView(),
    const SettingsView(),
  ];

  // Update selected tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (kDebugMode) {
        print(_selectedIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Donar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_on), label: 'Locaciones'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
    );
  }
}
