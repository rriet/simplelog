import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/aircraft/application/aircraft_data_controller.dart';

/// Public API documentation.
final aircraftDataControllerProvider =
    NotifierProvider<AircraftDataController, void>(
      AircraftDataController.new,
    );
