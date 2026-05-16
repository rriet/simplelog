// Small pure mapping helpers; field docs live on source/target option classes.
// ignore_for_file: public_member_api_docs

import 'package:simplelog/data/import/simplelog_import_options.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';
import 'package:simplelog/data/import/unified_import_options.dart';
import 'package:simplelog/data/import/wader_import_options.dart';

/// Maps shared pre-import options to source-specific import options.
class UnifiedImportOptionsMapper {
  const UnifiedImportOptionsMapper._();

  static SimpleLogImportOptions applyToSimpleLog(
    UnifiedImportOptions unified,
    SimpleLogImportOptions base,
  ) {
    return base.copyWith(
      recalculateTotalTime: unified.recalculateTotalTime,
      recalculateNightTime: unified.recalculateNightTime,
      recalculateTakeoffLanding: unified.recalculateTakeoffLanding,
      recalculateCrossCountry: unified.recalculateCrossCountry,
      recalculateIfrTime: unified.recalculateIfrTime,
      overrideAirportValues: unified.overrideAirportOnConflict,
      overrideAircraftValues: unified.overrideAircraftOnConflict,
      overrideAircraftTypeValues: unified.overrideTypeOnConflict,
    );
  }

  static SouthwestImportOptions applyToSouthwest(
    UnifiedImportOptions unified,
    SouthwestImportOptions base,
  ) {
    return base.copyWith(
      recalculateBlockTime: unified.recalculateTotalTime,
      recalculateNightTime: unified.recalculateNightTime,
      recalculateIfrTime: unified.recalculateIfrTime,
      recalculateCrossCountry: unified.recalculateCrossCountry,
      overrideExistingData:
          unified.overrideAirportOnConflict ||
          unified.overrideAircraftOnConflict ||
          unified.overrideTypeOnConflict,
    );
  }

  static WaderImportOptions applyToWader(UnifiedImportOptions unified) {
    return WaderImportOptions(
      recalculateTotalTime: unified.recalculateTotalTime,
    );
  }
}
