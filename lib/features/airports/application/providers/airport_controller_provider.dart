import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/airports/application/airport_controller.dart';

/// Public API documentation.
final airportControllerProvider = NotifierProvider<AirportController, void>(
  AirportController.new,
);
