import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/aircraft_types/application/aircraft_type_data_controller.dart';

/// Provider exposing the `AircraftTypeDataController` to the widget tree.
final NotifierProvider<AircraftTypeDataController, void>
aircraftTypeDataControllerProvider =
    NotifierProvider<AircraftTypeDataController, void>(
      AircraftTypeDataController.new,
    );
