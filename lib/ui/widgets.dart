import 'package:flutter/material.dart';

import '../data/models.dart';
import 'theme.dart';

class TopGradient extends StatelessWidget {
  const TopGradient({super.key, this.height = 560});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2848C9), Color(0xFF3A63DE), Color(0xFF9DBBF5), C.bg],
          stops: [0, 0.42, 0.78, 1],
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
      onTap: widget.onTap,
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

class WhiteBtn extends StatelessWidget {
  const WhiteBtn({super.key, required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x1A0D1220), blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: C.ink),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: C.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PillBtn extends StatelessWidget {
  const PillBtn({super.key, required this.label, this.icon, this.onTap, this.dark = true});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : C.ink;
    return Tap(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: dark ? C.ink : C.field,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 17, color: fg), const SizedBox(width: 6)],
            Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: fg)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 20, offset: Offset(0, 8))],
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
                  color: i == index ? C.ink : Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: i == index ? C.ink : C.line),
                ),
                child: Text(
                  items[i],
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: i == index ? Colors.white : C.ink2,
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
      return const ActStyle(Icons.add_box_rounded, C.green, 'Cetak Bata');
    case 'Bata Mentah Masuk':
    case 'Bakar Bata':
      return const ActStyle(Icons.local_fire_department_rounded, C.amber, 'Masuk Tungku');
    case 'Mulai Bakar':
      return const ActStyle(Icons.whatshot_rounded, C.amber, 'Mulai Bakar');
    case 'Batu Selesai Dibakar':
      return const ActStyle(Icons.check_circle_rounded, C.green, 'Selesai Dibakar');
    case 'Batu Telah Disusun':
    case 'Batu Siap Jual':
      return const ActStyle(Icons.inventory_2_rounded, C.blue, 'Disusun Siap Jual');
    case 'Pengiriman Bata':
      return const ActStyle(Icons.local_shipping_rounded, C.blue, 'Pengiriman Bata');
    case 'Penjualan Bata':
      return const ActStyle(Icons.payments_rounded, C.green, 'Penjualan Bata');
    case 'Kirim ke Total Utama':
      return const ActStyle(Icons.send_rounded, C.violet, 'Kirim ke Total Utama');
    case 'Penyesuaian Saldo':
      return const ActStyle(Icons.tune_rounded, C.ink2, 'Penyesuaian Saldo');
  }
  final title = a.tipe.isEmpty ? 'Aktivitas' : a.tipe;
  if (a.isKeluar) return ActStyle(Icons.south_west_rounded, C.red, title);
  if (a.isMasuk) return ActStyle(Icons.north_east_rounded, C.green, title);
  return ActStyle(Icons.circle_outlined, C.ink2, title);
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
            decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(14)),
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
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: C.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tglCantik(a.tanggal)} · $detail',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: C.ink3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amt, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: col)),
              if (!a.isUang) const Text('bata', style: TextStyle(fontSize: 10.5, color: C.ink3)),
            ],
          ),
        ],
      ),
    );
  }
}

class FeedCard extends StatelessWidget {
  const FeedCard({super.key, required this.items, required this.loading});

  final List<Aktivitas> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return WhiteCard(
        child: SizedBox(
          height: 90,
          child: Center(
            child: loading
                ? const CircularProgressIndicator(strokeWidth: 2.5)
                : const Text('Belum ada aktivitas', style: TextStyle(color: C.ink3)),
          ),
        ),
      );
    }
    return WhiteCard(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ActivityTile(items[i]),
            if (i != items.length - 1) const Divider(height: 1, color: Color(0xFFF0F1F4)),
          ],
        ],
      ),
    );
  }
}