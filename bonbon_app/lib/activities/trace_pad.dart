import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/trace_score.dart';
import '../theme.dart';
import 'feedback.dart';
import 'glyph_spec.dart';
import 'stroke_score.dart';
import 'trace_rubric.dart';
import 'trace_session.dart';

/// A model on ruled lines that she traces over with her finger; the caller
/// owns the check: [TracePadState.score] measures the ink, [TracePadState.clear]
/// wipes it.
///
/// With a [spec] (Dev A's stroke data) and a [rubric], the model is the
/// glyph's strokes, the ink is scored stroke by stroke (stroke_score.dart),
/// and [dots] shows the numbered start dots and the checkpoints, lit as she
/// reaches them (tier 1, « ghost+dots »). Without, it is the prototype's
/// font ghost and coverage scoring (same as TraceCanvas in
/// lib/screens/atelier.dart).
///
/// [mark] is the feedback on the whole pad (feedback.dart); [Mark.model]
/// shows the model in gold and, with a [spec], draws it stroke by stroke —
/// « the app plays the animated model once more » (trace-rubric.json).
/// [ghost] false hides the model (tier 3, « free »); [tolerance] is the
/// tier's multiplier.
class TracePad extends StatefulWidget {
  final String glyph;
  final bool cursive;
  final Mark mark;
  final bool ghost, dots;
  final double tolerance;
  final GlyphSpec? spec;
  final TraceRubric? rubric;
  final double height;
  final VoidCallback? onDraw;
  const TracePad({
    super.key,
    required this.glyph,
    this.cursive = false,
    this.mark = Mark.idle,
    this.ghost = true,
    this.dots = false,
    this.tolerance = 1,
    this.spec,
    this.rubric,
    this.height = 280,
    this.onDraw,
  });

  @override
  State<TracePad> createState() => TracePadState();
}

class TracePadState extends State<TracePad> with SingleTickerProviderStateMixin {
  static const penWidth = 12.0;
  final List<List<Offset>> _strokes = [];
  Size _size = Size.zero;
  late final AnimationController _model = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  bool get isEmpty => _strokes.isEmpty;
  bool get _byStrokes => widget.spec != null && widget.rubric != null;

  void clear() => setState(_strokes.clear);

  @override
  void didUpdateWidget(TracePad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mark == Mark.model && oldWidget.mark != Mark.model && widget.spec != null) _model.forward(from: 0);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // --- stroke-data mode -----------------------------------------------------

  /// Glyph units → canvas, fitting the viewBox in the pad.
  (double, Offset) _fit(GlyphSpec g, Size size) {
    final vb = g.viewBox;
    final scale = math.min(size.width * 0.86 / vb[2], size.height * 0.86 / vb[3]);
    return (scale, Offset((size.width - vb[2] * scale) / 2 - vb[0] * scale, (size.height - vb[3] * scale) / 2 - vb[1] * scale));
  }

  Pt _toGlyph(Offset o, (double, Offset) fit) => Pt((o.dx - fit.$2.dx) / fit.$1, (o.dy - fit.$2.dy) / fit.$1);

  List<List<Pt>> _inGlyph(GlyphSpec g) {
    final fit = _fit(g, _size);
    return [for (final s in _strokes) [for (final o in s) _toGlyph(o, fit)]];
  }

  /// Checkpoints reached so far, stroke by stroke (lit on the pad).
  List<int> _reached(GlyphSpec g) {
    final drawn = _inGlyph(g);
    final start = widget.rubric!['startProximity'].pass! * g.height * widget.rubric!.toleranceFor(g.char) * widget.tolerance;
    return [
      for (var k = 0; k < g.strokes.length; k++)
        k < drawn.length
            ? reachedInOrder(g.strokes[k], densify(drawn[k], 0.02 * g.height), checkpointRadius(g.strokes[k], g.height, start))
            : 0,
    ];
  }

  // --- font mode (prototype) ------------------------------------------------

  TextPainter _font(Size size, Color color) {
    TextStyle style(double fs) => widget.cursive
        ? GoogleFonts.playwriteFrModerne(fontSize: fs, color: color, height: 1)
        : GoogleFonts.plusJakartaSans(fontSize: fs, color: color, fontWeight: FontWeight.w800, height: 1);
    var fs = size.height * (widget.cursive ? 0.55 : 0.78);
    late TextPainter tp;
    for (var i = 0; i < 8; i++) {
      tp = TextPainter(text: TextSpan(text: widget.glyph, style: style(fs)), textDirection: TextDirection.ltr)..layout();
      if (tp.width <= size.width * 0.9) break;
      fs *= 0.85;
    }
    return tp;
  }

