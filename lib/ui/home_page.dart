import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import 'icons.dart';
import 'sheets.dart';
import 'theme.dart';
import 'widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _sapa() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat Pagi';
    if (h < 15) return 'Selamat Siang';
    if (h < 18) return 'Selamat Sore';
    return 'Selamat Malam';
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Color(0x1F0D1220), blurRadius: 16, offset: Offset(0, 6))],
              ),
              child: Icon(icon, size: 26, color: C.ink),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stok(AppStore s, int i, String label, num v, IconData icon, Color c) {
    return Expanded(
      child: Tap(
        onTap: () => s.openStok(i),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 16, offset: Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, size: 19, color: c),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  fmt(v),
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: C.ink),
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 12, color: C.ink3)),
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
    final feed = s.feed(0).take(5).toList();
    final sk = s.siklus;
    final plus = sk > 0 ? '+' : '';
    final saldo = s.hideSaldo ? 'Rp ••••••' : rp(s.kas);
    final sub = s.hideSaldo ? 'Siklus •••• · Utama ••••' : 'Siklus $plus${rp(sk)} · Utama ${rp(s.totalUtama)}';

    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: TopGradient(height: 520)),
        ListView(
          padding: EdgeInsets.fromLTRB(20, top + 14, 20, 130),
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
                RoundIconBtn(icon: Ic.search, onTap: () => s.setTab(2)),
                const SizedBox(width: 10),
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
                  'Sinkron bermasalah: ${s.error}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: C.red, fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 28),
            Text('Total Kas', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14)),
            const SizedBox(height: 4),
            Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      saldo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: s.toggleSaldo,
                  child: Icon(
                    s.hideSaldo ? Ic.eyeOff : Ic.eye,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5)),
            const SizedBox(height: 26),
            Row(
              children: [
                _aksi(Ic.add, 'Cetak', () => openTx(context, TxKind.cetak)),
                _aksi(Ic.fire, 'Ke Tungku', () => openTx(context, TxKind.pindah)),
                _aksi(Ic.truck, 'Kirim', () => openTx(context, TxKind.kirim)),
                _aksi(Ic.wallet, 'Biaya', () => openTx(context, TxKind.pengeluaran)),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                _stok(s, 0, 'Mentah', s.mentahKulon + s.mentahEtan, Ic.box, C.green),
                const SizedBox(width: 10),
                _stok(s, 1, 'Di Tungku', s.batu, Ic.fire, C.amber),
                const SizedBox(width: 10),
                _stok(s, 2, 'Siap Jual', s.siapJual, Ic.stock, C.blue),
              ],
            ),
            const SizedBox(height: 14),
            _SesiCard(s),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.ink),
                  ),
                ),
                GestureDetector(
                  onTap: () => s.setTab(2),
                  child: const Text(
                    'Lihat semua',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FeedCard(items: feed, loading: !s.ready),
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
      final sn = a['sesi'];
      info = 'Sesi $sn sedang berjalan dengan ${fmt(toNum(a['nominal']))} bata di tungku.';
      cta = 'Selesai bakar';
      onTap = () => openTx(context, TxKind.selesaiBakar);
    } else if (s.batu > 0) {
      info = '${fmt(s.batu)} bata sudah di tungku dan siap dibakar.';
      cta = 'Mulai bakar';
      onTap = () => openTx(context, TxKind.mulaiBakar);
    } else {
      info = 'Tungku masih kosong. Pindahkan bata mentah untuk memulai sesi bakar.';
      cta = 'Pindah ke tungku';
      onTap = () => openTx(context, TxKind.pindah);
    }
    return WhiteCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(6, 6, 6, 10),
            child: Row(
              children: [
                Icon(Ic.fire, color: Color(0xFF2B9BF0), size: 22),
                SizedBox(width: 8),
                Text('Sesi Bakar', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: C.ink)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(info, style: const TextStyle(fontSize: 13.5, height: 1.4, color: C.ink2)),
                const SizedBox(height: 12),
                Tap(
                  onTap: onTap,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cta, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.ink)),
                        const SizedBox(width: 8),
                        const Icon(Ic.arrowRight, size: 18, color: C.ink),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
