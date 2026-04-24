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
            Color(0xFFE9F2FF),
            Color(0xFFF6E9FF),
            Color(0xFFFFF1E6),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}
