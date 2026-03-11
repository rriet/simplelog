import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/reports_models.dart';
import 'package:simplelog/state/providers/database_provider.dart';

const _reportsPreferencesFileName = 'reports_preferences.json';
const _savedReportsQueriesFileName = 'saved_reports_queries.json';
const _reportsEventTypesFileName = 'reports_event_types.json';
const _reportsEventTypesSchemaVersion = 2;
const _selectedReportTemplateFileNameKey = 'selectedReportTemplateFileName';
const _openPdfAfterSavingKey = 'openPdfAfterSaving';

/// Whether reports should include previous experience totals.
final includePreviousExperienceProvider =
    NotifierProvider<IncludePreviousExperienceNotifier, bool>(
      IncludePreviousExperienceNotifier.new,
    );

/// Whether to include hours before the report range when computing totals.
final includeHoursBeforeProvider =
    NotifierProvider<IncludeHoursBeforeNotifier, bool>(
      IncludeHoursBeforeNotifier.new,
    );

/// Name of the last selected PDF template file.
final selectedReportTemplateFileNameProvider =
    NotifierProvider<SelectedReportTemplateFileNameNotifier, String?>(
      SelectedReportTemplateFileNameNotifier.new,
    );

/// Whether a generated PDF should be opened automatically after saving.
final openPdfAfterSavingProvider =
    NotifierProvider<OpenPdfAfterSavingNotifier, bool>(
      OpenPdfAfterSavingNotifier.new,
    );

/// Exposes pilot information used by PDF templates and report headers.
final reportPilotInfoProvider =
    NotifierProvider<ReportPilotInfoNotifier, ReportPilotInfo>(
      ReportPilotInfoNotifier.new,
    );

/// Pilot details printed on some report templates.
class ReportPilotInfo {
  /// Creates pilot information with optional default‑empty values.
  const ReportPilotInfo({
    this.name = '',
    this.licenses = '',
    this.address = '',
    this.signatureImage,
  });

  /// Builds a [ReportPilotInfo] instance from a database row.
  factory ReportPilotInfo.fromDatabaseRow(UserProfile row) {
    final settings = row.settingsJson;
    return ReportPilotInfo(
      name: (settings['name'] ?? '').toString(),
      licenses: (settings['licenses'] ?? '').toString(),
      address: (settings['address'] ?? '').toString(),
      signatureImage: row.signatureImage,
    );
  }

  /// Pilot name printed on reports.
  final String name;

  /// Licences printed on reports.
  final String licenses;

  /// Postal address printed on reports.
  final String address;

  /// Optional signature image bytes (PNG).
  final Uint8List? signatureImage;

  /// Returns a copy with some fields replaced.
  ReportPilotInfo copyWith({
    String? name,
    String? licenses,
    String? address,
    Uint8List? signatureImage,
    bool clearSignature = false,
  }) {
    return ReportPilotInfo(
      name: name ?? this.name,
      licenses: licenses ?? this.licenses,
      address: address ?? this.address,
      signatureImage: clearSignature
          ? null
          : (signatureImage ?? this.signatureImage),
    );
  }

  /// Backwards-compatible alias for old key names.
  String get licenceNumber => licenses;
}

/// Persists and exposes [ReportPilotInfo] via Riverpod.
class ReportPilotInfoNotifier extends Notifier<ReportPilotInfo> {
  @override
  ReportPilotInfo build() {
    unawaited(_ReportPilotInfoMigrationHelper.migrateIfNeeded(ref));
    unawaited(_load());
    return const ReportPilotInfo();
  }

  /// Updates the current state and writes it to disk.
  Future<void> setValue({required ReportPilotInfo value}) async {
    state = value;
    await _saveToDatabase(value);
  }

  /// Updates only the stored signature image.
  Future<void> setSignature(Uint8List? imageBytes) async {
    final next = state.copyWith(
      signatureImage: imageBytes,
      clearSignature: imageBytes == null,
    );
    state = next;
    await _saveToDatabase(next);
  }

