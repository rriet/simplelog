import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/aircraft_types/application/aircraft_type_data_controller.dart';

/// Public API documentation.
final aircraftTypeDataControllerProvider =
    NotifierProvider<AircraftTypeDataController, void>(
      AircraftTypeDataController.new,
    );
