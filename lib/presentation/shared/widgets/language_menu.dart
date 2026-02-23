import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

import 'package:simplelog/state/providers/locale_provider.dart';

/// App bar language selection menu.
class LanguageMenu extends ConsumerWidget {
  /// Creates the language menu.
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return PopupMenuButton<Locale?>(
      tooltip: l10n.languageLabel,
      icon: const Icon(Icons.language),
      initialValue: currentLocale,
      onSelected: (value) => ref.read(localeProvider.notifier).state = value,
      itemBuilder: (context) => [
        PopupMenuItem<Locale?>(
          child: Text(l10n.languageSystem),
        ),
        PopupMenuItem<Locale?>(
          value: const Locale('en'),
          child: Text(l10n.languageEnglish),
        ),
        PopupMenuItem<Locale?>(
          value: const Locale('es'),
          child: Text(l10n.languageSpanish),
        ),
        PopupMenuItem<Locale?>(
          value: const Locale('lv'),
          child: Text(l10n.languageLatvian),
        ),
      ],
    );
  }
}
