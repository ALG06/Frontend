import 'package:flutter/material.dart';
import "../../components/drop_down.dart";

class AddFoodDialog extends StatefulWidget {
  const AddFoodDialog({super.key});

  @override
  _AddFoodDialogState createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _amount = '';
  String? _category;
  final String _photoUrl = '';

  final List<String> foodCategories = [
    'Fruta',
    'Vegetales',
    'Legumbres',
    'Carnes',
    'Pescado',
    'Otros'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // Background color of the dialog
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      title: const Text('Añadir alimento'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      )),
                  validator: (value) =>
                      value!.isEmpty ? 'Por favor ingresa un nombre' : null,
                  onSaved: (value) => _name = value!,
                ),
                TextFormField(
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      )),
                  validator: (value) =>
                      value!.isEmpty ? 'Por favor ingresa un nombre' : null,
                  onSaved: (value) => _amount = value!,
                ),
                DropDownCategory(
                    categories: foodCategories,
                    selectedCategory: _category,
                    onChanged: (value) {
                      setState(() {
                        _category = value;
                      });
                    }),
                const SizedBox(height: 20),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Añadir Fotografía",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(8, 66, 130, 1),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              Navigator.of(context).pop({
                'name': _name,
                'amount': _amount,
                'category': _category,
                'photoUrl': _photoUrl,
              });
            }
          },
          child: const Text(
            'Añadir',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
