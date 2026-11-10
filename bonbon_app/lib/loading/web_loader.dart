/// Hands the loading screen over from the web page to the app.
///
/// On the web, the floating-logo loading screen lives in web/index.html and
/// stays up from the moment the page opens until the app calls [hideWebLoader]
/// — one continuous animation, then a single fade into the app. Elsewhere
/// (Android) there is no web page, so these do nothing and the app draws
/// its own loading screen (lib/screens/splash.dart).
library;

export 'web_loader_stub.dart' if (dart.library.js_interop) 'web_loader_web.dart';
