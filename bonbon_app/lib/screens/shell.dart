import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'accueil.dart';
import 'atelier.dart';
import 'parcours.dart';
import 'progres.dart';
import 'reglages.dart';

class Shell extends StatefulWidget {
  final int initialTab;
  const Shell({super.key, this.initialTab = 0});

  static void goTo(BuildContext context, int tab) =>
      context.findAncestorStateOfType<_ShellState>()?.select(tab);

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late int _tab = widget.initialTab;

  void select(int i) => setState(() => _tab = i);

  static const _items = [
    (Icons.home_rounded, 'Accueil', 'Home'),
    (Icons.auto_stories_rounded, 'Leçons', 'Lessons'),
    (Icons.draw_rounded, 'Atelier', 'Practice'),
    (Icons.emoji_events_rounded, 'Progrès', 'Progress'),
    (Icons.settings_rounded, 'Réglages', 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Accueil(),
      const Parcours(),
      const Atelier(),
      const Progres(),
      const Reglages(),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: IndexedStack(index: _tab, children: pages)),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: C.surface,
          border: Border(top: BorderSide(color: C.border, width: 1.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 76,
            child: Row(children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => select(i),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: _tab == i ? C.teal : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Icon(_items[i].$1, color: _tab == i ? Colors.white : C.inkSoft, size: 26),
                      ),
                      const SizedBox(height: 4),
                      Text(context.app.english ? _items[i].$3 : _items[i].$2,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _tab == i ? FontWeight.w800 : FontWeight.w600,
                            color: _tab == i ? C.teal : C.inkSoft,
                          )),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
