import 'package:flutter/material.dart';

import '../data/phrases.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';

/// Narrated first run: welcome, then a local profile (first name or avatar
/// only — no email, no password).
class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int _page = 0;
  int _avatar = 0;
  final _name = TextEditingController();

  static const _welcome = P.welcome;
  static const _profile = P.profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _page == 0 ? _buildWelcome(context) : _buildProfile(context),
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(20),
      children: [
        const Align(alignment: Alignment.centerRight, child: LangToggle()),
        const SizedBox(height: 12),
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              colors: [C.tealSoft, C.magentaSoft],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(children: [
            const Center(child: Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 48), child: BonbonLogo(size: 170))),
            Positioned(
              left: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                child: Row(children: [
                  const Icon(Icons.favorite_border_rounded, color: C.magenta, size: 20),
                  const SizedBox(width: 6),
                  Text(context.tr('Cercle d\'apprentissage', 'Learning circle'),
                      style: const TextStyle(color: C.teal, fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        Text(context.tr('Bienvenue à Bonbon !', 'Welcome to Bonbon!'),
            textAlign: TextAlign.center, style: t.headlineLarge?.copyWith(color: C.tealDark)),
        const SizedBox(height: 8),
        Text(context.tr('Apprenons à lire et à écrire ensemble, pas à pas.', 'Let\'s learn to read and write together, step by step.'),
            textAlign: TextAlign.center, style: t.bodyLarge?.copyWith(color: C.inkSoft)),
        const SizedBox(height: 28),
        Center(
          child: Panel(
            padding: const EdgeInsets.fromLTRB(10, 10, 24, 10),
            onTap: () => context.app.say(_welcome),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const SpeakButton(_welcome, size: 56),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(context.tr('Écouter', 'Listen'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: C.teal)),
                Text(context.tr('Français parlé', 'Spoken French'),
                    style: const TextStyle(fontSize: 15, color: C.inkSoft)),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 36),
        PressButton(
          label: context.tr('Suivant', 'Next'),
          icon: Icons.arrow_forward_rounded,
          onTap: () {
            setState(() => _page = 1);
            context.app.say(_profile);
          },
        ),
      ],
    );
  }

  Widget _buildProfile(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(20),
      children: [
        Row(children: [
          IconButton(
              onPressed: () => setState(() => _page = 0),
              icon: const Icon(Icons.arrow_back_rounded, size: 28)),
          const Spacer(),
          const LangToggle(),
          const SizedBox(width: 8),
          const SpeakButton(_profile),
        ]),
        const SizedBox(height: 8),
        Text(context.tr('Qui es-tu ?', 'Who are you?'), style: t.headlineLarge?.copyWith(color: C.tealDark)),
        const SizedBox(height: 6),
        Text(context.tr('Choisis ton image.', 'Choose your picture.'), style: t.bodyLarge?.copyWith(color: C.inkSoft)),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            for (var i = 0; i < avatarIcons.length; i++)
              GestureDetector(
                onTap: () => setState(() => _avatar = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: _avatar == i ? C.tealSoft : C.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _avatar == i ? C.teal : C.border, width: _avatar == i ? 3 : 1.5),
                  ),
                  child: Stack(children: [
                    Center(child: Avatar(i, size: 72)),
                    if (_avatar == i)
                      const Positioned(
                          right: 8, top: 8, child: Icon(Icons.check_circle_rounded, color: C.teal, size: 26)),
                  ]),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(context.tr('Ton prénom (facultatif)', 'Your first name (optional)'), style: t.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: _name,
          style: const TextStyle(fontSize: 20),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Amina',
            filled: true,
            fillColor: C.surface,
            prefixIcon: const Icon(Icons.person_outline_rounded),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: C.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: C.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: C.teal, width: 2.5)),
          ),
        ),
        const SizedBox(height: 32),
        PressButton.magenta(
          label: context.tr('Commencer', 'Start'),
          icon: Icons.play_arrow_rounded,
          onTap: () async {
            final app = context.app;
            await app.setProfile(_name.text, _avatar);
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));
          },
        ),
      ],
    );
  }
}
