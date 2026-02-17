import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/database_sync_controller.dart';

final databaseSyncControllerProvider =
    NotifierProvider<DatabaseSyncController, void>(
  DatabaseSyncController.new,
);
