import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Wraps a subtree so that if its `builder` throws during build (a null
/// value slipping through, a bad cast from a malformed API/cache record,
/// etc.), the app shows a small graceful fallback instead of the raw
/// exception text or a broken screen. This does not hide bugs — every
/// caught exception is still logged with `debugPrint` (and shows up in
/// `flutter run` / Logcat / Xcode console) so it stays fixable, it just
/// keeps one bad item from taking down the whole list/screen for the
/// end user.
class SafeBuild extends StatelessWidget {
  const SafeBuild({super.key, required this.builder, this.fallback, this.label});

  final WidgetBuilder builder;
  final Widget? fallback;

  /// Optional short tag included in the debug log, e.g. the item id,
  /// so a report from a tester ("crash on the mountain list") is easy
  /// to trace back to the exact widget that failed.
  final String? label;

  @override
  Widget build(BuildContext context) {
    try {
      return builder(context);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('SafeBuild caught${label != null ? ' [$label]' : ''}: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      return fallback ?? const SizedBox.shrink();
    }
  }
}
