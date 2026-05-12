import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/presentation/widgets/keyboard/keyboard_list_navigation.dart';
import 'package:simplelog/core/presentation/widgets/pickers/picker_search_bar.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';

/// Generic searchable picker dialog for selecting an entity of type [T].
class EntityPickerDialog<T> extends ConsumerStatefulWidget {
  /// Creates the picker dialog.
  const EntityPickerDialog({
    required this.title,
    required this.itemsBuilder,
    required this.itemTitle,
    required this.itemKey,
    super.key,
    this.searchLabel,
    this.searchLabelBuilder,
    this.itemSubtitle,
    this.itemFilter,
    this.searchTrailingBuilder,
    this.itemTrailingBuilder,
    this.isFavorite,
    this.onToggleFavorite,
    this.emptyText = 'No results found',
    this.loadingWidget,
    this.errorBuilder,
    this.showHeader = true,
  });

  /// Dialog title.
  final String title;

  /// Static search label (when [searchLabelBuilder] is not provided).
  final String? searchLabel;

  /// Dynamic search label builder.
  final String Function(WidgetRef ref)? searchLabelBuilder;

  /// Builds async items list for the current search query.
  final AsyncValue<List<T>> Function(WidgetRef ref, String query) itemsBuilder;

  /// Returns title text for each item row.
  final String Function(T item) itemTitle;

  /// Returns stable key value used for item identity.
  final Object Function(T item) itemKey;

  /// Optional subtitle text per item.
  final String? Function(T item)? itemSubtitle;

  /// Optional extra filter applied after loading items.
  final bool Function(T item)? itemFilter;

  /// Optional trailing widget builder for the search row.
  final Widget? Function(BuildContext context, WidgetRef ref)?
  searchTrailingBuilder;

  /// Optional trailing widget builder per item row.
  final Widget? Function(BuildContext context, T item)? itemTrailingBuilder;

  /// Optional favorite-state resolver.
  final bool Function(T item)? isFavorite;

  /// Optional callback to toggle favorite state.
  final Future<void> Function(WidgetRef ref, T item)? onToggleFavorite;

  /// Empty-state message.
  final String emptyText;

  /// Optional loading replacement widget.
  final Widget? loadingWidget;

  /// Optional custom error builder.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Whether to render built-in title/close header.
  final bool showHeader;

  @override
  ConsumerState<EntityPickerDialog<T>> createState() =>
      _EntityPickerDialogState<T>();
}

class _EntityPickerDialogState<T> extends ConsumerState<EntityPickerDialog<T>> {
  static const double _customKeyboardInset = 260;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final List<FocusNode> _itemFocusNodes = [];
  final List<GlobalKey> _itemKeys = [];
  List<T> _visibleItems = const [];
  String _query = '';
  int _focusedIndex = -1;
  bool _customKeyboardVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    for (final node in _itemFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _ensureItemFocusNodes(int count) {
    while (_itemFocusNodes.length < count) {
      _itemFocusNodes.add(FocusNode());
    }
    while (_itemFocusNodes.length > count) {
      _itemFocusNodes.removeLast().dispose();
    }
    while (_itemKeys.length < count) {
      _itemKeys.add(GlobalKey());
    }
    while (_itemKeys.length > count) {
      _itemKeys.removeLast();
    }
  }

  void _focusListIndex(int index) {
    if (index < 0 || index >= _itemFocusNodes.length) return;
    setState(() => _focusedIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _itemFocusNodes[index].requestFocus();
      final itemContext = _itemKeys[index].currentContext;
      if (itemContext != null) {
        Scrollable.ensureVisible(
          itemContext,
          duration: const Duration(milliseconds: 120),
          alignment: 0.5,
        );
      }
    });
  }

  void _selectItem(T item) {
    Navigator.of(context).pop(item);
  }

  KeyEventResult _onSearchKey(FocusNode node, KeyEvent event) {
    return KeyboardListNavigation.handleSearchKey(
      event: event,
      itemCount: _visibleItems.length,
      focusListIndex: _focusListIndex,
    );
  }

