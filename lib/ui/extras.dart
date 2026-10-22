import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:number_flow_flutter/number_flow_flutter.dart';

import '../data/store.dart';
import 'icons.dart';
import 'theme.dart';
import 'widgets.dart';

/// Angka dengan efek counter (count-up + roll) seperti di My Finance.
/// [hidden] = true membuat angka ter-blur halus.
class Counter extends StatefulWidget {
  const Counter({
    super.key,
    required this.value,
    required this.style,
    this.symbol = '',
    this.hidden = false,
  });

  final num value;
  final TextStyle style;
  final String symbol;
  final bool hidden;

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  num _shown = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = widget.value);
    });
  }

  @override
  void didUpdateWidget(covariant Counter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _shown = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final Widget number = s.counterAnim
        ? RepaintBoundary(
            child: NumberFlow(
              value: _shown,
              locale: 'id_ID',
              format: NumberFlowFormat.currency(currencyCode: 'IDR', symbol: widget.symbol),
              spring: NumberFlowSpring.bouncy,
              motionBlur: 5.5,
              digitSquish: 0.32,
              stagger: const Duration(milliseconds: 40),
              transformTiming: const TimingConfig(duration: Duration(milliseconds: 450), curve: Curves.easeInOut),
              opacityTiming: const TimingConfig(duration: Duration(milliseconds: 450), curve: Curves.easeOut),
              tabularNums: true,
              style: widget.style,
            ),
          )
        : Text('${widget.symbol}${fmt(widget.value)}', style: widget.style);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: widget.hidden ? 12.0 : 0.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, sigma, child) => sigma < 0.05
          ? child!
          : ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal),
              child: child,
            ),
      child: number,
    );
  }
}

/// Kartu pengaturan tampilan: warna tema, bahasa, animasi, getar
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: C.ink3)),
      );

  Widget _langChip(AppStore s, String text, bool english) {
    final sel = L.en == english;
    return Expanded(
      child: GestureDetector(
        onTap: () => s.setLang(english),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: sel ? C.ink : C.field, borderRadius: BorderRadius.circular(14)),
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: sel ? Colors.white : C.ink2),
          ),
        ),
      ),
    );
  }

  Widget _switchRow(IconData icon, String label, bool v, VoidCallback onTap) {
    return Row(
      children: [
        Icon(icon, size: 20, color: C.ink2),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: C.ink)),
        ),
        Switch(value: v, onChanged: (_) => onTap()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return Column(
      children: [
        WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L.t('settings'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.ink)),
              const SizedBox(height: 16),
              _label(L.t('theme_color')),
              Wrap(
                spacing: 12,
                runSpacing: 14,
                children: [
                  for (var i = 0; i < palettes.length; i++)
                    GestureDetector(
                      onTap: () => s.setPalette(i),
                      child: SizedBox(
                        width: 56,
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 44,
                              height: 44,
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
                                fontSize: 10.5,
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
              const SizedBox(height: 20),
              _label(L.t('language')),
              Row(
                children: [
                  _langChip(s, 'Bahasa Indonesia', false),
                  const SizedBox(width: 10),
                  _langChip(s, 'English', true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        WhiteCard(
          padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
          child: Column(
            children: [
              _switchRow(Ic.tune, L.t('counter_anim'), s.counterAnim, s.toggleCounter),
              const Divider(height: 1, color: Color(0xFFF0F1F4)),
              _switchRow(Ic.hand, L.t('haptic'), s.haptic, s.toggleHaptic),
            ],
          ),
        ),
      ],
    );
  }
}