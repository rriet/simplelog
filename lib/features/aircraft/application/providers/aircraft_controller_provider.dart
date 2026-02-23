import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/aircraft/application/aircraft_controller.dart';

/// Public API documentation.
final aircraftControllerProvider = NotifierProvider<AircraftController, void>(
  AircraftController.new,
);
