import 'dart:async';

import 'package:flutter/material.dart';

class InAppBanner {
  static OverlayEntry? _entry;
  static Timer? _autoDismiss;

  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    _autoDismiss?.cancel();
    _entry?.remove();
    _entry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 8,
        left: 12,
        right: 12,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              dismiss();
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        if (subtitle != null && subtitle.isNotEmpty)
                          Text(subtitle,
                              style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const IconButton(
                    icon: Icon(Icons.close, size: 18),
                    onPressed: InAppBanner.dismiss,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    _entry = entry;
    overlay.insert(entry);

    _autoDismiss = Timer(const Duration(seconds: 3), dismiss);
  }

  static void dismiss() {
    _autoDismiss?.cancel();
    _autoDismiss = null;
    _entry?.remove();
    _entry = null;
  }
}
