import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/data/models/reports_models.dart';

const _reportsPreferencesFileName = 'reports_preferences.json';
const _savedReportsQueriesFileName = 'saved_reports_queries.json';
const _reportsEventTypesFileName = 'reports_event_types.json';
const _selectedReportTemplateFileNameKey = 'selectedReportTemplateFileName';
const _openPdfAfterSavingKey = 'openPdfAfterSaving';
const _reportPilotInfoKey = 'reportPilotInfo';

/// Public API documentation.
final includePreviousExperienceProvider =
    NotifierProvider<IncludePreviousExperienceNotifier, bool>(
      IncludePreviousExperienceNotifier.new,
    );

/// Public API documentation.

/// Public API documentation.
final includeHoursBeforeProvider =
    NotifierProvider<IncludeHoursBeforeNotifier, bool>(
      IncludeHoursBeforeNotifier.new,

      /// Public API documentation.
    );

/// Public API documentation.
final selectedReportTemplateFileNameProvider =
    NotifierProvider<SelectedReportTemplateFileNameNotifier, String?>(
      SelectedReportTemplateFileNameNotifier.new,
    );

/// Public API documentation.
final openPdfAfterSavingProvider =
    NotifierProvider<OpenPdfAfterSavingNotifier, bool>(
      OpenPdfAfterSavingNotifier.new,
    );

/// Public API documentation.
final reportPilotInfoProvider =
    NotifierProvider<ReportPilotInfoNotifier, ReportPilotInfo>(
      ReportPilotInfoNotifier.new,
    );

/// Public API documentation.
class ReportPilotInfo {
  /// Public API documentation.
  const ReportPilotInfo({
    this.name = '',
    this.licenceNumber = '',
    this.address = '',
  });

  /// Public API documentation.
  factory ReportPilotInfo.fromJson(Map<String, dynamic> json) {
    return ReportPilotInfo(
      name: (json['name'] ?? '').toString(),
      licenceNumber: (json['licenceNumber'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
    );
  }

  /// Public API documentation.
  final String name;
  /// Public API documentation.
  final String licenceNumber;
  /// Public API documentation.
  final String address;

  /// Public API documentation.
  ReportPilotInfo copyWith({
    String? name,
    String? licenceNumber,
    String? address,
  }) {
    return ReportPilotInfo(
      name: name ?? this.name,
      licenceNumber: licenceNumber ?? this.licenceNumber,
      address: address ?? this.address,
    );
  }

  /// Public API documentation.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'licenceNumber': licenceNumber,
      'address': address,
    };
  }
}

/// Public API documentation.
class ReportPilotInfoNotifier extends Notifier<ReportPilotInfo> {
  @override
  ReportPilotInfo build() {
    unawaited(_load());
    return const ReportPilotInfo();
  }

  /// Public API documentation.
  Future<void> setValue({required ReportPilotInfo value}) async {
    state = value;
    await _save(value);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final raw = file.readAsStringSync();
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return;
      final rawPilot = data[_reportPilotInfoKey];
      if (rawPilot is Map<String, dynamic>) {
        state = ReportPilotInfo.fromJson(rawPilot);
      } else if (rawPilot is Map) {
        state = ReportPilotInfo.fromJson(
          Map<String, dynamic>.from(rawPilot),
        );
      }
    } on Object catch (_) {
      // Keep default value.
    }
  }

  Future<void> _save(ReportPilotInfo value) async {
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
        } on Object catch (_) {
          current = <String, dynamic>{};
        }
      }
      current[_reportPilotInfoKey] = value.toJson();
      await file.writeAsString(
        jsonEncode(current),
        flush: true,
      );
    } on Object catch (_) {
      // Best effort persistence.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

/// Public API documentation.
class IncludePreviousExperienceNotifier extends Notifier<bool> {
  @override
  bool build() {
    unawaited(_load());

    /// Public API documentation.
    return true;
  }

  /// Public API documentation.
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
    } on Object catch (_) {
      // Keep default value.
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
        } on Object catch (_) {
          current = <String, dynamic>{};
        }
      }
      current['includePreviousExperience'] = value;
      await file.writeAsString(
        jsonEncode(current),
        flush: true,
      );
    } on Object catch (_) {
      // Best effort persistence.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();

    /// Public API documentation.
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

/// Public API documentation.
class IncludeHoursBeforeNotifier extends Notifier<bool> {
  @override
  /// Public API documentation.
  bool build() {
    unawaited(_load());
    return true;
  }

  /// Public API documentation.
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
    } on Object catch (_) {
      // Keep default value.
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
        } on Object catch (_) {
          current = <String, dynamic>{};
        }
      }
      current['includeHoursBefore'] = value;
      await file.writeAsString(
        jsonEncode(current),
        flush: true,
      );
    } on Object catch (_) {
      // Best effort persistence.
    }
  }

  /// Public API documentation.
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

