import 'package:flutter/material.dart';
import "./main.dart";
/// TODO: Add Google Maps API support :)



class LocationsView extends StatelessWidget {
  const LocationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column( // Use Column to hold multiple widgets
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PuntoDonativoHeader(), // Use the new widget here
          SizedBox(height: 10), // Add some spacing
          GeneralTitle(title: 'Locaciones Page')
        ],
      ),
    );
  }
}
