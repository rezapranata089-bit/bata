import 'package:flutter/material.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

import 'icons.dart';
import 'theme.dart';

class _NavItem {
  const _NavItem(this.on, this.off, this.label);

  final IconData on, off;
  final String label;
}

const _items = [
  _NavItem(Ic.homeOn, Ic.home, 'Beranda'),
  _NavItem(Ic.boxOn, Ic.box, 'Stok'),
  _NavItem(Ic.chartOn, Ic.chart, 'Aktivitas'),
  _NavItem(Ic.userOn, Ic.user, 'Profil'),
];

/// Bottom nav melayang berbahan liquid glass (oc_liquid_glass)
class GlassNav extends StatelessWidget {
  const GlassNav({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const double _h = 68;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 10),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          return SizedBox(
            width: w,
            height: _h,
            child: OCLiquidGlassGroup(
              settings: const OCLiquidGlassSettings(
                refractStrength: -0.08,
                blurRadiusPx: 4,
                blendPx: 10,
                distortFalloffPx: 30,
                specStrength: 10,
                specWidth: 1.5,
                specPower: 6,
                lightbandStrength: 0.5,
                lightbandColor: Colors.white,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: OCLiquidGlass(
                      width: w,
                      height: _h,
                      borderRadius: _h / 2,
                      color: Colors.white.withValues(alpha: 0.35),
                      shadow: BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  // tepi tipis + isi ringan (juga jadi cadangan bila shader tidak aktif)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(_h / 2),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        children: [
                          for (var i = 0; i < _items.length; i++)
                            Expanded(
                              child: _NavBtn(
                                item: _items[i],
                                selected: i == index,
                                onTap: () => onChanged(i),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.item, required this.selected, required this.onTap});

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.78) : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? item.on : item.off, size: 24, color: selected ? C.ink : C.ink2),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? C.ink : C.ink2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}