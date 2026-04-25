import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

/// SliverAppBar with Liquid Glass surface.
/// floating + snap: hides on scroll-down, reappears on scroll-up.
/// Set [pinned] = true to keep it visible at the top when scrolled.
class GlassSliverAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool pinned;
  final bool forceElevated;

  const GlassSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.pinned = false,
    this.forceElevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: pinned,
      forceElevated: forceElevated,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      actions: actions,
      title: DefaultTextStyle.merge(
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        child: title,
      ),
      bottom: bottom,
      flexibleSpace: GlassSurface(
        blur: GlassTokens.blurThick,
        tintOpacity: 0.55,
        radius: 0,
        specular: false,
        child: const SizedBox.expand(),
      ),
    );
  }
}
