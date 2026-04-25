import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/theme/glass_tokens.dart';

import 'glass/glass_surface.dart';

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
            borderRadius: BorderRadius.circular(20),
            child: GlassSurface(
              blur: 30,
              tintOpacity: 0.55,
              radius: 20,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                fontWeight: FontWeight.bold,
                                color: GlassTokens.onGlass)),
                        if (subtitle != null && subtitle.isNotEmpty)
                          Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 12, color: GlassTokens.onGlassMuted)),
                      ],
                    ),
                  ),
                  const IconButton(
                    icon: Icon(Icons.close, size: 18, color: GlassTokens.onGlassMuted),
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
