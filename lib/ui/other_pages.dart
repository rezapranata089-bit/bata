import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import 'sheets.dart';
import 'theme.dart';
import 'widgets.dart';

TextStyle _h1() => const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5);

TextStyle _h1Sub() => TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 13.5);

// ───────────────────────── STOK ─────────────────────────
class StokPage extends StatelessWidget {
  const StokPage({super.key});

  Widget _mini(BuildContext context, String label, num v, String tempat) {
    return Expanded(
      child: WhiteCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mentah $label', style: const TextStyle(fontSize: 12.5, color: C.ink2, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(fmt(v), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.ink)),
            const SizedBox(height: 12),
            PillBtn(
              label: 'Cetak',
              icon: Icons.add_rounded,
              onTap: () => openTx(context, TxKind.cetak, tempat: tempat),
            ),
          ],
        ),
      ),
    );
  }

  Widget _arrow() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Center(child: Icon(Icons.keyboard_double_arrow_down_rounded, color: C.ink3)),
      );

  Widget _big(String title, String sub, num v, Color c, List<Widget> actions) {
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: C.ink2)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmt(v), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: C.ink)),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('bata', style: TextStyle(fontSize: 13, color: C.ink3)),
              ),
            ],
          ),
          Text(sub, style: const TextStyle(fontSize: 12.5, color: C.ink3)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final total = s.mentahKulon + s.mentahEtan + s.batu + s.siapJual;
    final sesi = s.sesi.reversed.take(6).toList();
    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: TopGradient(height: 380)),
        ListView(
          padding: EdgeInsets.fromLTRB(20, top + 18, 20, 130),
          children: [
            Text('Stok Bata', style: _h1()),
            const SizedBox(height: 4),
            Text('Total ${fmt(total)} bata di semua tahap', style: _h1Sub()),
            const SizedBox(height: 22),
            Row(
              children: [
                _mini(context, 'Kulon', s.mentahKulon, 'kulon'),
                const SizedBox(width: 12),
                _mini(context, 'Etan', s.mentahEtan, 'etan'),
              ],
            ),
            _arrow(),
            _big(
              'Di Tungku',
              s.burning ? 'Sesi ${s.sesiCount} sedang dibakar' : 'Menunggu dibakar',
              s.batu,
              C.amber,
              [
                PillBtn(label: 'Pindah mentah', icon: Icons.south_rounded, onTap: () => openTx(context, TxKind.pindah)),
                if (s.burning)
                  PillBtn(
                    label: 'Selesai bakar',
                    icon: Icons.check_rounded,
                    dark: false,
                    onTap: () => openTx(context, TxKind.selesaiBakar),
                  )
                else
                  PillBtn(
                    label: 'Mulai bakar',
                    icon: Icons.whatshot_rounded,
                    dark: false,
                    onTap: () => openTx(context, TxKind.mulaiBakar),
                  ),
              ],
            ),
            _arrow(),
            _big(
              'Siap Jual',
              'Tertata di gudang',
              s.siapJual,
              C.blue,
              [
                PillBtn(label: 'Susun dari tungku', icon: Icons.inventory_2_rounded, onTap: () => openTx(context, TxKind.susun)),
                PillBtn(
                  label: 'Kirim / jual',
                  icon: Icons.local_shipping_rounded,
                  dark: false,
                  onTap: () => openTx(context, TxKind.kirim),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const Text('Riwayat Sesi Bakar', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: C.ink)),
            const SizedBox(height: 12),
            WhiteCard(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: sesi.isEmpty
                  ? const SizedBox(
                      height: 80,
                      child: Center(child: Text('Belum ada sesi bakar', style: TextStyle(color: C.ink3))),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < sesi.length; i++) ...[
                          _SesiTile(sesi[i]),
                          if (i != sesi.length - 1) const Divider(height: 1, color: Color(0xFFF0F1F4)),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SesiTile extends StatelessWidget {
  const _SesiTile(this.e);

  final Map<String, dynamic> e;

  @override
  Widget build(BuildContext context) {
    final selesai = e['selesai'] == true;
    final biaya = e['biaya'];
    final total = biaya is Map ? toNum(biaya['total']) : 0;
    final tgl = (e['tanggalMulai'] ?? e['tanggal'] ?? '').toString();
    final sn = e['sesi'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(14)),
            child: Icon(
              selesai ? Icons.check_circle_rounded : Icons.whatshot_rounded,
              color: selesai ? C.green : C.amber,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sesi $sn', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: C.ink)),
                Text(
                  '${tglCantik(tgl)} · ${selesai ? 'Selesai' : 'Berjalan'}',
                  style: const TextStyle(fontSize: 12, color: C.ink3),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${fmt(toNum(e['nominal']))} bata',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: C.ink),
              ),
              if (total > 0) Text(rp(total), style: const TextStyle(fontSize: 11.5, color: C.ink3)),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── AKTIVITAS ─────────────────────────
class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  int _f = 0;

  Widget _stat(String label, num v, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                rp(v),
                style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
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
        const Positioned(top: 0, left: 0, right: 0, child: TopGradient(height: 420)),
        ListView(
          padding: EdgeInsets.fromLTRB(20, top + 18, 20, 130),
          children: [
            Text('Aktivitas', style: _h1()),
            const SizedBox(height: 4),
            Text('Riwayat kas dan stok usaha bata', style: _h1Sub()),
            const SizedBox(height: 20),
            Row(
              children: [
                _stat('Pemasukan bulan ini', s.pemasukanBulan, Icons.south_west_rounded),
                const SizedBox(width: 12),
                _stat('Pengeluaran bulan ini', s.pengeluaranBulan, Icons.north_east_rounded),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: WhiteBtn(
                    icon: Icons.remove_circle_outline_rounded,
                    label: 'Pengeluaran',
                    onTap: () => openTx(context, TxKind.pengeluaran),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: WhiteBtn(
                    icon: Icons.send_rounded,
                    label: 'Kirim ke Utama',
                    onTap: () => openTx(context, TxKind.kirimUtama),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilterChips(items: const ['Semua', 'Kas', 'Stok'], index: _f, onChanged: (i) => setState(() => _f = i)),
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

  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
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
            Text('Profil', style: _h1()),
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
                  _row('Status', aktif ? 'Aktif' : 'Tidak ada'),
                  _row('Sisa bata', fmt(toNum(s.bon['sisaBata']))),
                  _row('Sisa hutang', rp(toNum(s.bon['sisaRp']))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            WhiteCard(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Sembunyikan saldo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: C.ink)),
                  ),
                  Switch(value: s.hideSaldo, onChanged: (_) => s.toggleSaldo()),
                ],
              ),
            ),
            const SizedBox(height: 14),
            WhiteCard(
              child: Column(
                children: [
                  _row('Sinkron Firestore', s.error != null ? 'Bermasalah' : (s.ready ? 'Tersambung' : 'Menghubungkan')),
                  _row('Project', 'usaha-batu'),
                  _row('Versi', '1.0.0'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}