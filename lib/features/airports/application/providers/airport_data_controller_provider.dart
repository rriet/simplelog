import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/airports/application/airport_data_controller.dart';

final airportDataControllerProvider =
    NotifierProvider<AirportDataController, void>(
  AirportDataController.new,
);
