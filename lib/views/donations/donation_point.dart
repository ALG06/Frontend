import 'package:flutter/material.dart';

class DonationPoint extends StatelessWidget {
  final List<Map<String, dynamic>> foodList;

  // Constructor to accept the foodList
  const DonationPoint({Key? key, required this.foodList}) : super(key: key);

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escoger punto de donación')
      ),
    );
  }
}