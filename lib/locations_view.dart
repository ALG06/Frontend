import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "utils/utils.dart";

class LocationsView extends StatefulWidget {
  const LocationsView({super.key});
  @override
  State<LocationsView> createState() => _LocationsViewState();
}

class _LocationsViewState extends State<LocationsView> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(20.6750688, -103.3536598);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GeneralTitle(title: 'Locations'),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 12.0,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
