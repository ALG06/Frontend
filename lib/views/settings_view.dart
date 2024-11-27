import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "../components/main_title.dart";

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Settings state - all disabled, so these are just for display
  final bool _isDarkMode = false;
  final bool _notificationsEnabled = false;
  final bool _locationEnabled = false;
  final String _selectedDistance = 'km';
  final double _maxDistance = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          const GeneralTitle(title: "Configuración"),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Modo Oscuro'),
                  subtitle: const Text('Cambiar apariencia de la aplicación'),
                  trailing: Switch(
                    value: _isDarkMode,
                    activeColor: Colors.grey,
                    onChanged: null, // Disabled switch
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Notificaciones'),
                  subtitle: const Text('Recibir avisos de nuevas campañas'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    activeColor: Colors.grey,
                    onChanged: null, // Disabled switch
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Ubicación'),
                  subtitle: const Text('Permitir acceso a la ubicación'),
                  trailing: Switch(
                    value: _locationEnabled,
                    activeColor: Colors.grey,
                    onChanged: null, // Disabled switch
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Unidad de Distancia'),
                  subtitle: const Text('Cambiar unidad de medida'),
                  trailing: DropdownButton<String>(
                    value: _selectedDistance,
                    items: const [
                      DropdownMenuItem(
                        value: 'km',
                        child: Text('Kilómetros'),
                      ),
                      DropdownMenuItem(
                        value: 'm',
                        child: Text('Metros'),
                      ),
                    ],
                    onChanged: null, // Disabled dropdown
                    disabledHint: Text('Kilómetros'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distancia Máxima: ${_maxDistance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Slider(
                        value: _maxDistance,
                        min: 1.0,
                        max: 50.0,
                        divisions: 49,
                        activeColor: Colors.grey,
                        label: '${_maxDistance.round()} km',
                        onChanged: null, // Disabled slider
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Versión de la Aplicación'),
                  subtitle: Text('1.0.0'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              enabled: false, // Disabled list tile
              leading: Icon(Icons.delete_outline, color: Colors.grey),
              title: Text(
                'Borrar Datos',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: null, // Disabled tap
            ),
          ),
        ],
      ),
    );
  }
}