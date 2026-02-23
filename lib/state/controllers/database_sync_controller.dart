import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Reads database metadata needed by sync/import UI.
class DatabaseSyncController extends Notifier<void> {
  @override
  void build() {}

  /// Returns the current local schema version.
  int schemaVersion() {
    final db = ref.read(databaseProvider);
    return db.schemaVersion;
  }
}
