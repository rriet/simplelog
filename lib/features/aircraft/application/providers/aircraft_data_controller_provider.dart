import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/aircraft/application/aircraft_data_controller.dart';

/// Provider exposing [AircraftDataController] for create/update/delete flows.
final aircraftDataControllerProvider =
    NotifierProvider<AircraftDataController, void>(
      AircraftDataController.new,
    );
