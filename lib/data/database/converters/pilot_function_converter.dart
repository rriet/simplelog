import 'package:drift/drift.dart';

import 'package:simplelog/data/database/enums/pilot_function.dart';

/// Converts [PilotFunction] values to and from database strings.
class PilotFunctionConverter extends TypeConverter<PilotFunction, String> {
  /// Creates a stateless pilot function converter.
  const PilotFunctionConverter();

  @override
  PilotFunction fromSql(String fromDb) {
    final normalized = fromDb.trim().toUpperCase().replaceAll(' ', '');
    return switch (normalized) {
      'PF' => PilotFunction.pf,
      'PNF' => PilotFunction.pnf,
      'PM' => PilotFunction.pnf,
      'PF/PNF' => PilotFunction.pfPnf,
      'PNF/PF' => PilotFunction.pnfPf,
      'PM/PF' => PilotFunction.pnfPf,
      'IRP3' => PilotFunction.irp3,
      'IRP4' => PilotFunction.irp4,
      'OTHER' => PilotFunction.other,
      _ => PilotFunction.other,
    };
  }

  @override
  String toSql(PilotFunction value) {
    return switch (value) {
      PilotFunction.pf => 'PF',
      PilotFunction.pnf => 'PNF',
      PilotFunction.pfPnf => 'PF/PNF',
      PilotFunction.pnfPf => 'PNF/PF',
      PilotFunction.irp3 => 'IRP3',
      PilotFunction.irp4 => 'IRP4',
      PilotFunction.other => 'OTHER',
    };
  }
}
