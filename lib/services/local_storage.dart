// Conditional local storage interface. Uses browser localStorage on web,
// and an in-memory fallback on other platforms to avoid importing
// `dart:html` on non-web platforms.
export 'local_storage_stub.dart'
    if (dart.library.html) 'local_storage_web.dart';
