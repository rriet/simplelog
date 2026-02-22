import 'dart:typed_data';

import 'package:simplelog/data/database/enums/crew_position.dart';

class CrewInfoItem {
  const CrewInfoItem({
    required this.crewId,
    required this.name,
    required this.position,
    this.phone,
    this.email,
    this.notes,
    this.picture,
  });

  final int crewId;
  final String name;
  final CrewPosition position;
  final String? phone;
  final String? email;
  final String? notes;
  final Uint8List? picture;

  String get positionLabel => position.name.toUpperCase();
}
