import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../components/main_title.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Campaign {
  final int id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final bool active;
  final double? lat;
  final double? lon;
  double? distance;

  Campaign({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.active,
    this.lat,
    this.lon,
    this.distance,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      description: json['description'],
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      active: json['active'] ?? true,
      lat: json['lat']?.toDouble(),
      lon: json['lon']?.toDouble(),
    );
  }

  bool get hasLocation => lat != null && lon != null;

  String get status {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 'Programado';
    if (now.isAfter(endDate)) return 'Finalizado';
    return 'Activo';
  }
}

class CampaignView extends StatefulWidget {
  const CampaignView({super.key});

  @override
  State<CampaignView> createState() => _CampaignViewState();
}

class _CampaignViewState extends State<CampaignView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Campaign> allCampaigns = [];
  List<Campaign> registeredCampaigns = [];
  Position? _userPosition;
  bool _isLoading = true;
  String? _errorMessage;
  String? _userId;
  bool _sortByDistance = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeLocation();
    _loadUserIdAndFetchData();
  }

  Future<void> _loadUserIdAndFetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('user_id') ?? '1';
      await _fetchAllCampaigns();
      await _fetchRegisteredCampaigns();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading user data: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchAllCampaigns() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/campaigns/list'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allCampaigns = data.map((item) => Campaign.fromJson(item)).toList()
            ..sort((a, b) => a.startDate.compareTo(b.startDate));
          _updateDistances(allCampaigns);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching campaigns: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRegisteredCampaigns() async {
    try {
      final donorsResponse = await http.get(
        Uri.parse(
            'http://127.0.0.1:5000/campaign_donors/list_by_donor?donor_id=$_userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (donorsResponse.statusCode == 200) {
        final List<dynamic> donorsData = json.decode(donorsResponse.body);
        final List<int> campaignIds =
            donorsData.map((item) => item['campaign_id'] as int).toList();

        final response = await http.get(
          Uri.parse('http://127.0.0.1:5000/campaigns/list'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> allCampaignsData = json.decode(response.body);
          setState(() {
            registeredCampaigns = allCampaignsData
                .where((campaign) => campaignIds.contains(campaign['id']))
                .map((item) => Campaign.fromJson(item))
                .toList()
              ..sort((a, b) => a.startDate.compareTo(b.startDate));
            _updateDistances(registeredCampaigns);
          });
        }
      }
    } catch (e) {
      debugPrint('Error in _fetchRegisteredCampaigns: $e');
      setState(() {
        _errorMessage = 'Error fetching registered campaigns: ${e.toString()}';
      });
    }
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
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _updateDistances(List<Campaign> campaigns) {
    if (_userPosition != null) {
      for (var campaign in campaigns) {
        if (campaign.hasLocation) {
          campaign.distance = Geolocator.distanceBetween(
            _userPosition!.latitude,
            _userPosition!.longitude,
            campaign.lat!,
            campaign.lon!,
          );
        }
      }
      if (_sortByDistance) {
        campaigns.sort((a, b) => (a.distance ?? double.infinity)
            .compareTo(b.distance ?? double.infinity));
      }
    }
  }

  String _formatDistance(double? distance) {
    if (distance == null) return '';
    if (distance < 1000) return '${distance.round()}m';
    return '${(distance / 1000).toStringAsFixed(1)}km';
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
                campaign.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                campaign.description ?? 'Sin descripción',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fecha: ${campaign.startDate.day.toString().padLeft(2, '0')}-${campaign.startDate.month.toString().padLeft(2, '0')}-${campaign.startDate.year}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              if (campaign.hasLocation) ...[
                const SizedBox(height: 8),
                Text(
                  'Distancia: ${_formatDistance(campaign.distance)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: _getStatusColor(campaign.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Estado: ${campaign.status}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getStatusColor(campaign.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isUserRegistered(campaign))
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () => _confirmCancellation(context, campaign),
                  child: const Text('Cancelar Registro'),
                )
              else if (campaign.status.toLowerCase() != 'finalizado')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () => _confirmRegistration(context, campaign),
                  child: const Text('Registrarme en esta Campaña'),
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmRegistration(BuildContext context, Campaign campaign) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar registro'),
          content: const Text('¿Deseas registrarte en esta campaña?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                await _registerForCampaign(campaign);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  bool _isUserRegistered(Campaign campaign) {
    return registeredCampaigns.any((c) => c.id == campaign.id);
  }

  Future<void> _registerForCampaign(Campaign campaign) async {
    try {
      if (_userId == null) {
        throw 'Usuario no identificado';
      }

      final currentContext = context;

      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/campaign_donors/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'campaign_id': campaign.id,
          'donor_id': int.parse(_userId!),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        await _fetchRegisteredCampaigns();

        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Te has registrado exitosamente en la campaña'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content:
                Text(error['error'] ?? 'Ya estás registrado en esta campaña'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw 'Error al registrarse en la campaña';
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelRegistration(Campaign campaign) async {
    try {
      if (_userId == null) {
        throw 'Usuario no identificado';
      }

      final currentContext = context;

      final response = await http.delete(
        Uri.parse('http://127.0.0.1:5000/campaign_donors/delete'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'campaign_id': campaign.id,
          'donor_id': int.parse(_userId!),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await _fetchRegisteredCampaigns();

        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Te has dado de baja de la campaña exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw 'Error al dar de baja de la campaña';
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmCancellation(BuildContext context, Campaign campaign) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar cancelación'),
          content: const Text(
              '¿Estás seguro que deseas darte de baja de esta campaña?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('No, mantener registro'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                await _cancelRegistration(campaign);
              },
              child: const Text('Sí, dar de baja'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCampaignList(List<Campaign> campaigns) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _fetchAllCampaigns();
        await _fetchRegisteredCampaigns();
      },
      child: ListView.separated(
        itemCount: campaigns.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final campaign = campaigns[index];
          return ListTile(
            onTap: () => _showCampaignDetails(context, campaign),
            title: Text(
              campaign.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.description ?? "Sin descripción",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '📍 ${campaign.hasLocation ? _formatDistance(campaign.distance) ?? "Sin distancia" : "Sin ubicación"} • 📅 ${campaign.startDate.day.toString().padLeft(2, '0')}-${campaign.startDate.month.toString().padLeft(2, '0')}-${campaign.startDate.year}',
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'programado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: GeneralTitle(title: 'Campañas de Donación'),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Todas las Campañas'),
              Tab(text: 'Mis Campañas'),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _sortByDistance = !_sortByDistance;
                  if (_sortByDistance) {
                    _updateDistances(allCampaigns);
                    _updateDistances(registeredCampaigns);
                  } else {
                    allCampaigns
                        .sort((a, b) => a.startDate.compareTo(b.startDate));
                    registeredCampaigns
                        .sort((a, b) => a.startDate.compareTo(b.startDate));
                  }
                });
              },
              icon: Icon(
                _sortByDistance ? Icons.location_on : Icons.calendar_today,
                color: Colors.pink[300],
              ),
              label: Text(
                _sortByDistance ? 'Por Distancia' : 'Por Fecha',
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCampaignList(allCampaigns),
                _buildCampaignList(registeredCampaigns),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
