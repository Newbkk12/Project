import 'dart:html' as html show window;

String? getLocalStorageItem(String key) {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return null;
  }
}

void setLocalStorageItem(String key, String value) {
  try {
    html.window.localStorage[key] = value;
  } catch (_) {}
}
