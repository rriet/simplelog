import 'package:simplelog/data/database/app_database.dart';

class AircraftTypeRow {
  const AircraftTypeRow(this.type);

  final AircraftType type;

  int get id => type.id;
  String get code => type.code;
  String get family => type.family;
  String get longName => type.longName;
  String? get manufacturer => type.manufacturer;
  bool get isLocked => type.isLocked;
}
