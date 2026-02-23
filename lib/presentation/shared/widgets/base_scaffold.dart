import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

import 'package:simplelog/presentation/shared/widgets/language_menu.dart';

/// Public API documentation.
class BaseScaffold extends ConsumerWidget {
  /// Public API documentation.
  const BaseScaffold({
    required this.body,
    super.key,
    this.drawer,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final Widget body;
  /// Public API documentation.
  final Widget? drawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final drawerTitleStyle = theme.textTheme.titleLarge;
    final menuBackground = theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: menuBackground,
        surfaceTintColor: menuBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.homeTitle,
          style: drawerTitleStyle?.copyWith(
            fontSize: 18,
            color: drawerTitleStyle.color,
          ),
        ),
        actions: const [
          LanguageMenu(),
        ],
      ),
      drawer: drawer,
      body: body,
    );
  }
}
