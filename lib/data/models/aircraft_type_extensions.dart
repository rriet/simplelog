import 'package:simplelog/data/database/app_database.dart';

extension AircraftTypeExtensions on AircraftType {
  bool get isMultiEngine => engineCount > 1;
}
