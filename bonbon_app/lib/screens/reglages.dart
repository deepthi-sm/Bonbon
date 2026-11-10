import 'package:flutter/material.dart';

import '../data/phrases.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'onboarding.dart';

class Reglages extends StatelessWidget {
  const Reglages({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final t = Theme.of(context).textTheme;
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      TopBar(page: context.tr('Réglages', 'Settings'), spoken: P.settings),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),
          Panel(
            child: Row(children: [
              Avatar(app.avatar, size: 60),
              const SizedBox(width: 14),
              Expanded(child: Text(app.name ?? '', style: t.headlineSmall)),
            ]),
          ),
          const SizedBox(height: 16),
          _Toggle(
            icon: Icons.translate_rounded,
            title: context.tr('Interface en anglais (test)', 'English interface (testing)'),
            spoken: null,
            value: app.english,
            onChanged: app.setEnglish,
          ),
          _Toggle(
            icon: Icons.slow_motion_video_rounded,
            title: context.tr('Voix lente', 'Slow voice'),
            spoken: P.slowVoice,
            value: app.slowVoice,
            onChanged: (v) {
              app.setSlowVoice(v);
              app.say(v ? P.slowOn : P.slowOff);
            },
          ),
          _Toggle(
            icon: Icons.gesture_rounded,
            title: context.tr('Écriture cursive par défaut', 'Cursive by default'),
            spoken: P.cursiveDefault,
            value: app.cursiveDefault,
            onChanged: app.setCursiveDefault,
          ),
          _Toggle(
            icon: Icons.format_size_rounded,
            title: context.tr('Grand texte', 'Large text'),
            spoken: P.largeText,
            value: app.largeText,
            onChanged: app.setLargeText,
          ),
          const SizedBox(height: 12),
          Text(context.tr('Pour l\'animatrice', 'For the facilitator'), style: t.labelLarge?.copyWith(color: C.inkSoft)),
          const SizedBox(height: 8),
          _Toggle(
            icon: Icons.lock_open_rounded,
            title: context.tr('Ouvrir toutes les leçons', 'Unlock all lessons'),
            spoken: P.unlockAll,
            value: app.unlockAll,
            onChanged: app.setUnlockAll,
          ),
          const SizedBox(height: 16),
          PressButton.ghost(
            label: context.tr('Effacer les progrès', 'Reset progress'),
            icon: Icons.restart_alt_rounded,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(context.tr('Tout effacer ?', 'Erase everything?')),
                  content: Text(context.tr('Le profil et les progrès seront effacés sur ce téléphone.',
                      'The profile and progress on this device will be erased.')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: Text(context.tr('Non', 'No'))),
                    FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(context.tr('Oui, effacer', 'Yes, erase'))),
                  ],
                ),
              );
              if (ok != true || !context.mounted) return;
              await app.resetAll();
              if (!context.mounted) return;
              Navigator.of(context, rootNavigator: true)
                  .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const Onboarding()), (_) => false);
            },
          ),
          const SizedBox(height: 24),
          Panel(
            color: C.tealSoft,
            borderColor: C.tealMid,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const BonbonLogo(size: 40),
                const SizedBox(width: 10),
                Text(context.tr('À propos', 'About'), style: t.labelLarge),
              ]),
              const SizedBox(height: 8),
              Text(
                context.tr(
                    'Bonbon suit le Syllabaire alphanumérique de la Fondation Batonga (2ᵉ édition) : '
                        '56 leçons et les chiffres de 0 à 9.',
                    'Bonbon follows the Batonga Foundation\'s Syllabaire alphanumérique (2nd edition): '
                        '56 lessons and the digits 0 to 9.'),
                style: t.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(
                '${context.tr('Clips audio', 'Audio clips')} : ${app.speech.clipCount}',
                style: t.bodySmall,
              ),
            ]),
          ),
        ]),
      ),
    ]);
  }
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? spoken;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({
    required this.icon,
    required this.title,
    required this.spoken,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Panel(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          onTap: () => onChanged(!value),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: C.tealSoft, shape: BoxShape.circle),
              child: Icon(icon, color: C.teal),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
            if (spoken != null) SpeakButton(spoken!, size: 40, filled: false),
            const SizedBox(width: 8),
            Switch(value: value, onChanged: onChanged),
          ]),
        ),
      );
}
