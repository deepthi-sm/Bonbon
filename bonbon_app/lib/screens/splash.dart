import 'package:flutter/material.dart';

import '../theme.dart';

/// Full-screen loading screen: the Bonbon logo floating above a soft shadow,
/// with three pulsing dots. Matches the web page's loading screen
/// (web/index.html), which shows until this one has drawn.
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
    final width = MediaQuery.maybeSizeOf(context)?.width ?? 400;
    final logoW = (width * 0.7).clamp(160.0, 340.0);
    final t = CurvedAnimation(parent: _float, curve: Curves.easeInOut);

    return ColoredBox(
      color: C.canvas,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: t,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, reduce ? 0 : 6 - 22 * t.value),
              child: child,
            ),
            child: Image.asset('assets/brand/logo.png', width: logoW, semanticLabel: 'Bonbon'),
          ),
          const SizedBox(height: 22),
          AnimatedBuilder(
            animation: t,
            builder: (_, _) => Transform.scale(
              scaleX: reduce ? 1 : 1 - 0.28 * t.value,
              child: Opacity(
                opacity: reduce ? 1 : 1 - 0.45 * t.value,
                child: Container(
                  width: logoW * 0.56,
                  height: 16,
                  decoration: BoxDecoration(
                    color: C.ink.withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.all(Radius.elliptical(200, 16)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 34),
          if (widget.error == null)
            AnimatedBuilder(
              animation: _dots,
              builder: (_, _) => Row(mainAxisSize: MainAxisSize.min, children: [
                for (final (i, c) in const [C.teal, C.magenta, C.gold].indexed) ...[
                  if (i > 0) const SizedBox(width: 10),
                  _dot(c, i),
                ],
              ]),
            )
          else
            Padding(
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
        ]),
      ),
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
        child: Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      ),
    );
  }
}
