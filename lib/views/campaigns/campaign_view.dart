import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../components/main_title.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Campaign {
  final int id; // Add this line
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

  bool get isFull => registeredPeople >= capacity;

  Campaign({
    required this.id, // Add this line
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

class _CampaignViewState extends State<CampaignView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<Campaign> allCampaigns;
  late List<Campaign> registeredCampaigns;
  late List<Campaign> displayedCampaigns;
  bool _sortByDistance = false;
  Position? _userPosition;
  bool _isLoading = true;
  String? _errorMessage;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Only proceed if the tab actually changed
      if (!_tabController.indexIsChanging) {
        _onTabChanged();
      }
    });
    allCampaigns = [];
    registeredCampaigns = [];
    displayedCampaigns = [];
    _initializeLocation();
    _loadUserIdAndFetchData();
  }

  Future<void> _registerForCampaign(Campaign campaign) async {
    try {
      if (_userId == null) {
        throw 'Usuario no identificado';
      }

      // Store context in local variable
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

      // Check if widget is still mounted
      if (!mounted) return;

      if (response.statusCode == 201) {
        await _fetchRegisteredCampaigns(); // Refresh the list first

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

  Future<void> _loadUserIdAndFetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId =
          prefs.getString('user_id') ?? '1'; // Default to '1' if not found
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
          allCampaigns = data
              .map((item) => Campaign(
                    id: item["id"] ?? 0,
                    title: item['name'] ?? '',
                    description:
                        item['description'] ?? 'No description available',
                    status: _getCampaignStatus(
                        item['start_date'], item['end_date']),
                    date: DateTime.parse(item['start_date']),
                    location: item['location'] ?? 'Location not specified',
                    registeredPeople: item['registered_people'] ?? 0,
                    capacity: item['capacity'] ?? 100,
                    latitude: item['latitude'] ?? 0.0,
                    longitude: item['longitude'] ?? 0.0,
                  ))
              .toList();

          if (_tabController.index == 0) {
            displayedCampaigns = List.from(allCampaigns);
          }
          _updateDistances();
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
      // First, get the campaign IDs the user is registered for
      final donorsResponse = await http.get(
        Uri.parse(
            'http://127.0.0.1:5000/campaign_donors/list_by_donor?donor_id=$_userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (donorsResponse.statusCode == 200) {
        final List<dynamic> donorsData = json.decode(donorsResponse.body);
        final List<int> campaignIds =
            donorsData.map((item) => item['campaign_id'] as int).toList();

        // Now fetch full details for each campaign
        final response = await http.get(
          Uri.parse('http://127.0.0.1:5000/campaigns/list'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> allCampaignsData = json.decode(response.body);

          setState(() {
            // Filter only the campaigns the user is registered for
            registeredCampaigns = allCampaignsData
                .where((campaign) => campaignIds.contains(campaign['id']))
                .map((item) => Campaign(
                      id: item['id'] ?? 0,
                      title: item['name'] ?? '',
                      description:
                          item['description'] ?? 'No description available',
                      status: _getCampaignStatus(
                        item['start_date'],
                        item['end_date'],
                      ),
                      date: DateTime.parse(item['start_date']),
                      location: item['location'] ?? 'Location not specified',
                      registeredPeople: item['registered_people'] ?? 0,
                      capacity: item['capacity'] ?? 100,
                      latitude: double.tryParse(
                              item['latitude']?.toString() ?? '0') ??
                          0.0,
                      longitude: double.tryParse(
                              item['longitude']?.toString() ?? '0') ??
                          0.0,
                    ))
                .toList();

            if (_tabController.index == 1) {
              displayedCampaigns = List.from(registeredCampaigns);
            }
            _updateDistances();
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

  void _onTabChanged() {
    if (!mounted) return;
    setState(() {
      displayedCampaigns =
          _tabController.index == 0 ? allCampaigns : registeredCampaigns;
      _sortCampaigns();
    });
  }

  void _sortCampaigns() {
    setState(() {
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

  Widget _buildCampaignList(List<Campaign> campaigns) {
    return ListView.separated(
      itemCount: campaigns.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
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
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancelRegistration(Campaign campaign) async {
    try {
      if (_userId == null) {
        throw 'Usuario no identificado';
      }

      // Store context in local variable to ensure it's valid
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

      // Check if widget is still mounted before using context
      if (!mounted) return;

      if (response.statusCode == 200) {
        await _fetchRegisteredCampaigns(); // Refresh the list first

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
      // Check if widget is still mounted before using context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildRegistrationButton(Campaign campaign) {
    if (campaign.status.toLowerCase() == 'finalizado') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Campaña finalizada',
              style:
                  TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (_isUserRegistered(campaign)) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              // Use specific context for dialog
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
                      Navigator.pop(
                          dialogContext); // Close dialog using dialog context
                      Navigator.pop(context); // Close bottom sheet
                      await _cancelRegistration(campaign);
                    },
                    child: const Text('Sí, dar de baja'),
                  ),
                ],
              );
            },
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined),
            SizedBox(width: 8),
            Text('Cancelar registro'),
          ],
        ),
      );
    }

    if (campaign.isFull) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Campaña llena',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      onPressed: campaign.status.toLowerCase() == 'finalizado'
          ? null
          : () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  // Use specific context for dialog
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
                          Navigator.pop(
                              dialogContext); // Close dialog using dialog context
                          Navigator.pop(context); // Close bottom sheet
                          await _registerForCampaign(campaign);
                        },
                        child: const Text('Confirmar'),
                      ),
                    ],
                  );
                },
              );
            },
      child: const Text('Registrarme en esta Campaña'),
    );
  }

  Widget _buildStatusWarning(Campaign campaign) {
    if (campaign.status.toLowerCase() == 'finalizado') {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Esta campaña ya ha finalizado. No se pueden realizar nuevos registros.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _getCampaignStatus(String startDate, String endDate) {
    final now = DateTime.now();
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);

    if (now.isBefore(start)) return 'Programado';
    if (now.isAfter(end)) return 'Finalizado';
    if (now.isAfter(start) && now.isBefore(end)) return 'Activo';

    return 'Activo';
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
      for (var campaign in displayedCampaigns) {
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
              // Add the warning message for finalized campaigns
              _buildStatusWarning(campaign),
              // ... Rest of your existing details ...
              const SizedBox(height: 16),
              _buildRegistrationButton(campaign),
            ],
          ),
        );
      },
    );
  }

  bool _isUserRegistered(Campaign campaign) {
    return registeredCampaigns.any((c) => c.id == campaign.id);
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
