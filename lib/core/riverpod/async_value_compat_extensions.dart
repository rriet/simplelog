import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Backport of `valueOrNull` for `AsyncValue` until it lands upstream.
extension AsyncValueCompatValueOrNullX<T> on AsyncValue<T> {
  /// Returns the value when this is [AsyncData], otherwise `null`.
  T? get valueOrNull {
    return switch (this) {
      AsyncData(:final value) => value,
      _ => null,
    };
  }
}
