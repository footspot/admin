import 'package:flutter/services.dart';

/// Copies sensitive text to the clipboard.
///
/// On Android 13+ (API 33) the clip is flagged sensitive so the system
/// clipboard-preview popup hides the value (shows ••• instead of plaintext).
/// On iOS / older Android it falls back to a plain [Clipboard.setData].
///
/// Note: this only suppresses the OS preview/history — the destination app
/// you paste into still receives the real value.
class SecureClipboard {
  static const _ch = MethodChannel('app/secure_clipboard');

  static Future<void> copy(String value) async {
    try {
      await _ch.invokeMethod('copySensitive', {'text': value});
    } on MissingPluginException {
      // * iOS / older Android: no sensitive flag available, plain copy.
      await Clipboard.setData(ClipboardData(text: value));
    } on PlatformException {
      await Clipboard.setData(ClipboardData(text: value));
    }
  }
}
