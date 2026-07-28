import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

const _githubOwner = 'rriet';
const _githubRepo = 'simplelog';
const _releasesUrl =
    'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest';

/// Cache duration for the last successful update check.
const _cacheDuration = Duration(hours: 3);

/// Result of checking for an available update.
class UpdateResult {
  /// Creates an [UpdateResult].
  const UpdateResult({
    required this.latestVersion,
    this.releaseNotes,
    this.downloadUrl,
    this.releasePageUrl,
  });

  /// Latest version tag (e.g. "1.2.0").
  final String latestVersion;

  /// Markdown release notes.
  final String? releaseNotes;

  /// Direct download URL for the platform binary.
  final String? downloadUrl;

  /// Browser URL to the GitHub release page.
  final String? releasePageUrl;
}

/// Single service that checks GitHub for app updates.
class UpdateService {
  /// Creates an [UpdateService] with an optional HTTP [client].
  UpdateService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  UpdateResult? _cachedResult;
  DateTime? _lastCheckTime;

  /// Reads the current app version from package metadata.
  Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version.trim();
  }

  /// Whether the platform is iOS (store build — skip check).
  bool get _isIos =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Checks GitHub Releases for a newer version.
  ///
  /// Returns `null` when:
  /// - [checkForUpdates] is `false`
  /// - Platform is iOS
  /// - Network error or non-200 response
  /// - Latest version ≤ current version
  ///
  /// The caller is responsible for handling skipped versions
  /// (e.g. still highlight in menu but suppress dialog).
  Future<UpdateResult?> checkForUpdate({
    required bool checkForUpdates,
  }) async {
    if (!checkForUpdates || _isIos) return null;

    // Return cached result if still fresh.
    if (_cachedResult != null &&
        _lastCheckTime != null &&
        DateTime.now().difference(_lastCheckTime!) < _cacheDuration) {
      return _cachedResult;
    }

    final currentVersion = await getCurrentVersion();

    try {
      final response = await _client.get(
        Uri.parse(_releasesUrl),
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'SimpleLog/$currentVersion',
        },
      );
      if (response.statusCode != 200) return null;

      final json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final rawTag =
          (json['tag_name'] as String?)?.trim() ?? '';
      if (rawTag.isEmpty) return null;

      final latestVersion =
          rawTag.startsWith('v') ? rawTag.substring(1) : rawTag;

      if (!_isNewerVersion(currentVersion, latestVersion)) {
        return null;
      }

      final body = json['body'] as String?;
      final htmlUrl = json['html_url'] as String?;
      final assets = json['assets'] as List<dynamic>?;

      final downloadUrl = _findPlatformAsset(
        assets: assets,
        releasePageUrl: htmlUrl,
      );

      final result = UpdateResult(
        latestVersion: latestVersion,
        releaseNotes: body,
        downloadUrl: downloadUrl,
        releasePageUrl: htmlUrl,
      );

      _cachedResult = result;
      _lastCheckTime = DateTime.now();

      return result;
    } on Exception catch (_) {
      return null;
    }
  }

  /// Returns `true` when [remote] is strictly newer than [local].
  bool _isNewerVersion(String local, String remote) {
    final localParts = _parseVersion(local);
    final remoteParts = _parseVersion(remote);

    for (var i = 0; i < 3; i++) {
      final l = i < localParts.length ? localParts[i] : 0;
      final r = i < remoteParts.length ? remoteParts[i] : 0;
      if (r > l) return true;
      if (r < l) return false;
    }
    return false;
  }

  /// Parses a version string into numeric segments.
  List<int> _parseVersion(String version) {
    return version.split('.').map((part) {
      final digits = part.replaceAll(RegExp('[^0-9]'), '');
      return int.tryParse(digits) ?? 0;
    }).toList();
  }

  /// Finds the download URL for the current platform from release assets.
  String? _findPlatformAsset({
    required List<dynamic>? assets,
    required String? releasePageUrl,
  }) {
    if (assets == null || assets.isEmpty) return releasePageUrl;

    if (kIsWeb) return releasePageUrl;

    final String assetPattern;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        assetPattern = 'windows';
      case TargetPlatform.macOS:
        assetPattern = 'mac';
      case TargetPlatform.linux:
        assetPattern = 'linux';
      case TargetPlatform.android:
        assetPattern = 'android';
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return releasePageUrl;
    }

    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) continue;
      final name = (asset['name'] as String? ?? '').toLowerCase();
      if (name.contains(assetPattern)) {
        return asset['browser_download_url'] as String? ??
            releasePageUrl;
      }
    }

    return releasePageUrl;
  }
}
