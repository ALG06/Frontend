import 'package:flutter/material.dart';

import "./utils/utils.dart";

/// TODO: Add Google Maps API support :)

class LocationsView extends StatelessWidget {
  const LocationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeneralTitle(title: 'Locaciones Page'),
          SizedBox(height: 20), // Add some spacing
        ],
      ),
    );
  }
}
