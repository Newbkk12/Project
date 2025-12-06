// Fallback in-memory storage for non-web platforms. This does not persist
// across app restarts but avoids importing `dart:html` on mobile/desktop.
final Map<String, String> _inMemory = <String, String>{};

String? getLocalStorageItem(String key) {
  return _inMemory[key];
}

void setLocalStorageItem(String key, String value) {
  _inMemory[key] = value;
}
