import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/providers/database_provider.dart';

class DatabaseSyncController extends Notifier<void> {
  @override
  void build() {}

  int schemaVersion() {
    final db = ref.read(databaseProvider);
    return db.schemaVersion;
  }
}
