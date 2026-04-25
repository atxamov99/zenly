import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      blur: GlassTokens.blurThick,
      tintOpacity: 0.55,
      radius: 0,
      specular: false,
      child: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: DefaultTextStyle.merge(
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GlassTokens.onGlass,
          ),
          child: title,
        ),
        actions: actions,
        leading: leading,
        bottom: bottom,
      ),
    );
  }
}