  Offset _origin(TextPainter tp, Size size) => Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2);

  /// Measures the ink against the model; null when nothing is drawn.
  Future<TraceCheck?> score() async {
    if (_strokes.isEmpty || _size.isEmpty) return null;
    if (_byStrokes) {
      final s = scoreStrokes(widget.spec!, _inGlyph(widget.spec!), widget.rubric!, tierTolerance: widget.tolerance);
      return TraceCheck.strokes(s, widget.rubric!);
    }
    // Model and finger path on a half-resolution grid; see trace_score.dart.
    const scale = 0.5;
    final w = (_size.width * scale).ceil(), h = (_size.height * scale).ceil();
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec)..scale(scale);
    final tp = _font(_size, Colors.black);
    tp.paint(canvas, _origin(tp, _size));
    final img = await rec.endRecording().toImage(w, h);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bytes == null) return null;

    final ink = [for (var i = 0; i < w * h; i++) bytes.getUint8(i * 4 + 3) > 100];
    final path = <int>{};
    for (final s in _strokes) {
      for (var i = 0; i < s.length; i++) {
        final a = s[i], b = i + 1 < s.length ? s[i + 1] : s[i];
        final steps = ((b - a).distance * scale).ceil().clamp(1, 400);
        for (var k = 0; k <= steps; k++) {
          final p = Offset.lerp(a, b, k / steps)! * scale;
          final x = p.dx.floor().clamp(0, w - 1), y = p.dy.floor().clamp(0, h - 1);
          path.add(y * w + x);
        }
      }
    }
    return TraceCheck.coverage(scoreTrace(ink: ink, w: w, h: h, path: path, penRadius: penWidth / 2 * scale * widget.tolerance));
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.mark == Mark.model;
    return SizedBox(
      height: widget.height,
      child: Marked(
        mark: widget.mark,
        fill: C.surface,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: LayoutBuilder(builder: (context, box) {
            _size = Size(box.maxWidth, box.maxHeight);
            final spec = _byStrokes ? widget.spec : null;
            // The model always shows when the app lights it up for her.
            final showModel = widget.ghost || model;
            final color = model ? C.gold : C.tealMid.withValues(alpha: 0.75);
            // As in TraceCanvas: claim the pointer on touch-down so strokes in any
            // direction draw instead of scrolling the page.
            return RawGestureDetector(
              gestures: {
                EagerGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                  EagerGestureRecognizer.new,
                  (_) {},
                ),
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) {
                  setState(() => _strokes.add([e.localPosition]));
                  widget.onDraw?.call();
                },
                onPointerMove: (e) {
                  if (_strokes.isNotEmpty) setState(() => _strokes.last.add(e.localPosition));
                },
                child: AnimatedBuilder(
                  animation: _model,
                  builder: (context, _) => CustomPaint(
                    size: _size,
                    painter: _PadPainter(
                      strokes: _strokes,
                      font: spec == null && showModel ? _font(_size, color) : null,
                      origin: (tp) => _origin(tp, _size),
                      spec: spec != null && showModel ? spec : null,
                      fit: spec == null ? null : _fit(spec, _size),
                      modelColor: color,
                      // While the model draws itself, only the part drawn so far.
                      progress: model && spec != null && _model.isAnimating ? _model.value : 1,
                      dots: spec != null && widget.dots && !model,
                      reached: spec != null && widget.dots ? _reached(spec) : const [],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _PadPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final TextPainter? font;
  final Offset Function(TextPainter) origin;
  final GlyphSpec? spec;
  final (double, Offset)? fit;
  final Color modelColor;
  final double progress; // 0..1 of the model's strokes drawn
  final bool dots;
  final List<int> reached;
  _PadPainter({
    required this.strokes,
    required this.font,
    required this.origin,
    required this.spec,
    required this.fit,
    required this.modelColor,
    required this.progress,
    required this.dots,
    required this.reached,
  });

  Offset _at(Pt p) => Offset(p.x * fit!.$1 + fit!.$2.dx, p.y * fit!.$1 + fit!.$2.dy);

  @override
  void paint(Canvas canvas, Size size) {
    // Ruled lines, after the book's writing pages.
    final line = Paint()..color = const Color(0xFFDCE8E7);
    for (var i = 1; i < 8; i++) {
      final y = size.height * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line..strokeWidth = i % 2 == 0 ? 1.8 : 1);
    }
    final f = font;
    if (f != null) f.paint(canvas, origin(f));
    final g = spec;
    if (g != null) _model(canvas, g);
    final pen = Paint()
      ..color = C.teal
      ..strokeWidth = TracePadState.penWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) {
      if (s.length == 1) {
        canvas.drawCircle(s.first, TracePadState.penWidth / 2, pen..style = PaintingStyle.fill);
        pen.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (final p in s.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, pen);
    }
  }

  /// The glyph's strokes as thick ghost lines, in order, up to [progress];
  /// with [dots], each start as a numbered dot and the checkpoints, lit once reached.
  void _model(Canvas canvas, GlyphSpec g) {
    final ghost = Paint()
      ..color = modelColor
      ..strokeWidth = 0.11 * g.height * fit!.$1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final shown = progress * g.strokes.length;
    for (final (k, s) in g.strokes.indexed) {
      if (k >= shown.ceil()) break;
      final pts = s.polyline;
      final part = (shown - k).clamp(0.0, 1.0);
      final upto = math.max(1, (part * (pts.length - 1)).ceil());
      final path = Path()..moveTo(_at(pts.first).dx, _at(pts.first).dy);
      for (final p in pts.skip(1).take(upto)) {
        path.lineTo(_at(p).dx, _at(p).dy);
      }
      if (pts.length == 1) {
        canvas.drawCircle(_at(pts.first), ghost.strokeWidth / 2, Paint()..color = modelColor);
      } else {
        canvas.drawPath(path, ghost);
      }
    }
    if (!dots) return;
    for (final (k, s) in g.strokes.indexed) {
      final done = k < reached.length ? reached[k] : 0;
      for (final (i, c) in s.checkpoints.indexed) {
        canvas.drawCircle(_at(c), 5, Paint()..color = i < done ? C.success : C.border);
      }
      // The start: a numbered dot, in the stroke's order.
      final start = _at(s.startPoint);
      canvas.drawCircle(start, 13, Paint()..color = C.magenta);
      final n = TextPainter(
        text: TextSpan(text: '${s.order}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
        textDirection: TextDirection.ltr,
      )..layout();
      n.paint(canvas, start - Offset(n.width / 2, n.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
