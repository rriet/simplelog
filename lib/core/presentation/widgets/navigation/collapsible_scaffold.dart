import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/navigation/app_drawer.dart';
import 'package:simplelog/core/presentation/widgets/navigation/base_scaffold.dart';
import 'package:simplelog/state/aircraft_state.dart';
import 'package:simplelog/state/providers/batch_write_guard_provider.dart';
import 'package:simplelog/state/providers/navigation_provider.dart';

/// Scaffold used on compact layouts with a collapsible navigation drawer.
class CollapsibleScaffold extends ConsumerWidget {
  /// Creates the collapsible navigation scaffold.
  const CollapsibleScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedScreenProvider);
    final isBatchWriteInProgress = ref.watch(isBatchWriteInProgressProvider);

    return BaseScaffold(
      drawer: AppDrawer(
        selected: selected,
        onSelected: (screen) {
          if (isBatchWriteInProgress) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  )!.batchWriteNavigationBlockedMessage,
                ),
              ),
            );
            return;
          }
          ref.read(selectedScreenProvider.notifier).state = screen;
          Navigator.of(context).pop();
        },
      ),
      body: selected.build(),
    );
  }
}
