import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/previous_experience_row.dart';

/// Public API documentation.
class PreviousExperienceRepository {
  /// Public API documentation.
  PreviousExperienceRepository(this._db);

  /// Public API documentation.
  final AppDatabase _db;

  /// Public API documentation.
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
    /// Public API documentation.
    );
  }

  /// Public API documentation.
  Future<void> create(PreviousExperiencesCompanion companion) {
    return _db.into(_db.previousExperiences).insert(companion);
  }

  /// Public API documentation.
  Future<void> update(PreviousExperience value) {
    return _db.update(_db.previousExperiences).replace(value);
  }

  /// Public API documentation.
  Future<void> delete(int id) {
    return (_db.delete(
      _db.previousExperiences,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Public API documentation.
  Future<List<PreviousExperience>> fetchAll() {
    return _db.select(_db.previousExperiences).get();
  }
}
