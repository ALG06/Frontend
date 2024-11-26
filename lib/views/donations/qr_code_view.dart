import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class QRCodeView extends StatelessWidget {
  final String qrCodeBase64;

  const QRCodeView({Key? key, required this.qrCodeBase64}) : super(key: key);

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
            const Text(
              '¡Tu QR está listo!',
              style: TextStyle(
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
