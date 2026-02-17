import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/aircraft_controller.dart';

final aircraftControllerProvider =
    NotifierProvider<AircraftController, void>(
  AircraftController.new,
);
