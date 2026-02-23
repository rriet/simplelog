import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simplelog/presentation/shared/widgets/collapsible_scaffold.dart';
import 'package:simplelog/presentation/shared/widgets/large_scaffold.dart';

/// Public API documentation.
class MyHomePage extends ConsumerWidget {
  /// Public API documentation.
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
