import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/controllers/crew_controller.dart';

final crewControllerProvider =
    NotifierProvider<CrewController, void>(
  CrewController.new,
);
