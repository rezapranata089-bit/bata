import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../ui/theme.dart';
import 'models.dart';

/// Sama persis dengan hitungBiayaBakar() di stok-tab.js
Map<String, dynamic> hitungBiayaBakar(num jumlah, [num karung = 0, num hargaMerang = 0]) {
  final dompeng = (jumlah / 1000) * 60000;
  final cetak = (jumlah / 1000) * 80000;
  final tanahMobil = (jumlah / 5000).ceil();
  final tanah = tanahMobil * 270000;
  final merang = karung * hargaMerang;
  return {
    'dompeng': dompeng,
    'cetak': cetak,
    'tanahMobil': tanahMobil,
    'tanah': tanah,
    'karungMerang': karung,
    'hargaMerang': hargaMerang,
    'merang': merang,
    'total': dompeng + cetak + tanah + merang,
  };
}

class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({super.key, required AppStore store, required super.child}) : super(notifier: store);

  static AppStore of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
  static AppStore read(BuildContext c) => c.getInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}

class AppStore extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription<dynamic>> _subs = [];

  int tab = 0;
  bool hideSaldo = false;
  bool ready = false;
  String? error;

  // app_state/*
  num totalUtama = 0, batu = 0, siapJual = 0, mentahKulon = 0, mentahEtan = 0;
  Map<String, dynamic> bon = {};
  int sesiCount = 0;
  bool burning = false;
  List<Map<String, dynamic>> sesi = [];

  // aktivitas_*
  List<Aktivitas> dompeng = [], mentah = [], beranda = [], siapjual = [];
  List<Aktivitas>? _semua;

  void setTab(int i) {
    if (tab == i) return;
    tab = i;
    notifyListeners();
  }

  void toggleSaldo() {
    hideSaldo = !hideSaldo;
    notifyListeners();
  }

  // ───────────── LISTENERS ─────────────
  void start() {
    _state('dompeng', (d) => totalUtama = toNum(d['total_utama']));
    _state('batu', (d) => batu = toNum(d['total']));
    _state('siapjual', (d) => siapJual = toNum(d['total']));
    _state('mentah', (d) {
      mentahKulon = toNum(d['kulon']);
      mentahEtan = toNum(d['etan']);
    });
    _state('bon', (d) => bon = d);
    _state('bakar', (d) {
      sesiCount = toNum(d['sesiCount']).toInt();
      burning = d['status'] == 'burning';
      final raw = (d['riwayatSesi'] as List<dynamic>?) ?? const [];
      sesi = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    });

    // dompeng dibaca penuh (perlu untuk hitung siklus, sama seperti web)
    _col('aktivitas_dompeng', null, (l) => dompeng = l);
    _col('aktivitas_mentah', 100, (l) => mentah = l);
    _col('aktivitas_beranda', 100, (l) => beranda = l);
    _col('aktivitas_siapjual', 100, (l) => siapjual = l);
  }

  void _state(String id, void Function(Map<String, dynamic>) apply) {
    _subs.add(_db.collection('app_state').doc(id).snapshots().listen((s) {
      apply(s.data() ?? <String, dynamic>{});
      _changed();
    }, onError: _onErr));
  }

  void _col(String col, int? limit, void Function(List<Aktivitas>) apply) {
    Query<Map<String, dynamic>> q = _db.collection(col).orderBy('createdAt', descending: true);
    if (limit != null) q = q.limit(limit);
    _subs.add(q.snapshots().listen((s) {
      apply(s.docs.map((d) => Aktivitas.fromDoc(col, d)).toList());
      _changed();
    }, onError: _onErr));
  }

  void _onErr(Object e) {
    error = e.toString();
    notifyListeners();
  }

  void _changed() {
    _semua = null;
    ready = true;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  // ───────────── TURUNAN ─────────────
  Map<String, dynamic>? get sesiAktif => burning && sesi.isNotEmpty ? sesi.last : null;

  /// Siklus = semua transaksi dompeng dengan isSiklusAktif != false
  num get siklus {
    num t = 0;
    for (final a in dompeng) {
      if (!a.siklusAktif) continue;
      if (a.isMasuk) {
        t += a.nominal;
      } else if (a.isKeluar) {
        t -= a.nominal;
      }
    }
    return t;
  }

  num get kas => totalUtama + siklus;

  bool _uang(Aktivitas a) => a.tipe != 'Kirim ke Total Utama' && a.tipe != 'Penyesuaian Saldo';

  String get _bulan => tanggalHariIni().substring(0, 7);

  num get pemasukanBulan => dompeng
      .where((a) => a.isMasuk && _uang(a) && a.tanggal.startsWith(_bulan))
      .fold<num>(0, (t, a) => t + a.nominal);

  num get pengeluaranBulan => dompeng
      .where((a) => a.isKeluar && _uang(a) && a.tanggal.startsWith(_bulan))
      .fold<num>(0, (t, a) => t + a.nominal);

  /// 0 = semua, 1 = kas, 2 = stok
  List<Aktivitas> feed(int f) {
    if (f == 1) return dompeng.take(150).toList();
    _semua ??= _gabung();
    if (f == 2) return _semua!.where((a) => !a.isUang).toList();
    return _semua!;
  }

  List<Aktivitas> _gabung() {
    // sisi kembar dari satu transaksi disembunyikan supaya tidak dobel
    const sembunyi = {'Bakar Bata', 'Batu Siap Jual', 'Penjualan Bata'};
    final l = <Aktivitas>[...dompeng.take(120), ...mentah, ...beranda, ...siapjual]
        .where((a) => !sembunyi.contains(a.tipe))
        .toList();
    l.sort((a, b) => b.waktu.compareTo(a.waktu));
    return l.take(200).toList();
  }

  // ───────────── HELPER TULIS ─────────────
  DocumentReference<Map<String, dynamic>> _st(String id) => _db.collection('app_state').doc(id);
  DocumentReference<Map<String, dynamic>> _ref(String col, String id) => _db.collection(col).doc(id);
  String _id(String p) => '${p}_${DateTime.now().microsecondsSinceEpoch}';

  /// Tidak di-await supaya jalan offline-first seperti versi web
  void _go(WriteBatch b) {
    unawaited(b.commit().catchError((Object e) {
      error = e.toString();
      notifyListeners();
    }));
  }

  Map<String, dynamic> _akt({
    required String tipe,
    required String arus,
    required num nominal,
    String ket = '',
    Map<String, dynamic> extra = const {},
  }) {
    return {
      'tipe': tipe,
      'arus': arus,
      'nominal': nominal,
      'keterangan': ket,
      'tanggal': tanggalHariIni(),
      'createdAt': Timestamp.now(),
      ...extra,
    };
  }

  // ───────────── WORKFLOW (return null = sukses, selain itu pesan error) ─────────────

  /// 1. Cetak bata -> stok mentah (kulon / etan)
  String? cetakBata({required String tempat, required int jumlah, String ket = ''}) {
    if (jumlah <= 0) return 'Jumlah bata harus lebih dari 0';
    final b = _db.batch();
    b.set(_st('mentah'), {tempat: FieldValue.increment(jumlah)}, SetOptions(merge: true));
    b.set(
      _ref('aktivitas_mentah', _id('cb')),
      _akt(tipe: 'Cetak Bata', arus: 'masuk', nominal: jumlah, ket: ket, extra: {'tempat': tempat}),
    );
    _go(b);
    return null;
  }

  /// 2. Mentah -> tungku (Total Stok Batu)
  String? pindahKeTungku({required String tempat, required int jumlah, String ket = ''}) {
    final stok = tempat == 'kulon' ? mentahKulon : mentahEtan;
    if (jumlah <= 0) return 'Jumlah bata harus lebih dari 0';
    if (jumlah > stok) return 'Stok mentah ${areaLabel(tempat)} hanya ${fmt(stok)} bata';
    final id = _id('bkr');
    final b = _db.batch();
    b.set(_st('mentah'), {tempat: FieldValue.increment(-jumlah)}, SetOptions(merge: true));
    b.set(_st('batu'), {'total': FieldValue.increment(jumlah)}, SetOptions(merge: true));
    b.set(
      _ref('aktivitas_mentah', id),
      _akt(tipe: 'Bakar Bata', arus: 'keluar', nominal: jumlah, ket: ket, extra: {'tempat': tempat}),
    );
    b.set(
      _ref('aktivitas_beranda', id),
      _akt(
        tipe: 'Bata Mentah Masuk',
        arus: 'masuk',
        nominal: jumlah,
        ket: ket.isEmpty ? 'Dari mentah ${areaLabel(tempat)}' : ket,
      ),
    );
    _go(b);
    return null;
  }

  /// 3a. Mulai sesi bakar
  String? mulaiBakar() {
    if (burning) return 'Masih ada sesi bakar yang berjalan';
    if (batu <= 0) return 'Stok di tungku masih kosong';
    final n = sesiCount + 1;
    final id = _id('bkr');
    final t = tanggalHariIni();
    final Map<String, dynamic> item = {
      'id': id,
      'sesi': n,
      'nominal': batu,
      'tanggal': t,
      'tanggalMulai': t,
      'biaya': hitungBiayaBakar(batu),
    };
    final b = _db.batch();
    b.set(
      _st('bakar'),
      {
        'sesiCount': n,
        'status': 'burning',
        'riwayatSesi': [...sesi, item],
      },
      SetOptions(merge: true),
    );
    b.set(
      _ref('aktivitas_beranda', id),
      _akt(tipe: 'Mulai Bakar', arus: 'netral', nominal: batu, ket: 'Sesi $n'),
    );
    _go(b);
    return null;
  }

  /// 3b. Selesai bakar (biaya merang opsional)
  String? selesaiBakar({int karung = 0, int hargaMerang = 0}) {
    if (sesiAktif == null) return 'Tidak ada sesi bakar yang berjalan';
    final list = sesi.map((e) => Map<String, dynamic>.from(e)).toList();
    final last = list.last;
    final nominal = toNum(last['nominal']);
    final sn = last['sesi'];
    last['selesai'] = true;
    last['tanggalSelesai'] = tanggalHariIni();
    last['biaya'] = hitungBiayaBakar(nominal, karung, hargaMerang);
    final b = _db.batch();
    b.set(_st('bakar'), {'status': 'idle', 'riwayatSesi': list}, SetOptions(merge: true));
    b.set(
      _ref('aktivitas_beranda', _id('bkr')),
      _akt(tipe: 'Batu Selesai Dibakar', arus: 'masuk', nominal: nominal, ket: 'Sesi $sn'),
    );
    _go(b);
    return null;
  }

  /// 4. Tungku -> gudang siap jual
  String? susunSiapJual({required int jumlah, String ket = ''}) {
    if (jumlah <= 0) return 'Jumlah bata harus lebih dari 0';
    if (jumlah > batu) return 'Stok di tungku hanya ${fmt(batu)} bata';
    final id = _id('bkr');
    final b = _db.batch();
    b.set(_st('batu'), {'total': FieldValue.increment(-jumlah)}, SetOptions(merge: true));
    b.set(_st('siapjual'), {'total': FieldValue.increment(jumlah)}, SetOptions(merge: true));
    b.set(
      _ref('aktivitas_beranda', id),
      _akt(
        tipe: 'Batu Telah Disusun',
        arus: 'keluar',
        nominal: jumlah,
        ket: ket.isEmpty ? 'Disusun ke gudang Siap Jual' : ket,
      ),
    );
    b.set(
      _ref('aktivitas_siapjual', id),
      _akt(
        tipe: 'Batu Siap Jual',
        arus: 'masuk',
        nominal: jumlah,
        ket: ket.isEmpty ? 'Masuk dari pembakaran' : ket,
      ),
    );
    _go(b);
    return null;
  }

  /// 5. Kirim / jual bata -> pendapatan masuk siklus dompeng
  String? kirimBata({required String tujuan, required int jumlah, required int harga, String ket = ''}) {
    if (tujuan.trim().isEmpty) return 'Isi tujuan pengiriman';
    if (jumlah <= 0) return 'Jumlah bata harus lebih dari 0';
    if (jumlah > siapJual) return 'Stok siap jual hanya ${fmt(siapJual)} bata';
    final detail = ket.isEmpty ? '$tujuan • ${fmt(jumlah)} bata' : ket;
    final b = _db.batch();
    b.set(_st('siapjual'), {'total': FieldValue.increment(-jumlah)}, SetOptions(merge: true));
    b.set(
      _ref('aktivitas_siapjual', _id('krm')),
      _akt(
        tipe: 'Pengiriman Bata',
        arus: 'keluar',
        nominal: jumlah,
        ket: detail,
        extra: {'harga': harga, 'tujuan': tujuan.trim()},
      ),
    );
    if (harga > 0) {
      b.set(
        _ref('aktivitas_dompeng', _id('jual')),
        _akt(
          tipe: 'Penjualan Bata',
          arus: 'masuk',
          nominal: jumlah * harga,
          ket: detail,
          extra: {'isSiklusAktif': true},
        ),
      );
    }
    _go(b);
    return null;
  }

  /// Catat pengeluaran (tidak masuk hitungan siklus)
  String? catatPengeluaran({required String kategori, required int nominal, String ket = ''}) {
    if (nominal <= 0) return 'Nominal harus lebih dari 0';
    final b = _db.batch();
    b.set(
      _ref('aktivitas_dompeng', _id('out')),
      _akt(tipe: kategori, arus: 'keluar', nominal: nominal, ket: ket, extra: {'isSiklusAktif': false}),
    );
    _go(b);
    return null;
  }

  /// Kirim ke Total Utama: siklus ditutup dan dijumlahkan ke total_utama
  String? kirimKeUtama() {
    final aktif = dompeng.where((a) => a.siklusAktif).toList();
    if (aktif.isEmpty) return 'Belum ada transaksi di siklus ini';
    final sk = siklus;
    final num baru = totalUtama + sk < 0 ? 0 : totalUtama + sk;
    final jumlahMasuk = aktif.where((a) => a.isMasuk).length;
    var b = _db.batch();
    var ops = 0;
    for (final a in aktif) {
      b.update(_ref('aktivitas_dompeng', a.id), {'isSiklusAktif': false});
      ops++;
      if (ops >= 400) {
        _go(b);
        b = _db.batch();
        ops = 0;
      }
    }
    b.set(_st('dompeng'), {'total_utama': baru}, SetOptions(merge: true));
    b.set(
      _ref('aktivitas_dompeng', _id('krm')),
      _akt(
        tipe: 'Kirim ke Total Utama',
        arus: sk >= 0 ? 'masuk' : 'keluar',
        nominal: sk.abs(),
        ket: '$jumlahMasuk dompengan dikirim',
        extra: {'isPermanent': true, 'isSiklusAktif': false},
      ),
    );
    _go(b);
    return null;
  }
}