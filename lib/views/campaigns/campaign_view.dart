import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../components/main_title.dart';

class Campaign {
  final String title;
  final String description;
  final String status;
  final DateTime date;
  final String location;
  final int registeredPeople;
  final int capacity;
  final double latitude;
  final double longitude;
  double? distance;

  Campaign({
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    required this.location,
    required this.registeredPeople,
    required this.capacity,
    required this.latitude,
    required this.longitude,
    this.distance,
  });
}

class CampaignView extends StatefulWidget {
  const CampaignView({super.key});

  @override
  State<CampaignView> createState() => _CampaignViewState();
}

class _CampaignViewState extends State<CampaignView> {
  late List<Campaign> campaigns;
  late List<Campaign> displayedCampaigns;
  bool _sortByDistance = false;
  Position? _userPosition;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    campaigns = [
      Campaign(
        title: 'Hospital Infantil de Zapopan',
        description: 'Apoyo para equipamiento médico pediátrico',
        status: 'Activo',
        date: DateTime(2024, 12, 15),
        location: 'Zapopan, Jalisco',
        registeredPeople: 150,
        capacity: 300,
        latitude: 20.7214,
        longitude: -103.3913,
      ),
      Campaign(
        title: 'Ayuda por Inundaciones',
        description: 'Asistencia inmediata para damnificados en Tlaquepaque',
        status: 'Urgente',
        date: DateTime(2024, 11, 3),
        location: 'Tlaquepaque, Jalisco',
        registeredPeople: 75,
        capacity: 100,
        latitude: 20.6389,
        longitude: -103.3110,
      ),
      Campaign(
        title: 'Educación para Todos',
        description: 'Útiles escolares para estudiantes de bajos recursos',
        status: 'Programado',
        date: DateTime(2025, 8, 20),
        location: 'Tonalá, Jalisco',
        registeredPeople: 45,
        capacity: 200,
        latitude: 20.6247,
        longitude: -103.2344,
      ),
      Campaign(
        title: 'Refugio Animal GDL',
        description: 'Ayuda para el cuidado de mascotas abandonadas',
        status: 'Activo',
        date: DateTime(2025, 7, 10),
        location: 'Guadalajara, Jalisco',
        registeredPeople: 80,
        capacity: 150,
        latitude: 20.6597,
        longitude: -103.3496,
      ),
    ];
    displayedCampaigns = List.from(campaigns);
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Los servicios de ubicación están desactivados';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Los permisos de ubicación fueron denegados';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Los permisos de ubicación fueron denegados permanentemente';
      }

      _userPosition = await Geolocator.getCurrentPosition();
      _updateDistances();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateDistances() {
    if (_userPosition != null) {
      for (var campaign in campaigns) {
        campaign.distance = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          campaign.latitude,
          campaign.longitude,
        );
      }
    }
  }

  String _formatDistance(double? distance) {
    if (distance == null) return '';
    if (distance < 1000) {
      return '${distance.round()}m';
    }
    return '${(distance / 1000).toStringAsFixed(1)}km';
  }

  void _toggleSort() {
    setState(() {
      _sortByDistance = !_sortByDistance;

      if (_sortByDistance && _userPosition != null) {
        displayedCampaigns.sort((a, b) => (a.distance ?? double.infinity)
            .compareTo(b.distance ?? double.infinity));
      } else {
        final now = DateTime.now();
        displayedCampaigns.sort((a, b) {
          final diffA = a.date.difference(now).abs();
          final diffB = b.date.difference(now).abs();
          return diffA.compareTo(diffB);
        });
      }
    });
  }

  void _showCampaignDetails(BuildContext context, Campaign campaign) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                campaign.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Descripción:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(campaign.description),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(campaign.status),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Fecha:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${campaign.date.day.toString().padLeft(2, '0')}-${campaign.date.month.toString().padLeft(2, '0')}-${campaign.date.year}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Ubicación:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                  '${campaign.location}${campaign.distance != null ? ' (${_formatDistance(campaign.distance)})' : ''}'),
              const SizedBox(height: 12),
              Text(
                'Participantes:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${campaign.registeredPeople} personas registradas de ${campaign.capacity} espacios disponibles',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    debugPrint('Support this campaign button pressed');
                  },
                  child: const Text('Apoyar esta Campaña'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: GeneralTitle(title: 'Campañas de Donación'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton.icon(
              onPressed: _toggleSort,
              icon: Icon(
                _sortByDistance ? Icons.location_on : Icons.calendar_today,
                color: Colors.pink[300],
              ),
              label: Text(
                _sortByDistance ? 'Por Distancia' : 'Por Fecha Cercana',
                style: TextStyle(color: Colors.pink[300]),
              ),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: displayedCampaigns.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final campaign = displayedCampaigns[index];
                return ListTile(
                  onTap: () => _showCampaignDetails(context, campaign),
                  title: Text(
                    campaign.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📍 ${campaign.location}${campaign.distance != null ? ' (${_formatDistance(campaign.distance)})' : ''} • 📅 ${campaign.date.day.toString().padLeft(2, '0')}-${campaign.date.month.toString().padLeft(2, '0')}-${campaign.date.year} • 👥 ${campaign.registeredPeople}/${campaign.capacity}',
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
                      color: _getStatusColor(campaign.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      campaign.status,
                      style: TextStyle(
                        color: _getStatusColor(campaign.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'urgente':
        return Colors.red;
      case 'programado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
