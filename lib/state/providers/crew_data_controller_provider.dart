import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/crew_data_controller.dart';

final crewDataControllerProvider =
    NotifierProvider<CrewDataController, void>(
  CrewDataController.new,
);
