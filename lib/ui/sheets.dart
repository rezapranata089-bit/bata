import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

import '../data/models.dart';
import '../data/store.dart';
import 'theme.dart';
import 'widgets.dart';

enum TxKind { cetak, pindah, mulaiBakar, selesaiBakar, susun, kirim, pengeluaran, kirimUtama }

/// Sheet / dialog dengan latar yang ter-blur (seperti pada desain)
Future<T?> _blurRoute<T>(BuildContext context, {required Widget child, required bool sheet}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup',
    barrierColor: Colors.black.withValues(alpha: 0.12),
    transitionDuration: const Duration(milliseconds: 340),
    pageBuilder: (c, a1, a2) {
      final page = Material(type: MaterialType.transparency, child: child);
      if (sheet) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom), child: page),
        );
      }
      return Center(child: page);
    },
    transitionBuilder: (c, anim, a2, page) {
      final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
      return Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: curve,
              builder: (context, _) {
                final v = 14 * curve.value;
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: v, sigmaY: v),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
          if (sheet)
            SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curve),
              child: page,
            )
          else
            FadeTransition(
              opacity: curve,
              child: ScaleTransition(scale: Tween<double>(begin: 0.92, end: 1).animate(curve), child: page),
            ),
        ],
      );
    },
  );
}

Future<void> openTx(BuildContext context, TxKind kind, {String? tempat}) async {
  final msg = await _blurRoute<String>(context, sheet: true, child: TxSheet(kind: kind, tempat: tempat));
  if (msg != null && context.mounted) {
    await _blurRoute<void>(context, sheet: false, child: _SuccessCard(message: msg));
  }
}

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final t = fmt(int.parse(digits));
    return TextEditingValue(text: t, selection: TextSelection.collapsed(offset: t.length));
  }
}

