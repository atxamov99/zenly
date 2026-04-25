import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

class GlassFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  const GlassFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: GlassSurface(
        blur: GlassTokens.blurThick,
        tintOpacity: 0.55,
        radius: size / 2,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(size / 2),
            child: Center(
              child: Icon(icon, color: GlassTokens.onGlass, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
