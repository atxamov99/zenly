import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrShowDialog extends StatelessWidget {
  final String username;

  const QrShowDialog({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Mening QR kodim',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            QrImageView(
              data: username,
              version: QrVersions.auto,
              size: 220,
            ),
            const SizedBox(height: 12),
            Text(
              '@$username',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Yopish'),
            ),
          ],
        ),
      ),
    );
  }
}