// ───────────────────────── SUKSES ─────────────────────────
class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Color(0x290D1220), blurRadius: 40, offset: Offset(0, 16))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: OCLiquidGlassGroup(
                settings: const OCLiquidGlassSettings(
                  refractStrength: -0.07,
                  blurRadiusPx: 1.5,
                  blendPx: 8,
                  distortFalloffPx: 24,
                  specStrength: 8,
                  specWidth: 1.5,
                  specPower: 6,
                  lightbandStrength: 0.4,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(color: Color(0xFFEDEEF2), shape: BoxShape.circle),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: OCLiquidGlass(
                        width: 84,
                        height: 84,
                        borderRadius: 42,
                        color: C.blue.withValues(alpha: 0.10),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: C.ink, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Tersimpan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.ink)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.4, color: C.ink2),
            ),
            const SizedBox(height: 22),
            _BigBtn(
              label: 'Ke Beranda',
              onTap: () {
                StoreScope.read(context).setTab(0);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BigBtn extends StatelessWidget {
  const _BigBtn({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(28)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ───────────────────────── FORM + KONFIRMASI ─────────────────────────
class TxSheet extends StatefulWidget {
  const TxSheet({super.key, required this.kind, this.tempat});

  final TxKind kind;
  final String? tempat;

  @override
  State<TxSheet> createState() => _TxSheetState();
}

class _TxSheetState extends State<TxSheet> {
  final _jumlah = TextEditingController();
  final _harga = TextEditingController();
  final _tujuan = TextEditingController();
  final _ket = TextEditingController();
  final _nominal = TextEditingController();
  final _karung = TextEditingController();
  final _hargaMerang = TextEditingController();

  late String _tempat = widget.tempat ?? 'kulon';
  String _kat = 'Solar';
  late int _step = _hasFields ? 0 : 1;
  String? _err;

  bool get _hasFields => widget.kind != TxKind.mulaiBakar && widget.kind != TxKind.kirimUtama;

  @override
  void dispose() {
    _jumlah.dispose();
    _harga.dispose();
    _tujuan.dispose();
    _ket.dispose();
    _nominal.dispose();
    _karung.dispose();
    _hargaMerang.dispose();
    super.dispose();
  }

  int _int(TextEditingController c) => int.tryParse(c.text.replaceAll('.', '')) ?? 0;

  String get _title => switch (widget.kind) {
        TxKind.cetak => 'Cetak Bata',
        TxKind.pindah => 'Pindah ke Tungku',
        TxKind.mulaiBakar => 'Mulai Bakar',
        TxKind.selesaiBakar => 'Selesai Bakar',
        TxKind.susun => 'Susun ke Siap Jual',
        TxKind.kirim => 'Kirim / Jual Bata',
        TxKind.pengeluaran => 'Catat Pengeluaran',
        TxKind.kirimUtama => 'Kirim ke Total Utama',
      };

  IconData get _icon => switch (widget.kind) {
        TxKind.cetak => Icons.add_box_rounded,
        TxKind.pindah => Icons.local_fire_department_rounded,
        TxKind.mulaiBakar => Icons.whatshot_rounded,
        TxKind.selesaiBakar => Icons.check_circle_rounded,
        TxKind.susun => Icons.inventory_2_rounded,
        TxKind.kirim => Icons.local_shipping_rounded,
        TxKind.pengeluaran => Icons.south_west_rounded,
        TxKind.kirimUtama => Icons.send_rounded,
      };

  String get _headline => switch (widget.kind) {
        TxKind.cetak => 'Cetak Bata – Stok Mentah',
        TxKind.pindah => 'Bata Mentah – Tungku',
        TxKind.mulaiBakar => 'Sesi Bakar Baru',
        TxKind.selesaiBakar => 'Pembakaran Selesai',
        TxKind.susun => 'Tungku – Gudang Siap Jual',
        TxKind.kirim => 'Pengiriman – Penjualan Bata',
        TxKind.pengeluaran => 'Pengeluaran Usaha',
        TxKind.kirimUtama => 'Tutup Siklus Kas',
      };

  String? _validate(AppStore s) {
    final j = _int(_jumlah);
    switch (widget.kind) {
      case TxKind.cetak:
        return j <= 0 ? 'Isi jumlah bata yang dicetak' : null;
      case TxKind.pindah:
        final stok = _tempat == 'kulon' ? s.mentahKulon : s.mentahEtan;
        if (j <= 0) return 'Isi jumlah bata';
        if (j > stok) return 'Stok mentah ${areaLabel(_tempat)} hanya ${fmt(stok)} bata';
        return null;
      case TxKind.susun:
        if (j <= 0) return 'Isi jumlah bata';
        if (j > s.batu) return 'Stok di tungku hanya ${fmt(s.batu)} bata';
        return null;
      case TxKind.kirim:
        if (_tujuan.text.trim().isEmpty) return 'Isi tujuan pengiriman';
        if (j <= 0) return 'Isi jumlah bata';
        if (j > s.siapJual) return 'Stok siap jual hanya ${fmt(s.siapJual)} bata';
        return null;
      case TxKind.pengeluaran:
        return _int(_nominal) <= 0 ? 'Isi nominal pengeluaran' : null;
      case TxKind.selesaiBakar:
      case TxKind.mulaiBakar:
      case TxKind.kirimUtama:
        return null;
    }
  }

  List<List<String>> _rows(AppStore s) {
    final j = _int(_jumlah);
    final harga = _int(_harga);
    switch (widget.kind) {
      case TxKind.cetak:
        return [
          ['Jenis', 'Cetak bata mentah'],
          ['Area', areaLabel(_tempat)],
          ['Jumlah', '${fmt(j)} bata'],
        ];
      case TxKind.pindah:
        return [
          ['Dari', 'Mentah ${areaLabel(_tempat)}'],
          ['Ke', 'Tungku bakar'],
          ['Jumlah', '${fmt(j)} bata'],
        ];
      case TxKind.mulaiBakar:
        return [
          ['Sesi', 'Sesi ke-${s.sesiCount + 1}'],
          ['Batu di tungku', '${fmt(s.batu)} bata'],
          ['Estimasi biaya', rp(toNum(hitungBiayaBakar(s.batu)['total']))],
        ];
      case TxKind.selesaiBakar:
        final a = s.sesiAktif;
        final n = a == null ? 0 : toNum(a['nominal']);
        return [
          ['Sesi', '${a == null ? '-' : a['sesi']}'],
          ['Batu dibakar', '${fmt(n)} bata'],
          ['Merang', '${_int(_karung)} karung × ${rp(_int(_hargaMerang))}'],
        ];
      case TxKind.susun:
        return [
          ['Dari', 'Tungku bakar'],
          ['Ke', 'Gudang siap jual'],
          ['Jumlah', '${fmt(j)} bata'],
        ];
      case TxKind.kirim:
        return [
          ['Tujuan', _tujuan.text.trim()],
          ['Dari', 'Stok siap jual'],
          ['Jumlah', '${fmt(j)} bata'],
          ['Harga / bata', harga > 0 ? rp(harga) : 'Tanpa harga'],
        ];
      case TxKind.pengeluaran:
        return [
          ['Kategori', _kat],
          ['Catatan', _ket.text.trim().isEmpty ? '-' : _ket.text.trim()],
        ];
      case TxKind.kirimUtama:
        return [
          ['Total utama', rp(s.totalUtama)],
          ['Siklus berjalan', rp(s.siklus)],
        ];
    }
  }

  List<String> _total(AppStore s) {
    final j = _int(_jumlah);
    switch (widget.kind) {
      case TxKind.cetak:
      case TxKind.pindah:
      case TxKind.susun:
        return ['Total', '${fmt(j)} bata'];
      case TxKind.mulaiBakar:
        return ['Batu dibakar', '${fmt(s.batu)} bata'];
      case TxKind.selesaiBakar:
        final a = s.sesiAktif;
        final n = a == null ? 0 : toNum(a['nominal']);
        final t = toNum(hitungBiayaBakar(n, _int(_karung), _int(_hargaMerang))['total']);
        return ['Total biaya', rp(t)];
      case TxKind.kirim:
        final h = _int(_harga);
        return h > 0 ? ['Total', rp(j * h)] : ['Total', '${fmt(j)} bata'];
      case TxKind.pengeluaran:
        return ['Total', rp(_int(_nominal))];
      case TxKind.kirimUtama:
        final baru = s.totalUtama + s.siklus;
        return ['Utama baru', rp(baru < 0 ? 0 : baru)];
    }
  }

  void _next(AppStore s) {
    final e = _validate(s);
    setState(() {
      _err = e;
      if (e == null) _step = 1;
    });
  }

  void _submit(AppStore s) {
    final j = _int(_jumlah);
    final ket = _ket.text.trim();
    String? err;
    String msg;
    switch (widget.kind) {
      case TxKind.cetak:
        err = s.cetakBata(tempat: _tempat, jumlah: j, ket: ket);
        msg = '${fmt(j)} bata mentah area ${areaLabel(_tempat)} sudah dicatat.';
      case TxKind.pindah:
        err = s.pindahKeTungku(tempat: _tempat, jumlah: j, ket: ket);
        msg = '${fmt(j)} bata dipindahkan dari mentah ${areaLabel(_tempat)} ke tungku.';
      case TxKind.mulaiBakar:
        err = s.mulaiBakar();
        msg = 'Sesi bakar dimulai dengan ${fmt(s.batu)} bata di tungku.';
      case TxKind.selesaiBakar:
        err = s.selesaiBakar(karung: _int(_karung), hargaMerang: _int(_hargaMerang));
        msg = 'Sesi bakar ditandai selesai. Bata siap disusun ke gudang.';
      case TxKind.susun:
        err = s.susunSiapJual(jumlah: j, ket: ket);
        msg = '${fmt(j)} bata sudah disusun ke stok siap jual.';
      case TxKind.kirim:
        err = s.kirimBata(tujuan: _tujuan.text, jumlah: j, harga: _int(_harga), ket: ket);
        msg = 'Pengiriman ${fmt(j)} bata ke ${_tujuan.text.trim()} sudah dicatat.';
      case TxKind.pengeluaran:
        err = s.catatPengeluaran(kategori: _kat, nominal: _int(_nominal), ket: ket);
        msg = 'Pengeluaran $_kat sebesar ${rp(_int(_nominal))} sudah dicatat.';
      case TxKind.kirimUtama:
        err = s.kirimKeUtama();
        msg = 'Siklus kas sudah dikirim ke total utama.';
    }
    if (err != null) {
      setState(() {
        _err = err;
        if (_hasFields) _step = 0;
      });
      return;
    }
    Navigator.of(context).pop(msg);
  }

  // ───────── UI helpers ─────────
  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.ink2)),
      );

  Widget _tf(String label, TextEditingController c, {String hint = '', bool number = false, String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          TextField(
            controller: c,
            keyboardType: number ? TextInputType.number : TextInputType.text,
            inputFormatters: number
                ? <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                    ThousandsFormatter(),
                  ]
                : null,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: C.ink),
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffix,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chips(List<String> opts, String cur, ValueChanged<String> pick, String Function(String) text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final o in opts)
            GestureDetector(
              onTap: () => setState(() => pick(o)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: o == cur ? C.ink : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  text(o),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: o == cur ? Colors.white : C.ink2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _hint(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t, style: const TextStyle(fontSize: 12.5, color: C.ink3)),
      );

  Widget _input(AppStore s) {
    final kids = <Widget>[];
    switch (widget.kind) {
      case TxKind.cetak:
        kids.addAll([
          _label('Area'),
          _chips(['kulon', 'etan'], _tempat, (v) => _tempat = v, areaLabel),
          _tf('Jumlah bata', _jumlah, number: true, hint: '0', suffix: 'bata'),
          _tf('Keterangan (opsional)', _ket),
        ]);
      case TxKind.pindah:
        final stok = _tempat == 'kulon' ? s.mentahKulon : s.mentahEtan;
        kids.addAll([
          _label('Ambil dari'),
          _chips(['kulon', 'etan'], _tempat, (v) => _tempat = v, areaLabel),
          _hint('Tersedia ${fmt(stok)} bata di mentah ${areaLabel(_tempat)}'),
          _tf('Jumlah bata', _jumlah, number: true, hint: '0', suffix: 'bata'),
          _tf('Keterangan (opsional)', _ket),
        ]);
      case TxKind.susun:
        kids.addAll([
          _hint('Tersedia ${fmt(s.batu)} bata di tungku'),
          _tf('Jumlah bata', _jumlah, number: true, hint: '0', suffix: 'bata'),
          _tf('Keterangan (opsional)', _ket),
        ]);
      case TxKind.kirim:
        kids.addAll([
          _hint('Tersedia ${fmt(s.siapJual)} bata siap jual'),
          _tf('Tujuan', _tujuan, hint: 'Nama pembeli / lokasi'),
          _tf('Jumlah bata', _jumlah, number: true, hint: '0', suffix: 'bata'),
          _tf('Harga per bata (opsional)', _harga, number: true, hint: '0', suffix: 'Rp'),
          _tf('Keterangan (opsional)', _ket),
        ]);
      case TxKind.pengeluaran:
        kids.addAll([
          _label('Kategori'),
          _chips(['Solar', 'Kayu Bakar', 'Gaji', 'Lainnya'], _kat, (v) => _kat = v, (v) => v),
          _tf('Nominal', _nominal, number: true, hint: '0', suffix: 'Rp'),
          _tf('Catatan (opsional)', _ket),
        ]);
      case TxKind.selesaiBakar:
        kids.addAll([
          _hint('Isi bila ada biaya merang. Boleh dikosongkan.'),
          _tf('Jumlah karung merang', _karung, number: true, hint: '0', suffix: 'karung'),
          _tf('Harga per karung', _hargaMerang, number: true, hint: '0', suffix: 'Rp'),
        ]);
      case TxKind.mulaiBakar:
      case TxKind.kirimUtama:
        break;
    }
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: kids),
        ),
      ],
    );
  }

  Widget _confirm(AppStore s) {
    final rows = _rows(s);
    final tot = _total(s);
    return Column(
      key: const ValueKey(1),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Icon(_icon, color: C.blue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(_headline, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: C.ink)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(22)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 2, 4, 8),
                child: Text('Ringkasan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.ink)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rows[i][0], style: const TextStyle(fontSize: 13, color: C.ink3)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                rows[i][1],
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: C.ink),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i != rows.length - 1) const Divider(height: 1, color: Color(0xFFF0F1F4)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Text(tot[0], style: const TextStyle(fontSize: 13, color: C.ink3)),
                    const Spacer(),
                    Text(tot[1], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.ink)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final maxH = MediaQuery.sizeOf(context).height * 0.92;
    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.paddingOf(context).bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  _step == 0 ? _title : 'Konfirmasi $_title',
                  style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: C.ink),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.line)),
                      child: const Icon(Icons.close_rounded, size: 20, color: C.ink),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _step == 0 ? _input(s) : _confirm(s),
              ),
            ),
          ),
          if (_err != null) ...[
            const SizedBox(height: 10),
            Text(_err!, textAlign: TextAlign.center, style: const TextStyle(color: C.red, fontSize: 13)),
          ],
          const SizedBox(height: 14),
          _BigBtn(
            label: _step == 0 ? 'Lanjut' : 'Konfirmasi',
            onTap: () => _step == 0 ? _next(s) : _submit(s),
          ),
          if (_step == 1 && _hasFields)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: () => setState(() => _step = 0),
                child: const Text('Ubah data', style: TextStyle(color: C.ink2, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}