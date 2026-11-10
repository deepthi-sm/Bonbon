import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/phrases.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'trace_score.dart';

/// Free practice, no progression: alphabet wall, digits, writing notebook.
class Atelier extends StatelessWidget {
  const Atelier({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    void push(Widget w) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      TopBar(page: context.tr('Atelier', 'Practice'), spoken: P.atelier),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),
          Text(context.tr('Entraînement libre', 'Free practice'), style: t.headlineMedium),
          const SizedBox(height: 4),
          Text(context.tr('Choisis une activité pour t\'entraîner, à ton rythme.', 'Pick an activity and practise at your own pace.'), style: t.bodySmall),
          const SizedBox(height: 18),
          _AtelierCard(context.tr('Le mur des lettres', 'Alphabet wall'), context.tr('Les 26 lettres, à écouter et à tracer.', 'All 26 letters, to hear and trace.'), P.alphabet, 'Aa', C.goldSoft, C.goldDeep,
              () => push(const AlphabetWall())),
          const SizedBox(height: 12),
          _AtelierCard(context.tr('Les chiffres', 'Digits'), context.tr('De 0 à 9 : écoute et écris.', '0 to 9: listen and write.'), P.digits, '123', C.tealSoft, C.teal,
              () => push(const DigitWall())),
          const SizedBox(height: 12),
          _AtelierCard(context.tr('Cahier d\'écriture', 'Writing notebook'), context.tr('Trace une lettre avec ton doigt.', 'Trace a letter with your finger.'), P.notebook, '✎', C.magentaSoft, C.magenta,
              () => push(const FreeTrace())),
          const SizedBox(height: 24),
          Panel(
            color: C.tealSoft,
            borderColor: C.tealMid,
            child: Row(children: [
              const Icon(Icons.thumb_up_alt_outlined, color: C.teal, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.tr('La pratique rend forte', 'Practice makes strong'), style: t.labelLarge),
                  Text(context.tr('Chaque tracé au doigt aide ta mémoire pour la lecture.', 'Every finger trace helps your memory for reading.'), style: t.bodySmall),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    ]);
  }
}

class _AtelierCard extends StatelessWidget {
  final String title, sub, spoken, glyph;
  final Color bg, fg;
  final VoidCallback onTap;
  const _AtelierCard(this.title, this.sub, this.spoken, this.glyph, this.bg, this.fg, this.onTap);

  @override
  Widget build(BuildContext context) => Panel(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Text(glyph, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: fg)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              Text(sub, style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
          SpeakButton(spoken, size: 40, filled: false),
          const SizedBox(width: 6),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ),
        ]),
      );
}

class _SubPage extends StatelessWidget {
  final String title;
  final String spoken;
  final Widget child;
  const _SubPage({required this.title, required this.spoken, required this.child});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
          actions: [const Padding(padding: EdgeInsets.only(right: 8), child: LangToggle()),
            Padding(padding: const EdgeInsets.only(right: 16), child: SpeakButton(spoken, size: 44))],
        ),
        body: SafeArea(child: child),
      );
}

void _practiceSheet(BuildContext context, String model, String speech, Widget header) {
  context.app.say(speech);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: C.canvas,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
          child: Container(
              width: 48, height: 5, decoration: BoxDecoration(color: C.border, borderRadius: BorderRadius.circular(9))),
        ),
        const SizedBox(height: 12),
        header,
        const SizedBox(height: 14),
        TraceCanvas(model: model),
      ]),
    ),
  );
}

class AlphabetWall extends StatelessWidget {
  const AlphabetWall({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return _SubPage(
      title: context.tr('Le mur des lettres', 'Alphabet wall'),
      spoken: P.alphabet,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12),
        itemCount: app.repo.alphabet.length,
        itemBuilder: (context, i) {
          final e = app.repo.alphabet[i];
          final c = e.category == 'vowel' ? C.teal : C.magenta;
          return Panel(
            padding: const EdgeInsets.all(8),
            onTap: () => _practiceSheet(
              context,
              e.lower,
              e.lower,
              Row(children: [
                Text('${e.upper} ${e.lower}', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: c)),
                const SizedBox(width: 16),
                Text('${e.upper} ${e.lower}', style: cursive(36)),
                const Spacer(),
                SpeakButton(e.lower, size: 52),
              ]),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${e.upper}${e.lower}', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: c)),
              Text('${e.upper}${e.lower}', style: cursive(20, color: C.inkSoft)),
            ]),
          );
        },
      ),
    );
  }
}

