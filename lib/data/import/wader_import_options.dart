/// Runtime options for Wader CSV import.
class WaderImportOptions {
  /// Creates options.
  const WaderImportOptions({this.recalculateTotalTime = false});

  /// Whether total time should be recalculated for all eligible rows.
  final bool recalculateTotalTime;

  /// Returns a copy with selected values replaced.
  WaderImportOptions copyWith({bool? recalculateTotalTime}) {
    return WaderImportOptions(
      recalculateTotalTime: recalculateTotalTime ?? this.recalculateTotalTime,
    );
  }
}
