# Bonbon — Flutter prototype

Literacy app for the Fondation Batonga *Syllabaire alphanumérique* (2ᵉ édition):
56 lessons + digits 0–9, French UI, offline progress on the device.

## Run locally

Flutter SDK is at `C:\src\flutter` (the `flutter` on PATH is stale).

```powershell
cd C:\Users\josep\Desktop\projects\Bonbon\bonbon_app
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\flutter.bat run -d chrome          # dev, hot reload
```

Hosted build (what testers should use):

```powershell
C:\src\flutter\bin\flutter.bat build web
python tool\serve.py            # http://localhost:8080, caching off so a reload shows the new build
python tool\serve.py 8080 --lan # also reachable from a phone on the same Wi-Fi: http://<PC-IP>:8080
```

Android: `flutter.bat build apk` (needs the Android SDK).

## Deploying (Vercel)

Live site: **https://bonbon-phi.vercel.app**

Every push to `main` on https://github.com/deepthi-sm/Bonbon deploys automatically. Vercel runs
`bonbon_app/tool/vercel_build.sh` (see `vercel.json` at the repository root), which installs Flutter 3.47.5
and builds the web app. A deploy takes about 3–5 minutes; follow it on the Vercel dashboard.
Pushes to other branches create preview links; `dev/*` and `develop` don't deploy.

## Logo

The logo lives in one file: `assets/brand/logo.png` (transparent PNG, square-ish, at least 512 px).
The top bar, welcome screen and settings read it directly. For the browser tab icon and the
Android/installed-app icons, run once after replacing it:

```powershell
python tool\make_icons.py
```

## Voice recordings

The app speaks only with the team's own recordings, bundled in `assets/audio/`, so it works with no
internet. There is no browser or device voice. A sentence with no recording stays silent and shows a black
"Pas encore d'audio" banner naming the sentence.

```powershell
C:\src\flutter\bin\flutter.bat test test/export_utterances_test.dart   # list every sentence -> tool/utterances.json
python tool\audio.py script     # -> tool/recording-script.csv: lesson, file name, text, recorded?
#   record each line; save it as <file>.mp3 / .m4a / .wav / .ogg in assets\audio\ (one folder, no subfolders)
python tool\audio.py manifest   # -> assets/audio/manifest.json, and a report of what is still missing
C:\src\flutter\bin\flutter.bat build web                               # rebuild so the clips are bundled
```

File names come from the sentence itself, so they don't change when lessons are added. Re-run the
export after editing content or `lib/data/phrases.dart`; new lines appear in the script with empty "recorded".
Recording tips: one quiet room, the same phone and distance, mono, trim the silence at both ends.

## Interface language

The FR/EN pill in the top bar (also in Réglages) switches the interface text to English for testing.
Lesson content and the voice stay French.

## QA shortcuts

In debug builds, or a web build made with `--dart-define=DEV_ROUTES=true`:

- `?lesson=L08&step=3` opens a lesson at a given step (`N3` = digit 3)
- `?tab=1&done=9` opens a tab with the first 9 lessons marked done; add `&lang=en` for English

*Réglages → Ouvrir toutes les leçons* unlocks the whole path.

## Structure

- `assets/content/` is copied verbatim from `Batonga-Content-Engine/packages/content/content`
  (schema v1.0.2). Don't hand-edit it; fixes go through the content engine.
- `assets/images/` holds the 24 illustrations and 44 cursive glyphs extracted from the book.
- `lib/data/content.dart` loads lessons, digits, alphabet and assets.
- `lib/screens/lesson_player.dart` turns each lesson's blocks into steps, one renderer per block type.
- `lib/screens/activities.dart` generates the exercises (find the letter, listen and choose)
  only from the lesson's own items, plus letters already taught.
- `lib/screens/atelier.dart` holds the alphabet wall, digits and the tracing canvas, which
  scores coverage of the letter and how well the ink stays on it.
- `lib/state/app_state.dart` holds the profile, progress, streak and settings
  (shared_preferences) and the voice.

## Prototype limits

- No recordings yet: the app is silent until the team records the script (see above). For single
  letters, decide with Batonga whether to record the letter's sound (/t/) or its name (té).
- Tracing accepts strokes in any direction and order; it checks how well the shape is covered.
- No comprehension questions, placement test or spaced review yet (plan §U–§W).
- Fonts (Plus Jakarta Sans, Playwrite FR Moderne) are fetched from Google Fonts on first
  load. Bundle them before any offline field test.
