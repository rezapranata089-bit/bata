import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import 'extras.dart';
import 'icons.dart';
import 'sheets.dart';
import 'theme.dart';
import 'widgets.dart';

/// Tab Stok: sub-tab Mentah / Tungku / Siap Jual (bisa di-swipe)
class StokPage extends StatelessWidget {
  const StokPage({super.key});

  static List<String> get _labels => [L.t('raw'), L.t('kiln'), L.t('ready')];

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final i = s.stokTab;
    final total = s.mentahKulon + s.mentahEtan + s.batu + s.siapJual;
    final Widget body = switch (i) {
      0 => _Mentah(s),
      1 => _Tungku(s),
      _ => _SiapJual(s),
    };
    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: TopGradient(height: 300)),
        Positioned.fill(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, top + 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L.t('stok_title'), style: pageTitle),
                    const SizedBox(height: 4),
                    Text(L.t('stok_total').replaceAll('{n}', fmt(total)), style: pageSub),
                    const SizedBox(height: 18),
                    _SegTabs(labels: _labels, index: i, onChanged: s.setStokTab),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: (d) {
                    final v = d.primaryVelocity ?? 0;
                    if (v < -300 && i < 2) s.setStokTab(i + 1);
                    if (v > 300 && i > 0) s.setStokTab(i - 1);
                  },
                  child: AnimatedSwitcher(duration: const Duration(milliseconds: 240), child: body),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SegTabs extends StatelessWidget {
  const _SegTabs({required this.labels, required this.index, required this.onChanged});

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? C.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: i == index ? FontWeight.w700 : FontWeight.w600,
                      color: i == index ? C.ink : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    StoreScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.ink)),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
      child: Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.pill,
    this.sub,
  });

  final String label;
  final num value;
  final IconData icon;
  final Color color;
  final String? pill;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.ink2)),
              ),
              if (pill != null) _Pill(pill!, color),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Counter(
                value: value,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: C.ink, height: 1),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('bata', style: TextStyle(fontSize: 14, color: C.ink3)),
              ),
            ],
          ),
          if (sub != null) ...[
            const SizedBox(height: 8),
            Text(sub!, style: TextStyle(fontSize: 12.5, color: C.ink3)),
          ],
        ],
      ),
    );
  }
}

class _Area extends StatelessWidget {
  const _Area(this.label, this.value);

  final String label;
  final num value;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Area $label', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: C.ink2)),
          const SizedBox(height: 8),
          Counter(
            value: value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: C.ink, height: 1),
          ),
          const SizedBox(height: 4),
          Text('bata mentah', style: TextStyle(fontSize: 12, color: C.ink3)),
        ],
      ),
    );
  }
}

// ───────────────────────── SUB-TAB: MENTAH ─────────────────────────
class _Mentah extends StatelessWidget {
  const _Mentah(this.s);

  final AppStore s;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('mentah'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
      children: [
        Row(
          children: [
            Expanded(child: _Area('Kulon', s.mentahKulon)),
            const SizedBox(width: 12),
            Expanded(child: _Area('Etan', s.mentahEtan)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ActBtn(label: 'Cetak bata', icon: Ic.add, dark: true, onTap: () => openTx(context, TxKind.cetak)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActBtn(label: 'Ke tungku', icon: Ic.fire, onTap: () => openTx(context, TxKind.pindah)),
            ),
          ],
        ),
        _Section(L.t('h_raw')),
        FeedCard(items: s.mentah.take(15).toList(), loading: !s.ready),
      ],
    );
  }
}

// ───────────────────────── SUB-TAB: TUNGKU ─────────────────────────
class _Tungku extends StatelessWidget {
  const _Tungku(this.s);

  final AppStore s;

  @override
  Widget build(BuildContext context) {
    final a = s.sesiAktif;
    final sn = a?['sesi'];
    final sesi = s.sesi.reversed.take(5).toList();
    return ListView(
      key: const ValueKey('tungku'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
      children: [
        _Hero(
          label: 'Stok di tungku',
          value: s.batu,
          icon: Ic.fire,
          color: C.amber,
          pill: s.burning ? 'Sedang dibakar' : 'Menunggu',
          sub: a != null ? 'Sesi $sn · ${fmt(toNum(a['nominal']))} bata sedang dibakar' : null,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: s.burning
                  ? ActBtn(
                      label: 'Selesai bakar',
                      icon: Ic.checkLine,
                      dark: true,
                      onTap: () => openTx(context, TxKind.selesaiBakar),
                    )
                  : ActBtn(
                      label: 'Mulai bakar',
                      icon: Ic.play,
                      dark: true,
                      onTap: () => openTx(context, TxKind.mulaiBakar),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActBtn(label: 'Pindah mentah', icon: Ic.arrowDown, onTap: () => openTx(context, TxKind.pindah)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ActBtn(label: 'Susun ke siap jual', icon: Ic.stock, onTap: () => openTx(context, TxKind.susun)),
        _Section(L.t('h_sessions')),
        WhiteCard(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: sesi.isEmpty
              ? SizedBox(
                  height: 80,
                  child: Center(child: Text(L.t('no_session'), style: TextStyle(color: C.ink3))),
                )
              : Column(
                  children: [
                    for (var i = 0; i < sesi.length; i++) ...[
                      _SesiTile(sesi[i]),
                      if (i != sesi.length - 1) Divider(height: 1, color: C.div),
                    ],
                  ],
                ),
        ),
        _Section(L.t('h_kiln')),
        FeedCard(items: s.beranda.take(10).toList(), loading: !s.ready),
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
    final c = selesai ? C.green : C.amber;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: c.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(14)),
            child: Icon(selesai ? Ic.check : Ic.fire, color: c, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sesi $sn', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: C.ink)),
                const SizedBox(height: 2),
                Text(
                  '${tglCantik(tgl)} · ${selesai ? 'Selesai' : 'Berjalan'}',
                  style: TextStyle(fontSize: 12, color: C.ink3),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${fmt(toNum(e['nominal']))} bata',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: C.ink),
              ),
              if (total > 0) Text(rp(total), style: TextStyle(fontSize: 11.5, color: C.ink3)),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── SUB-TAB: SIAP JUAL ─────────────────────────
class _SiapJual extends StatelessWidget {
  const _SiapJual(this.s);

  final AppStore s;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('siapjual'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
      children: [
        _Hero(label: 'Stok siap jual', value: s.siapJual, icon: Ic.stock, color: C.blue, sub: 'Tertata di gudang'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ActBtn(
                label: 'Susun dari tungku',
                icon: Ic.stock,
                dark: true,
                onTap: () => openTx(context, TxKind.susun),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActBtn(label: 'Kirim / jual', icon: Ic.truck, onTap: () => openTx(context, TxKind.kirim)),
            ),
          ],
        ),
        _Section(L.t('h_ready')),
        FeedCard(items: s.siapjual.take(15).toList(), loading: !s.ready),
      ],
    );
  }
}
