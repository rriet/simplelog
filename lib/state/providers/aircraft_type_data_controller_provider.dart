import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/aircraft_type_data_controller.dart';

final aircraftTypeDataControllerProvider =
    NotifierProvider<AircraftTypeDataController, void>(
  AircraftTypeDataController.new,
);