  Future<void> _load() async {
    try {
      final db = ref.read(databaseProvider);
      final row = await db.select(db.userProfiles).getSingleOrNull();
      if (row != null) {
        state = ReportPilotInfo.fromDatabaseRow(row);
      }
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<void> _saveToDatabase(ReportPilotInfo value) async {
    try {
      final db = ref.read(databaseProvider);
      final existing = await db.select(db.userProfiles).getSingleOrNull();
      final existingSettings = existing?.settingsJson ?? <String, dynamic>{};
      final mergedSettings = Map<String, dynamic>.from(existingSettings)
        ..['name'] = value.name
        ..['address'] = value.address
        ..['licenses'] = value.licenses;
      await db
          .into(db.userProfiles)
          .insertOnConflictUpdate(
            UserProfilesCompanion(
              id: const Value(1),
              settingsJson: Value(mergedSettings),
              signatureImage: Value(value.signatureImage),
            ),
          );
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }
}

/// Legacy in-file migration to move old pilot info prefs into database once.
class _ReportPilotInfoMigrationHelper {
  const _ReportPilotInfoMigrationHelper._();

  static Future<void> migrateIfNeeded(Ref ref) async {
    try {
      final file = await _file();
      if (!file.existsSync()) {
        return;
      }
      final raw = file.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return;
      }
      final data = Map<String, dynamic>.from(decoded);
      final rawPilot = data['reportPilotInfo'];
      if (rawPilot is! Map) {
        return;
      }
      final pilot = Map<String, dynamic>.from(rawPilot);
      final migrated = ReportPilotInfo(
        name: (pilot['name'] ?? '').toString(),
        licenses: (pilot['licenceNumber'] ?? '').toString(),
        address: (pilot['address'] ?? '').toString(),
      );
      final db = ref.read(databaseProvider);
      final existing = await db.select(db.userProfiles).getSingleOrNull();
      final existingSettings = existing?.settingsJson ?? <String, dynamic>{};
      if (existing == null ||
          ((existingSettings['name'] ?? '').toString().isEmpty &&
              (existingSettings['address'] ?? '').toString().isEmpty &&
              (existingSettings['licenses'] ?? '').toString().isEmpty)) {
        await db
            .into(db.userProfiles)
            .insertOnConflictUpdate(
              UserProfilesCompanion(
                id: const Value(1),
                settingsJson: Value(<String, dynamic>{
                  ...existingSettings,
                  'name': migrated.name,
                  'address': migrated.address,
                  'licenses': migrated.licenses,
                }),
              ),
            );
      }
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

/// Notifier controlling whether previous experience is included in totals.
class IncludePreviousExperienceNotifier extends Notifier<bool> {
  @override
  bool build() {
    unawaited(_load());
    return true;
  }

  /// Updates the current state and persists it.
  Future<void> setValue({required bool value}) async {
    state = value;
    await _save(value);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final raw = file.readAsStringSync();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final value = data['includePreviousExperience'] == true;
      state = value;
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<void> _save(bool value) async {
    try {
      final file = await _file();
      var current = <String, dynamic>{};
      if (file.existsSync()) {
        try {
          final raw = file.readAsStringSync();
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            current = decoded;
          } else if (decoded is Map) {
            current = Map<String, dynamic>.from(decoded);
          }
        } on Object catch (error, stackTrace) {
          Zone.current.handleUncaughtError(error, stackTrace);
        }
      }
      current['includePreviousExperience'] = value;
      await file.writeAsString(
        jsonEncode(current),
        flush: true,
      );
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

/// Notifier controlling whether hours before the query range are included.
class IncludeHoursBeforeNotifier extends Notifier<bool> {
  @override
  bool build() {
    unawaited(_load());
    return true;
  }

  /// Updates the current state and persists it.
  Future<void> setValue({required bool value}) async {
    state = value;
    await _save(value);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final raw = file.readAsStringSync();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final value = data['includeHoursBefore'] != false;
      state = value;
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<void> _save(bool value) async {
    try {
      final file = await _file();
      var current = <String, dynamic>{};
      if (file.existsSync()) {
        try {
          final raw = file.readAsStringSync();
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            current = decoded;
          } else if (decoded is Map) {
            current = Map<String, dynamic>.from(decoded);
          }
        } on Object catch (error, stackTrace) {
          Zone.current.handleUncaughtError(error, stackTrace);
        }
      }
      current['includeHoursBefore'] = value;
      await file.writeAsString(
        jsonEncode(current),
        flush: true,
      );
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

/// Notifier storing the name of the last selected report template file.
class SelectedReportTemplateFileNameNotifier extends Notifier<String?> {
  @override
  String? build() {
    unawaited(_load());
    return null;
  }

  /// Updates the current state and persists the value.
  Future<void> setValue({required String? value}) async {
    state = value;
    await _save(value);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final raw = file.readAsStringSync();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final value = data[_selectedReportTemplateFileNameKey];
      if (value is String && value.trim().isNotEmpty) {
        state = value.trim();
      }
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<void> _save(String? value) async {
    try {
      final file = await _file();
      var current = <String, dynamic>{};
      if (file.existsSync()) {
        try {
          final raw = file.readAsStringSync();
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            current = decoded;
          } else if (decoded is Map) {
            current = Map<String, dynamic>.from(decoded);
          }
        } on Object catch (error, stackTrace) {
          Zone.current.handleUncaughtError(error, stackTrace);
        }
      }
      if (value == null || value.trim().isEmpty) {
        current.remove(_selectedReportTemplateFileNameKey);
      } else {
        current[_selectedReportTemplateFileNameKey] = value.trim();
      }
      await file.writeAsString(
        jsonEncode(current),
        flush: true,
      );
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

/// Notifier controlling whether the PDF viewer is opened automatically.
class OpenPdfAfterSavingNotifier extends Notifier<bool> {
  @override
  bool build() {
    unawaited(_load());
    return true;
  }

  /// Updates the current state and persists the value.
  Future<void> setValue({required bool value}) async {
    state = value;
    await _save(value);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final raw = file.readAsStringSync();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final value = data[_openPdfAfterSavingKey];
      if (value is bool) {
        state = value;
      }
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<void> _save(bool value) async {
    try {
      final file = await _file();
      var current = <String, dynamic>{};
      if (file.existsSync()) {
        try {
          final raw = file.readAsStringSync();
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            current = decoded;
          } else if (decoded is Map) {
            current = Map<String, dynamic>.from(decoded);
          }
        } on Object catch (error, stackTrace) {
          Zone.current.handleUncaughtError(error, stackTrace);
        }
      }
      current[_openPdfAfterSavingKey] = value;
      await file.writeAsString(
        jsonEncode(current),
        flush: true,
      );
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

/// List of saved report queries created by the user.
final savedReportsQueriesProvider =
    NotifierProvider<SavedReportsQueriesNotifier, List<SavedReportsQuery>>(
      SavedReportsQueriesNotifier.new,
    );

/// Manages the list of named report queries stored on disk.
class SavedReportsQueriesNotifier extends Notifier<List<SavedReportsQuery>> {
  @override
  List<SavedReportsQuery> build() {
    unawaited(_load());
    return const [];
  }

  /// Inserts or replaces a saved [query] with the same id.
  Future<void> addQuery(SavedReportsQuery query) async {
    final current = [...state];
    final index = current.indexWhere((item) => item.id == query.id);
    if (index >= 0) {
      current[index] = query;
    } else {
      current.add(query);
    }
    state = current;
    await _save(current);
  }

  /// Removes a saved query by [id].
  Future<void> removeQuery(String id) async {
    final current = state
        .where((item) => item.id != id)
        .toList(growable: false);
    state = current;
    await _save(current);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final raw = file.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      state = decoded
          .whereType<Map<String, dynamic>>()
          .map(SavedReportsQuery.fromJson)
          .toList(growable: false);
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<void> _save(List<SavedReportsQuery> queries) async {
    try {
      final file = await _file();
      await file.writeAsString(
        jsonEncode(
          queries.map((item) => item.toJson()).toList(growable: false),
        ),
        flush: true,
      );
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_savedReportsQueriesFileName');
  }
}

/// Selection of event types that should appear in reports.
final reportsEventTypesProvider =
    NotifierProvider<ReportsEventTypesNotifier, ReportsEventTypesSelection>(
      ReportsEventTypesNotifier.new,
    );

/// Riverpod provider for the in‑memory reports query being edited.
final reportsRuntimeQueryProvider =
    NotifierProvider<ReportsRuntimeQueryNotifier, ReportsRuntimeQueryState>(
      ReportsRuntimeQueryNotifier.new,
    );

/// Which types of logbook events are included when generating reports.
class ReportsEventTypesSelection {
  /// Creates a new selection; all fields default to `true`.
  const ReportsEventTypesSelection({
    this.flights = true,
    this.simulator = true,
    this.duty = true,
    this.positioning = true,
  });

  /// Builds a selection from a JSON map.
  factory ReportsEventTypesSelection.fromJson(Map<String, dynamic> json) {
    return ReportsEventTypesSelection(
      flights: json['flights'] != false,
      simulator: json['simulator'] != false,
      duty: json['duty'] != false,
      positioning: json['positioning'] != false,
    );
  }

  /// Whether flights should be included.
  final bool flights;

  /// Whether simulator training should be included.
  final bool simulator;

  /// Whether duty periods should be included.
  final bool duty;

  /// Whether positioning segments should be included.
  final bool positioning;

  /// Returns a copy with some flags replaced.
  ReportsEventTypesSelection copyWith({
    bool? flights,
    bool? simulator,
    bool? duty,
    bool? positioning,
  }) {
    return ReportsEventTypesSelection(
      flights: flights ?? this.flights,
      simulator: simulator ?? this.simulator,
      duty: duty ?? this.duty,
      positioning: positioning ?? this.positioning,
    );
  }

  /// Serializes the selection to JSON.
  Map<String, dynamic> toJson() {
    return {
      'flights': flights,
      'simulator': simulator,
      'duty': duty,
      'positioning': positioning,
    };
  }
}

/// Notifier that persists [ReportsEventTypesSelection] to disk.
class ReportsEventTypesNotifier extends Notifier<ReportsEventTypesSelection> {
  @override
  ReportsEventTypesSelection build() {
    unawaited(_load());
    return const ReportsEventTypesSelection();
  }

  /// Updates [state] and saves it.
  Future<void> setValue(ReportsEventTypesSelection value) async {
    state = value;
    await _save(value);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final raw = file.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final json = Map<String, dynamic>.from(decoded);
      final schemaVersion = (json['schemaVersion'] as num?)?.toInt() ?? 1;
      var next = ReportsEventTypesSelection.fromJson(json);
      if (schemaVersion < _reportsEventTypesSchemaVersion &&
          !next.positioning) {
        next = next.copyWith(positioning: true);
        await _save(next);
      }
      state = next;
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<void> _save(ReportsEventTypesSelection value) async {
    try {
      final file = await _file();
      final payload = <String, dynamic>{
        ...value.toJson(),
        'schemaVersion': _reportsEventTypesSchemaVersion,
      };
      await file.writeAsString(
        jsonEncode(payload),
        flush: true,
      );
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsEventTypesFileName');
  }
}

/// Runtime state for the report query editor UI.
class ReportsRuntimeQueryState {
  /// Creates a runtime query state object.
  const ReportsRuntimeQueryState({
    required this.from,
    required this.to,
    required this.selectedPreset,
    required this.matchMode,
    required this.filters,
  });

  /// Start of the query date range (inclusive).
  final DateTime from;

  /// End of the query date range (inclusive).
  final DateTime to;

  /// Identifier for the currently active preset (if any).
  final String selectedPreset;

  /// How filters are combined when querying.
  final ReportsFilterMatchMode matchMode;

  /// Runtime filter conditions applied by the user.
  final List<ReportsFilterCondition> filters;
}

/// Notifier that holds query values while the reports UI is open.
class ReportsRuntimeQueryNotifier extends Notifier<ReportsRuntimeQueryState> {
  @override
  ReportsRuntimeQueryState build() {
    return ReportsRuntimeQueryState(
      from: DateTime.utc(1990),
      to: DateTime.now().toUtc(),
      selectedPreset: 'sinceBeginning',
      matchMode: ReportsFilterMatchMode.all,
      filters: const <ReportsFilterCondition>[],
    );
  }

  // explicit mutation API for persisted runtime query state.
  /// Current query state.
  ReportsRuntimeQueryState get value => state;

  /// Replaces the current query state.
  set value(ReportsRuntimeQueryState value) {
    state = value;
  }
}

/// Serializable representation of a saved report query.
class SavedReportsQuery {
  /// Creates a new saved query description.
  const SavedReportsQuery({
    /// Unique identifier used to update or remove this query.
    required this.id,

    /// User‑visible query name.
    required this.name,

    /// Start of the date range.
    required this.from,

    /// End of the date range.
    required this.to,

    /// Whether previous experience is included.
    required this.includePreviousExperience,

    /// Filter match mode for this query.
    required this.filterMatchMode,

    /// Filters applied when this query is executed.
    required this.filters,
  });

  /// Unique id of the query.
  factory SavedReportsQuery.fromJson(Map<String, dynamic> json) {
    final filtersRaw = json['filters'];
    return SavedReportsQuery(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      from: DateTime.parse(
        (json['from'] as String?) ?? DateTime.utc(1990).toIso8601String(),
      ),
      to: DateTime.parse(
        (json['to'] as String?) ?? DateTime.now().toUtc().toIso8601String(),
      ),
      includePreviousExperience: json['includePreviousExperience'] == true,
      filterMatchMode: _filterMatchModeFromName(
        (json['filterMatchMode'] as String?) ?? '',
      ),
      filters: filtersRaw is List
          ? filtersRaw
                .whereType<Map<String, dynamic>>()
                .map(_filterConditionFromJson)
                .toList(growable: false)
          : const [],
    );
  }

  /// Unique identifier for the saved query.
  final String id;

  /// Human‑friendly name of the query.
  final String name;

  /// Start date/time of the range.
  final DateTime from;

  /// End date/time of the range.
  final DateTime to;

  /// Whether previous experience is included in totals.
  final bool includePreviousExperience;

  /// Filter match mode.
  final ReportsFilterMatchMode filterMatchMode;

  /// Filter conditions stored with the query.
  final List<ReportsFilterCondition> filters;

  /// Serializes this query to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'from': from.toUtc().toIso8601String(),
      'to': to.toUtc().toIso8601String(),
      'includePreviousExperience': includePreviousExperience,
      'filterMatchMode': filterMatchMode.name,
      'filters': filters.map(_filterConditionToJson).toList(growable: false),
    };
  }

  static ReportsFilterMatchMode _filterMatchModeFromName(String name) {
    return ReportsFilterMatchMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ReportsFilterMatchMode.all,
    );
  }

  static ReportsFilterCondition _filterConditionFromJson(
    Map<String, dynamic> json,
  ) {
    final fieldName = (json['field'] as String?) ?? '';
    final operatorName = (json['operator'] as String?) ?? '';
    return ReportsFilterCondition(
      field: ReportsFilterField.values.firstWhere(
        (value) => value.name == fieldName,
        orElse: () => ReportsFilterField.departureIcao,
      ),
      operator: ReportsFilterOperator.values.firstWhere(
        (value) => value.name == operatorName,
        orElse: () => ReportsFilterOperator.contains,
      ),
      textValue: json['textValue'] as String?,
      numberValue: (json['numberValue'] as num?)?.toInt(),
    );
  }

  static Map<String, dynamic> _filterConditionToJson(
    ReportsFilterCondition filter,
  ) {
    return {
      'field': filter.field.name,
      'operator': filter.operator.name,
      'textValue': filter.textValue,
      'numberValue': filter.numberValue,
    };
  }
}
