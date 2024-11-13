import 'package:flutter/material.dart';
import 'package:myapp/views/donations/form_view.dart';
import "../../components/main_title.dart";

class Donation {
  final String name;
  final double amount;
  final DateTime date;
  final bool pending;

  Donation({
    required this.name,
    required this.amount,
    required this.date,
    required this.pending,
  });
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

class DonateView extends StatefulWidget {
  const DonateView({super.key});

  @override
  State<DonateView> createState() => _DonateViewState();
}

class _DonateViewState extends State<DonateView> {
  List<Donation> pendingDonations = [];
  List<Donation> passedDonations = [];
  bool _showingPending = true;

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

  Color _getDonationColor(bool isPending) {
    return isPending ? Colors.blue : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GeneralTitle(title: "Donaciones"),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showingPending = !_showingPending;
                    });
                  },
                  icon: Icon(
                    _showingPending ? Icons.pending_actions : Icons.history,
                    color: Colors.pink[300],
                  ),
                  label: Text(
                    _showingPending
                        ? 'Donaciones Activas'
                        : 'Donaciones Pasadas',
                    style: TextStyle(color: Colors.pink[300]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _showingPending
                  ? pendingDonations.length
                  : passedDonations.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final donation = _showingPending
                    ? pendingDonations[index]
                    : passedDonations[index];
                return ListTile(
                  title: Text(
                    donation.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '⚖️ ${donation.amount.toStringAsFixed(2)} kg • 📅 ${donation.date.day.toString().padLeft(2, '0')}-${donation.date.month.toString().padLeft(2, '0')}-${donation.date.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _getDonationColor(donation.pending).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      donation.pending ? 'Activa' : 'Completada',
                      style: TextStyle(
                        color: _getDonationColor(donation.pending),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormDonationView()),
          );
        },
        backgroundColor: const Color.fromRGBO(8, 66, 130, 1),
        label: const Text(
          'Crear Donativo',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
