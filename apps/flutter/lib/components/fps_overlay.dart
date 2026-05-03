import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FpsOverlay extends StatefulWidget {
  const FpsOverlay({required this.child, super.key});

  final Widget child;

  @override
  State<FpsOverlay> createState() => _FpsOverlayState();
}

class _FpsOverlayState extends State<FpsOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastSample = Duration.zero;
  int _frames = 0;
  double _fps = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_handleTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 12,
          bottom: 12 + MediaQuery.paddingOf(context).bottom,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.inverseSurface.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  '${_fps.toStringAsFixed(0)} FPS',
                  style: TextStyle(
                    color: colors.onInverseSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleTick(Duration elapsed) {
    _frames++;
    final delta = elapsed - _lastSample;
    if (delta < const Duration(seconds: 1)) {
      return;
    }

    setState(() {
      _fps = _frames * Duration.microsecondsPerSecond / delta.inMicroseconds;
      _frames = 0;
      _lastSample = elapsed;
    });
  }
}
