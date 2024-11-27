import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class QRCodeView extends StatelessWidget {
  final String qrCodeBase64;
  final String titleText; // New prop for customizable text

  const QRCodeView({
    Key? key,
    required this.qrCodeBase64,
    required this.titleText, // Required text prop
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uint8List qrImageData = base64Decode(qrCodeBase64);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Código QR'),
        backgroundColor: const Color.fromRGBO(8, 66, 130, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              titleText, // Use the passed-in titleText
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Image.memory(
              qrImageData,
              height: 300,
              width: 300,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
