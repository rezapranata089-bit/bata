import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/store.dart';
import 'ui/shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Config publik yang sama dengan index.html (Firestore project usaha-batu)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyB4cwBDTbZurNctceQNa9abXp90IQ5LWN0',
      appId: '1:508756450060:web:776ac8311c8e031106c729',
      messagingSenderId: '508756450060',
      projectId: 'usaha-batu',
      storageBucket: 'usaha-batu.firebasestorage.app',
    ),
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  unawaited(OCLiquidGlassGroup.precacheShader());

  final prefs = await SharedPreferences.getInstance();
  final store = AppStore(prefs)..start();
  runApp(BataApp(store: store));
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
          theme: buildTheme(store.pal.accent),
          home: const Shell(),
        ),
      ),
    );
  }
}
