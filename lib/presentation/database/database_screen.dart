import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simplelog/presentation/database/widgets/database_sync_trigger.dart';

/// Public API documentation.
class DatabaseScreen extends ConsumerWidget {
  /// Public API documentation.
  const DatabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DatabaseSyncTrigger();
  }
}
