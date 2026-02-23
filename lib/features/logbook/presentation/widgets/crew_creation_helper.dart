import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/crew/presentation/crew_edit_screen.dart';
import 'package:simplelog/features/logbook/presentation/widgets/edit_dialog_presenter.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Public API documentation.
Future<int?> createCrewAndReturnId({
  required BuildContext context,
  required WidgetRef ref,
  required Map<int, String> crewLabelCache,
}) async {
  const placeholder = CrewData(
    id: kPlaceholderId,
    name: '',
    isSelf: false,
    isFavorite: false,
    isLocked: false,
  );

  final result = await showConstrainedEditDialog<dynamic>(
    context: context,
    child: const CrewEditScreen(item: placeholder, isCreate: true),
  );
  if (result != true) return null;

  final db = ref.read(databaseProvider);
  final created =
      await (db.select(db.crew)
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(1))
          .getSingleOrNull();
  if (created == null) return null;

  crewLabelCache[created.id] = created.name;
  return created.id;
}
