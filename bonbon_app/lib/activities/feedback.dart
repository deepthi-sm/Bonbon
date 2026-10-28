import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// The feedback layer (plan §J.3, task B7): how every activity shows a
/// judgement on a tile, slot or canvas. One place for the colour, icon and
/// motion of each mark, so all five activity types look and move alike. The
/// sound is the voice: each screen plays its session's `say` with the mark.
///
/// Never colour alone — every judgement also carries an icon, a motion and a
/// spoken sentence. No red, no cross, no buzzer (repair-ladder.json, neverDo).
enum Mark {
  /// Not judged yet.
  idle,

  /// Right: green, a check, a small pop.
  right,

  /// A wrong attempt: grey, an ear (« listen again »), a gentle nudge.
  tried,

  /// The app shows the answer (repair rung 3, trace's last attempt): gold, a
  /// pointing hand, a slow pulse until she acts.
  model,

  /// Taken out by the repair ladder (rung 2): faded, no icon.
  faded,
}

class MarkStyle {
  final Color fill, border, ink;
  final double borderWidth;
  final IconData? icon;
  final Color iconColor;
  final double opacity;
  const MarkStyle({
    required this.fill,
    required this.border,
    this.ink = C.ink,
    this.borderWidth = 3,
    this.icon,
    this.iconColor = C.inkSoft,
    this.opacity = 1,
  });

  static MarkStyle of(Mark m) => switch (m) {
        Mark.idle => const MarkStyle(fill: C.surface, border: C.border, borderWidth: 1.5),
        Mark.right => const MarkStyle(fill: C.successSoft, border: C.success, icon: Icons.check_circle_rounded, iconColor: C.success),
        Mark.tried => const MarkStyle(fill: C.canvas, border: C.locked, ink: C.inkSoft, icon: Icons.hearing_rounded),
        Mark.model => const MarkStyle(fill: C.goldSoft, border: C.gold, icon: Icons.touch_app_rounded, iconColor: C.gold),
        Mark.faded => const MarkStyle(fill: C.surface, border: C.border, borderWidth: 1.5, opacity: 0.25),
      };
}

/// Draws [child] in the style of [mark] and moves when the mark changes.
/// [fill] and [border] replace the idle look (an empty slot, a word's letter).
class Marked extends StatefulWidget {
  final Mark mark;
  final Widget child;
  final double radius;
  final bool showIcon;
  final Color? fill, border;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;
  final bool shadow;
  const Marked({
    super.key,
    required this.mark,
    required this.child,
    this.radius = 24,
    this.showIcon = true,
    this.fill,
    this.border,
    this.constraints,
    this.padding,
    this.shadow = false,
  });

  @override
  State<Marked> createState() => _MarkedState();
}

class _MarkedState extends State<Marked> with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  bool _started = false;

  bool get _still => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // First start here, not in initState: reduced motion is read from context.
    if (!_started) {
      _started = true;
      _start();
    }
  }

  @override
  void didUpdateWidget(Marked old) {
    super.didUpdateWidget(old);
    if (old.mark != widget.mark) _start();
  }

  void _start() {
    _motion.stop();
    _motion.value = 0;
    if (_still) return; // reduced motion: no motion runs at all
    switch (widget.mark) {
      case Mark.right || Mark.tried:
        _motion.forward();
      case Mark.model:
        _motion.repeat(reverse: true, period: const Duration(milliseconds: 900));
      case Mark.idle || Mark.faded:
        break;
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  /// Scale and sideways offset at time [t] (0..1) of the current motion.
  (double, double) _pose(double t) => switch (widget.mark) {
        Mark.right => (1 + 0.08 * math.sin(math.pi * t), 0), // pop
        Mark.tried => (1, 6 * math.sin(3 * math.pi * t) * (1 - t)), // nudge, settling
        Mark.model => (1 + 0.04 * t, 0), // pulse
        Mark.idle || Mark.faded => (1, 0),
      };

  @override
  Widget build(BuildContext context) {
    final s = MarkStyle.of(widget.mark);
    final idle = widget.mark == Mark.idle;
    final still = _still;
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      constraints: widget.constraints,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: idle ? widget.fill ?? s.fill : s.fill,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: idle ? widget.border ?? s.border : s.border, width: s.borderWidth),
        boxShadow: widget.shadow ? const [BoxShadow(color: Color(0x141F2937), offset: Offset(0, 3))] : null,
      ),
      child: Stack(alignment: Alignment.center, children: [
        widget.child,
        if (widget.showIcon && s.icon != null)
          Positioned(right: 8, top: 8, child: Icon(s.icon, color: s.iconColor, size: 26)),
      ]),
    );
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: s.opacity,
      child: still
          ? box
          : AnimatedBuilder(
              animation: _motion,
              child: box,
              builder: (context, child) {
                final (scale, dx) = _pose(_motion.value);
                return Transform.translate(offset: Offset(dx, 0), child: Transform.scale(scale: scale, child: child));
              },
            ),
    );
  }
}
