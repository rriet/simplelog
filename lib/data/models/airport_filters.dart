import 'package:flutter/foundation.dart';

/// Public API documentation.
class AirportFilters {
  /// Public API documentation.
  const AirportFilters({
    this.orderBy = AirportOrderBy.icao,
    this.searchField = AirportSearchField.all,
    this.showOnlyVisited = false,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final AirportOrderBy orderBy;
  /// Public API documentation.
  final AirportSearchField searchField;
  /// Public API documentation.
  final bool showOnlyVisited;

  /// Public API documentation.
  AirportFilters copyWith({
    AirportOrderBy? orderBy,
    AirportSearchField? searchField,
    bool? showOnlyVisited,
  }) {
    return AirportFilters(
      orderBy: orderBy ?? this.orderBy,
      /// Public API documentation.
      searchField: searchField ?? this.searchField,
      /// Public API documentation.
      showOnlyVisited: showOnlyVisited ?? this.showOnlyVisited,
    /// Public API documentation.
    );
  /// Public API documentation.
  }
/// Public API documentation.
}
/// Public API documentation.

/// Public API documentation.
enum AirportOrderBy {
  /// Public API documentation.
  icao,
  /// Public API documentation.
  iata,
  /// Public API documentation.
  name,
  /// Public API documentation.
  city,
  /// Public API documentation.
  country,
  /// Public API documentation.
  landings,
  /// Public API documentation.
  takeoffs,
  /// Public API documentation.
  visits,
}

/// Public API documentation.
enum AirportSearchField {
  /// Public API documentation.
  all,
  /// Public API documentation.
  icao,
  /// Public API documentation.
  iata,
  /// Public API documentation.
  icaoOrIata,
  /// Public API documentation.
  name,
  /// Public API documentation.
  city,
  /// Public API documentation.
  country,
}

@immutable
/// Public API documentation.
class AirportSearchParams {
  /// Public API documentation.
  const AirportSearchParams({
    required this.query,
    required this.filters,
  });

  /// Public API documentation.
  final String query;
  /// Public API documentation.
  final AirportFilters filters;

  @override
  bool operator ==(Object other) {
    return other is AirportSearchParams &&
        other.query == query &&
        other.filters.orderBy == filters.orderBy &&
        other.filters.searchField == filters.searchField &&
        other.filters.showOnlyVisited == filters.showOnlyVisited;
  }

  @override
  int get hashCode => Object.hash(
    query,
    filters.orderBy,
    filters.searchField,
    filters.showOnlyVisited,
  );
}
