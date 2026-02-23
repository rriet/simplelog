import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/presentation/shared/widgets/app_drawer.dart';
import 'package:simplelog/presentation/shared/widgets/base_scaffold.dart';
import 'package:simplelog/state/aircraft_state.dart';
import 'package:simplelog/state/providers/navigation_provider.dart';

/// Public API documentation.
class CollapsibleScaffold extends ConsumerWidget {
  /// Public API documentation.
  const CollapsibleScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedScreenProvider);

    return BaseScaffold(
      drawer: AppDrawer(
        selected: selected,
        onSelected: (screen) {
          ref.read(selectedScreenProvider.notifier).state = screen;
          Navigator.of(context).pop();
        },
      ),
      body: selected.build(),
    );
  }
}
