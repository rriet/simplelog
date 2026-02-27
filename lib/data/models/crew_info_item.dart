import 'dart:typed_data';

import 'package:simplelog/data/database/enums/crew_position.dart';

/// Expanded crew information used in detail views and reports.
class CrewInfoItem {
  /// Creates a crew info item.
  const CrewInfoItem({
    required this.crewId,
    required this.name,
    required this.position,
    this.phone,
    this.email,
    this.notes,
    this.picture,
  });

  /// Crew id.
  final int crewId;
  /// Crew display name.
  final String name;
  /// Assigned crew position.
  final CrewPosition position;
  /// Optional phone number.
  final String? phone;
  /// Optional email address.
  final String? email;
  /// Optional notes.
  final String? notes;
  /// Optional picture bytes.
  final Uint8List? picture;

  /// Uppercase label of [position].
  String get positionLabel => position.name.toUpperCase();
}
