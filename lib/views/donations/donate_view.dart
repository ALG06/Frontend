import 'package:flutter/material.dart';
import 'package:myapp/views/donations/form_view.dart';
import "../../components/main_title.dart";
import 'package:http/http.dart' as http;
import 'qr_code_view.dart';
import 'dart:convert';

class Donation {
  final int? id;
  final String type;
  final DateTime date;
  final String time;
  final String state;
  final int? idDonor;
  final int? idPoint;
  final bool pending;
  final DateTime createdAt;

  Donation({
    this.id,
    required this.type,
    required this.date,
    required this.time,
    required this.state,
    this.idDonor,
    this.idPoint,
    required this.pending,
    required this.createdAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      type: json['type'] ?? 'Sin tipo',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: json['time'] ?? '00:00',
      state: json['state'] ?? 'pending',
      idDonor: json['id_donor'] != null
          ? int.parse(json['id_donor'].toString())
          : null,
      idPoint: json['id_point'] != null
          ? int.parse(json['id_point'].toString())
          : null,
      pending: json['pending'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
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
  List<Donation> completedDonations = [];
  bool _showingPending = true;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/donations/list'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> donationsJson = json.decode(response.body);
        final List<Donation> allDonations =
            donationsJson.map((json) => Donation.fromJson(json)).toList();

        setState(() {
          pendingDonations = allDonations.where((d) => d.pending).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          completedDonations = allDonations.where((d) => !d.pending).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load donations');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getDonationColor(bool isPending) {
    return isPending ? Colors.blue : Colors.grey;
  }

  Future<void> _refresh() async {
    await _fetchDonations();
  }

  Future<String> _fetchQRCode(int donationId) async {
    final url = Uri.parse('http://127.0.0.1:5000/donations/qrcode/$donationId'); // Use the correct endpoint for fetching QR code

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final qrCodeBase64 = responseBody['qr']; // Adjusted to match backend response structure

        if (qrCodeBase64 != null) {
          return qrCodeBase64;
        } else {
          throw Exception('QR code not found in the response.');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to fetch QR code.');
      }
    } catch (e) {
      throw Exception('Error fetching QR code: $e');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GeneralTitle(title: "Donaciones"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showingPending = !_showingPending;
                          });
                        },
                        icon: Icon(
                          _showingPending
                              ? Icons.pending_actions
                              : Icons.history,
                          color: Colors.pink[300],
                        ),
                        label: Text(
                          _showingPending
                              ? 'Donaciones Activas'
                              : 'Donaciones Pasadas',
                          style: TextStyle(color: Colors.pink[300]),
                        ),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _showingPending
                          ? pendingDonations.length
                          : completedDonations.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final donation = _showingPending
                            ? pendingDonations[index]
                            : completedDonations[index];
                        return ListTile(
                          title: Text(
                            'Donación ${donation.id ?? "Sin ID"}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '🏷️ ${donation.type} • 📅 ${donation.date.day.toString().padLeft(2, '0')}-${donation.date.month.toString().padLeft(2, '0')}-${donation.date.year} • ⏰ ${donation.time}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Estado: ${donation.state}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            if (donation.id != null) {
                              try {
                                final qrCode = await _fetchQRCode(donation.id!);
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QRCodeView(qrCodeBase64: qrCode, titleText: "QR de la donación",),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to fetch QR Code: $e')),
                                );
                              }
                            }
                          },
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getDonationColor(donation.pending)
                                  .withOpacity(0.1),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormDonationView()),
          );
          // Refresh the list after returning from the form
          _fetchDonations();
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
