import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../views/auth/auth_start_view.dart';
import '../views/donations/form_view.dart';
import '../views/locations_view.dart';
import '../views/campaigns/campaign_view.dart';
import '../../components/main_title.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Stat {
  final String value;
  final String title;
  final Color color;

  const Stat({
    required this.value,
    required this.title,
    required this.color,
  });
}

class QuickAction {
  final String title;
  final String description;
  final IconData icon;
  final Function(BuildContext) onTap;

  const QuickAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}

class Activity {
  final String title;
  final String description;
  final DateTime date;
  final IconData icon;

  const Activity({
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
  });
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  List<Stat>? stats;
  bool _isLoading = true;
  String? _error;
  late List<QuickAction> quickActions;

  final recentActivities = [
    Activity(
      title: 'Donación Realizada',
      description: 'Donaste 5kg de alimentos',
      date: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.check_circle,
    ),
    Activity(
      title: 'Nueva Campaña',
      description: 'Te uniste a la campaña "Alimentos para Todos"',
      date: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.campaign,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchDonorStats();
    _initializeQuickActions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchDonorStats();
    }
  }

  void _initializeQuickActions() {
    quickActions = [
      QuickAction(
        title: 'Donar Alimentos',
        description: 'Registra tu donación de alimentos',
        icon: Icons.food_bank,
        onTap: _navigateToFormDonation,
      ),
      QuickAction(
        title: 'Encontrar Centros',
        description: 'Localiza centros de acopio cercanos',
        icon: Icons.location_on,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LocationsView()),
          );
        },
      ),
      QuickAction(
        title: 'Ver Campañas',
        description: 'Descubre campañas activas',
        icon: Icons.campaign,
        onTap: _navigateToCampaigns,
      ),
    ];
  }

  Future<void> _navigateToFormDonation(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormDonationView()),
    );

    if (result == true) {
      await _fetchDonorStats();
    }
  }

  Future<void> _navigateToCampaigns(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CampaignView()),
    );

    if (result == true) {
      await _fetchDonorStats();
    }
  }

  Future<void> _fetchDonorStats() async {
    try {
      final donorStatsResponse = await http.get(
        Uri.parse('http://127.0.0.1:5000/donors/stats/1'),
        headers: {'Content-Type': 'application/json'},
      );

      final campaignsResponse = await http.get(
        Uri.parse(
            'http://127.0.0.1:5000/campaign_donors/list_by_donor?donor_id=1'),
        headers: {'Content-Type': 'application/json'},
      );

      if (donorStatsResponse.statusCode == 200 &&
          campaignsResponse.statusCode == 200) {
        final donorData = json.decode(donorStatsResponse.body);
        final campaignsData = json.decode(campaignsResponse.body) as List;

        setState(() {
          stats = [
            Stat(
              value: '${donorData['total_kg_donated']}kg',
              title: 'Alimentos Donados',
              color: Colors.blue,
            ),
            Stat(
              value: donorData['total_donations'].toString(),
              title: 'Donaciones Totales',
              color: Colors.green,
            ),
            Stat(
              value: campaignsData.length.toString(),
              title: 'Campañas Totales',
              color: Colors.orange,
            ),
          ];
          _isLoading = false;
        });
      } else {
        throw 'Failed to load donor stats';
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildStats() {
    if (_isLoading) {
      return const SizedBox(
        height: 105,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        height: 105,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Error loading stats',
            style: TextStyle(color: Colors.red[900]),
          ),
        ),
      );
    }

    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stats?.length ?? 0,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final stat = stats![index];
          return Container(
            width: 128,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stat.value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: stat.color,
                  ),
                ),
                const Spacer(),
                Text(
                  stat.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: RefreshIndicator(
        onRefresh: _fetchDonorStats,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const GeneralTitle(title: "Bienvenido");
                    } else if (snapshot.hasError) {
                      return const GeneralTitle(title: "Bienvenido");
                    } else {
                      final prefs = snapshot.data as SharedPreferences;
                      final name = prefs.getString('name') ?? '';
                      return GeneralTitle(title: "Bienvenido \n$name");
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.pink),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text(
                            '¿Estás seguro que deseas cerrar sesión?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.pink,
                            ),
                            child: const Text('Cerrar Sesión'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      try {
                        await context.read<AuthService>().logout();
                        if (context.mounted) {
                          navigatorKey.currentState?.pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const AuthStartView(),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error al cerrar sesión')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStats(),
            const SizedBox(height: 24),
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...quickActions.map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(action.icon, color: Colors.pink[300]),
                      title: Text(action.title),
                      subtitle: Text(
                        action.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => action.onTap(context),
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            Text(
              'Actividad Reciente',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...recentActivities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(activity.icon, color: Colors.green[300]),
                      title: Text(activity.title),
                      subtitle: Text(
                        activity.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        '${activity.date.day}/${activity.date.month}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
