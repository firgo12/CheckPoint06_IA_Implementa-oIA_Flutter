// Web implementation that registers an HtmlElementView factory using
// `window.flutterPlatformViewRegistry.registerViewFactory` via JS interop.
// This file is only imported on web builds via conditional import.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js_util' as js_util;

/// Registers a platform view factory for [viewType].
void registerWebViewFactory(String viewType, dynamic Function(int) factory) {
  try {
    final registry = js_util.getProperty(html.window, 'flutterPlatformViewRegistry');
    if (registry != null) {
      // Wrap the Dart factory to a JS function using allowInterop.
      final jsFactory = js_util.allowInterop((int viewId) {
        return factory(viewId);
      });
      js_util.callMethod(registry, 'registerViewFactory', [viewType, jsFactory]);
    }
  } catch (e) {
    // registration is web-only; ignore failures
  }
}
