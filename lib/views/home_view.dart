import 'package:flutter/material.dart';
import '../components/main_title.dart';
import 'donations/form_view.dart';
import 'locations_view.dart';
import 'campaigns/campaign_view.dart';

class StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class QuickAction {
  final String title;
  final String description;
  final IconData icon;
  final void Function(BuildContext) onTap;

  const QuickAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}

class RecentActivity {
  final String title;
  final String description;
  final DateTime date;
  final String status;

  const RecentActivity({
    required this.title,
    required this.description,
    required this.date,
    required this.status,
  });
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<StatCard> stats = [
      const StatCard(
        title: 'Donaciones Activas',
        value: '3',
        icon: Icons.pending_actions,
        color: Colors.blue,
      ),
      const StatCard(
        title: 'Total Donado',
        value: '45.5 kg',
        icon: Icons.scale,
        color: Colors.green,
      ),
      const StatCard(
        title: 'Familias Ayudadas',
        value: '12',
        icon: Icons.people,
        color: Colors.orange,
      ),
    ];

    final List<QuickAction> quickActions = [
      QuickAction(
        title: 'Crear Donación',
        description: 'Registra una nueva donación de alimentos',
        icon: Icons.add_circle_outline,
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormDonationView()),
          );
        },
      ),
      QuickAction(
        title: 'Encuentra un Centro',
        description: 'Localiza el centro de donación más cercano',
        icon: Icons.location_on_outlined,
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LocationsView()),
          );
        },
      ),
      QuickAction(
        title: 'Ver Campañas',
        description: 'Descubre campañas activas de donación',
        icon: Icons.campaign_outlined,
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CampaignView()),
          );
        },
      ),
    ];

    final List<RecentActivity> recentActivities = [
      RecentActivity(
        title: 'Donación de Arroz',
        description: '4.0 kg - BAMX Tlaquepaque',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Pendiente',
      ),
      RecentActivity(
        title: 'Donación de Frijol',
        description: '7.0 kg - BAMX Guadalajara',
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Completada',
      ),
      RecentActivity(
        title: 'Donación de Atún',
        description: '2.0 kg - BAMX Zapopan',
        date: DateTime.now().subtract(const Duration(days: 7)),
        status: 'Completada',
      ),
    ];

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        clipBehavior: Clip.none, // Added to prevent ListView overflow
        children: [
          const GeneralTitle(title: 'Hola Andrés,\n¿Qué deseas donar?'),
          const SizedBox(height: 24),
          // Stats Cards
          SizedBox(
            height: 105,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stats.length,
              clipBehavior:
                  Clip.none, // Added to prevent horizontal ListView overflow
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final stat = stats[index];
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(stat.icon, color: stat.color),
                      const Spacer(),
                      Text(
                        stat.value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: stat.color,
                        ),
                      ),
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
          ),
          const SizedBox(height: 24),
          Text(
            'Acciones Rápidas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          // Quick Actions
          ...quickActions.map((action) => Padding(
                padding: const EdgeInsets.only(
                    bottom: 8), // Changed from margin to padding
                child: Card(
                  margin: EdgeInsets.zero, // Removed card margin
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
          // Recent Activities
          ...recentActivities.map((activity) => Padding(
                padding: const EdgeInsets.only(
                    bottom: 8), // Changed from margin to padding
                child: Card(
                  margin: EdgeInsets.zero, // Removed card margin
                  child: ListTile(
                    title: Text(activity.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.description,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          '${activity.date.day}/${activity.date.month}/${activity.date.year}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: activity.status == 'Pendiente'
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activity.status,
                        style: TextStyle(
                          color: activity.status == 'Pendiente'
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
