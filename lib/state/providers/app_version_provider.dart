import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Returns formatted app version and build from runtime package metadata.
final appVersionLabelProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  final version = info.version.trim();
  final build = info.buildNumber.trim();
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
