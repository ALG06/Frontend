import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "../components/main_title.dart";

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Settings state
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _selectedDistance = 'km'; // can be 'km' or 'm'
  double _maxDistance = 10.0; // in kilometers

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      await _loadSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Use default values if loading fails
      setState(() {
        _isDarkMode = false;
        _notificationsEnabled = true;
        _locationEnabled = true;
        _selectedDistance = 'km';
        _maxDistance = 10.0;
      });
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = prefs.getBool('darkMode') ?? false;
        _notificationsEnabled = prefs.getBool('notifications') ?? true;
        _locationEnabled = prefs.getBool('location') ?? true;
        _selectedDistance = prefs.getString('distanceUnit') ?? 'km';
        _maxDistance = prefs.getDouble('maxDistance') ?? 10.0;
      });
    } catch (e) {
      debugPrint('Error in _loadSettings: $e');
      rethrow;
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', _isDarkMode);
      await prefs.setBool('notifications', _notificationsEnabled);
      await prefs.setBool('location', _locationEnabled);
      await prefs.setString('distanceUnit', _selectedDistance);
      await prefs.setDouble('maxDistance', _maxDistance);
    } catch (e) {
      debugPrint('Error saving settings: $e');
      // Optionally show an error message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la configuración'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

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
                    activeColor: const Color.fromRGBO(8, 66, 130, 1),
                    onChanged: (bool value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Notificaciones'),
                  subtitle: const Text('Recibir avisos de nuevas campañas'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    activeColor: const Color.fromRGBO(8, 66, 130, 1),
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _saveSettings();
                    },
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
                    activeColor: const Color.fromRGBO(8, 66, 130, 1),
                    onChanged: (bool value) {
                      setState(() {
                        _locationEnabled = value;
                      });
                      _saveSettings();
                    },
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
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedDistance = value;
                        });
                        _saveSettings();
                      }
                    },
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
                        activeColor: const Color.fromRGBO(8, 66, 130, 1),
                        label: '${_maxDistance.round()} km',
                        onChanged: (double value) {
                          setState(() {
                            _maxDistance = value;
                          });
                          _saveSettings();
                        },
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
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Borrar Datos',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Borrar Datos'),
                      content: const Text(
                          '¿Estás seguro de que quieres borrar todos los datos de la aplicación? Esta acción no se puede deshacer.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                            }
                            _loadSettings();
                          },
                          child: const Text(
                            'Borrar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
