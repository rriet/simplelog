import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

import 'package:simplelog/presentation/shared/widgets/language_menu.dart';

/// Shared scaffold for top‑level screens with a 
/// localized title and language menu.
class BaseScaffold extends ConsumerWidget {
  /// Creates a scaffold with the given [body] and optional [drawer].
  const BaseScaffold({
    required this.body,
    super.key,
    this.drawer,
  });

  /// Main content of the page.
  final Widget body;

  /// Optional navigation drawer.
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
