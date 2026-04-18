import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = GlassTokens.radiusCard,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = GlassSurface(
      blur: GlassTokens.blurRegular,
      tintOpacity: 0.45,
      radius: radius,
      padding: padding,
      child: child,
    );

    return Padding(
      padding: margin,
      child: onTap == null
          ? surface
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(radius),
                child: surface,
              ),
            ),
    );
  }
}
