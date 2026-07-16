import 'package:simplelog/data/import/unified_import_options.dart';
import 'package:simplelog/data/import/wader_import_models.dart';

/// Options and user resolutions applied to a ForeFlight import.
class ForeFlightImportOptions {
  /// Creates ForeFlight import options.
  const ForeFlightImportOptions({
    required this.unified,
    this.review = const WaderImportReviewOptions(),
  });

  /// Shared recalculation and conflict behavior.
  final UnifiedImportOptions unified;

  /// Per-row values selected in the shared issue review UI.
  final WaderImportReviewOptions review;

  /// Returns a copy with selected values replaced.
  ForeFlightImportOptions copyWith({
    UnifiedImportOptions? unified,
    WaderImportReviewOptions? review,
  }) {
    return ForeFlightImportOptions(
      unified: unified ?? this.unified,
      review: review ?? this.review,
    );
  }
}
