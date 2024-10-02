import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punto Donativo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
          children: [
            Text(
              'Punto Donativo',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.grey, // Gray color for the text
                fontWeight: FontWeight.bold,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Hola Andrés, ¿Qué deseas donar?',
                style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),

              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // First Box
                Expanded(
                  child: Container(
                    height: 150,
                    color: Colors.teal,
                    child: const Center(
                      child: Text(
                        'Chart 1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Second Box
                Expanded(
                  child: Container(
                    height: 150,
                    color: Colors.blueAccent,
                    child: const Center(
                      child: Text(
                        'Chart 2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Third Box
            Expanded(
              child: Container(
                color: Colors.redAccent,
                child: const Center(
                  child: Text(
                    'Chart 3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.black, // Black background for the navbar
        selectedItemColor: Colors.black, // White icons for selected item
        unselectedItemColor: Colors.black, // White icons for unselected items too
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Donar'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Locaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
    );
  }
}
