import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../data/store.dart';
import 'theme.dart';
import 'glass_nav.dart';
import 'home_view.dart';
import 'other_pages.dart';
import 'stok_page.dart';

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Material(
        color: C.bg,
        child: GlassScaffold(
          backgroundColor: C.bg,
          edgeFade: false,
          extendBody: true,
          body: IndexedStack(
            index: s.tab,
            children: const [HomePage(), StokPage(), AktivitasPage(), ProfilPage()],
          ),
          bottomBar: GlassNav(index: s.tab, onChanged: s.setTab),
        ),
      ),
    );
  }
}