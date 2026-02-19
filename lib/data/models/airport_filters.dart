class AirportFilters {
  const AirportFilters({
    this.orderBy = AirportOrderBy.icao,
    this.searchField = AirportSearchField.all,
    this.showOnlyVisited = false,
  });

  final AirportOrderBy orderBy;
  final AirportSearchField searchField;
  final bool showOnlyVisited;

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

enum AirportOrderBy {
  icao,
  iata,
  name,
  city,
  country,
  landings,
  takeoffs,
  visits,
}

enum AirportSearchField {
  all,
  icao,
  iata,
  icaoOrIata,
  name,
  city,
  country,
}

class AirportSearchParams {
  const AirportSearchParams({
    required this.query,
    required this.filters,
  });

  final String query;
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
