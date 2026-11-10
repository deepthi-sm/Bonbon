import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Whether web/index.html put its loading screen up (it defines bonbonReady).
bool get hasWebLoader => globalContext.has('bonbonReady');

/// Fades out the web-page loading screen (see bonbonReady in web/index.html).
void hideWebLoader() {
  if (hasWebLoader) globalContext.callMethod('bonbonReady'.toJS);
}
