import 'dart:convert';
import 'package:drift/drift.dart';

/// Converts profile settings JSON text into a typed map and back.
class JsonMapConverter extends TypeConverter<Map<String, dynamic>, String> {
  /// Creates a const converter.
  const JsonMapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(fromDb);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return <String, dynamic>{};
  }

  @override
  String toSql(Map<String, dynamic> value) => jsonEncode(value);
}

/// Stores user-level profile settings and signature assets.
class UserProfiles extends Table {
  /// Single-row identifier (always `1`).
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// User profile and preferences serialized as JSON.
  TextColumn get settingsJson =>
      text().withDefault(const Constant('{}')).map(const JsonMapConverter())();

  /// Drawn pilot signature image (PNG bytes).
  BlobColumn get signatureImage => blob().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
