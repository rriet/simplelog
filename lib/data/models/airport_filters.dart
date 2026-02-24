import 'package:flutter/foundation.dart';

/// User-selected filter and sort options for airport searches.
class AirportFilters {
  /// Creates a new set of airport filters.
  const AirportFilters({
    this.orderBy = AirportOrderBy.icao,
    this.searchField = AirportSearchField.all,
    this.showOnlyVisited = false,
  });

  /// Column used to order airport results.
  final AirportOrderBy orderBy;

  /// Field used when interpreting the search query.
  final AirportSearchField searchField;

  /// When `true`, only airports that appear in the logbook are shown.
  final bool showOnlyVisited;

  /// Returns a copy with some fields replaced.
  AirportFilters copyWith({
    AirportOrderBy? orderBy,
    AirportSearchField? searchField,
    bool? showOnlyVisited,
  }) {
    return AirportFilters(
      orderBy: orderBy ?? this.orderBy,
      searchField: searchField ?? this.searchField,
      showOnlyVisited: showOnlyVisited ?? this.showOnlyVisited,
    );
  }
}

/// Fields that can be used to sort airport lists.
enum AirportOrderBy {
  /// Sort by ICAO code.
  icao,

  /// Sort by IATA code.
  iata,

  /// Sort by airport name.
  name,

  /// Sort by city.
  city,

  /// Sort by country.
  country,

  /// Sort by number of landings.
  landings,

  /// Sort by number of takeoffs.
  takeoffs,

  /// Sort by number of unique visits.
  visits,
}

/// Fields that the search box can target.
enum AirportSearchField {
  /// Search across multiple fields.
  all,

  /// Search by ICAO only.
  icao,

  /// Search by IATA only.
  iata,

  /// Search by either ICAO or IATA.
  icaoOrIata,

  /// Search by airport name.
  name,

  /// Search by city name.
  city,

  /// Search by country name.
  country,
}

@immutable
/// Parameter object used to memoize airport search queries.
class AirportSearchParams {
  /// Creates a parameter object for [query] and [filters].
  const AirportSearchParams({
    required this.query,
    required this.filters,
  });

  /// Search string typed by the user.
  final String query;

  /// Filter and sort options.
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
