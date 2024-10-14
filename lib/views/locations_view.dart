import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "../utils/utils.dart";

class LocationsView extends StatefulWidget {
  const LocationsView({super.key});
  @override
  State<LocationsView> createState() => _LocationsViewState();
}

class _LocationsViewState extends State<LocationsView> {
  late GoogleMapController? mapController;

  bool _mapLoaded = false;
  final LatLng _center = const LatLng(20.6750688, -103.3536598);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _mapLoaded = true);
      }
    });
  }

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('1'),
      position: LatLng(20.5942101, -103.3995043),
      infoWindow: InfoWindow(
        title: 'BAMX Tlaquepaque',
        snippet:
            'Hda. de La Calerilla 360, Santa María Tequepexpan, 45601 San Pedro Tlaquepaque, Jal.',
      ),
    ),
    const Marker(
      markerId: MarkerId('2'),
      position: LatLng(20.5320654, -103.1548235),
      infoWindow: InfoWindow(
        title: 'BAMX Juanacatan',
        snippet: 'Cam. al Viejo Seminario 83, 45880 San Antonio, Jal.',
      ),
    ),
    const Marker(
      markerId: MarkerId('3'),
      position: LatLng(20.6346218, -103.0694927),
      infoWindow: InfoWindow(
        title: 'BAMX Zapotlanejo',
        snippet:
            'Cam. Antiguo al Bajio 160, Fraccionamiento Universidad, 45430 Zapotlanejo, Jal.',
      ),
    ),
    const Marker(
      markerId: MarkerId('4'),
      position: LatLng(20.6560847, -103.355554),
      infoWindow: InfoWindow(
        title: 'BAMX Guadalajara',
        snippet: 'Pichón, Morelos, 44910 Guadalajara, Jal.',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: GeneralTitle(title: 'Locaciones'),
          ),
          Expanded(
            child: _mapLoaded
                ? GoogleMap(
                    onMapCreated: _onMapCreated,
                    markers: _markers,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 10.0,
                    ))
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
