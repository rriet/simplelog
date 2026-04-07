import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns formatted app version and build from Flutter build env values.
///
/// These values are derived from `pubspec.yaml` (`version:`) by Flutter:
/// `FLUTTER_BUILD_NAME` and `FLUTTER_BUILD_NUMBER`.
final appVersionLabelProvider = Provider<String>((ref) {
  final version = const String.fromEnvironment('FLUTTER_BUILD_NAME').trim();
  final build = const String.fromEnvironment('FLUTTER_BUILD_NUMBER').trim();
  if (version.isEmpty && build.isEmpty) {
    return '';
  }
  if (build.isEmpty || build == version) {
    return version;
  }
  if (version.isEmpty) {
    return build;
  }
  return '$version+$build';
});
