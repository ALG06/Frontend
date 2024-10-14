import "package:qr_flutter/qr_flutter.dart";
import "package:flutter/material.dart";

/// QR_Component is a StatelessWidget that displays a QR code
/// with the given data.
///
/// It receives a String data and displays a QR code with

class QRComponent extends StatelessWidget {
  final String data;
  const QRComponent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: 200.0,
      ),
    );
  }
}
