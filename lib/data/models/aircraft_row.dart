import 'package:simplelog/data/database/app_database.dart';

class AircraftRow {
  const AircraftRow(this.aircraft, this.type);

  final Aircraft aircraft;
  final AircraftType? type;

  int get id => aircraft.id;
  String get registration => aircraft.registration;
  bool get isFavorite => aircraft.isFavorite;
  bool get isLocked => aircraft.isLocked;
  int get effectiveMtow => aircraft.mtow ?? type?.mtow ?? 0;
}
