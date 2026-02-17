import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/airport_data_controller.dart';

final airportDataControllerProvider =
    NotifierProvider<AirportDataController, void>(
  AirportDataController.new,
);
