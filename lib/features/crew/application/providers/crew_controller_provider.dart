import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/crew/application/crew_controller.dart';

/// Provider exposing the `CrewController` to the widget tree.
final crewControllerProvider = NotifierProvider<CrewController, void>(
  CrewController.new,
);
