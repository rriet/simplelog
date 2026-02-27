import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/airports/application/airport_controller.dart';

/// Provider exposing [AirportController] for list row actions.
final airportControllerProvider = NotifierProvider<AirportController, void>(
  AirportController.new,
);