/// Public API documentation.

/// Public API documentation.
class SelectedReportTemplateFileNameNotifier extends Notifier<String?> {
  @override
  String? build() {
    unawaited(_load());
    return null;
  }

  /// Public API documentation.
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
    } on Object catch (_) {
      // Keep default value.
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
        } on Object catch (_) {
          current = <String, dynamic>{};
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
    } on Object catch (_) {
      // Best effort persistence.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

/// Public API documentation.
class OpenPdfAfterSavingNotifier extends Notifier<bool> {
  @override
  bool build() {
    unawaited(_load());
    return true;
  }

  /// Public API documentation.
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
    } on Object catch (_) {
      // Keep default value.
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
        } on Object catch (_) {
          current = <String, dynamic>{};
        }
      }
      current[_openPdfAfterSavingKey] = value;
      await file.writeAsString(
        jsonEncode(current),
        flush: true,
      );
    } on Object catch (_) {
      // Best effort persistence.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

/// Public API documentation.
final savedReportsQueriesProvider =
    NotifierProvider<SavedReportsQueriesNotifier, List<SavedReportsQuery>>(
      SavedReportsQueriesNotifier.new,
    );

/// Public API documentation.
class SavedReportsQueriesNotifier extends Notifier<List<SavedReportsQuery>> {
  @override
  List<SavedReportsQuery> build() {
    unawaited(_load());
    return const [];
  }

  /// Public API documentation.
  Future<void> addQuery(SavedReportsQuery query) async {
    final current = [...state];
    final index = current.indexWhere((item) => item.id == query.id);

    /// Public API documentation.
    if (index >= 0) {
      current[index] = query;
    } else {
      current.add(query);
    }
    state = current;
    await _save(current);
  }

  /// Public API documentation.
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
    } on Object catch (_) {
      // Keep default value.
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
    } on Object catch (_) {
      /// Public API documentation.
      // Best effort persistence.
    }
  }

  Future<File> _file() async {
    /// Public API documentation.
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_savedReportsQueriesFileName');
  }
}

/// Public API documentation.
final reportsEventTypesProvider =
    NotifierProvider<ReportsEventTypesNotifier, ReportsEventTypesSelection>(
      ReportsEventTypesNotifier.new,
    );

/// Public API documentation.
final reportsRuntimeQueryProvider =
    /// Public API documentation.
    NotifierProvider<ReportsRuntimeQueryNotifier, ReportsRuntimeQueryState>(
      ReportsRuntimeQueryNotifier.new,
    );

/// Public API documentation.
class ReportsEventTypesSelection {
  /// Public API documentation.
  const ReportsEventTypesSelection({
    this.flights = true,

    /// Public API documentation.
    this.simulator = true,

    /// Public API documentation.
    this.duty = true,

    /// Public API documentation.
    this.positioning = false,

    /// Public API documentation.
  });

