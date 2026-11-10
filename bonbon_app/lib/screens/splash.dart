import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// The app's own loading screen: the Bonbon logo floating above a soft
/// shadow, with three pulsing dots. Drawn on Android, and on the web only to
/// show a start-up error (the web page's identical loading screen covers the
/// web start-up; see lib/loading/web_loader.dart).
/// Height / width of assets/brand/logo.png (720 × 643).
const _logoAspect = 643 / 720;

class SplashScreen extends StatefulWidget {
  final String? error;
  final VoidCallback? onRetry;
  const SplashScreen({super.key, this.error, this.onRetry});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _float =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
  late final AnimationController _dots =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _float.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final t = CurvedAnimation(parent: _float, curve: Curves.easeInOut);

    // Same geometry as the web loading screen in web/index.html: logo exactly
    // centred, min(36% of width, 180) wide; shadow 12 px and dots 40 px below it.
    return ColoredBox(
      color: C.canvas,
      child: LayoutBuilder(builder: (context, box) {
        final logoW = math.min(box.maxWidth * 0.36, 180.0);
        final logoH = logoW * _logoAspect;
        final below = box.maxHeight / 2 + logoH / 2;
        return Stack(children: [
          Positioned(
            left: (box.maxWidth - logoW) / 2,
            top: box.maxHeight / 2 - logoH / 2,
            child: AnimatedBuilder(
              animation: t,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, reduce ? 0 : 3 - 11 * t.value),
                child: child,
              ),
              child: Image.asset('assets/brand/logo.png',
                  width: logoW, height: logoH, fit: BoxFit.contain, semanticLabel: 'Bonbon'),
            ),
          ),
          Positioned(
            left: (box.maxWidth - logoW * 0.56) / 2,
            top: below + 12,
            child: AnimatedBuilder(
              animation: t,
              builder: (_, _) => Transform.scale(
                scaleX: reduce ? 1 : 1 - 0.28 * t.value,
                child: Opacity(
                  opacity: reduce ? 1 : 1 - 0.45 * t.value,
                  child: Container(
                    width: logoW * 0.56,
                    height: 8,
                    decoration: BoxDecoration(
                      color: C.ink.withValues(alpha: 0.12),
                      borderRadius: const BorderRadius.all(Radius.elliptical(200, 8)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: below + 40,
            child: widget.error == null
                ? AnimatedBuilder(
                    animation: _dots,
                    builder: (_, _) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      for (final (i, c) in const [C.teal, C.magenta, C.gold].indexed) ...[
                        if (i > 0) const SizedBox(width: 8),
                        _dot(c, i),
                      ],
                    ]),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(children: [
                      Text(widget.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: C.inkSoft, fontSize: 15, decoration: TextDecoration.none)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: widget.onRetry,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(color: C.teal, shape: BoxShape.circle),
                          child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 34),
                        ),
                      ),
                    ]),
                  ),
          ),
        ]);
      }),
    );
  }

  Widget _dot(Color c, int i) {
    // Each dot pulses in turn, 0.2 s apart (same rhythm as the web loader).
    final phase = ((_dots.value - i * 0.166) % 1.0);
    final pulse = 1 - (2 * phase - 1).abs(); // 0 -> 1 -> 0
    return Opacity(
      opacity: 0.25 + 0.75 * pulse,
      child: Transform.scale(
        scale: 0.85 + 0.25 * pulse,
        child: Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      ),
    );
  }
}
