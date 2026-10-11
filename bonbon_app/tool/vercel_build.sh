#!/usr/bin/env bash
# Builds the Bonbon web app on Vercel's build servers, which have no Flutter.
# Called from the repository's vercel.json; Vercel serves bonbon_app/build/web.
# Pinned to the Flutter version used locally so builds match.
set -euo pipefail

FLUTTER_VERSION=3.47.5
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FLUTTER_DIR="$ROOT/.flutter-sdk"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "Installing Flutter $FLUTTER_VERSION..."
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --no-analytics --enable-web >/dev/null
flutter --version

cd "$ROOT/bonbon_app"
flutter pub get
# DEV_ROUTES keeps the reviewer shortcuts (?lesson=L08&step=3, ?tab=1&lang=en).
flutter build web --release --dart-define=DEV_ROUTES=true
