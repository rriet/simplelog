import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/database_sync_controller.dart';

/// Provides [DatabaseSyncController] actions for database UI.
final databaseSyncControllerProvider =
    NotifierProvider<DatabaseSyncController, void>(
      DatabaseSyncController.new,
    );
