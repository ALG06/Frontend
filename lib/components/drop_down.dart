import 'package:flutter/material.dart';

class DropDownCategory extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onChanged;

  const DropDownCategory({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onChanged,
  });

  @override
  State<DropDownCategory> createState() => _DropDownCategoryState();
}

class _DropDownCategoryState extends State<DropDownCategory> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
            labelText: 'Categoría del alimento',
            labelStyle: TextStyle(
              color: Colors.black,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            )),
        value: widget.selectedCategory,
        items: widget.categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: widget.onChanged,
        validator: (value) =>
            value == null ? 'Por favor selecciona una categoría' : null);
  }
}
