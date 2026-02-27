import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/crew/application/crew_data_controller.dart';

/// Provider exposing [CrewDataController] for create/update/delete actions.
final crewDataControllerProvider = NotifierProvider<CrewDataController, void>(
  CrewDataController.new,
);
