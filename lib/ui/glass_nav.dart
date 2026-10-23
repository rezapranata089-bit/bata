import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../data/store.dart';
import 'icons.dart';
import 'sheets.dart';
import 'theme.dart';

class _NavItem {
  const _NavItem(this.on, this.off, this.label);

  final IconData on, off;
  final String label;
}

const _items = [
  _NavItem(Ic.homeOn, Ic.home, 'nav_home'),
  _NavItem(Ic.boxOn, Ic.box, 'nav_stok'),
  _NavItem(Ic.chartOn, Ic.chart, 'nav_act'),
  _NavItem(Ic.userOn, Ic.user, 'nav_profile'),
];

/// Bottom nav melayang berbahan liquid glass (liquid_glass_widgets).
/// Dipasang lewat GlassScaffold.bottomBar di shell.dart.
class GlassNav extends StatelessWidget {
  const GlassNav({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = C.dark;
    final accent = StoreScope.of(context).pal.accent;
    return GlassTabBar.bottom(
      selectedIndex: index,
      onTabSelected: onChanged,
      horizontalPadding: 16,
      verticalPadding: 10,
      barHeight: 68,
      barBorderRadius: 34,
      iconSize: 24,
      labelFontSize: 10.5,
      iconLabelSpacing: 2,
      quality: GlassQuality.premium,
      interactionBehavior: GlassInteractionBehavior.full,
      extraButton: GlassTabBarExtraButton.menu(
        icon: const Icon(CupertinoIcons.plus),
        label: 'Tambah',
        iconColor: accent,
        size: 68,
        placement: GlassExtraButtonPlacement.right,
        menuWidth: 230,
        menuItems: [
          GlassMenuItem(
            title: L.t('act_print'),
            icon: Icon(Ic.add),
            onTap: () => openTx(context, TxKind.cetak),
          ),
          GlassMenuItem(
            title: L.t('act_kiln'),
            icon: Icon(Ic.fire),
            onTap: () => openTx(context, TxKind.pindah),
          ),
          GlassMenuItem(
            title: L.t('act_send'),
            icon: Icon(Ic.truck),
            onTap: () => openTx(context, TxKind.kirim),
          ),
          GlassMenuItem(
            title: L.t('act_cost'),
            icon: Icon(Ic.wallet),
            onTap: () => openTx(context, TxKind.pengeluaran),
          ),
        ],
      ),
      selectedIconColor: accent,
      unselectedIconColor: C.ink2,
      selectedLabelColor: accent,
      unselectedLabelColor: C.ink2,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      indicatorColor: Colors.white.withValues(alpha: dark ? 0.14 : 0.55),
      settings: LiquidGlassSettings(
        glassColor: (dark ? Colors.black : Colors.white).withValues(alpha: dark ? 0.30 : 0.28),
        thickness: 24,
        blur: 6,
        chromaticAberration: 0.01,
        lightIntensity: 0.6,
        refractiveIndex: 1.2,
        saturation: 1.3,
      ),
      tabs: [
        for (final it in _items)
          GlassTab(
            icon: Icon(it.off),
            activeIcon: Icon(it.on),
            label: L.t(it.label),
          ),
      ],
    );
  }
}
