import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import 'extras.dart';
import 'icons.dart';
import 'sheets.dart';
import 'theme.dart';
import 'widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _sapa() {
    final h = DateTime.now().hour;
    if (h < 11) return L.t('hi_morning');
    if (h < 15) return L.t('hi_noon');
    if (h < 18) return L.t('hi_evening');
    return L.t('hi_night');
  }

  Widget _btn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Tap(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: const Color(0xFF0D1220)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Color(0xFF0D1220)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final minH = MediaQuery.sizeOf(context).height - 430;
    final feed = s.feed(0).take(6).toList();
    final sk = s.siklus;
    final plus = sk > 0 ? '+' : '';
    final sub = s.hideSaldo
        ? '${L.t('cycle')} •••• · ${L.t('main')} ••••'
        : '${L.t('cycle')} $plus${rp(sk)} · ${L.t('main')} ${rp(s.totalUtama)}';

    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: TopGradient(height: 504)),
        ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              child: Padding(
              padding: EdgeInsets.fromLTRB(24, top + 16, 24, 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Avatar(size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_sapa()} 👋',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                            ),
                            const Text(
                              'Reza',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      RoundIconBtn(icon: Ic.bell, dot: s.burning),
                    ],
                  ),
                  if (s.error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${L.t('sync_error')}: ${s.error}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: C.red, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(L.t('total_cash'), style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Counter(
                          value: s.kas,
                          symbol: 'Rp ',
                          hidden: s.hideSaldo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: s.toggleSaldo,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            s.hideSaldo ? Ic.eyeOff : Ic.eye,
                            color: Colors.white.withValues(alpha: 0.75),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _btn(Ic.add, L.t('act_print'), () => openTx(context, TxKind.cetak)),
                      const SizedBox(width: 12),
                      _btn(Ic.fire, L.t('act_kiln'), () => openTx(context, TxKind.pindah)),
                      const SizedBox(width: 12),
                      Tap(
                        onTap: () => openTx(context, TxKind.kirim),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B0E17),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Ic.truck, size: 22, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
            Container(
              constraints: BoxConstraints(minHeight: minH),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 128),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SesiCard(s),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          L.t('latest'),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.ink),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => s.setTab(2),
                        child: Text(
                          L.t('see_all'),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: s.pal.accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FeedCard(items: feed, loading: !s.ready, flat: true),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class _SesiCard extends StatelessWidget {
  const _SesiCard(this.s);

  final AppStore s;

  @override
  Widget build(BuildContext context) {
    final a = s.sesiAktif;
    final String info;
    final String cta;
    final VoidCallback onTap;
    if (a != null) {
      info = L
          .t('sesi_running')
          .replaceAll('{n}', '${a['sesi']}')
          .replaceAll('{b}', fmt(toNum(a['nominal'])));
      cta = L.t('cta_finish');
      onTap = () => openTx(context, TxKind.selesaiBakar);
    } else if (s.batu > 0) {
      info = L.t('sesi_ready').replaceAll('{b}', fmt(s.batu));
      cta = L.t('cta_start');
      onTap = () => openTx(context, TxKind.mulaiBakar);
    } else {
      info = L.t('sesi_empty');
      cta = L.t('cta_move');
      onTap = () => openTx(context, TxKind.pindah);
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(24),
        border: C.dark ? Border.all(color: C.line) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Ic.fire, color: s.pal.accent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  L.t('sesi_title'),
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: C.ink),
                ),
              ),
              if (a != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: C.amber.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    L.t('running'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.amber),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(16)),
            child: Text(info, style: TextStyle(fontSize: 13.5, height: 1.4, color: C.ink2)),
          ),
          const SizedBox(height: 12),
          Tap(
            onTap: onTap,
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      cta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Ic.arrowRight, size: 18, color: C.ink),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
