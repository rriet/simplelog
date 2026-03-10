import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simplelog/core/presentation/widgets/navigation/collapsible_scaffold.dart';
import 'package:simplelog/core/presentation/widgets/navigation/large_scaffold.dart';

/// Chooses between compact and large layouts for the main home screen.
class MyHomePage extends ConsumerWidget {
  /// Creates the responsive home page.
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 980;

        if (isCompact) {
          return const CollapsibleScaffold();
        }

        return const LargeScaffold();
      },
    );
  }
}
