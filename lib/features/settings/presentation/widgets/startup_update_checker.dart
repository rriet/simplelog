import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/features/settings/presentation/widgets/update_dialog.dart';
import 'package:simplelog/state/providers/update_check_preferences_provider.dart';
import 'package:simplelog/state/providers/update_checker_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Listens for available updates on startup and shows a dialog.
///
/// Place this widget once near the top of the widget tree (inside
/// [MaterialApp.home]) so it only runs once per app lifecycle.
class StartupUpdateChecker extends ConsumerStatefulWidget {
  /// Creates a startup update checker.
  const StartupUpdateChecker({required this.child, super.key});

  /// The child widget tree.
  final Widget child;

  @override
  ConsumerState<StartupUpdateChecker> createState() =>
      _StartupUpdateCheckerState();
}

class _StartupUpdateCheckerState
    extends ConsumerState<StartupUpdateChecker> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    final update =
        ref.watch(latestUpdateProvider).valueOrNull;

    if (!_dialogShown && update != null) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          showUpdateDialog(
            context,
            update: update,
            onSkip: () {
              unawaited(
                ref
                    .read(skippedVersionProvider.notifier)
                    .skip(update.latestVersion),
              );
            },
            onDownload: () {
              final url = update.downloadUrl ??
                  update.releasePageUrl;
              if (url != null) {
                final uri = Uri.parse(url);
                unawaited(
                  launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  ),
                );
              }
            },
          ),
        );
      });
    }

    return widget.child;
  }
}
