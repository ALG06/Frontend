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

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('1'),
      position: LatLng(20.6750688, -103.3536598),
      infoWindow: InfoWindow(
        title: 'Punto Donativo',
        snippet: 'Donaciones de ropa y alimentos',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const GeneralTitle(title: 'Locations'),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                    onMapCreated: _onMapCreated,
                    markers: _markers,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 12.0,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
