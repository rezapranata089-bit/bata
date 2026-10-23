import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../data/store.dart';
import 'icons.dart';
import 'theme.dart';

const pageTitle = TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.8);

final pageSub = TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 13.5);

/// Avatar bulat: foto profil bila ada, kalau tidak huruf "R"
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.size, this.border = true, this.fill, this.fg});

  final double size;
  final bool border;
  final Color? fill, fg;

  @override
  Widget build(BuildContext context) {
    final img = StoreScope.of(context).avatar;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill ?? Colors.white.withValues(alpha: 0.2),
        border: border ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5) : null,
        image: img == null ? null : DecorationImage(image: MemoryImage(img), fit: BoxFit.cover),
      ),
      child: img == null
          ? Text(
              'R',
              style: TextStyle(color: fg ?? Colors.white, fontSize: size * 0.4, fontWeight: FontWeight.w800),
            )
          : null,
    );
  }
}

/// Tombol aksi lebar (terang / gelap)
class ActBtn extends StatelessWidget {
  const ActBtn({super.key, required this.label, required this.icon, this.onTap, this.dark = false});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? C.inv : C.ink;
    return Tap(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: dark ? C.ink : C.card,
          borderRadius: BorderRadius.circular(16),
          border: dark ? null : Border.all(color: C.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopGradient extends StatelessWidget {
  const TopGradient({super.key, this.height = 560});

  final double height;

  @override
  Widget build(BuildContext context) {
    final p = StoreScope.of(context).pal;
    final dk = C.dark;
    Color d(Color c, double t) => dk ? Color.lerp(c, Colors.black, t)! : c;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            d(p.top, 0.45),
            d(p.mid, 0.5),
            dk ? Color.lerp(p.soft, C.bg, 0.78)! : p.soft,
            C.bg,
          ],
          stops: const [0, 0.42, 0.78, 1],
        ),
      ),
    );
  }
}

class Tap extends StatefulWidget {
  const Tap({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (StoreScope.read(context).haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 90),
        child: widget.child,
      ),
    );
  }
}

class RoundIconBtn extends StatelessWidget {
  const RoundIconBtn({super.key, required this.icon, this.onTap, this.dot = false});

  final IconData icon;
  final VoidCallback? onTap;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (dot)
              Positioned(
                top: 11,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFFF6B5E), shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WhiteCard extends StatelessWidget {
  const WhiteCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(24),
        border: C.dark ? Border.all(color: C.line) : null,
        boxShadow: C.dark ? null : const [BoxShadow(color: Color(0x0F101828), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: child,
    );
  }
}

class FilterChips extends StatelessWidget {
  const FilterChips({super.key, required this.items, required this.index, required this.onChanged});

  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: i == index ? C.ink : C.card,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: i == index ? C.ink : C.line),
                ),
                child: Text(
                  items[i],
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: i == index ? C.inv : C.ink2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ActStyle {
  const ActStyle(this.icon, this.color, this.title);

  final IconData icon;
  final Color color;
  final String title;
}

ActStyle styleFor(Aktivitas a) {
  switch (a.tipe) {
    case 'Cetak Bata':
      return const ActStyle(Ic.add, C.green, 'Cetak Bata');
    case 'Bata Mentah Masuk':
    case 'Bakar Bata':
      return const ActStyle(Ic.fire, C.amber, 'Masuk Tungku');
    case 'Mulai Bakar':
      return const ActStyle(Ic.play, C.amber, 'Mulai Bakar');
    case 'Batu Selesai Dibakar':
      return const ActStyle(Ic.check, C.green, 'Selesai Dibakar');
    case 'Batu Telah Disusun':
    case 'Batu Siap Jual':
      return const ActStyle(Ic.stock, C.blue, 'Disusun Siap Jual');
    case 'Pengiriman Bata':
      return const ActStyle(Ic.truck, C.blue, 'Pengiriman Bata');
    case 'Penjualan Bata':
      return const ActStyle(Ic.money, C.green, 'Penjualan Bata');
    case 'Kirim ke Total Utama':
      return const ActStyle(Ic.send, C.violet, 'Kirim ke Total Utama');
    case 'Penyesuaian Saldo':
      return ActStyle(Ic.tune, C.ink2, 'Penyesuaian Saldo');
  }
  final title = a.tipe.isEmpty ? 'Aktivitas' : a.tipe;
  if (a.isKeluar) return ActStyle(Ic.outgoing, C.red, title);
  if (a.isMasuk) return ActStyle(Ic.incoming, C.green, title);
  return ActStyle(Ic.tune, C.ink2, title);
}

class ActivityTile extends StatelessWidget {
  const ActivityTile(this.a, {super.key});

  final Aktivitas a;

  @override
  Widget build(BuildContext context) {
    final s = styleFor(a);
    String amt;
    Color col;
    if (a.isUang) {
      if (a.isMasuk) {
        amt = '+${rp(a.nominal)}';
        col = C.green;
      } else if (a.isKeluar) {
        amt = '-${rp(a.nominal)}';
        col = C.red;
      } else {
        amt = 'Rp 0';
        col = C.ink3;
      }
    } else if (a.isMasuk) {
      amt = '+${fmt(a.nominal)}';
      col = C.green;
    } else if (a.isKeluar) {
      amt = '-${fmt(a.nominal)}';
      col = C.red;
    } else {
      amt = fmt(a.nominal);
      col = C.ink2;
    }
    final detail = a.keterangan.isNotEmpty
        ? a.keterangan
        : (a.tempat.isNotEmpty ? 'Area ${areaLabel(a.tempat)}' : a.col.replaceAll('aktivitas_', ''));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: s.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(s.icon, color: s.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: C.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tglCantik(a.tanggal)} · $detail',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: C.ink3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amt, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: col)),
              if (!a.isUang) Text('bata', style: TextStyle(fontSize: 10.5, color: C.ink3)),
            ],
          ),
        ],
      ),
    );
  }
}

class FeedCard extends StatelessWidget {
  const FeedCard({super.key, required this.items, required this.loading, this.flat = false});

  final List<Aktivitas> items;
  final bool loading;

  /// true = tanpa kartu (dipakai di dalam sheet)
  final bool flat;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final empty = SizedBox(
        height: 90,
        child: Center(
          child: loading
              ? const CircularProgressIndicator(strokeWidth: 2.5)
              : Text(L.t('no_activity'), style: TextStyle(color: C.ink3)),
        ),
      );
      return flat ? empty : WhiteCard(child: empty);
    }
    final list = Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          ActivityTile(items[i]),
          if (i != items.length - 1) Divider(height: 1, color: C.div),
        ],
      ],
    );
    if (flat) return list;
    return WhiteCard(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: list,
    );
  }
}
