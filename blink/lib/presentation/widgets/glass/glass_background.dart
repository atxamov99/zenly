import 'package:flutter/material.dart';

/// Liquid Glass ekranlari uchun yumshoq gradient fon.
/// Map ekrani bilan vizual uyg'unlik yaratadi va GlassSurface tint'lariga
/// orqa qatlam beradi.
class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D1117),
            Color(0xFF1A1035),
            Color(0xFF0A1F3D),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}
