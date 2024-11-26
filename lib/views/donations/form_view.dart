import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'choose_location_view.dart';
import '../../components/main_title.dart';

class AddFoodForm extends StatefulWidget {
  const AddFoodForm({super.key});

  @override
  AddFoodFormState createState() => AddFoodFormState();
}

class AddFoodFormState extends State<AddFoodForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedCategory = 'Carnes'; // Default value
  bool _isPerishable = false;

  final List<String> _categories = [
    'Carnes',
    'Vegetales',
    'Frutas',
    'Lácteos',
    'Granos',
    'Bebidas',
    'Otros',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Alimento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del alimento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la cantidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Perecedero'),
                value: _isPerishable,
                onChanged: (bool? value) {
                  setState(() {
                    _isPerishable = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'name': _nameController.text,
                      'quantity': _quantityController.text,
                      'category': _selectedCategory,
                      'perishable': _isPerishable,
                    });
                  }
                },
                child: const Text('Agregar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormDonationView extends StatefulWidget {
  const FormDonationView({super.key});

  @override
  FormDonationViewState createState() => FormDonationViewState();
}

class FormDonationViewState extends State<FormDonationView> {
  List<Map<String, dynamic>> foodList = [];
  LatLng? selectedLocation;
  String? selectedLocationTitle;
  int? selectedPointId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;
  int currentStep = 0;

  Future<void> _showAddFoodBottomSheet() async {
    final newFood = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: const AddFoodForm(),
        );
      },
    );

    if (newFood != null) {
      setState(() {
        foodList.add(newFood);
      });
    }
  }

  void _removeFood(int index) {
    setState(() {
      foodList.removeAt(index);
    });
  }

  Future<void> _submitDonation() async {
    if (foodList.isEmpty ||
        selectedLocation == null ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final donation = {
        'id': DateTime.now().millisecondsSinceEpoch, // Temporary ID generation
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'time': '${selectedTime!.hour}:${selectedTime!.minute}:00',
        'state': 'pending',
        'id_donor': 1, // Replace with actual donor ID from authentication
        'id_point': selectedPointId,
        'type': foodList.map((food) => food['category']).toSet().join(', '),
        'pending': true,
      };

      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/donations/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(donation),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donación enviada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          foodList.clear();
          selectedLocation = null;
          selectedLocationTitle = null;
          selectedDate = null;
          selectedTime = null;
          currentStep = 0;
        });
        Navigator.pop(context); // Return to previous screen
      } else {
        throw Exception('Failed to submit donation');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar la donación: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      _selectTime(); // Automatically show time picker after date selection
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _chooseLocation() async {
    final location = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const ChooseLocationView()),
    );

    if (location != null) {
      setState(() {
        selectedLocation = location['position'];
        selectedLocationTitle = location['title'];
        selectedPointId =
            location['id']; // Make sure this is provided by ChooseLocationView
      });
    }
  }

  Widget _buildFoodStep() {
    return Column(
      children: [
        const GeneralTitle(title: '¿Qué vamos a donar hoy?'),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _showAddFoodBottomSheet,
            child: const Text(
              "Añadir alimento",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (foodList.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: foodList.length,
              itemBuilder: (context, index) {
                final food = foodList[index];
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) => _removeFood(index),
                  child: ListTile(
                    title: Text(food['name']),
                    subtitle: Text('${food['quantity']} g'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            '${food['category']} - ${food['perishable'] ? 'Perecedero' : 'No Perecedero'}'),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFood(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (foodList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentStep = 1;
                });
              },
              child: const Text('Continuar'),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      children: [
        const GeneralTitle(title: 'Selecciona el punto de donación'),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _chooseLocation,
            child: const Text(
              "Escoger punto de donación",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        if (selectedLocationTitle != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ubicación Seleccionada: $selectedLocationTitle',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (selectedLocationTitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentStep = 2;
                });
              },
              child: const Text('Continuar'),
            ),
          ),
      ],
    );
  }

  Widget _buildDateTimeStep() {
    return Column(
      children: [
        const GeneralTitle(title: 'Selecciona fecha y hora de entrega'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _selectDate,
          child: const Text('Seleccionar Fecha y Hora'),
        ),
        if (selectedDate != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Fecha seleccionada: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        if (selectedTime != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Hora seleccionada: ${selectedTime!.format(context)}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        if (selectedDate != null && selectedTime != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isLoading ? null : _submitDonation,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Confirmar Donación',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Formulario de Donación',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(8, 66, 130, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    currentStep--;
                  });
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0, 'Alimentos'),
                _buildStepConnector(0),
                _buildStepIndicator(1, 'Ubicación'),
                _buildStepConnector(1),
                _buildStepIndicator(2, 'Fecha'),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: currentStep == 0
                  ? _buildFoodStep()
                  : currentStep == 1
                      ? _buildLocationStep()
                      : _buildDateTimeStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = currentStep >= step;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color.fromRGBO(8, 66, 130, 1) : Colors.grey,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color.fromRGBO(8, 66, 130, 1) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final isActive = currentStep > step;
    return Container(
      width: 50,
      height: 2,
      color: isActive ? const Color.fromRGBO(8, 66, 130, 1) : Colors.grey,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
