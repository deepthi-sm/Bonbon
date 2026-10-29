import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/trace_score.dart';
import '../theme.dart';
import 'feedback.dart';

/// A ghosted model on ruled lines that she traces over with her finger. Same
/// drawing and measuring as the prototype's TraceCanvas (lib/screens/atelier.dart),
/// but the strokes and the check belong to the caller: [TracePadState.score]
/// measures the ink, [TracePadState.clear] wipes it.
///
/// [mark] is the feedback on the whole pad (feedback.dart); [Mark.model]
/// also lights the ghost in gold: the app showing her the letter.
///
/// [ghost] false hides the model (trace tier 3, « free »): she writes from
/// memory, and the hidden model is still what the ink is measured against.
/// [tolerance] widens or narrows how far off the model the ink may stray.
class TracePad extends StatefulWidget {
  final String glyph;
  final bool cursive;
  final Mark mark;
  final bool ghost;
  final double tolerance;
  final double height;
  final VoidCallback? onDraw;
  const TracePad({
    super.key,
    required this.glyph,
    this.cursive = false,
    this.mark = Mark.idle,
    this.ghost = true,
    this.tolerance = 1,
    this.height = 280,
    this.onDraw,
  });

  @override
  State<TracePad> createState() => TracePadState();
}

class TracePadState extends State<TracePad> {
  static const penWidth = 12.0;
  final List<List<Offset>> _strokes = [];
  Size _size = Size.zero;

  bool get isEmpty => _strokes.isEmpty;

  void clear() => setState(_strokes.clear);

  TextPainter _ghost(Size size, Color color) {
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
  Future<TraceResult?> score() async {
    if (_strokes.isEmpty || _size.isEmpty) return null;
    // Model and finger path on a half-resolution grid; see trace_score.dart.
    const scale = 0.5;
    final w = (_size.width * scale).ceil(), h = (_size.height * scale).ceil();
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec)..scale(scale);
    final tp = _ghost(_size, Colors.black);
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
    return scoreTrace(ink: ink, w: w, h: h, path: path, penRadius: penWidth / 2 * scale * widget.tolerance);
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
            child: CustomPaint(
              size: _size,
              painter: _PadPainter(
                strokes: _strokes,
                // The model always shows when the app lights it up for her.
                ghost: widget.ghost || model ? _ghost(_size, model ? C.gold : C.tealMid.withValues(alpha: 0.75)) : null,
                origin: (tp) => _origin(tp, _size),
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
  final TextPainter? ghost;
  final Offset Function(TextPainter) origin;
  _PadPainter({required this.strokes, required this.ghost, required this.origin});

  @override
  void paint(Canvas canvas, Size size) {
    // Ruled lines, after the book's writing pages.
    final line = Paint()..color = const Color(0xFFDCE8E7);
    for (var i = 1; i < 8; i++) {
      final y = size.height * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line..strokeWidth = i % 2 == 0 ? 1.8 : 1);
    }
    final g = ghost;
    if (g != null) g.paint(canvas, origin(g));
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
