import 'package:flutter/material.dart';

class C {
  static const blue = Color(0xFF2F55D4);
  static const ink = Color(0xFF0D1220);
  static const ink2 = Color(0xFF6B7280);
  static const ink3 = Color(0xFF9AA1AD);
  static const bg = Color(0xFFF4F6FA);
  static const field = Color(0xFFF4F5F7);
  static const line = Color(0xFFE6E8ED);
  static const green = Color(0xFF12A150);
  static const red = Color(0xFFE5484D);
  static const amber = Color(0xFFF59E0B);
  static const violet = Color(0xFF7C4DDB);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.blue),
    scaffoldBackgroundColor: C.bg,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}

/// 12000 -> "12.000"
String fmt(num n) {
  final neg = n < 0;
  final s = n.abs().round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return neg ? '-$b' : b.toString();
}

String rp(num n) => n < 0 ? '-Rp ${fmt(n.abs())}' : 'Rp ${fmt(n)}';

String tanggalHariIni([DateTime? d]) {
  final n = d ?? DateTime.now();
  final m = n.month.toString().padLeft(2, '0');
  final h = n.day.toString().padLeft(2, '0');
  return '${n.year}-$m-$h';
}

const _bln = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

String tglCantik(String ymd) {
  final p = ymd.split('-');
  if (p.length != 3) return ymd;
  final m = int.tryParse(p[1]) ?? 1;
  final d = int.tryParse(p[2]) ?? 0;
  return '$d ${_bln[(m - 1).clamp(0, 11).toInt()]}';
}

String areaLabel(String t) => t == 'kulon' ? 'Kulon' : 'Etan';