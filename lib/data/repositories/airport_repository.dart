import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';

class AirportRepository {
  AirportRepository(this._db);

  final AppDatabase _db;

  Stream<List<AirportRow>> watchAirports(
    String query,
    AirportFilters filters,
  ) {
    final trimmed = query.trim();
    final hasQuery = trimmed.isNotEmpty;
    final term = '%$trimmed%';
    final whereParts = <String>[];
    final variables = <Variable>[];

    if (hasQuery) {
      switch (filters.searchField) {
        case AirportSearchField.all:
          whereParts.add(
            '(a.icao LIKE ? OR COALESCE(a.iata, \'\') LIKE ? OR '
            'COALESCE(a.name, \'\') LIKE ? OR COALESCE(a.city, \'\') LIKE ? '
            'OR COALESCE(a.country, \'\') LIKE ?)',
          );
          variables.addAll(List.filled(5, Variable.withString(term)));
          break;
        case AirportSearchField.icao:
          whereParts.add('a.icao LIKE ?');
          variables.add(Variable.withString(term));
          break;
        case AirportSearchField.iata:
          whereParts.add('COALESCE(a.iata, \'\') LIKE ?');
          variables.add(Variable.withString(term));
          break;
        case AirportSearchField.icaoOrIata:
          whereParts.add(
            '(a.icao LIKE ? OR COALESCE(a.iata, \'\') LIKE ?)',
          );
          variables.addAll(List.filled(2, Variable.withString(term)));
          break;
        case AirportSearchField.name:
          whereParts.add('COALESCE(a.name, \'\') LIKE ?');
          variables.add(Variable.withString(term));
          break;
        case AirportSearchField.city:
          whereParts.add('COALESCE(a.city, \'\') LIKE ?');
          variables.add(Variable.withString(term));
          break;
        case AirportSearchField.country:
          whereParts.add('COALESCE(a.country, \'\') LIKE ?');
          variables.add(Variable.withString(term));
          break;
      }
    }

    if (filters.showOnlyVisited) {
      whereParts.add(
        '(COALESCE(fv.flight_count, 0) + COALESCE(pv.positioning_count, 0)) > 0',
      );
    }

    final whereClause =
        whereParts.isEmpty ? '' : 'WHERE ${whereParts.join(' AND ')}';

    final orderBy = switch (filters.orderBy) {
      AirportOrderBy.icao => 'a.icao ASC',
      AirportOrderBy.iata => 'a.iata ASC',
      AirportOrderBy.name => 'a.name ASC',
      AirportOrderBy.city => 'a.city ASC',
      AirportOrderBy.country => 'a.country ASC',
      AirportOrderBy.landings => 'COALESCE(ld.landing_count, 0) DESC',
      AirportOrderBy.takeoffs => 'COALESCE(tk.takeoff_count, 0) DESC',
      AirportOrderBy.visits =>
        '(COALESCE(fv.flight_count, 0) + COALESCE(pv.positioning_count, 0)) DESC',
    };

    final sql = '''
WITH flight_visits AS (
  SELECT airport_id, COUNT(*) AS flight_count
  FROM (
    SELECT id AS flight_id, departure_airport_id AS airport_id FROM flights
    UNION
    SELECT id AS flight_id, arrival_airport_id AS airport_id FROM flights
  )
  GROUP BY airport_id
),
positioning_visits AS (
  SELECT airport_id, COUNT(*) AS positioning_count
  FROM (
    SELECT id AS positioning_id, departure_place_id AS airport_id FROM positionings
    UNION
    SELECT id AS positioning_id, arrival_place_id AS airport_id FROM positionings
  )
  GROUP BY airport_id
),
takeoffs AS (
  SELECT departure_airport_id AS airport_id,
         COALESCE(SUM(take_offs_days + take_offs_night), 0) AS takeoff_count
  FROM flights
  GROUP BY departure_airport_id
),
landings AS (
  SELECT arrival_airport_id AS airport_id,
         COALESCE(SUM(landings_day + landings_night), 0) AS landing_count
  FROM flights
  GROUP BY arrival_airport_id
)
SELECT a.*,
  COALESCE(fv.flight_count, 0) AS flight_count,
  COALESCE(pv.positioning_count, 0) AS positioning_count,
  COALESCE(tk.takeoff_count, 0) AS takeoff_count,
  COALESCE(ld.landing_count, 0) AS landing_count,
  (COALESCE(fv.flight_count, 0) + COALESCE(pv.positioning_count, 0)) AS visit_count
FROM airports a
LEFT JOIN flight_visits fv ON fv.airport_id = a.id
LEFT JOIN positioning_visits pv ON pv.airport_id = a.id
LEFT JOIN takeoffs tk ON tk.airport_id = a.id
LEFT JOIN landings ld ON ld.airport_id = a.id
$whereClause
ORDER BY a.is_favorite DESC, $orderBy
''';

    final customQuery = _db.customSelect(
      sql,
      variables: variables,
      readsFrom: {_db.airports, _db.flights, _db.positionings},
    );

    return customQuery.watch().map((rows) {
      return rows
          .map((row) {
            final airport = _db.airports.map(row.data);
            final flightCount = row.read<int>('flight_count');
            final positioningCount = row.read<int>('positioning_count');
            final takeoffCount = row.read<int>('takeoff_count');
            final landingCount = row.read<int>('landing_count');
            return AirportRow(
              airport,
              flightCount: flightCount,
              positioningCount: positioningCount,
              takeoffCount: takeoffCount,
              landingCount: landingCount,
            );
          })
          .toList();
    });
  }

  Future<void> toggleLock(Airport item) async {
    await _db.update(_db.airports).replace(
          item.copyWith(isLocked: !item.isLocked),
        );
  }

  Future<void> toggleFavorite(Airport item) async {
    await _db.update(_db.airports).replace(
          item.copyWith(isFavorite: !item.isFavorite),
        );
  }

  Future<void> delete(Airport item) async {
    await _db.delete(_db.airports).delete(item);
  }

  Future<int> create(AirportsCompanion companion) {
    return _db.into(_db.airports).insert(companion);
  }

  Future<void> update(Airport item) async {
    await _db.update(_db.airports).replace(item);
  }

  Future<int> countDuplicateIcao(String icao, int currentId) async {
    final countExpr = _db.airports.id.count();
    final query = _db.selectOnly(_db.airports)
      ..addColumns([countExpr])
      ..where(
        _db.airports.icao.lower().equals(icao.toLowerCase()) &
            _db.airports.id.isNotIn([currentId]),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
