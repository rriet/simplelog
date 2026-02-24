import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/aircraft/application/aircraft_controller.dart';

/// Provider exposing the `AircraftController` to the widget tree.
final aircraftControllerProvider = NotifierProvider<AircraftController, void>(
  AircraftController.new,
);
