import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';

/// Liquid Glass'ning atom widget'i.
///
/// Ostidagi kontentni blur qiladi, tint qatlamini qo'shadi va
/// (ixtiyoriy) yuqorida 1pt specular highlight chizadi.
///
/// Barcha glass komponentlar shu widget ustiga quriladi.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double blur;
  final double tintOpacity;
  final double radius;
  final bool specular;
  final EdgeInsetsGeometry? padding;

  const GlassSurface({
    super.key,
    required this.child,
    this.blur = GlassTokens.blurRegular,
    this.tintOpacity = 0.14,
    this.radius = GlassTokens.radiusCard,
    this.specular = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: tintOpacity),
            border: Border(
              top: specular
                  ? const BorderSide(
                      color: GlassTokens.strokeSpecular,
                      width: 1,
                    )
                  : BorderSide.none,
              bottom: const BorderSide(
                color: GlassTokens.strokeContour,
                width: 0.5,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
