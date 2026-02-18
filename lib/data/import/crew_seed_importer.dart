import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';

class CrewSeedImporter {
  const CrewSeedImporter();

  Future<int> importIfEmpty(AppDatabase db) async {
    final countExpr = db.crew.id.count();
    final query = db.selectOnly(db.crew)..addColumns([countExpr]);
    final row = await query.getSingle();
    final count = row.read(countExpr) ?? 0;
    if (count > 0) {
      return 0;
    }

    await db.into(db.crew).insert(
          CrewCompanion.insert(
            name: 'Self',
            email: const Value(null),
            notes: const Value(null),
            phone: const Value(null),
            picture: const Value(null),
            isSelf: true,
            isFavorite: false,
            isLocked: false,
          ),
        );
    return 1;
  }
}

