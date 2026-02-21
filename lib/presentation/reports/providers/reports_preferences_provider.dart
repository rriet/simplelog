import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/data/models/reports_models.dart';

const _reportsPreferencesFileName = 'reports_preferences.json';
const _savedReportsQueriesFileName = 'saved_reports_queries.json';
const _reportsEventTypesFileName = 'reports_event_types.json';

final includePreviousExperienceProvider =
    NotifierProvider<IncludePreviousExperienceNotifier, bool>(
  IncludePreviousExperienceNotifier.new,
);

final includeHoursBeforeProvider =
    NotifierProvider<IncludeHoursBeforeNotifier, bool>(
  IncludeHoursBeforeNotifier.new,
);

class IncludePreviousExperienceNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> setValue(bool value) async {
    state = value;
    await _save(value);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final value = data['includePreviousExperience'] == true;
      state = value;
    } catch (_) {
      // Keep default value.
    }
  }

  Future<void> _save(bool value) async {
    try {
      final file = await _file();
      Map<String, dynamic> current = <String, dynamic>{};
      if (await file.exists()) {
        try {
          final raw = await file.readAsString();
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            current = decoded;
          } else if (decoded is Map) {
            current = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {
          current = <String, dynamic>{};
        }
      }
      current['includePreviousExperience'] = value;
      await file.writeAsString(
        jsonEncode(current),
        flush: true,
      );
    } catch (_) {
      // Best effort persistence.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

class IncludeHoursBeforeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> setValue(bool value) async {
    state = value;
    await _save(value);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final value = data['includeHoursBefore'] != false;
      state = value;
    } catch (_) {
      // Keep default value.
    }
  }

  Future<void> _save(bool value) async {
    try {
      final file = await _file();
      Map<String, dynamic> current = <String, dynamic>{};
      if (await file.exists()) {
        try {
          final raw = await file.readAsString();
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            current = decoded;
          } else if (decoded is Map) {
            current = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {
          current = <String, dynamic>{};
        }
      }
      current['includeHoursBefore'] = value;
      await file.writeAsString(
        jsonEncode(current),
        flush: true,
      );
    } catch (_) {
      // Best effort persistence.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsPreferencesFileName');
  }
}

final savedReportsQueriesProvider =
    NotifierProvider<SavedReportsQueriesNotifier, List<SavedReportsQuery>>(
  SavedReportsQueriesNotifier.new,
);

class SavedReportsQueriesNotifier extends Notifier<List<SavedReportsQuery>> {
  @override
  List<SavedReportsQuery> build() {
    _load();
    return const [];
  }

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

  Future<void> removeQuery(String id) async {
    final current = state.where((item) => item.id != id).toList(growable: false);
    state = current;
    await _save(current);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      state = decoded
          .whereType<Map>()
          .map((item) => SavedReportsQuery.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    } catch (_) {
      // Keep default value.
    }
  }

  Future<void> _save(List<SavedReportsQuery> queries) async {
    try {
      final file = await _file();
      await file.writeAsString(
        jsonEncode(queries.map((item) => item.toJson()).toList(growable: false)),
        flush: true,
      );
    } catch (_) {
      // Best effort persistence.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_savedReportsQueriesFileName');
  }
}

final reportsEventTypesProvider =
    NotifierProvider<ReportsEventTypesNotifier, ReportsEventTypesSelection>(
  ReportsEventTypesNotifier.new,
);

final reportsRuntimeQueryProvider =
    NotifierProvider<ReportsRuntimeQueryNotifier, ReportsRuntimeQueryState>(
  ReportsRuntimeQueryNotifier.new,
);

class ReportsEventTypesSelection {
  const ReportsEventTypesSelection({
    this.flights = true,
    this.simulator = true,
    this.duty = true,
    this.positioning = false,
  });

  final bool flights;
  final bool simulator;
  final bool duty;
  final bool positioning;

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

  Map<String, dynamic> toJson() {
    return {
      'flights': flights,
      'simulator': simulator,
      'duty': duty,
      'positioning': positioning,
    };
  }

  factory ReportsEventTypesSelection.fromJson(Map<String, dynamic> json) {
    return ReportsEventTypesSelection(
      flights: json['flights'] != false,
      simulator: json['simulator'] != false,
      duty: json['duty'] != false,
      positioning: json['positioning'] == true,
    );
  }
}

class ReportsEventTypesNotifier extends Notifier<ReportsEventTypesSelection> {
  @override
  ReportsEventTypesSelection build() {
    _load();
    return const ReportsEventTypesSelection();
  }

  Future<void> setValue(ReportsEventTypesSelection value) async {
    state = value;
    await _save(value);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      state = ReportsEventTypesSelection.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      // Keep defaults.
    }
  }

  Future<void> _save(ReportsEventTypesSelection value) async {
    try {
      final file = await _file();
      await file.writeAsString(
        jsonEncode(value.toJson()),
        flush: true,
      );
    } catch (_) {
      // Best effort persistence.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_reportsEventTypesFileName');
  }
}

class ReportsRuntimeQueryState {
  const ReportsRuntimeQueryState({
    required this.from,
    required this.to,
    required this.matchMode,
    required this.filters,
  });

  final DateTime from;
  final DateTime to;
  final ReportsFilterMatchMode matchMode;
  final List<ReportsFilterCondition> filters;
}

class ReportsRuntimeQueryNotifier extends Notifier<ReportsRuntimeQueryState> {
  @override
  ReportsRuntimeQueryState build() {
    return ReportsRuntimeQueryState(
      from: DateTime.utc(1990, 1, 1),
      to: DateTime.now().toUtc(),
      matchMode: ReportsFilterMatchMode.all,
      filters: const <ReportsFilterCondition>[],
    );
  }

  void setValue(ReportsRuntimeQueryState value) {
    state = value;
  }
}

class SavedReportsQuery {
  const SavedReportsQuery({
    required this.id,
    required this.name,
    required this.from,
    required this.to,
    required this.includePreviousExperience,
    required this.filterMatchMode,
    required this.filters,
  });

  final String id;
  final String name;
  final DateTime from;
  final DateTime to;
  final bool includePreviousExperience;
  final ReportsFilterMatchMode filterMatchMode;
  final List<ReportsFilterCondition> filters;

  factory SavedReportsQuery.fromJson(Map<String, dynamic> json) {
    final filtersRaw = json['filters'];
    return SavedReportsQuery(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      from: DateTime.parse((json['from'] as String?) ?? DateTime.utc(1990).toIso8601String()),
      to: DateTime.parse((json['to'] as String?) ?? DateTime.now().toUtc().toIso8601String()),
      includePreviousExperience: json['includePreviousExperience'] == true,
      filterMatchMode:
          _filterMatchModeFromName((json['filterMatchMode'] as String?) ?? ''),
      filters: filtersRaw is List
          ? filtersRaw
              .whereType<Map>()
              .map((item) => _filterConditionFromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const [],
    );
  }

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