  /// Public API documentation.
  factory ReportsEventTypesSelection.fromJson(Map<String, dynamic> json) {
    return ReportsEventTypesSelection(
      flights: json['flights'] != false,
      simulator: json['simulator'] != false,
      duty: json['duty'] != false,
      positioning: json['positioning'] == true,
    );
  }

  /// Public API documentation.
  final bool flights;

  /// Public API documentation.
  final bool simulator;

  /// Public API documentation.
  final bool duty;

  /// Public API documentation.
  final bool positioning;

  /// Public API documentation.
  ReportsEventTypesSelection copyWith({
    bool? flights,
    bool? simulator,
    bool? duty,

    /// Public API documentation.
    bool? positioning,
  }) {
    return ReportsEventTypesSelection(
      flights: flights ?? this.flights,
      simulator: simulator ?? this.simulator,
      duty: duty ?? this.duty,
      positioning: positioning ?? this.positioning,

      /// Public API documentation.
    );
  }

  /// Public API documentation.
  Map<String, dynamic> toJson() {
    return {
      'flights': flights,
      'simulator': simulator,
      'duty': duty,
      'positioning': positioning,
    };
  }
}

/// Public API documentation.
class ReportsEventTypesNotifier extends Notifier<ReportsEventTypesSelection> {
  @override
  ReportsEventTypesSelection build() {
    unawaited(_load());
    return const ReportsEventTypesSelection();
  }

  /// Public API documentation.
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
      state = ReportsEventTypesSelection.fromJson(
        Map<String, dynamic>.from(decoded),
      );

      /// Public API documentation.
    } on Object catch (_) {
      /// Public API documentation.
      // Keep defaults.
    }
  }

  Future<void> _save(ReportsEventTypesSelection value) async {
    try {
      final file = await _file();

      /// Public API documentation.
      await file.writeAsString(
        /// Public API documentation.
        jsonEncode(value.toJson()),

        /// Public API documentation.
        flush: true,

        /// Public API documentation.
      );
    } on Object catch (_) {
      // Best effort persistence.
      /// Public API documentation.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsEventTypesFileName');
  }
}

/// Public API documentation.
class ReportsRuntimeQueryState {
  /// Public API documentation.
  const ReportsRuntimeQueryState({
    required this.from,
    required this.to,
    required this.selectedPreset,
    required this.matchMode,
    required this.filters,

    /// Public API documentation.
  });

  /// Public API documentation.

  /// Public API documentation.
  final DateTime from;

  /// Public API documentation.
  final DateTime to;

  /// Public API documentation.
  final String selectedPreset;

  /// Public API documentation.
  final ReportsFilterMatchMode matchMode;

  /// Public API documentation.
  final List<ReportsFilterCondition> filters;
}

/// Public API documentation.

/// Public API documentation.
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
  /// Public API documentation.
  ReportsRuntimeQueryState get value => state;

  /// Public API documentation.
  set value(ReportsRuntimeQueryState value) {
    state = value;
  }
}

/// Public API documentation.
class SavedReportsQuery {
  /// Public API documentation.
  const SavedReportsQuery({
    /// Public API documentation.
    required this.id,

    /// Public API documentation.
    required this.name,

    /// Public API documentation.
    required this.from,

    /// Public API documentation.
    required this.to,

    /// Public API documentation.
    required this.includePreviousExperience,

    /// Public API documentation.
    required this.filterMatchMode,

    /// Public API documentation.
    required this.filters,
  });

  /// Public API documentation.

  /// Public API documentation.
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

  /// Public API documentation.
  final String id;

  /// Public API documentation.
  final String name;

  /// Public API documentation.
  final DateTime from;

  /// Public API documentation.
  final DateTime to;

  /// Public API documentation.
  final bool includePreviousExperience;

  /// Public API documentation.
  final ReportsFilterMatchMode filterMatchMode;

  /// Public API documentation.
  final List<ReportsFilterCondition> filters;

  /// Public API documentation.
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
