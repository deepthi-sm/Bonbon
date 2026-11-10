import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

extension AppX on BuildContext {
  AppState get app => AppScope.of(this);

  /// Interface text in French, or English when the debug language toggle is on.
  /// Lesson content and the voice always stay French.
  String tr(String fr, String en) => app.english ? en : fr;
}

/// Small FR/EN switch for the interface language.
class LangToggle extends StatelessWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Semantics(
      button: true,
      label: 'Langue / Language',
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => app.setEnglish(!app.english),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: C.border, width: 1.5),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(app.english ? 'EN' : 'FR',
                style: const TextStyle(fontWeight: FontWeight.w800, color: C.teal, fontSize: 14)),
          ),
        ),
      ),
    );
  }
}

/// Shows which sentence has no recorded clip, so gaps in the audio pack are
/// visible during testing instead of silently doing nothing.
class MissingAudioBanner extends StatefulWidget {
  final Widget child;
  const MissingAudioBanner({super.key, required this.child});

  @override
  State<MissingAudioBanner> createState() => _MissingAudioBannerState();
}

class _MissingAudioBannerState extends State<MissingAudioBanner> {
  String? _text;
  int _gen = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final n = context.app.speech.missing;
    n.removeListener(_onMissing);
    n.addListener(_onMissing);
  }

  void _onMissing() {
    final t = context.app.speech.missing.value;
    if (t == null || !mounted) return;
    final g = ++_gen;
    setState(() => _text = t);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && g == _gen) setState(() => _text = null);
    });
    context.app.speech.missing.value = null;
  }

  @override
  Widget build(BuildContext context) => Stack(children: [
        widget.child,
        if (_text != null)
          Positioned(
            left: 16,
            right: 16,
            top: 8,
            child: SafeArea(
              child: Material(
                color: C.ink,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    const Icon(Icons.volume_off_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${context.tr('Pas encore d\'audio', 'No audio clip yet')} : « $_text »',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
      ]);
}

/// Tactile "physical button": solid darker bottom edge that compresses on press.
class PressButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final Color edge;
  final Color fg;
  final bool expand;
  final bool outlined;

  const PressButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.color = C.teal,
    this.edge = C.tealDark,
    this.fg = Colors.white,
    this.expand = true,
    this.outlined = false,
  });

  const PressButton.magenta({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.expand = true,
  })  : color = C.magenta,
        edge = C.magentaDark,
        fg = Colors.white,
        outlined = false;

  const PressButton.ghost({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.expand = true,
  })  : color = C.surface,
        edge = C.tealMid,
        fg = C.teal,
        outlined = true;

  @override
  State<PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<PressButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final edge = _down ? 1.0 : 4.0;
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      margin: EdgeInsets.only(top: 4 - edge),
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: enabled ? widget.color : C.locked,
        borderRadius: BorderRadius.circular(999),
        border: Border(
          bottom: BorderSide(color: enabled ? widget.edge : C.border, width: edge),
          top: widget.outlined ? BorderSide(color: widget.edge, width: 2) : BorderSide.none,
          left: widget.outlined ? BorderSide(color: widget.edge, width: 2) : BorderSide.none,
          right: widget.outlined ? BorderSide(color: widget.edge, width: 2) : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: enabled ? widget.fg : C.inkSoft, size: 24),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: enabled ? widget.fg : C.inkSoft,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: MouseRegion(
            cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer, child: child),
      ),
    );
  }
}

/// Round speaker button. Speaks [text]; pulses while that text is playing.
class SpeakButton extends StatelessWidget {
  final String text;
  final double size;
  final bool filled;
  final bool counts;

  const SpeakButton(this.text, {super.key, this.size = 48, this.filled = true, this.counts = false});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return ValueListenableBuilder<String?>(
      valueListenable: app.speech.speaking,
      builder: (context, now, _) {
        final active = now == text;
        return Semantics(
          button: true,
          label: context.tr('Écouter', 'Listen'),
          child: InkResponse(
            onTap: () => app.say(text, counts: counts),
            radius: size / 2 + 6,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? (active ? C.magentaDark : C.magenta) : C.magentaSoft,
                boxShadow: active
                    ? [BoxShadow(color: C.magenta.withValues(alpha: 0.35), blurRadius: 0, spreadRadius: 6)]
                    : null,
              ),
              child: Icon(active ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                  color: filled ? Colors.white : C.magenta, size: size * 0.5),
            ),
          ),
        );
      },
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = C.surface,
    this.borderColor = C.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x0F1F2937), offset: Offset(0, 2), blurRadius: 4)],
      ),
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(24), onTap: onTap, child: box),
    );
  }
}

