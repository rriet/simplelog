import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Public API documentation.
extension AsyncValueCompatValueOrNullX<T> on AsyncValue<T> {
  /// Public API documentation.
  T? get valueOrNull {
    return switch (this) {
      AsyncData(:final value) => value,
      _ => null,
    };
  }
}
