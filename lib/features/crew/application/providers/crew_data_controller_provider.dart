import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/crew/application/crew_data_controller.dart';

/// Public API documentation.
final crewDataControllerProvider = NotifierProvider<CrewDataController, void>(
  CrewDataController.new,
);
