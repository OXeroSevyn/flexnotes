import 'dart:html' as html;

class WebStorage {
  static Future<void> save(String key, String value) async {
    html.window.localStorage[key] = value;
  }
  static Future<String?> load(String key) async {
    return html.window.localStorage[key];
  }
}
