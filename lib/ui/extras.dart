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
              style: widget.style.copyWith(fontFamily: 'Satoshi'),
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

// Pengaturan dipindah ke settings_pages.dart (sub panel fullscreen)
