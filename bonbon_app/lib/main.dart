import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/content.dart';
import 'screens/lesson_player.dart';
import 'screens/onboarding.dart';
import 'screens/shell.dart';
import 'screens/splash.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'widgets/common.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Root());
}

/// Shows the floating-logo loading screen straight away, loads everything
/// the app needs, then fades into the app.
class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  AppState? _state;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final results = await Future.wait([
        ContentRepo.load(),
        SharedPreferences.getInstance(),
        Speech.load(),
        // Fonts and the logo, so the first screen doesn't flash in a fallback font.
        GoogleFonts.pendingFonts([GoogleFonts.plusJakartaSans(), GoogleFonts.playwriteFrModerne()])
            .catchError((_) => const <void>[]),
        // Keep the logo up long enough to read as a loading screen, not a flicker.
        Future<void>.delayed(const Duration(milliseconds: 900)),
      ]);
      final state = AppState(results[0] as ContentRepo, results[1] as SharedPreferences, results[2] as Speech);
      _devStart = _devHome(state); // once, before the app's first frame
      if (mounted) setState(() => _state = state);
    } catch (e) {
      debugPrint('startup failed: $e');
      if (mounted) setState(() => _error = "Bonbon n'a pas pu démarrer. Touche pour réessayer.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: state == null
            ? SplashScreen(key: const ValueKey('splash'), error: _error, onRetry: _load)
            : AppScope(key: const ValueKey('app'), state: state, child: const BonbonApp()),
      ),
    );
  }
}

Widget? _devStart;

/// Debug builds only: `?lesson=L08&step=3` or `?tab=1` opens a screen
/// directly, for screenshots and QA.
Widget? _devHome(AppState app) {
  if (!kDebugMode && !const bool.fromEnvironment('DEV_ROUTES')) return null;
  final q = Uri.base.queryParameters;
  if (q.isEmpty) return null;
  if (!app.onboarded) app.setProfile('Amina', 0);
  if (q['lang'] != null) app.setEnglish(q['lang'] == 'en');
  final done = int.tryParse(q['done'] ?? '') ?? 0;
  for (final l in app.repo.lessons.take(done)) {
    if (!app.isDone(l)) app.completeLesson(l);
  }
  final lesson = q['lesson'] == null ? null : app.repo.byKey(q['lesson']!);
  if (lesson != null) {
    app.saveStep(lesson, int.tryParse(q['step'] ?? '') ?? 0);
    return LessonPlayer(lesson: lesson);
  }
  if (q['tab'] != null) return Shell(initialTab: int.tryParse(q['tab']!) ?? 0);
  return null;
}

class BonbonApp extends StatelessWidget {
  const BonbonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return MaterialApp(
      title: 'Bonbon',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // Phone-first layout: on a wide browser window, centre a phone-width column.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return ColoredBox(
          color: const Color(0xFFEDE7DD),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: MediaQuery(
                data: mq.copyWith(textScaler: TextScaler.linear(app.largeText ? 1.15 : 1.0)),
                child: ClipRect(child: MissingAudioBanner(child: child!)),
              ),
            ),
          ),
        );
      },
      home: _devStart ?? (app.onboarded ? const Shell() : const Onboarding()),
    );
  }
}
