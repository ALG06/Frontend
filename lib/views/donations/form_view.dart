import 'package:flutter/material.dart';
import "package:myapp/views/donations/donation_point.dart";
import "../../components/main_title.dart";
import "./alert_form.dart";

class FormDonationView extends StatefulWidget {
  const FormDonationView({super.key});

  @override
  FormDonationViewState createState() => FormDonationViewState();
}

class FormDonationViewState extends State<FormDonationView> {
  // This list will dynamically update as elements are added
  List<Map<String, dynamic>> foodList = [];

  // Function to show the pop-up dialog
  Future<void> _showAddFoodDialog() async {
    final newFood = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return const AddFoodDialog();
      },
    );

    // If the user submitted the form, add the new food to the list
    if (newFood != null) {
      setState(() {
        foodList.add(newFood);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GeneralTitle(title: '¿Qué vamos a donar hoy?'),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: _showAddFoodDialog,
                child: const Text(
                  "Añadir alimento",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                )),
          ),
          const SizedBox(height: 20),

          // Show the list title if there are any items in the list
          if (foodList.isNotEmpty)
            const Text(
              "Lista de alimentos añadidos",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          const SizedBox(height: 10),

          // The dynamic list of food items
          Expanded(
            child: foodList.isNotEmpty
                ? ListView.builder(
                    itemCount: foodList.length,
                    itemBuilder: (context, index) {
                      final food = foodList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(food['photoUrl']),
                        ),
                        title: Text(food['name']),
                        subtitle: Text(food['amount']),
                        trailing: Text(food['category']),
                      );
                    },
                  )
                : const Center(child: Text('No hay alimentos añadidos aún.')),
          ),

          const SizedBox(height: 20),
          Center(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: const Color.fromRGBO(8, 66, 130, 1),
                  ),
                  onPressed: () {
                    // Navigate to the new view and pass the foodList
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DonationPoint(foodList: foodList),
                      ),
                    );
                  },
                  child: const Text("Escoger punto de donación",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ))))
        ],
      ),
    );
  }
}
