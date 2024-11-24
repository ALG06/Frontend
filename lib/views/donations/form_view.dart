import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'choose_location_view.dart';
import '../../components/main_title.dart';

class FormDonationView extends StatefulWidget {
  const FormDonationView({super.key});

  @override
  FormDonationViewState createState() => FormDonationViewState();
}

class FormDonationViewState extends State<FormDonationView> {
  List<Map<String, dynamic>> foodList = [];
  LatLng? selectedLocation;
  String? selectedLocationTitle;

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

  Future<void> _chooseLocation() async {
    final location = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const ChooseLocationView()),
    );

    if (location != null) {
      setState(() {
        selectedLocation = location['position'];
        selectedLocationTitle = location['title'];
      });
    }
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    return ListTile(
                      title: Text(food['name']),
                      subtitle: Text(food['quantity']),
                      trailing: Text(
                          '${food['category']} - ${food['perishable'] ? 'Perecedero' : 'No Perecedero'}'),
                    );
                  },
                ),
              ),
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
            if (foodList.isNotEmpty && selectedLocationTitle != null)
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Handle the submission of the donation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Donación enviada con éxito'),
                      ),
                    );
                  },
                  child: const Text(
                    'Enviar Donación',
                    style: TextStyle(
                      // TODO: Make donation here please
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AddFoodForm extends StatefulWidget {
  const AddFoodForm({Key? key}) : super(key: key);

  @override
  _AddFoodFormState createState() => _AddFoodFormState();
}

class _AddFoodFormState extends State<AddFoodForm> {
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
                  labelText: 'Cantidad',
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
