import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/previous_experience_row.dart';

/// Drift repository for previous-experience totals.
class PreviousExperienceRepository {
  /// Creates repository bound to [_db].
  PreviousExperienceRepository(this._db);

  /// Database handle.
  final AppDatabase _db;

  /// Watches joined previous-experience rows with aircraft type metadata.
  Stream<List<PreviousExperienceRow>> watchRows() {
    final query = _db.select(_db.previousExperiences).join([
      innerJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.previousExperiences.aircraftTypeId),
      ),
    ])..orderBy([OrderingTerm.asc(_db.aircraftTypes.code)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => PreviousExperienceRow(
              previousExperience: row.readTable(_db.previousExperiences),
              aircraftType: row.readTable(_db.aircraftTypes),
            ),
          )
          .toList(growable: false),
    );
  }

  /// Inserts a new previous-experience row.
  Future<void> create(PreviousExperiencesCompanion companion) {
    return _db.into(_db.previousExperiences).insert(companion);
  }

  /// Updates an existing previous-experience row.
  Future<void> update(PreviousExperience value) {
    return _db.update(_db.previousExperiences).replace(value);
  }

  /// Deletes previous-experience row by [id].
  Future<void> delete(int id) {
    return (_db.delete(
      _db.previousExperiences,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Returns all previous-experience rows.
  Future<List<PreviousExperience>> fetchAll() {
    return _db.select(_db.previousExperiences).get();
  }
}