  KeyEventResult _onRowKey(int index, T item, KeyEvent event) {
    return KeyboardListNavigation.handleRowKey(
      event: event,
      index: index,
      itemCount: _visibleItems.length,
      onActivate: () => _selectItem(item),
      focusListIndex: _focusListIndex,
      focusSearch: _searchFocusNode.requestFocus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = widget.itemsBuilder(ref, _query);
    final loadedItems = itemsAsync.valueOrNull ?? <T>[];
    _visibleItems = widget.itemFilter == null
        ? loadedItems
        : loadedItems.where(widget.itemFilter!).toList(growable: false);
    _ensureItemFocusNodes(_visibleItems.length);
    if (_focusedIndex >= _visibleItems.length) {
      _focusedIndex = _visibleItems.isEmpty ? -1 : _visibleItems.length - 1;
    }

    return Column(
      children: [
        if (widget.showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        PickerSearchBar(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: true,
          useCustomKeyboard: true,
          onCustomKeyboardVisibilityChanged: (visible) {
            if (_customKeyboardVisible == visible) return;
            setState(() => _customKeyboardVisible = visible);
          },
          label:
              widget.searchLabelBuilder?.call(ref) ??
              widget.searchLabel ??
              'Search',
          onChanged: (value) => setState(() => _query = value),
          onSubmitted: (_) {
            if (_visibleItems.isEmpty) return;
            _selectItem(_visibleItems.first);
          },
          onKeyEvent: _onSearchKey,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          trailing: widget.searchTrailingBuilder?.call(context, ref),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: _customKeyboardVisible ? _customKeyboardInset : 0,
            ),
            child: itemsAsync.when(
              data: (items) {
                final list = widget.itemFilter == null
                    ? items
                    : items.where(widget.itemFilter!).toList();
                if (list.isEmpty) {
                  return Center(child: Text(widget.emptyText));
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final isFocused = _focusedIndex == index;
                    final isActive = isFocused;
                    final subtitle = widget.itemSubtitle?.call(item);
                    final extraTrailing = widget.itemTrailingBuilder?.call(
                      context,
                      item,
                    );
                    final hasFavorite =
                        widget.isFavorite != null &&
                        widget.onToggleFavorite != null;
                    final trailingWidgets = <Widget?>[
                      extraTrailing,
                      if (hasFavorite)
                        IconButton(
                          tooltip: widget.isFavorite!(item)
                              ? 'Remove favorite'
                              : 'Mark favorite',
                          icon: Icon(
                            widget.isFavorite!(item)
                                ? Icons.star
                                : Icons.star_border,
                            color: widget.isFavorite!(item)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                          onPressed: () async {
                            await widget.onToggleFavorite!(ref, item);
                          },
                        ),
                    ].whereType<Widget>().toList(growable: false);

                    return Focus(
                      key: _itemKeys[index],
                      focusNode: _itemFocusNodes[index],
                      onFocusChange: (hasFocus) {
                        if (hasFocus && mounted) {
                          setState(() => _focusedIndex = index);
                        }
                      },
                      onKeyEvent: (node, event) =>
                          _onRowKey(index, item, event),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        color: isActive
                            ? Theme.of(context).colorScheme.primaryContainer
                                  .withValues(alpha: 0.45)
                            : Colors.transparent,
                        child: ListTile(
                          selected: isActive,
                          title: Text(widget.itemTitle(item)),
                          subtitle: subtitle == null ? null : Text(subtitle),
                          trailing: trailingWidgets.isEmpty
                              ? null
                              : trailingWidgets.length == 1
                              ? trailingWidgets.first
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: trailingWidgets,
                                ),
                          onTap: () => _selectItem(item),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  widget.loadingWidget ??
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  widget.errorBuilder?.call(context, error) ??
                  Center(child: Text(error.toString())),
            ),
          ),
        ),
      ],
    );
  }
}
