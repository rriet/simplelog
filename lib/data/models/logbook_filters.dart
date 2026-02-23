import 'package:flutter/foundation.dart';
import 'package:simplelog/data/models/logbook_entry.dart';

@immutable
/// Public API documentation.
class LogbookFilters {
  /// Public API documentation.
  const LogbookFilters({
    required this.types,
    this.from,
    this.to,
  /// Public API documentation.
  });

  /// Public API documentation.
  factory LogbookFilters.initial() {
    return const LogbookFilters(
      types: {
        LogbookEventType.flight,
        LogbookEventType.simulatorTraining,
        LogbookEventType.dutyPeriod,
        LogbookEventType.positioning,
      },
    /// Public API documentation.
    );
  /// Public API documentation.
  }
/// Public API documentation.

  /// Public API documentation.
  final DateTime? from;
  /// Public API documentation.
  final DateTime? to;
  /// Public API documentation.
  final Set<LogbookEventType> types;

  /// Public API documentation.
  LogbookFilters copyWith({
    DateTime? from,
    DateTime? to,
    Set<LogbookEventType>? types,
  }) {
    return LogbookFilters(
      from: from ?? this.from,
      to: to ?? this.to,
      types: types ?? this.types,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LogbookFilters &&
        other.from == from &&
        other.to == to &&
        _setEquals(other.types, types);
  }

  @override
  int get hashCode {
    return Object.hash(from, to, Object.hashAll(types));
  }

  bool _setEquals(Set<LogbookEventType> a, Set<LogbookEventType> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final value in a) {
      if (!b.contains(value)) return false;
    }
    return true;
  }
}
