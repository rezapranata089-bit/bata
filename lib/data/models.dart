import 'package:cloud_firestore/cloud_firestore.dart';

num toNum(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}

class Aktivitas {
  Aktivitas({
    required this.id,
    required this.col,
    required this.tipe,
    required this.arus,
    required this.keterangan,
    required this.tanggal,
    required this.tempat,
    required this.tujuan,
    required this.nominal,
    required this.harga,
    required this.waktu,
    required this.siklusAktif,
  });

  final String id, col, tipe, arus, keterangan, tanggal, tempat, tujuan;
  final num nominal, harga;
  final DateTime waktu;
  final bool siklusAktif;

  bool get isMasuk => arus == 'masuk';
  bool get isKeluar => arus == 'keluar';
  bool get isUang => col == 'aktivitas_dompeng';

  factory Aktivitas.fromDoc(String col, QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    final ts = m['createdAt'];
    return Aktivitas(
      id: d.id,
      col: col,
      tipe: (m['tipe'] ?? '').toString(),
      arus: (m['arus'] ?? '').toString(),
      keterangan: (m['keterangan'] ?? '').toString(),
      tanggal: (m['tanggal'] ?? '').toString(),
      tempat: (m['tempat'] ?? '').toString(),
      tujuan: (m['tujuan'] ?? '').toString(),
      nominal: toNum(m['nominal']),
      harga: toNum(m['harga']),
      waktu: ts is Timestamp ? ts.toDate() : DateTime.fromMillisecondsSinceEpoch(0),
      siklusAktif: m['isSiklusAktif'] != false,
    );
  }
}