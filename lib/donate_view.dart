import 'package:flutter/material.dart';
import "./utils/utils.dart";

class Donation {
  final String name;
  final double amount;
  final DateTime date;
  final bool pending;

  Donation(
      {required this.name,
      required this.amount,
      required this.date,
      required this.pending});
}

// Simulating the server response data
Map<String, dynamic> serverResponse = {
  "pending": [
    {"id": 1, "name": "Arroz", "amount": 4.0, "pending": true},
    {"id": 2, "name": "Atún", "amount": 2.0, "pending": true},
  ],
  "passed": [
    {"id": 1, "name": "Frijol", "amount": 7.0, "pending": false},
    {"id": 2, "name": "Gitomate", "amount": 20.0, "pending": false},
    {"id": 3, "name": "Papa", "amount": 10.0, "pending": false},
    {"id": 4, "name": "Zanahoria", "amount": 15.0, "pending": false},
    {"id": 5, "name": "Tomate", "amount": 12.0, "pending": false},
    {"id": 6, "name": "Lechuga", "amount": 8.0, "pending": false},
    {"id": 7, "name": "Cebolla", "amount": 18.0, "pending": false},
    {"id": 8, "name": "Zanahoria", "amount": 22.0, "pending": false},
    {"id": 9, "name": "Tomate", "amount": 14.0, "pending": false},
    {"id": 10, "name": "Lechuga", "amount": 11.0, "pending": false},
  ]
};

// Function to simulate fetching data and mapping it to a List<Donation>
List<Donation> getDonationsFromResponse(String status) {
  List<Donation> donations = [];
  var data = serverResponse[status];
  for (var item in data) {
    donations.add(Donation(
      name: item['name'],
      amount: item['amount'].toDouble(),
      date: DateTime.now().subtract(Duration(days: item['id'])),
      pending: item['pending'],
    ));
  }
  return donations;
}

Widget buildDonationItem(Donation donation) {
  return Padding(
    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
    child: Card(
      color: Colors.white,
      elevation: 2,
      child: ListTile(
        title: Text(donation.name),
        subtitle: Text('${donation.amount.toStringAsFixed(2)} kg'),
        trailing: Text(
            '${donation.date.day}/${donation.date.month}/${donation.date.year}'),
      ),
    ),
  );
}

class DonationList extends StatelessWidget {
  final List<Donation> donations;
  final Widget title;

  const DonationList({super.key, required this.donations, required this.title});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title,
        Expanded(
          child: ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, index) {
              return buildDonationItem(donations[index]);
            },
          ),
        ),
      ],
    );
  }
}

class DonateView extends StatelessWidget {
  const DonateView({super.key});

  @override
  Widget build(BuildContext context) {
    List<Donation> pendingDonations = getDonationsFromResponse('pending');
    List<Donation> passedDonations = getDonationsFromResponse('passed');

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 80,
          title: const Padding(
            padding: EdgeInsets.only(left: 30.0), // Example padding
            child: GeneralTitle(title: "Donaciones"),
          ),
          titleSpacing: 0, // Remove default title spacing
        ),
        body: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(30.0),
                child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: const Color.fromRGBO(8, 66, 130, 1),
                        padding: const EdgeInsets.only(left: 50, right: 50)),
                    child: const Text(
                      "Crear donativo",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ))),
            Expanded(
              flex: 2,
              child: DonationList(
                title: const Text("Donaciones activas",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                donations: pendingDonations,
              ),
            ),
            Expanded(
              flex: 3,
              child: DonationList(
                title: const Text("Donaciones pasadas",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                donations: passedDonations,
              ),
            )
          ],
        ));
  }
}
