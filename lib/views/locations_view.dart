import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "../components/main_title.dart";

class LocationData {
  final String id;
  final String title;
  final String address;
  final LatLng position;

  const LocationData({
    required this.id,
    required this.title,
    required this.address,
    required this.position,
  });
}

class LocationsView extends StatefulWidget {
  const LocationsView({super.key});

  @override
  State<LocationsView> createState() => _LocationsViewState();
}

class _LocationsViewState extends State<LocationsView> {
  late GoogleMapController? mapController;
  bool _mapLoaded = false;
  final LatLng _center = const LatLng(20.6750688, -103.3536598);
  bool _showList = false;

  final List<LocationData> locations = const [
    LocationData(
      id: '1',
      title: 'BAMX Tlaquepaque',
      address:
          'Hda. de La Calerilla 360, Santa María Tequepexpan, 45601 San Pedro Tlaquepaque, Jal.',
      position: LatLng(20.5942101, -103.3995043),
    ),
    LocationData(
      id: '2',
      title: 'BAMX Juanacatan',
      address: 'Cam. al Viejo Seminario 83, 45880 San Antonio, Jal.',
      position: LatLng(20.5320654, -103.1548235),
    ),
    LocationData(
      id: '3',
      title: 'BAMX Zapotlanejo',
      address:
          'Cam. Antiguo al Bajio 160, Fraccionamiento Universidad, 45430 Zapotlanejo, Jal.',
      position: LatLng(20.6346218, -103.0694927),
    ),
    LocationData(
      id: '4',
      title: 'BAMX Guadalajara',
      address: 'Pichón, Morelos, 44910 Guadalajara, Jal.',
      position: LatLng(20.6560847, -103.355554),
    ),
  ];

  Set<Marker> get _markers {
    return locations
        .map((loc) => Marker(
              markerId: MarkerId(loc.id),
              position: loc.position,
              infoWindow: InfoWindow(
                title: loc.title,
                snippet: loc.address,
              ),
            ))
        .toSet();
  }

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

  void _focusLocation(LatLng position) {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GeneralTitle(title: 'Locaciones'),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showList = !_showList;
                    });
                  },
                  icon: Icon(
                    _showList ? Icons.map : Icons.list,
                    color: Colors.pink[300],
                  ),
                  label: Text(
                    _showList ? 'Ver Mapa' : 'Ver Lista',
                    style: TextStyle(color: Colors.pink[300]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _showList
                ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: locations.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final location = locations[index];
                      return ListTile(
                        onTap: () {
                          setState(() => _showList = false);
                          _focusLocation(location.position);
                        },
                        title: Text(
                          location.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '📍 ${location.address}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Ver en Mapa',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : _mapLoaded
                    ? GoogleMap(
                        onMapCreated: _onMapCreated,
                        markers: _markers,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 10.0,
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
