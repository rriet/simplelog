import 'package:drift/drift.dart';

/// Stored PDF report template definitions editable by users.
class ReportTemplates extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Stable template identifier, e.g. `standard` or `easa`.
  TextColumn get templateName => text().named('template_name')();

  /// Full template JSON payload.
  TextColumn get templateJson => text().named('template_json')();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {templateName},
  ];
}
