import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simplelog/presentation/database/widgets/database_sync_trigger.dart';

/// Simple wrapper screen exposing database sync and management tools.
class DatabaseScreen extends ConsumerWidget {
  /// Creates the database tools screen.
  const DatabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DatabaseSyncTrigger();
  }
}
