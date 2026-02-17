import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simplelog/state/aircraft_state.dart';
import 'package:simplelog/state/providers/navigation_provider.dart';
import 'app_drawer.dart';
import 'base_scaffold.dart';

class LargeScaffold extends ConsumerWidget {
  const LargeScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedScreenProvider);

    return BaseScaffold(
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: AppDrawer(
              selected: selected,
              onSelected: (screen) =>
                  ref.read(selectedScreenProvider.notifier).state = screen,
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
