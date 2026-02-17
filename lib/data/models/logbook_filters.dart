import 'logbook_entry.dart';

class LogbookFilters {
  const LogbookFilters({
    this.from,
    this.to,
    required this.types,
  });

  final DateTime? from;
  final DateTime? to;
  final Set<LogbookEventType> types;

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

  static LogbookFilters initial() {
    return const LogbookFilters(
      types: {
        LogbookEventType.flight,
        LogbookEventType.simulatorTraining,
        LogbookEventType.dutyPeriod,
        LogbookEventType.positioning,
      },
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
