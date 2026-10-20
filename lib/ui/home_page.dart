import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import 'sheets.dart';
import 'theme.dart';
import 'widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _f = 0;

  String _sapa() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat Pagi';
    if (h < 15) return 'Selamat Siang';
    if (h < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final feed = s.feed(_f).take(6).toList();
    final sk = s.siklus;
    final plus = sk > 0 ? '+' : '';
    final saldo = s.hideSaldo ? 'Rp ••••••' : rp(s.kas);
    final sub = s.hideSaldo ? 'Siklus •••• · Utama ••••' : 'Siklus $plus${rp(sk)} · Utama ${rp(s.totalUtama)}';

    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: TopGradient()),
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
                RoundIconBtn(icon: Icons.search_rounded, onTap: () => s.setTab(2)),
                const SizedBox(width: 10),
                RoundIconBtn(icon: Icons.notifications_none_rounded, dot: s.burning),
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
            const SizedBox(height: 26),
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
                    s.hideSaldo ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5)),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: WhiteBtn(
                    icon: Icons.add_rounded,
                    label: 'Cetak',
                    onTap: () => openTx(context, TxKind.cetak),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: WhiteBtn(
                    icon: Icons.swap_vert_rounded,
                    label: 'Kirim',
                    onTap: () => openTx(context, TxKind.kirim),
                  ),
                ),
                const SizedBox(width: 12),
                Tap(
                  onTap: () => openTx(context, TxKind.pindah),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.local_fire_department_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SesiCard(s),
            const SizedBox(height: 16),
            _StatStrip(s),
            const SizedBox(height: 26),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: C.ink),
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
            FilterChips(items: const ['Semua', 'Kas', 'Stok'], index: _f, onChanged: (i) => setState(() => _f = i)),
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
      info = 'Sesi $sn sedang berjalan dengan ${fmt(toNum(a['nominal']))} bata di tungku. '
          'Tap bila pembakaran sudah selesai.';
      cta = 'Selesai bakar';
      onTap = () => openTx(context, TxKind.selesaiBakar);
    } else if (s.batu > 0) {
      info = '${fmt(s.batu)} bata sudah di tungku dan siap dibakar. Mulai sesi baru sekarang.';
      cta = 'Mulai bakar';
      onTap = () => openTx(context, TxKind.mulaiBakar);
    } else {
      info = 'Tungku masih kosong. Pindahkan bata mentah ke tungku untuk memulai sesi bakar.';
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
                Icon(Icons.local_fire_department_rounded, color: Color(0xFF2B9BF0), size: 22),
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
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: C.ink),
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

class _StatStrip extends StatelessWidget {
  const _StatStrip(this.s);

  final AppStore s;

  Widget _cell(String label, num v, Color c) {
    return Expanded(
      child: Column(
        children: [
          Text(fmt(v), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: C.ink3)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const div = SizedBox(height: 30, child: VerticalDivider(width: 1, color: C.line));
    return WhiteCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _cell('Mentah', s.mentahKulon + s.mentahEtan, C.green),
          div,
          _cell('Di Tungku', s.batu, C.amber),
          div,
          _cell('Siap Jual', s.siapJual, C.blue),
        ],
      ),
    );
  }
}