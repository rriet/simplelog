import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/presentation/shared/widgets/keyboard_list_navigation.dart';
import 'package:simplelog/presentation/shared/widgets/picker_search_bar.dart';

/// Public API documentation.
class EntityPickerDialog<T> extends ConsumerStatefulWidget {
  /// Public API documentation.
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
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final String title;
  /// Public API documentation.
  final String? searchLabel;
  /// Public API documentation.
  final String Function(WidgetRef ref)? searchLabelBuilder;
  /// Public API documentation.
  final AsyncValue<List<T>> Function(WidgetRef ref, String query) itemsBuilder;
  /// Public API documentation.
  final String Function(T item) itemTitle;
  /// Public API documentation.
  final Object Function(T item) itemKey;
  /// Public API documentation.
  final String? Function(T item)? itemSubtitle;
  /// Public API documentation.
  final bool Function(T item)? itemFilter;
  /// Public API documentation.
  final Widget? Function(BuildContext context, WidgetRef ref)?
      searchTrailingBuilder;
  /// Public API documentation.
  final Widget? Function(BuildContext context, T item)? itemTrailingBuilder;
  /// Public API documentation.
  final bool Function(T item)? isFavorite;
  /// Public API documentation.
  final Future<void> Function(WidgetRef ref, T item)? onToggleFavorite;
  /// Public API documentation.
  final String emptyText;
  /// Public API documentation.
  final Widget? loadingWidget;
  /// Public API documentation.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  ConsumerState<EntityPickerDialog<T>> createState() =>
      _EntityPickerDialogState<T>();
}

class _EntityPickerDialogState<T> extends ConsumerState<EntityPickerDialog<T>> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final List<FocusNode> _itemFocusNodes = [];
  final List<GlobalKey> _itemKeys = [];
  List<T> _visibleItems = const [];
  String _query = '';
  int _focusedIndex = -1;

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
        unawaited(
          Scrollable.ensureVisible(
            itemContext,
            duration: const Duration(milliseconds: 120),
            alignment: 0.5,
          ),
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
                    onKeyEvent: (node, event) => _onRowKey(index, item, event),
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
      ],
    );
  }
}
