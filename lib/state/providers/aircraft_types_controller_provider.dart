import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/aircraft_types_controller.dart';

final aircraftTypesControllerProvider =
    NotifierProvider<AircraftTypesController, void>(
  AircraftTypesController.new,
);
