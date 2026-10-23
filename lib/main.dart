import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/store.dart';
import 'ui/shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await LiquidGlassWidgets.initialize();

  // Di rilis, error saat build biasanya tampil layar kosong. Tampilkan teksnya.
  ErrorWidget.builder = (details) => Material(
        color: const Color(0xFF200000),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              details.exceptionAsString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      );

  // runApp langsung, inisialisasi berat dikerjakan di Boot sambil menampilkan status
  runApp(const Boot());
}

/// Menjalankan inisialisasi bertahap. Kalau macet atau error, langkah dan
/// pesannya tampil di layar (tanpa perlu logcat).
class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> {
  AppStore? _store;
  String _step = 'Memulai';
  String? _err;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _set(String t) async {
    if (!mounted) return;
    setState(() => _step = t);
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }

  Future<void> _init() async {
    if (mounted) setState(() => _err = null);
    try {
      await _set('1/4 Membaca pengaturan');
      final prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 15));

      await _set('2/4 Menyambung Firebase');
      if (Firebase.apps.isEmpty) {
        // Config publik yang sama dengan index.html (Firestore project usaha-batu)
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyB4cwBDTbZurNctceQNa9abXp90IQ5LWN0',
            appId: '1:508756450060:web:776ac8311c8e031106c729',
            messagingSenderId: '508756450060',
            projectId: 'usaha-batu',
            storageBucket: 'usaha-batu.firebasestorage.app',
          ),
        ).timeout(const Duration(seconds: 15));
      }

      await _set('3/4 Menyiapkan database');
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      await _set('4/4 Memuat data');
      final store = AppStore(prefs)..start();
      if (!mounted) return;
      setState(() => _store = store);
    } catch (e, st) {
      if (mounted) setState(() => _err = 'Gagal di langkah: $_step\n\n$e\n\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _store;
    if (s != null) {
      return LiquidGlassWidgets.wrap(
        brightnessResolver: Theme.maybeBrightnessOf,
        child: BataApp(store: s),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0B0E17),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _err == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aplikasi gagal dimulai',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            _err!,
                            style: const TextStyle(color: Color(0xFFFF8A8A), fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(onPressed: _init, child: const Text('Coba lagi')),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class BataApp extends StatelessWidget {
  const BataApp({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      store: store,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => MaterialApp(
          title: 'Usaha Bata',
          debugShowCheckedModeBanner: false,
          themeMode: switch (store.themeMode) {
            1 => ThemeMode.light,
            2 => ThemeMode.dark,
            _ => ThemeMode.system,
          },
          theme: buildTheme(store.pal.accent, false),
          darkTheme: buildTheme(store.pal.accent, true),
          builder: (context, child) {
            C.dark = Theme.of(context).brightness == Brightness.dark;
            return child!;
          },
          home: const Shell(),
        ),
      ),
    );
  }
}
