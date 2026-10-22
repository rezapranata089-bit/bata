import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import 'extras.dart';
import 'icons.dart';
import 'sheets.dart';
import 'theme.dart';
import 'widgets.dart';

// ───────────────────────── AKTIVITAS ─────────────────────────
class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  int _f = 0;

  Widget _flow(String label, num v, Color c, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: c.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: c),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12.5, color: C.ink2)),
            ],
          ),
          const SizedBox(height: 10),
          Counter(
            value: v,
            symbol: 'Rp ',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.ink),
          ),
        ],
      ),
    );
  }

  String _label(String t) => t == tanggalHariIni() ? 'Hari ini' : tglCantik(t);

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final feed = s.feed(_f).take(120).toList();
    final groups = <String, List<Aktivitas>>{};
    for (final a in feed) {
      groups.putIfAbsent(a.tanggal.isEmpty ? '-' : a.tanggal, () => <Aktivitas>[]).add(a);
    }
    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: TopGradient(height: 360)),
        ListView(
          padding: EdgeInsets.fromLTRB(20, top + 18, 20, 130),
          children: [
            Text(L.t('activity_title'), style: pageTitle),
            const SizedBox(height: 4),
            Text(L.t('activity_sub'), style: pageSub),
            const SizedBox(height: 20),
            WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L.t('this_month'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: C.ink3)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _flow(L.t('income'), s.pemasukanBulan, C.green, Ic.incoming),
                      const SizedBox(height: 40, child: VerticalDivider(width: 24, color: C.line)),
                      _flow(L.t('expense'), s.pengeluaranBulan, C.red, Ic.outgoing),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ActBtn(label: L.t('expense'), icon: Ic.wallet, onTap: () => openTx(context, TxKind.pengeluaran)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActBtn(
                    label: L.t('send_main'),
                    icon: Ic.send,
                    dark: true,
                    onTap: () => openTx(context, TxKind.kirimUtama),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilterChips(items: [L.t('f_all'), L.t('f_cash'), L.t('f_stock')], index: _f, onChanged: (i) => setState(() => _f = i)),
            const SizedBox(height: 14),
            if (feed.isEmpty) FeedCard(items: feed, loading: !s.ready),
            for (final e in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Text(
                  _label(e.key),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.ink2),
                ),
              ),
              FeedCard(items: e.value, loading: false),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── PROFIL ─────────────────────────
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  Widget _row(IconData icon, String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 20, color: C.ink2),
          const SizedBox(width: 12),
          Expanded(child: Text(l, style: const TextStyle(color: C.ink2, fontSize: 14))),
          Text(v, style: const TextStyle(color: C.ink, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final aktif = s.bon['kasbonActive'] == true;
    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: TopGradient(height: 360)),
        ListView(
          padding: EdgeInsets.fromLTRB(20, top + 18, 20, 130),
          children: [
            Text(L.t('profile'), style: pageTitle),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.5),
                  ),
                  child: const Text('R', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reza', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('Pemilik Usaha Bata', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kasbon Pekerja', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.ink)),
                  const SizedBox(height: 6),
                  _row(Ic.hand, L.t('status'), aktif ? L.t('active') : L.t('none')),
                  _row(Ic.box, L.t('rest_brick'), fmt(toNum(s.bon['sisaBata']))),
                  _row(Ic.money, L.t('rest_debt'), rp(toNum(s.bon['sisaRp']))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SettingsCard(),
            const SizedBox(height: 14),
            WhiteCard(
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
              child: Row(
                children: [
                  const Icon(Ic.eyeOff, size: 20, color: C.ink2),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(L.t('hide_balance'), style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: C.ink)),
                  ),
                  Switch(value: s.hideSaldo, onChanged: (_) => s.toggleSaldo()),
                ],
              ),
            ),
            const SizedBox(height: 14),
            WhiteCard(
              child: Column(
                children: [
                  _row(Ic.cloud, L.t('sync'), s.error != null ? L.t('problem') : (s.ready ? L.t('connected') : L.t('connecting'))),
                  _row(Ic.info, 'Project', 'usaha-batu'),
                  _row(Ic.tune, L.t('version'), '1.1.0'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
