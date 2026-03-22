import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/navigation/app_drawer.dart';
import 'package:simplelog/core/presentation/widgets/navigation/base_scaffold.dart';
import 'package:simplelog/state/aircraft_state.dart';
import 'package:simplelog/state/providers/batch_write_guard_provider.dart';
import 'package:simplelog/state/providers/navigation_provider.dart';

/// Two-pane scaffold used on larger displays.
class LargeScaffold extends ConsumerWidget {
  /// Creates the large-screen scaffold.
  const LargeScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedScreenProvider);
    final isBatchWriteInProgress = ref.watch(isBatchWriteInProgressProvider);

    return BaseScaffold(
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: AppDrawer(
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
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selected.build(),
          ),
        ],
      ),
    );
  }
}
