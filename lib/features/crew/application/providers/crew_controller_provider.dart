import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/crew/application/crew_controller.dart';

/// Public API documentation.
final crewControllerProvider = NotifierProvider<CrewController, void>(
  CrewController.new,
);
