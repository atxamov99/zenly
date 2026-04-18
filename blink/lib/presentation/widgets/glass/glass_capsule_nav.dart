import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

/// BottomNav'dagi bitta tab elementi.
class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final int badgeCount;

  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    this.badgeCount = 0,
  });
}

/// Pastdan suzayotgan glass capsule navigation bar.
///
/// Selected pellet `Stack` ichida `AnimatedAlign` orqali tab orasida
/// liquid morph bilan suriladi.
class GlassCapsuleNav extends StatelessWidget {
  final int currentIndex;
  final List<GlassNavItem> items;
  final ValueChanged<int> onTap;

  const GlassCapsuleNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        GlassTokens.capsuleHorizontalMargin,
        0,
        GlassTokens.capsuleHorizontalMargin,
        bottomInset + GlassTokens.capsuleBottomGap,
      ),
      child: SizedBox(
        height: GlassTokens.capsuleHeight,
        child: GlassSurface(
          blur: GlassTokens.blurRegular + 10,
          tintOpacity: 0.18,
          radius: GlassTokens.capsuleRadius,
          child: Stack(
            children: [
              _Pellet(
                index: currentIndex,
                count: items.length,
              ),
              Row(
                children: [
                  for (int i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavTab(
                        item: items[i],
                        active: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pellet extends StatelessWidget {
  final int index;
  final int count;
  const _Pellet({required this.index, required this.count});

  @override
  Widget build(BuildContext context) {
    final alignmentX = count == 1 ? 0.0 : -1.0 + (2.0 * index / (count - 1));
    return AnimatedAlign(
      duration: GlassTokens.springDuration,
      curve: GlassTokens.spring,
      alignment: Alignment(alignmentX, 0),
      child: FractionallySizedBox(
        widthFactor: 1 / count,
        heightFactor: 1,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
              color: GlassTokens.tintProminent,
              borderRadius: BorderRadius.circular(GlassTokens.radiusButton + 4),
              border: Border.all(
                color: GlassTokens.strokeSpecular,
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final GlassNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GlassTokens.radiusButton + 4),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                active ? item.activeIcon : item.icon,
                key: ValueKey(active),
                size: 26,
                color: active ? Colors.black87 : Colors.black54,
              ),
            ),
            if (item.badgeCount > 0)
              Positioned(
                top: -4,
                right: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${item.badgeCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