class DigitWall extends StatelessWidget {
  const DigitWall({super.key});

  @override
  Widget build(BuildContext context) {
    final digits = context.app.repo.units.last.lessons;
    return _SubPage(
      title: context.tr('Les chiffres', 'Digits'),
      spoken: P.digits,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.2),
        itemCount: digits.length,
        itemBuilder: (context, i) {
          final d = digits[i];
          return Panel(
            onTap: () => _practiceSheet(
              context,
              '${d.number}',
              d.targets[1],
              Row(children: [
                Text('${d.number}', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: C.goldDeep)),
                const SizedBox(width: 16),
                Expanded(child: Text(d.targets[1], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700))),
                SpeakButton(d.targets[1], size: 52),
              ]),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${d.number}', style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w800, color: C.goldDeep, height: 1)),
              Text(d.targets[1], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ]),
          );
        },
      ),
    );
  }
}

class FreeTrace extends StatefulWidget {
  const FreeTrace({super.key});

  @override
  State<FreeTrace> createState() => _FreeTraceState();
}

class _FreeTraceState extends State<FreeTrace> {
  String _model = 'a';
  bool _cursive = false;

  @override
  Widget build(BuildContext context) {
    final letters = [for (final e in context.app.repo.alphabet) e.lower];
    final digitWords = {for (final d in context.app.repo.units.last.lessons) '${d.number}': d.targets[1]};
    final models = [...letters, ...digitWords.keys];
    return _SubPage(
      title: context.tr('Cahier d\'écriture', 'Writing notebook'),
      spoken: P.notebook,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        ScriptToggle(cursive: _cursive, onChanged: (v) => setState(() => _cursive = v)),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: models.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final m = models[i];
              final on = m == _model;
              return GestureDetector(
                onTap: () {
                  setState(() => _model = m);
                  context.app.say(digitWords[m] ?? m);
                },
                child: Container(
                  width: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? C.teal : C.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: on ? C.teal : C.border, width: 1.5),
                  ),
                  child: Text(m, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: on ? Colors.white : C.ink)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        TraceCanvas(key: ValueKey('$_model$_cursive'), model: _model, cursiveModel: _cursive),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------

/// Trace over a ghosted model on ruled lines. "Vérifier" compares the ink
/// with the model's shape: how much of the letter was covered and how much
/// of the ink stayed on it. Not handwriting recognition (plan §J.4).
class TraceCanvas extends StatefulWidget {
  final String model;
  final bool cursiveModel;
  final double height;
  const TraceCanvas({super.key, required this.model, this.cursiveModel = false, this.height = 260});

  @override
  State<TraceCanvas> createState() => _TraceCanvasState();
}

class _TraceCanvasState extends State<TraceCanvas> {
  final List<List<Offset>> _strokes = [];
  int? _stars;
  Size _size = Size.zero;

  TextPainter _ghost(Size size, Color color) {
    TextStyle style(double fs) => widget.cursiveModel
        ? GoogleFonts.playwriteFrModerne(fontSize: fs, color: color, height: 1)
        : GoogleFonts.plusJakartaSans(fontSize: fs, color: color, fontWeight: FontWeight.w800, height: 1);
    var fs = size.height * (widget.cursiveModel ? 0.55 : 0.78);
    late TextPainter tp;
    for (var i = 0; i < 8; i++) {
      tp = TextPainter(text: TextSpan(text: widget.model, style: style(fs)), textDirection: TextDirection.ltr)..layout();
      if (tp.width <= size.width * 0.9) break;
      fs *= 0.85;
    }
    return tp;
  }

  Offset _ghostOrigin(TextPainter tp, Size size) =>
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2);

  Future<void> _check() async {
    final app = context.app;
    if (_strokes.isEmpty) {
      app.say(P.traceEmpty);
      return;
    }
    // Model and finger path on a half-resolution grid; see trace_score.dart.
    const scale = 0.5;
    final w = (_size.width * scale).ceil(), h = (_size.height * scale).ceil();
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec)..scale(scale);
    final tp = _ghost(_size, Colors.black);
    tp.paint(canvas, _ghostOrigin(tp, _size));
    final img = await rec.endRecording().toImage(w, h);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bytes == null || !mounted) return;

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
    final result = scoreTrace(ink: ink, w: w, h: h, path: path, penRadius: _penWidth / 2 * scale);
    if (kDebugMode) debugPrint('[trace] "${widget.model}" $result');
    setState(() => _stars = result.stars);
    app.say(switch (result.stars) {
      3 => P.trace[3],
      2 => P.trace[2],
      _ => P.trace[0],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: C.border, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(builder: (context, box) {
          _size = Size(box.maxWidth, box.maxHeight);
          // The canvas sits inside scrolling pages. An eager recognizer claims
          // the pointer on touch-down so vertical and diagonal strokes draw
          // instead of scrolling the page; Listener supplies the raw points,
          // so strokes can go in any direction.
          return RawGestureDetector(
            gestures: {
              EagerGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                EagerGestureRecognizer.new,
                (_) {},
              ),
            },
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) => setState(() {
                _stars = null;
                _strokes.add([e.localPosition]);
              }),
              onPointerMove: (e) {
                if (_strokes.isNotEmpty) setState(() => _strokes.last.add(e.localPosition));
              },
              child: CustomPaint(
              size: _size,
              painter: _TracePainter(
                strokes: _strokes,
                ghost: _ghost(_size, C.tealMid.withValues(alpha: 0.75)),
                origin: (tp) => _ghostOrigin(tp, _size),
              ),
            ),
            ),
          );
        }),
      ),
      if (_stars != null) ...[
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < 3; i++)
            Icon(i < _stars! ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < _stars! ? C.gold : C.locked, size: 44),
        ]),
        const SizedBox(height: 4),
        Text(
          switch (_stars!) {
            3 => context.tr('Très bien tracé !', 'Traced perfectly!'),
            2 => context.tr('Presque ! Suis bien tout le modèle.', 'Almost! Follow the whole model.'),
            _ => context.tr('Pas encore. Efface et réessaie sur le modèle gris.',
                'Not yet. Clear and try again over the grey model.'),
          },
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: _stars! >= 2 ? C.tealDark : C.magentaDark),
        ),
      ],
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: PressButton.ghost(
            label: _stars == 1 ? context.tr('Réessayer', 'Try again') : context.tr('Effacer', 'Clear'),
            icon: Icons.delete_outline_rounded,
            onTap: () => setState(() {
              _strokes.clear();
              _stars = null;
            }),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: PressButton(label: context.tr('Vérifier', 'Check'), icon: Icons.check_circle_outline_rounded, onTap: _check)),
      ]),
    ]);
  }
}

const double _penWidth = 12;

class _TracePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final TextPainter ghost;
  final Offset Function(TextPainter) origin;
  _TracePainter({required this.strokes, required this.ghost, required this.origin});

  @override
  void paint(Canvas canvas, Size size) {
    // Ruled lines, after the book's writing pages.
    final line = Paint()
      ..color = const Color(0xFFDCE8E7)
      ..strokeWidth = 1.2;
    for (var i = 1; i < 8; i++) {
      final y = size.height * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line..strokeWidth = i % 2 == 0 ? 1.8 : 1);
    }
    ghost.paint(canvas, origin(ghost));
    final pen = Paint()
      ..color = C.teal
      ..strokeWidth = _penWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) {
      if (s.length == 1) {
        canvas.drawCircle(s.first, 6, pen..style = PaintingStyle.fill);
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
