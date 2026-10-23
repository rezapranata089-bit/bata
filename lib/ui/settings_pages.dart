import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../data/models.dart';
import '../data/store.dart';
import 'icons.dart';
import 'theme.dart';
import 'widgets.dart';

/// Buka halaman fullscreen dengan transisi geser + fade
void openPage(BuildContext context, Widget page) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return FadeTransition(
          opacity: c,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(c),
            child: child,
          ),
        );
      },
    ),
  );
}

/// Kerangka halaman pengaturan fullscreen
class SubPage extends StatelessWidget {
  const SubPage({super.key, required this.title, this.subtitle, required this.children});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    StoreScope.of(context);
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: C.bg,
        body: Stack(
          children: [
            const Positioned(top: 0, left: 0, right: 0, child: TopGradient(height: 360)),
            ListView(
              padding: EdgeInsets.fromLTRB(20, top + 12, 20, 40),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: RoundIconBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const SizedBox(height: 18),
                Text(title, style: pageTitle),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(subtitle!, style: pageSub),
                  ),
                const SizedBox(height: 26),
                ...children,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Grup baris pengaturan dalam satu kartu
class SetGroup extends StatelessWidget {
  const SetGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 10),
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: C.ink3),
            ),
          ),
        WhiteCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) Divider(height: 1, indent: 52, color: C.div),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

/// Satu baris pengaturan (ikon, judul, keterangan, panah / kontrol)
class SetTile extends StatelessWidget {
  const SetTile({super.key, required this.icon, required this.title, this.value, this.onTap, this.trailing, this.color});

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? StoreScope.of(context).pal.accent;
    return Tap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 21, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: C.ink)),
                  if (value != null) ...[
                    const SizedBox(height: 2),
                    Text(value!, style: TextStyle(fontSize: 12.5, color: C.ink3)),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(Icons.chevron_right_rounded, size: 22, color: C.ink3),
          ],
        ),
      ),
    );
  }
}

Widget _val(String v) => Text(v, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: C.ink));

// ───────────────────────── TAMPILAN ─────────────────────────
class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  Widget _preview(AppStore s) {
    final p = s.pal;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: 130,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.top, p.mid, p.soft],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(L.t('total_cash'), style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            rp(s.kas),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8),
          ),
        ],
      ),
    );
  }

  Widget _mode(AppStore s, int i, IconData icon, String label) {
    final sel = s.themeMode == i;
    final acc = s.pal.accent;
    return Expanded(
      child: GestureDetector(
        onTap: () => s.setThemeMode(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: sel ? acc.withValues(alpha: 0.12) : C.field,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: sel ? acc : Colors.transparent, width: 1.8),
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: sel ? acc : C.ink2),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
                  color: sel ? acc : C.ink2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SubPage(
      title: L.t('appearance'),
      subtitle: L.t('appearance_sub'),
      children: [
        _preview(s),
        const SizedBox(height: 22),
        SetGroup(
          title: L.t('screen_mode'),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  _mode(s, 0, Icons.brightness_auto_rounded, L.t('mode_system')),
                  const SizedBox(width: 10),
                  _mode(s, 1, Icons.light_mode_rounded, L.t('mode_light')),
                  const SizedBox(width: 10),
                  _mode(s, 2, Icons.dark_mode_rounded, L.t('mode_dark')),
                ],
              ),
            ),
          ],
        ),
        SetGroup(
          title: L.t('theme_color'),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 16,
                children: [
                  for (var i = 0; i < palettes.length; i++)
                    GestureDetector(
                      onTap: () => s.setPalette(i),
                      child: SizedBox(
                        width: 60,
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [palettes[i].top, palettes[i].soft],
                                ),
                                border: Border.all(
                                  color: s.paletteIdx == i ? C.ink : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: s.paletteIdx == i
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              palettes[i].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: s.paletteIdx == i ? FontWeight.w700 : FontWeight.w500,
                                color: s.paletteIdx == i ? C.ink : C.ink3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── BAHASA ─────────────────────────
class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  Widget _opt(AppStore s, String label, String code, bool english) {
    final sel = L.en == english;
    return SetTile(
      icon: Icons.translate_rounded,
      color: C.blue,
      title: label,
      value: code,
      onTap: () => s.setLang(english),
      trailing: Icon(
        sel ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        size: 24,
        color: sel ? s.pal.accent : C.ink3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SubPage(
      title: L.t('language'),
      subtitle: L.t('language_sub'),
      children: [
        SetGroup(
          children: [
            _opt(s, 'Bahasa Indonesia', 'ID', false),
            _opt(s, 'English', 'EN', true),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── ANIMASI & GETAR ─────────────────────────
class GeneralPage extends StatelessWidget {
  const GeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SubPage(
      title: L.t('anim_haptic'),
      subtitle: L.t('anim_sub'),
      children: [
        SetGroup(
          children: [
            SetTile(
              icon: Icons.speed_rounded,
              color: C.green,
              title: L.t('counter_anim'),
              value: L.t('counter_desc'),
              onTap: s.toggleCounter,
              trailing: GlassSwitch(
                value: s.counterAnim,
                onChanged: (_) => s.toggleCounter(),
                useOwnLayer: true,
                activeColor: s.pal.accent,
              ),
            ),
            SetTile(
              icon: Icons.vibration_rounded,
              color: C.amber,
              title: L.t('haptic'),
              value: L.t('haptic_desc'),
              onTap: s.toggleHaptic,
              trailing: GlassSwitch(
                value: s.haptic,
                onChanged: (_) => s.toggleHaptic(),
                useOwnLayer: true,
                activeColor: s.pal.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── PRIVASI ─────────────────────────
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SubPage(
      title: L.t('privacy'),
      subtitle: L.t('privacy_sub'),
      children: [
        SetGroup(
          children: [
            SetTile(
              icon: Ic.eyeOff,
              color: C.red,
              title: L.t('hide_balance'),
              value: L.t('hide_desc'),
              onTap: s.toggleSaldo,
              trailing: GlassSwitch(
                value: s.hideSaldo,
                onChanged: (_) => s.toggleSaldo(),
                useOwnLayer: true,
                activeColor: s.pal.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── KASBON PEKERJA ─────────────────────────
class KasbonPage extends StatelessWidget {
  const KasbonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final aktif = s.bon['kasbonActive'] == true;
    return SubPage(
      title: L.t('kasbon'),
      subtitle: L.t('kasbon_sub'),
      children: [
        SetGroup(
          children: [
            SetTile(icon: Ic.hand, color: C.amber, title: L.t('status'), trailing: _val(aktif ? L.t('active') : L.t('none'))),
            SetTile(icon: Ic.box, color: C.green, title: L.t('rest_brick'), trailing: _val(fmt(toNum(s.bon['sisaBata'])))),
            SetTile(icon: Ic.money, color: C.red, title: L.t('rest_debt'), trailing: _val(rp(toNum(s.bon['sisaRp'])))),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── SINKRON & TENTANG ─────────────────────────
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final sync = s.error != null ? L.t('problem') : (s.ready ? L.t('connected') : L.t('connecting'));
    return SubPage(
      title: L.t('sync_about'),
      subtitle: L.t('sync_sub'),
      children: [
        SetGroup(
          children: [
            SetTile(icon: Ic.cloud, color: s.error != null ? C.red : C.green, title: L.t('sync'), trailing: _val(sync)),
            SetTile(icon: Ic.info, color: C.blue, title: L.t('project'), trailing: _val('usaha-batu')),
            SetTile(icon: Ic.tune, color: C.violet, title: L.t('version'), trailing: _val('1.2.0')),
          ],
        ),
      ],
    );
  }
}