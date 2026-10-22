import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/store.dart';
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
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: s.tab,
                children: const [HomePage(), StokPage(), AktivitasPage(), ProfilPage()],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlassNav(index: s.tab, onChanged: s.setTab),
            ),
          ],
        ),
      ),
    );
  }
}