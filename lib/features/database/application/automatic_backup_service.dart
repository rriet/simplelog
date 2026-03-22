import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/user_settings_json.dart';

/// Persisted options for automatic database backups.
class AutomaticBackupSettings {
  /// Creates backup settings.
  const AutomaticBackupSettings({
    required this.enabled,
    required this.destinationFolder,
    required this.maxVersions,
  });

  /// Whether automatic backup is enabled.
  final bool enabled;

  /// Absolute destination folder path.
  final String destinationFolder;

  /// Maximum number of backups to keep.
  final int maxVersions;

  /// Creates a modified copy.
  AutomaticBackupSettings copyWith({
    bool? enabled,
    String? destinationFolder,
    int? maxVersions,
  }) {
    return AutomaticBackupSettings(
      enabled: enabled ?? this.enabled,
      destinationFolder: destinationFolder ?? this.destinationFolder,
      maxVersions: maxVersions ?? this.maxVersions,
    );
  }

  /// Default settings: disabled until user configures destination.
  static const defaults = AutomaticBackupSettings(
    enabled: false,
    destinationFolder: '',
    maxVersions: 10,
  );
}

/// Creates and prunes automatic backups when the database changes.
class AutomaticBackupService {
  AutomaticBackupService._();

  /// Singleton instance.
  static final instance = AutomaticBackupService._();

  static const _settingsKey = 'database.automatic_backup';
  static const _enabledKey = 'enabled';
  static const _destinationFolderKey = 'destinationFolder';
  static const _maxVersionsKey = 'maxVersions';
  static const _filePrefix = 'simplelog-auto-backup-';

  AppDatabase? _db;
  UserSettingsJsonStore? _store;
  StreamSubscription<Set<TableUpdate>>? _tableUpdateSubscription;
  bool _isDirty = false;

  /// Initializes service and drift table update subscription.
  void init(AppDatabase db) {
    if (identical(_db, db)) {
      return;
    }
    unawaited(_tableUpdateSubscription?.cancel());
    _db = db;
    _store = UserSettingsJsonStore(db);
    _tableUpdateSubscription = db
        .tableUpdates(TableUpdateQuery.onAllTables(db.allTables))
        .listen((_) {
          _isDirty = true;
        });
  }

  /// Loads current automatic backup settings from DB settings JSON.
  Future<AutomaticBackupSettings> loadSettings() async {
    final store = _store;
    if (store == null) {
      return AutomaticBackupSettings.defaults;
    }
    final settings = await store.load();
    final raw = settings[_settingsKey];
    if (raw is! Map) {
      return AutomaticBackupSettings.defaults;
    }
    final enabled = raw[_enabledKey] == true;
    final destinationFolder =
        (raw[_destinationFolderKey] ?? '').toString().trim();
    final maxVersionsRaw = raw[_maxVersionsKey];
    final maxVersions = () {
      if (maxVersionsRaw is int) {
        return maxVersionsRaw;
      }
      if (maxVersionsRaw is num) {
        return maxVersionsRaw.toInt();
      }
      if (maxVersionsRaw is String) {
        return int.tryParse(maxVersionsRaw) ??
            AutomaticBackupSettings.defaults.maxVersions;
      }
      return AutomaticBackupSettings.defaults.maxVersions;
    }();
    return AutomaticBackupSettings(
      enabled: enabled,
      destinationFolder: destinationFolder,
      maxVersions: maxVersions < 1 ? 1 : maxVersions,
    );
  }

  /// Persists automatic backup settings in DB settings JSON.
  Future<void> saveSettings(AutomaticBackupSettings next) async {
    final store = _store;
    if (store == null) {
      return;
    }
    await store.patch((settings) {
      settings[_settingsKey] = <String, dynamic>{
        _enabledKey: next.enabled,
        _destinationFolderKey: next.destinationFolder.trim(),
        _maxVersionsKey: next.maxVersions < 1 ? 1 : next.maxVersions,
      };
    });
  }

  /// Creates a backup when automatic backup is enabled and DB changed.
  Future<bool> createBackupIfDirty() async {
    final db = _db;
    if (db == null) {
      return false;
    }
    final settings = await loadSettings();
    if (!settings.enabled) {
      return false;
    }
    if (settings.destinationFolder.trim().isEmpty) {
      return false;
    }
    if (!_isDirty) {
      return false;
    }
    final destination = Directory(settings.destinationFolder);
    if (!destination.existsSync()) {
      await destination.create(recursive: true);
    }
    final bytes = await _readDatabaseBytes(db);
    final timestamp = _utcTimestampForFile(DateTime.now().toUtc());
    final filePath =
        '${destination.path}${Platform.pathSeparator}'
        '$_filePrefix$timestamp.sqlite';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    await _pruneBackups(
      directory: destination,
      maxVersions: settings.maxVersions,
    );
    _isDirty = false;
    return true;
  }

  String _utcTimestampForFile(DateTime value) {
    final yyyy = value.year.toString().padLeft(4, '0');
    final mm = value.month.toString().padLeft(2, '0');
    final dd = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    final ss = value.second.toString().padLeft(2, '0');
    return '$yyyy$mm${dd}T$hh$min${ss}Z';
  }

  Future<void> _pruneBackups({
    required Directory directory,
    required int maxVersions,
  }) async {
    final entities = directory.listSync(followLinks: false);
    final files = entities
        .whereType<File>()
        .where((file) {
          final name = file.uri.pathSegments.isEmpty
              ? file.path
              : file.uri.pathSegments.last;
          return name.startsWith(_filePrefix) && name.endsWith('.sqlite');
        })
        .toList(growable: false);
    if (files.length <= maxVersions) {
      return;
    }
    final sorted = files.toList(growable: false)
      ..sort((a, b) {
        final aModified = a.lastModifiedSync();
        final bModified = b.lastModifiedSync();
        return aModified.compareTo(bModified);
      });
    final toDelete = sorted.length - maxVersions;
    for (var i = 0; i < toDelete; i++) {
      await sorted[i].delete();
    }
  }

  Future<Uint8List> _readDatabaseBytes(AppDatabase db) async {
    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final path = await _databasePath();
    return File(path).readAsBytes();
  }

  Future<String> _databasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final currentPath = '${dir.path}/$appDatabaseFileName.sqlite';
    final legacyPath = '${dir.path}/simplelog.sqlite';
    if (File(currentPath).existsSync()) {
      return currentPath;
    }
    if (File(legacyPath).existsSync()) {
      return legacyPath;
    }
    return currentPath;
  }
}
