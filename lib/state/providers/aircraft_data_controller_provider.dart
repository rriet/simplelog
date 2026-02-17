import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/aircraft_data_controller.dart';

final aircraftDataControllerProvider =
    NotifierProvider<AircraftDataController, void>(
  AircraftDataController.new,
);
