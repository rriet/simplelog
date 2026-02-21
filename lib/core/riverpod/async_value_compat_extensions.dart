import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueCompatValueOrNullX<T> on AsyncValue<T> {
  T? get valueOrNull {
    return switch (this) {
      AsyncData(:final value) => value,
      _ => null,
    };
  }
}