/// The Bonbon logo, from assets/brand/logo.png (the single source for the
/// in-app logo; tool/make_icons.py makes the browser and launcher icons from
/// the same file). Until that file exists, a drawn placeholder is shown.
class BonbonLogo extends StatelessWidget {
  final double size;
  const BonbonLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size * 1.12, // the logo is slightly wider than tall
        height: size,
        child: Image.asset(
          'assets/brand/logo.png',
          filterQuality: FilterQuality.medium,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _placeholder(),
        ),
      );

  Widget _placeholder() => SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          Positioned(
              bottom: 0, child: Icon(Icons.auto_stories_rounded, color: C.teal, size: size * 0.78)),
          Positioned(top: 0, child: Icon(Icons.spa_rounded, color: C.magenta, size: size * 0.55)),
        ]),
      );
}

const avatarIcons = [
  Icons.face_3_rounded,
  Icons.face_4_rounded,
  Icons.face_2_rounded,
  Icons.face_6_rounded,
  Icons.face_5_rounded,
  Icons.face_rounded,
];
const avatarColors = [C.teal, C.magenta, C.goldDeep, Color(0xFF6D28D9), Color(0xFF0369A1), Color(0xFF9F1239)];

class Avatar extends StatelessWidget {
  final int index;
  final double size;
  const Avatar(this.index, {super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final c = avatarColors[index % avatarColors.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.withValues(alpha: 0.14),
        border: Border.all(color: c, width: 2.5),
      ),
      child: Icon(avatarIcons[index % avatarIcons.length], color: c, size: size * 0.62),
    );
  }
}

/// Top bar used on every tab: logo, page name, speaker, avatar.
class TopBar extends StatelessWidget {
  final String page;
  final String spoken;
  const TopBar({super.key, required this.page, required this.spoken});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(children: [
        const BonbonLogo(size: 46),
        const SizedBox(width: 8),
        const Text('Bonbon',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.teal)),
        // The page name is not shown (the bottom bar already marks the tab);
        // it stays available to screen readers.
        Expanded(child: Semantics(header: true, label: page, child: const SizedBox.shrink())),
        const LangToggle(),
        const SizedBox(width: 8),
        SpeakButton(spoken, size: 44),
        const SizedBox(width: 8),
        Avatar(context.app.avatar, size: 40),
      ]),
    );
  }
}

/// Toggle between print (scripte) and cursive.
class ScriptToggle extends StatelessWidget {
  final bool cursive;
  final ValueChanged<bool> onChanged;
  const ScriptToggle({super.key, required this.cursive, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool value, TextStyle style) {
      final on = cursive == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? C.teal : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label, style: style.copyWith(color: on ? Colors.white : C.teal)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: C.tealSoft, borderRadius: BorderRadius.circular(999)),
      child: Row(children: [
        seg(context.tr('scripte', 'print'), false, const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        seg('cursive', true, cursiveStyle(16, C.teal)),
      ]),
    );
  }
}

/// Renders [text] in print or cursive.
class ScriptText extends StatelessWidget {
  final String text;
  final bool cursive;
  final double size;
  final Color color;
  final FontWeight weight;
  final TextAlign align;

  const ScriptText(this.text,
      {super.key,
      required this.cursive,
      this.size = 26,
      this.color = C.ink,
      this.weight = FontWeight.w700,
      this.align = TextAlign.start});

  @override
  Widget build(BuildContext context) => Text(text,
      textAlign: align,
      style: cursive
          ? cursiveStyle(size * 0.82, color)
          : TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.3));
}

TextStyle cursiveStyle(double size, Color color) => cursive(size, color: color);

class SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, required this.icon, this.trailing});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: C.teal, size: 26),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.headlineSmall)),
        ?trailing,
      ]);
}
