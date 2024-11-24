import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChooseLocationView extends StatefulWidget {
  const ChooseLocationView({super.key});

  @override
  State<ChooseLocationView> createState() => _ChooseLocationViewState();
}

class _ChooseLocationViewState extends State<ChooseLocationView> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  String? selectedLocationTitle;

  final List<Map<String, dynamic>> locations = [
    {
      'title': 'BAMX Tlaquepaque',
      'position': const LatLng(20.5942101, -103.3995043),
    },
    {
      'title': 'BAMX Juanacatan',
      'position': const LatLng(20.5320654, -103.1548235),
    },
    {
      'title': 'BAMX Zapotlanejo',
      'position': const LatLng(20.6346218, -103.0694927),
    },
    {
      'title': 'BAMX Guadalajara',
      'position': const LatLng(20.6560847, -103.355554),
    },
  ];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onLocationSelected(Map<String, dynamic> location) {
    setState(() {
      selectedLocation = location['position'];
      selectedLocationTitle = location['title'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escoger punto de donación'),
        backgroundColor: const Color.fromRGBO(8, 66, 130, 1),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(20.5942101, -103.3995043),
                zoom: 12.0,
              ),
              markers: locations
                  .map((location) => Marker(
                        markerId: MarkerId(location['title']),
                        position: location['position'],
                        onTap: () => _onLocationSelected(location),
                      ))
                  .toSet(),
            ),
          ),
          if (selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'position': selectedLocation,
                    'title': selectedLocationTitle,
                  });
                },
                child: const Text('Confirmar ubicación'),
              ),
            ),
        ],
      ),
    );
  }
}
