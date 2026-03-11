import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/airports/application/airport_data_controller.dart';

/// Provider exposing the `AirportDataController` to the widget tree.
final NotifierProvider<AirportDataController, void>
airportDataControllerProvider =
    NotifierProvider<AirportDataController, void>(
      AirportDataController.new,
    );
