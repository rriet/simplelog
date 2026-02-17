import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simplelog/presentation/shared/widgets/collapsible_scaffold.dart';
import 'package:simplelog/presentation/shared/widgets/large_scaffold.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 840;

        if (isCompact) {
          return const CollapsibleScaffold();
        }

        return const LargeScaffold();
      },
    );
  }
}
