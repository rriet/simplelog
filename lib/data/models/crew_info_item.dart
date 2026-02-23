import 'dart:typed_data';

import 'package:simplelog/data/database/enums/crew_position.dart';

/// Public API documentation.
class CrewInfoItem {
  /// Public API documentation.
  const CrewInfoItem({
    required this.crewId,
    required this.name,
    required this.position,
    this.phone,
    this.email,
    this.notes,
    this.picture,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final int crewId;
  /// Public API documentation.
  final String name;
  /// Public API documentation.
  final CrewPosition position;
  /// Public API documentation.
  final String? phone;
  /// Public API documentation.
  final String? email;
  /// Public API documentation.
  final String? notes;
  /// Public API documentation.
  final Uint8List? picture;

  /// Public API documentation.
  String get positionLabel => position.name.toUpperCase();
}
