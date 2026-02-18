import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/aircraft_types/application/aircraft_types_controller.dart';

final aircraftTypesControllerProvider =
    NotifierProvider<AircraftTypesController, void>(
  AircraftTypesController.new,
);
