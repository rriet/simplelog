import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

import 'language_menu.dart';

class BaseScaffold extends ConsumerWidget {
  const BaseScaffold({
    super.key,
    required this.body,
    this.drawer,
  });

  final Widget body;
  final Widget? drawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: const [
          LanguageMenu(),
        ],
      ),
      drawer: drawer,
      body: body,
    );
  }
}
