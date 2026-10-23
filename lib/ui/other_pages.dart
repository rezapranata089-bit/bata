import 'package:flutter/cupertino.dart'
    show CupertinoActionSheet, CupertinoActionSheetAction, CupertinoIcons, showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:image_picker/image_picker.dart';

import '../data/models.dart';
import '../data/store.dart';
import 'extras.dart';
import 'icons.dart';
import 'settings_pages.dart';
import 'sheets.dart';
import 'theme.dart';
import 'widgets.dart';

// ───────────────────────── AKTIVITAS ─────────────────────────
class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  int _f = 0;

  Widget _flow(String label, num v, Color c, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: c.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: c),
              ),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12.5, color: C.ink2)),
            ],
          ),
          const SizedBox(height: 10),
          Counter(
            value: v,
            symbol: 'Rp ',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.ink),
          ),
        ],
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
        const Positioned(top: 0, left: 0, right: 0, child: TopGradient(height: 360)),
        ListView(
          padding: EdgeInsets.fromLTRB(20, top + 18, 20, 130),
          children: [
            Text(L.t('activity_title'), style: pageTitle),
            const SizedBox(height: 4),
            Text(L.t('activity_sub'), style: pageSub),
            const SizedBox(height: 20),
            WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L.t('this_month'), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: C.ink3)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _flow(L.t('income'), s.pemasukanBulan, C.green, Ic.incoming),
                      SizedBox(height: 40, child: VerticalDivider(width: 24, color: C.line)),
                      _flow(L.t('expense'), s.pengeluaranBulan, C.red, Ic.outgoing),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ActBtn(label: L.t('expense'), icon: Ic.wallet, onTap: () => openTx(context, TxKind.pengeluaran)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActBtn(
                    label: L.t('send_main'),
                    icon: Ic.send,
                    dark: true,
                    onTap: () => openTx(context, TxKind.kirimUtama),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilterChips(
              items: [L.t('f_all'), L.t('f_cash'), L.t('f_stock')],
              index: _f,
              onChanged: (i) => setState(() => _f = i),
            ),
            const SizedBox(height: 14),
            if (feed.isEmpty) FeedCard(items: feed, loading: !s.ready),
            for (final e in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Text(
                  _label(e.key),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.ink2),
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

// ───────────────────────── PROFIL (gaya iOS) ─────────────────────────
Color get _pPage => C.dark ? C.bg : Colors.white;
Color get _pBox => C.dark ? C.card : C.field;
Color get _pChip => C.dark ? C.field : Colors.white;

class _PSection extends StatelessWidget {
  const _PSection(this.title, this.children);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.ink)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(color: _pBox, borderRadius: BorderRadius.circular(22)),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) Divider(height: 1, indent: 50, color: C.line),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PRow extends StatelessWidget {
  const _PRow({required this.icon, required this.title, required this.value, required this.onTap});

  final IconData icon;
  final String title, value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: _pChip, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, size: 20, color: C.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: C.ink)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 12, color: C.ink3)),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_forward, size: 16, color: C.ink3),
          ],
        ),
      ),
    );
  }
}

class _PMini extends StatelessWidget {
  const _PMini({required this.icon, required this.title, required this.sub, required this.onTap});

  final IconData icon;
  final String title, sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: _pBox, borderRadius: BorderRadius.circular(22)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: _pChip, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, size: 18, color: C.ink),
                  ),
                  const Spacer(),
                  Icon(Ic.outgoing, size: 16, color: C.ink3),
                ],
              ),
              const SizedBox(height: 14),
              Text(title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: C.ink)),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(fontSize: 12, color: C.ink3)),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  String _onOff(bool v) => v ? L.t('on') : L.t('off');

  Future<void> _pick(AppStore s, ImageSource src) async {
    try {
      final f = await ImagePicker().pickImage(source: src, maxWidth: 600, maxHeight: 600, imageQuality: 82);
      if (f != null) s.setAvatar(await f.readAsBytes());
    } catch (_) {}
  }

  void _avatarMenu(BuildContext context, AppStore s) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (c) => CupertinoActionSheet(
        title: Text(L.t('profile_photo')),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(c);
              _pick(s, ImageSource.gallery);
            },
            child: Text(L.t('from_gallery')),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(c);
              _pick(s, ImageSource.camera);
            },
            child: Text(L.t('take_photo')),
          ),
          if (s.avatar != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(c);
                s.setAvatar(null);
              },
              child: Text(L.t('remove_photo')),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.pop(c), child: Text(L.t('cancel'))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final acc = s.pal.accent;
    final aktif = s.bon['kasbonActive'] == true;
    final modes = [L.t('mode_system'), L.t('mode_light'), L.t('mode_dark')];
    final sync = s.error != null ? L.t('problem') : (s.ready ? L.t('connected') : L.t('connecting'));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (C.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: ColoredBox(
        color: _pPage,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, top + 16, 20, 130),
          children: [
            Center(
              child: Text(L.t('profile'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: C.ink)),
            ),
            const SizedBox(height: 22),
            Center(
              child: GestureDetector(
                onTap: () => _avatarMenu(context, s),
                child: SizedBox(
                  width: 104,
                  height: 104,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Avatar(size: 104, border: false, fill: acc.withValues(alpha: 0.15), fg: acc),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: acc,
                            shape: BoxShape.circle,
                            border: Border.all(color: _pPage, width: 3),
                          ),
                          child: const Icon(CupertinoIcons.pencil, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text('Reza', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.ink)),
            ),
            const SizedBox(height: 2),
            Center(child: Text(L.t('role'), style: TextStyle(fontSize: 13.5, color: C.ink3))),
            const SizedBox(height: 24),
            Row(
              children: [
                _PMini(
                  icon: Ic.hand,
                  title: L.t('kasbon'),
                  sub: aktif ? L.t('active') : L.t('none'),
                  onTap: () => openPage(context, const KasbonPage()),
                ),
                const SizedBox(width: 12),
                _PMini(
                  icon: Ic.cloud,
                  title: L.t('sync'),
                  sub: sync,
                  onTap: () => openPage(context, const AboutPage()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _PSection(L.t('settings'), [
              _PRow(
                icon: CupertinoIcons.paintbrush,
                title: L.t('appearance'),
                value: '${s.pal.name} · ${modes[s.themeMode]}',
                onTap: () => openPage(context, const AppearancePage()),
              ),
              _PRow(
                icon: CupertinoIcons.globe,
                title: L.t('language'),
                value: L.en ? 'English' : 'Bahasa Indonesia',
                onTap: () => openPage(context, const LanguagePage()),
              ),
              _PRow(
                icon: CupertinoIcons.sparkles,
                title: L.t('anim_haptic'),
                value: '${L.t('counter_anim')}: ${_onOff(s.counterAnim)}',
                onTap: () => openPage(context, const GeneralPage()),
              ),
              _PRow(
                icon: Ic.eyeOff,
                title: L.t('privacy'),
                value: '${L.t('hide_balance')}: ${_onOff(s.hideSaldo)}',
                onTap: () => openPage(context, const PrivacyPage()),
              ),
            ]),
            const SizedBox(height: 24),
            _PSection(L.t('about'), [
              _PRow(
                icon: Ic.info,
                title: L.t('sync_about'),
                value: sync,
                onTap: () => openPage(context, const AboutPage()),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
