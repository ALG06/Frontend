import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../views/auth/auth_start_view.dart';
import "../../components/main_title.dart";
import 'package:shared_preferences/shared_preferences.dart';

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

class _HomeViewState extends State<HomeView> {
  // Sample Data
  final stats = const [
    Stat(
      value: '150kg',
      title: 'Alimentos Donados',
      color: Colors.blue,
    ),
    Stat(
      value: '12',
      title: 'Campañas Activas',
      color: Colors.green,
    ),
    Stat(
      value: '3',
      title: 'Centros Cercanos',
      color: Colors.orange,
    ),
  ];

  final quickActions = [
    QuickAction(
      title: 'Donar Alimentos',
      description: 'Registra tu donación de alimentos',
      icon: Icons.food_bank,
      onTap: (context) {},
    ),
    QuickAction(
      title: 'Encontrar Centros',
      description: 'Localiza centros de acopio cercanos',
      icon: Icons.location_on,
      onTap: (context) {
        // Navigate to locations screen
      },
    ),
    QuickAction(
      title: 'Ver Campañas',
      description: 'Descubre campañas activas',
      icon: Icons.campaign,
      onTap: (context) {
        // Navigate to campaigns screen
      },
    ),
  ];

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
  Widget build(BuildContext context) {
    return ListView(
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
                    content:
                        const Text('¿Estás seguro que deseas cerrar sesión?'),
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
                        const SnackBar(content: Text('Error al cerrar sesión')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stats.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final stat = stats[index];
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
        ),
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
    );
  }
}
