import 'package:flutter/cupertino.dart' show CupertinoIcons;
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
Color get _pPage => C.bg;
Color get _pBox => C.card;
Color get _pChip => C.field;

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

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.icon, required this.label, required this.onTap, this.color});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? C.ink;
    return Tap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: c),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.paddingOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: C.line, borderRadius: BorderRadius.circular(99)),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: C.ink)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SheetBtn extends StatelessWidget {
  const _SheetBtn({required this.label, required this.onTap, this.filled = true});

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? C.ink : C.field,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          style: TextStyle(color: filled ? C.inv : C.ink, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _PhotoSheet extends StatelessWidget {
  const _PhotoSheet({
    required this.hasPhoto,
    required this.onGallery,
    required this.onCamera,
    required this.onRemove,
  });

  final bool hasPhoto;
  final VoidCallback onGallery, onCamera, onRemove;

  @override
  Widget build(BuildContext context) {
    void run(VoidCallback f) {
      Navigator.of(context).pop();
      f();
    }

    return _SheetFrame(
      title: L.t('profile_photo'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(24)),
            child: Column(
              children: [
                _SheetRow(icon: CupertinoIcons.photo, label: L.t('from_gallery'), onTap: () => run(onGallery)),
                Divider(height: 1, indent: 52, color: C.line),
                _SheetRow(icon: CupertinoIcons.camera, label: L.t('take_photo'), onTap: () => run(onCamera)),
                if (hasPhoto) ...[
                  Divider(height: 1, indent: 52, color: C.line),
                  _SheetRow(
                    icon: CupertinoIcons.trash,
                    label: L.t('remove_photo'),
                    color: C.red,
                    onTap: () => run(onRemove),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SheetBtn(label: L.t('cancel'), filled: false, onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

class _NameSheet extends StatefulWidget {
  const _NameSheet();

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  late final TextEditingController _c = TextEditingController(text: StoreScope.read(context).name);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _save() {
    if (_c.text.trim().isEmpty) return;
    StoreScope.read(context).setName(_c.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: L.t('edit_name'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    L.t('name_label'),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.ink2),
                  ),
                ),
                TextField(
                  controller: _c,
                  autofocus: true,
                  maxLength: 24,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: C.ink),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: C.card,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SheetBtn(label: L.t('save'), onTap: _save),
        ],
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
    openSheet<void>(
      context,
      _PhotoSheet(
        hasPhoto: s.avatar != null,
        onGallery: () => _pick(s, ImageSource.gallery),
        onCamera: () => _pick(s, ImageSource.camera),
        onRemove: () => s.setAvatar(null),
      ),
    );
  }

  void _nameMenu(BuildContext context) {
    openSheet<void>(context, const _NameSheet());
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
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: ColoredBox(
        color: _pPage,
        child: Stack(
          children: [
            const Positioned(top: 0, left: 0, right: 0, child: TopGradient(height: 360)),
            ListView(
          padding: EdgeInsets.fromLTRB(20, top + 16, 20, 130),
          children: [
            Center(
              child: const Text('Profil', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
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
                      const Avatar(size: 104),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: acc,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
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
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _nameMenu(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(CupertinoIcons.pencil, size: 16, color: Colors.white70),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Center(child: Text(L.t('role'), style: const TextStyle(fontSize: 13.5, color: Colors.white70))),
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
          ],
        ),
      ),
    );
  }
}
