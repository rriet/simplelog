import 'package:flutter/foundation.dart';

/// Temporary debug logger for edit-screen lifecycle tracking.
///
/// Keep this helper while investigating leaks, then remove once validated.
class EditScreenLifecycleLogger {
  const EditScreenLifecycleLogger._();

  /// Logs an edit screen `initState` with a stable state identity hash.
  static void onInit({
    required String screen,
    required Object state,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    if (!kDebugMode) return;
    final detailsText = _formatDetails(details);
    debugPrint(
      '[LIFECYCLE][${DateTime.now().toUtc().toIso8601String()}] '
      '$screen initState state#${identityHashCode(state)}$detailsText',
    );
  }

  /// Logs an edit screen `dispose` with a stable state identity hash.
  static void onDispose({
    required String screen,
    required Object state,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    if (!kDebugMode) return;
    final detailsText = _formatDetails(details);
    debugPrint(
      '[LIFECYCLE][${DateTime.now().toUtc().toIso8601String()}] '
      '$screen dispose state#${identityHashCode(state)}$detailsText',
    );
  }

  static String _formatDetails(Map<String, Object?> details) {
    if (details.isEmpty) return '';
    final parts = details.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join(', ');
    return ' [$parts]';
  }
}
