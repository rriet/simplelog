import 'package:simplelog/data/database/enums/crew_position.dart';

/// Import configuration collected before processing a Qatar Airways workbook.
class QatarAirwaysImportOptions {
  /// Creates import options.
  const QatarAirwaysImportOptions({
    this.defaultPosition = CrewPosition.sic,
    this.myName = '',
  });

  /// Default position assigned to the self crew member.
  final CrewPosition defaultPosition;

  /// Pilot name as it appears in the workbook when self is a captain.
  final String myName;

  /// Returns a copy with selected fields replaced.
  QatarAirwaysImportOptions copyWith({
    CrewPosition? defaultPosition,
    String? myName,
  }) {
    return QatarAirwaysImportOptions(
      defaultPosition: defaultPosition ?? this.defaultPosition,
      myName: myName ?? this.myName,
    );
  }
}
