import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/airport_controller.dart';

final airportControllerProvider =
    NotifierProvider<AirportController, void>(
  AirportController.new,
);
