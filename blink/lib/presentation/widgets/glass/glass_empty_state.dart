import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';
import 'glass_card.dart';

/// Liquid Glass uslubidagi empty/error holat ko'rsatkichi.
/// Markazlashgan glass card ichida ikona, sarlavha va ixtiyoriy
/// tafsilot + retry tugmasi ko'rsatadi.
class GlassEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? detail;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const GlassEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.detail,
    this.retryLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.black54),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (detail != null) ...[
              const SizedBox(height: 6),
              Text(
                detail!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: GlassTokens.tintProminent,
                  foregroundColor: Colors.black87,
                ),
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? "Qayta urinib ko'rish"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
