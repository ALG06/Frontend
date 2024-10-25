import 'package:flutter/material.dart';
import 'package:myapp/views/donations/form_view.dart';
import "../../components/main_title.dart";

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
  return Card(
    color: Colors.white,
    elevation: 1,
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    child: ListTile(
      title: Text(donation.name),
      subtitle: Text('${donation.amount.toStringAsFixed(2)} kg'),
      trailing: Text(
          '${donation.date.day}/${donation.date.month}/${donation.date.year}'),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: title,
        ),
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

class DonateView extends StatefulWidget {
  const DonateView({super.key});

  @override
  State<DonateView> createState() => _DonateViewState();
}

class _DonateViewState extends State<DonateView> {
  List<Donation> pendingDonations = [];
  List<Donation> passedDonations = [];

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    setState(() {
      pendingDonations = getDonationsFromResponse('pending');
      passedDonations = getDonationsFromResponse('passed');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GeneralTitle(title: "Donaciones"),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FormDonationView()),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              backgroundColor: const Color.fromRGBO(8, 66, 130, 1),
              padding: const EdgeInsets.symmetric(horizontal: 50),
            ),
            child: const Text(
              "Crear donativo",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          ),
          const SizedBox(height: 20),
          const Text("Donaciones activas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 8),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: pendingDonations.length,
              itemBuilder: (context, index) {
                return buildDonationItem(pendingDonations[index]);
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text("Donaciones pasadas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 8),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: passedDonations.length,
              itemBuilder: (context, index) {
                return buildDonationItem(passedDonations[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
