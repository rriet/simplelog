import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/data/models/airport_filters.dart';

const _airportFiltersFileName = 'airport_filters.json';

/// Stores airport list filters and persists them locally.
final airportFiltersProvider =
    NotifierProvider<AirportFiltersNotifier, AirportFilters>(
      AirportFiltersNotifier.new,
    );

/// Notifier responsible for reading and writing persisted airport filters.
class AirportFiltersNotifier extends Notifier<AirportFilters> {
  @override
  AirportFilters build() {
    unawaited(_load());
    return const AirportFilters();
  }

  /// Updates filter state and persists the new value.
  Future<void> setFilters(AirportFilters filters) async {
    state = filters;
    await _save(filters);
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final raw = file.readAsStringSync();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final loaded = AirportFilters(
        orderBy:
            AirportOrderBy.values[_safeInt(
              data['orderBy'],
              fallback: AirportOrderBy.icao.index,
              max: AirportOrderBy.values.length - 1,
            )],
        searchField:
            AirportSearchField.values[_safeInt(
              data['searchField'],
              fallback: AirportSearchField.all.index,
              max: AirportSearchField.values.length - 1,
            )],
        showOnlyVisited: data['showOnlyVisited'] == true,
      );
      state = loaded;
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<void> _save(AirportFilters filters) async {
    try {
      final file = await _file();
      final payload = {
        'orderBy': filters.orderBy.index,
        'searchField': filters.searchField.index,
        'showOnlyVisited': filters.showOnlyVisited,
      };
      await file.writeAsString(jsonEncode(payload), flush: true);
    } on Object catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_airportFiltersFileName');
  }

  int _safeInt(
    dynamic value, {
    required int fallback,
    required int max,
  }) {
    if (value is! int) return fallback;
    if (value < 0 || value > max) return fallback;
    return value;
  }
}
