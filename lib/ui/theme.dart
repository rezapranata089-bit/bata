import 'package:flutter/material.dart';

class C {
  /// diatur oleh MaterialApp.builder (lihat main.dart)
  static bool dark = false;

  static const blue = Color(0xFF2F55D4);
  static const green = Color(0xFF12A150);
  static const red = Color(0xFFE5484D);
  static const amber = Color(0xFFF59E0B);
  static const violet = Color(0xFF7C4DDB);

  static const bgL = Color(0xFFF4F6FA);
  static const bgD = Color(0xFF0B0E17);

  static Color get bg => dark ? bgD : bgL;
  static Color get card => dark ? const Color(0xFF151A27) : Colors.white;
  static Color get field => dark ? const Color(0xFF1D2333) : const Color(0xFFF4F5F7);
  static Color get line => dark ? const Color(0xFF2A3145) : const Color(0xFFE6E8ED);
  static Color get div => dark ? const Color(0xFF232A3C) : const Color(0xFFF0F1F4);
  static Color get ink => dark ? const Color(0xFFF1F4FA) : const Color(0xFF0D1220);

  /// warna kebalikan ink (teks di atas tombol ink)
  static Color get inv => dark ? const Color(0xFF0D1220) : Colors.white;
  static Color get ink2 => dark ? const Color(0xFFA3ABBA) : const Color(0xFF6B7280);
  static Color get ink3 => dark ? const Color(0xFF7B8496) : const Color(0xFF9AA1AD);
}

class Pal {
  const Pal(this.name, this.top, this.mid, this.soft, this.accent);

  final String name;
  final Color top, mid, soft, accent;
}

const palettes = [
  Pal('Biru', Color(0xFF2848C9), Color(0xFF3A63DE), Color(0xFF9DBBF5), Color(0xFF2F55D4)),
  Pal('Ungu', Color(0xFF5B3CC4), Color(0xFF7655D8), Color(0xFFC4B2F2), Color(0xFF7655D8)),
  Pal('Hijau', Color(0xFF12803F), Color(0xFF24A148), Color(0xFFA7E3BD), Color(0xFF12A150)),
  Pal('Rose', Color(0xFFC03A5A), Color(0xFFE05270), Color(0xFFF7BFCC), Color(0xFFE05270)),
  Pal('Oranye', Color(0xFFD9730A), Color(0xFFF59E0B), Color(0xFFFBD99A), Color(0xFFE08A00)),
  Pal('Teal', Color(0xFF0F766E), Color(0xFF14A89C), Color(0xFFA3E6DF), Color(0xFF0F9488)),
  Pal('Slate', Color(0xFF1F2A44), Color(0xFF334266), Color(0xFF9AA8C7), Color(0xFF334266)),
  Pal('Samudra', Color(0xFF0B5FA5), Color(0xFF2196F3), Color(0xFFA8D4F7), Color(0xFF1E88E5)),
];

/// Terjemahan sederhana: [id, en]
class L {
  static bool en = false;

  static String t(String k) {
    final v = _m[k];
    if (v == null) return k;
    return en ? v[1] : v[0];
  }

