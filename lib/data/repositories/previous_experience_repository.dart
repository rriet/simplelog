import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/previous_experience_row.dart';

class PreviousExperienceRepository {
  PreviousExperienceRepository(this._db);

  final AppDatabase _db;

  Stream<List<PreviousExperienceRow>> watchRows() {
    final query = _db.select(_db.previousExperiences).join([
      innerJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.previousExperiences.aircraftTypeId),
      ),
    ])
      ..orderBy([OrderingTerm.asc(_db.aircraftTypes.code)]);
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

  Future<void> create(PreviousExperiencesCompanion companion) {
    return _db.into(_db.previousExperiences).insert(companion);
  }

  Future<void> update(PreviousExperience value) {
    return _db.update(_db.previousExperiences).replace(value);
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.previousExperiences)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<List<PreviousExperience>> fetchAll() {
    return _db.select(_db.previousExperiences).get();
  }
}
