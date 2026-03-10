import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard navigation helpers for searchable picker lists.
class KeyboardListNavigation {
  /// Utility class; do not instantiate.
  const KeyboardListNavigation._();

  /// Handles arrow-key navigation from the search field into the list.
  static KeyEventResult handleSearchKey({
    required KeyEvent event,
    required int itemCount,
    required void Function(int index) focusListIndex,
  }) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (itemCount == 0) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      focusListIndex(0);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      focusListIndex(itemCount - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Handles per-row keyboard actions in list items.
  static KeyEventResult handleRowKey({
    required KeyEvent event,
    required int index,
    required int itemCount,
    required VoidCallback onActivate,
    required void Function(int index) focusListIndex,
    required VoidCallback focusSearch,
  }) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      onActivate();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      final next = index + 1;
      if (next < itemCount) {
        focusListIndex(next);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      final prev = index - 1;
      if (prev >= 0) {
        focusListIndex(prev);
        return KeyEventResult.handled;
      }
      focusSearch();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