  static const _m = <String, List<String>>{
    'hi_morning': ['Selamat Pagi', 'Good Morning'],
    'hi_noon': ['Selamat Siang', 'Good Afternoon'],
    'hi_evening': ['Selamat Sore', 'Good Evening'],
    'hi_night': ['Selamat Malam', 'Good Night'],
    'total_cash': ['Total Kas', 'Total Cash'],
    'cycle': ['Siklus', 'Cycle'],
    'main': ['Utama', 'Main'],
    'act_print': ['Cetak', 'Print'],
    'act_kiln': ['Ke Tungku', 'To Kiln'],
    'act_send': ['Kirim', 'Send'],
    'act_cost': ['Biaya', 'Costs'],
    'sesi_title': ['Sesi Bakar', 'Burn Session'],
    'sesi_running': ['Sesi {n} sedang berjalan dengan {b} bata di tungku.', 'Session {n} is running with {b} bricks in the kiln.'],
    'sesi_ready': ['{b} bata sudah di tungku dan siap dibakar.', '{b} bricks are in the kiln, ready to burn.'],
    'sesi_empty': ['Tungku masih kosong. Pindahkan bata mentah untuk memulai sesi bakar.', 'The kiln is empty. Move raw bricks to start a session.'],
    'cta_finish': ['Selesai bakar', 'Finish burning'],
    'cta_start': ['Mulai bakar', 'Start burning'],
    'cta_move': ['Pindah ke tungku', 'Move to kiln'],
    'running': ['Berjalan', 'Running'],
    'latest': ['Aktivitas Terbaru', 'Recent Activity'],
    'see_all': ['Lihat semua', 'See all'],
    'sync_error': ['Sinkron bermasalah', 'Sync problem'],
    'nav_home': ['Beranda', 'Home'],
    'nav_stok': ['Stok', 'Stock'],
    'nav_act': ['Aktivitas', 'Activity'],
    'nav_profile': ['Profil', 'Profile'],
    'profile': ['Profil', 'Profile'],
    'activity_title': ['Aktivitas', 'Activity'],
    'activity_sub': ['Riwayat kas dan stok usaha bata', 'Cash and stock history'],
    'this_month': ['Bulan ini', 'This month'],
    'income': ['Pemasukan', 'Income'],
    'expense': ['Pengeluaran', 'Expenses'],
    'send_main': ['Kirim ke utama', 'Send to main'],
    'f_all': ['Semua', 'All'],
    'f_cash': ['Kas', 'Cash'],
    'f_stock': ['Stok', 'Stock'],
    'stok_title': ['Stok Bata', 'Brick Stock'],
    'raw': ['Mentah', 'Raw'],
    'kiln': ['Tungku', 'Kiln'],
    'ready': ['Siap Jual', 'Ready'],
    'status': ['Status', 'Status'],
    'active': ['Aktif', 'Active'],
    'none': ['Tidak ada', 'None'],
    'rest_brick': ['Sisa bata', 'Bricks left'],
    'rest_debt': ['Sisa hutang', 'Debt left'],
    'hide_balance': ['Sembunyikan saldo', 'Hide balance'],
    'sync': ['Sinkron', 'Sync'],
    'connected': ['Tersambung', 'Connected'],
    'connecting': ['Menghubungkan', 'Connecting'],
    'problem': ['Bermasalah', 'Problem'],
    'version': ['Versi', 'Version'],
    'settings': ['Pengaturan', 'Settings'],
    'theme_color': ['Warna tema', 'Theme color'],
    'language': ['Bahasa', 'Language'],
    'counter_anim': ['Animasi angka', 'Number animation'],
    'haptic': ['Getar saat ditekan', 'Haptic feedback'],
    'saved': ['Tersimpan', 'Saved'],
    'go_home': ['Ke Beranda', 'Go Home'],
    'role': ['Pemilik Usaha Bata', 'Brick Business Owner'],
    'business': ['Usaha', 'Business'],
    'about': ['Tentang', 'About'],
    'appearance': ['Tampilan', 'Appearance'],
    'appearance_sub': ['Mode layar dan warna tema', 'Screen mode and theme color'],
    'screen_mode': ['Mode layar', 'Screen mode'],
    'mode_system': ['Sistem', 'System'],
    'mode_light': ['Terang', 'Light'],
    'mode_dark': ['Gelap', 'Dark'],
    'language_sub': ['Pilih bahasa aplikasi', 'Choose the app language'],
    'anim_haptic': ['Animasi & Getar', 'Animation & Haptics'],
    'anim_sub': ['Efek angka dan getar', 'Number effects and haptics'],
    'counter_desc': ['Angka bergulir saat nilai berubah', 'Numbers roll when values change'],
    'haptic_desc': ['Getar halus saat menekan tombol', 'Light vibration on taps'],
    'privacy': ['Privasi', 'Privacy'],
    'privacy_sub': ['Atur tampilan data sensitif', 'Control sensitive data display'],
    'hide_desc': ['Saldo kas diblur di Beranda', 'Cash balance is blurred on Home'],
    'kasbon': ['Kasbon Pekerja', 'Worker Advance'],
    'kasbon_sub': ['Ringkasan kasbon pekerja', 'Worker advance summary'],
    'sync_about': ['Sinkronisasi & Tentang', 'Sync & About'],
    'sync_sub': ['Status koneksi dan info aplikasi', 'Connection status and app info'],
    'project': ['Project', 'Project'],
    'on': ['Aktif', 'On'],
    'off': ['Mati', 'Off'],
    'stok_total': ['Total {n} bata di semua tahap', 'Total {n} bricks across all stages'],
    'h_raw': ['Riwayat Mentah', 'Raw History'],
    'h_sessions': ['Sesi Bakar', 'Burn Sessions'],
    'h_kiln': ['Aktivitas Tungku', 'Kiln Activity'],
    'h_ready': ['Riwayat Siap Jual', 'Ready History'],
    'no_session': ['Belum ada sesi bakar', 'No burn sessions yet'],
    'no_activity': ['Belum ada aktivitas', 'No activity yet'],
  };
}

ThemeData buildTheme(Color seed, bool dark) {
  final b = dark ? Brightness.dark : Brightness.light;
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    fontFamily: 'Satoshi',
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: b),
    scaffoldBackgroundColor: dark ? C.bgD : C.bgL,
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