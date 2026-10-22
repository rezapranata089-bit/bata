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

  Widget _aksi(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Tap(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: C.dark ? null : const [BoxShadow(color: Color(0x1F0D1220), blurRadius: 16, offset: Offset(0, 6))],
              ),
              child: Icon(icon, size: 26, color: C.ink),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ],
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
        const Positioned(top: 0, left: 0, right: 0, child: TopGradient(height: 520)),
        ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, top + 14, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                        ),
                        child: const Text(
                          'R',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
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
                  const SizedBox(height: 26),
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
                            letterSpacing: -1.4,
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
                      _aksi(Ic.add, L.t('act_print'), () => openTx(context, TxKind.cetak)),
                      _aksi(Ic.fire, L.t('act_kiln'), () => openTx(context, TxKind.pindah)),
                      _aksi(Ic.truck, L.t('act_send'), () => openTx(context, TxKind.kirim)),
                      _aksi(Ic.wallet, L.t('act_cost'), () => openTx(context, TxKind.pengeluaran)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(minHeight: minH),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 130),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: C.dark ? 0.35 : 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SesiCard(s),
                  const SizedBox(height: 26),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(22)),
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
          const SizedBox(height: 10),
          Text(info, style: TextStyle(fontSize: 13.5, height: 1.4, color: C.ink2)),
          const SizedBox(height: 12),
          Tap(
            onTap: onTap,
            child: Container(
              height: 46,
              decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cta, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.ink)),
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
