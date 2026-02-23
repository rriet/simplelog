import 'package:flutter/material.dart';

/// Public API documentation.
class AlphanumericSearchKeyboard extends StatelessWidget {
  /// Public API documentation.
  const AlphanumericSearchKeyboard({
    required this.onText,
    required this.onBackspace,
    required this.onEnter,
    super.key,
    this.onSpace,
    this.onHide,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final ValueChanged<String> onText;
  /// Public API documentation.
  final VoidCallback onBackspace;
  /// Public API documentation.
  final VoidCallback onEnter;
  /// Public API documentation.
  final VoidCallback? onSpace;
  /// Public API documentation.
  final VoidCallback? onHide;

  static const _gap = 8.0;
  static const _rowHeight = 56.0;
  static const double _bottomSpacer = _rowHeight * 2 / 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      color: const Color(0xFFD1D5DB),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          _buildRow(
            [
              ...'1234567890'.split(''),
            ],
            fixedKeyWidth: true,
          ),
          const SizedBox(height: _gap),
          _buildRow(
            [
              ...'QWERTYUIOP'.split(''),
            ],
            fixedKeyWidth: true,
          ),
          const SizedBox(height: _gap),
          _buildRow(
            [
              ...'ASDFGHJKL'.split(''),
            ],
            fixedKeyWidth: true,
          ),
          const SizedBox(height: _gap),
          _buildRow(
            [
              ...'ZXCVBNM'.split(''),
              '-',
              const _KeySpec.icon(
                Icons.backspace_outlined,
                action: _KeyAction.backspace,
                isSpecial: true,
              ),
            ],
            fixedKeyWidth: true,
          ),
          const SizedBox(height: _gap),
          _buildRow(
            [
              const _KeySpec.smallInset(),
              const _KeySpec.text('SPACE', action: _KeyAction.space, flex: 7),
              const _KeySpec.icon(
                Icons.keyboard_hide_outlined,
                action: _KeyAction.hide,
                isSpecial: true,
              ),
              const _KeySpec.icon(
                Icons.check,
                action: _KeyAction.enter,
                isPrimary: true,
                flex: 2,
              ),
            ],
          ),
          const SizedBox(height: _bottomSpacer),
        ],
      ),
    );
  }

  Widget _buildRow(List<dynamic> items, {bool fixedKeyWidth = false}) {
    final specs = items.map(_toSpec).toList(growable: false);
    if (fixedKeyWidth) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedWidth || constraints.maxWidth <= 0) {
            return _buildFlexibleRow(specs);
          }
          final count = specs.length;
          if (count == 0) return const SizedBox.shrink();
          final maxFitWidth =
              (constraints.maxWidth - (count - 1) * _gap) / count;
          if (maxFitWidth <= 0) {
            return _buildFlexibleRow(specs);
          }
          final targetWidth = constraints.maxWidth * 0.088;
          final minWidth = maxFitWidth < 36.0 ? maxFitWidth : 36.0;
          final keyWidth = targetWidth.clamp(minWidth, maxFitWidth);
          final rowWidth = count * keyWidth + (count - 1) * _gap;
          final horizontalInset = ((constraints.maxWidth - rowWidth) / 2).clamp(
            0.0,
            double.infinity,
          );
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalInset),
            child: Row(
              children: [
                for (var i = 0; i < specs.length; i++) ...[
                  SizedBox(width: keyWidth, child: _buildKey(specs[i])),
                  if (i != specs.length - 1) const SizedBox(width: _gap),
                ],
              ],
            ),
          );
        },
      );
    }
    return _buildFlexibleRow(specs);
  }

  Widget _buildFlexibleRow(List<_KeySpec> specs) {
    return Row(
      children: [
        for (var i = 0; i < specs.length; i++) ...[
          Expanded(
            flex: specs[i].flex,
            child: _buildKey(specs[i]),
          ),
          if (i != specs.length - 1) const SizedBox(width: _gap),
        ],
      ],
    );
  }

  _KeySpec _toSpec(dynamic value) {
    if (value is _KeySpec) return value;
    if (value is String) {
      return _KeySpec.text(value, action: _KeyAction.text);
    }
    throw ArgumentError('Unsupported key spec type: ${value.runtimeType}');
  }

  Widget _buildKey(_KeySpec spec) {
    if (spec.isSpacer) {
      return const SizedBox(height: _rowHeight);
    }

    void onPressed() {
      switch (spec.action) {
        case _KeyAction.text:
          onText(spec.label!);
        case _KeyAction.backspace:
          onBackspace();
        case _KeyAction.enter:
          onEnter();
        case _KeyAction.space:
          if (onSpace != null) {
            onSpace!();
          } else {
            onText(' ');
          }
        case _KeyAction.hide:
          onHide?.call();
        case _KeyAction.none:
          return;
      }
    }

    final style = FilledButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, _rowHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      backgroundColor: spec.isPrimary
          ? const Color(0xFF0A84FF)
          : (spec.isSpecial
                ? const Color(0xFFA5ADB8)
                : const Color(0xFFF2F2F3)),
      foregroundColor: spec.isPrimary ? Colors.white : Colors.black87,
    );

    return FilledButton(
      onPressed: spec.action == _KeyAction.none ? null : onPressed,
      style: style,
      child: spec.icon != null
          ? Icon(spec.icon, size: 24)
          : Text(
              spec.label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
    );
  }
}

enum _KeyAction { text, backspace, enter, space, hide, none }

class _KeySpec {
  const _KeySpec.text(
    this.label, {
    this.action = _KeyAction.none,
    this.flex = 1,
  }) : icon = null,
       isPrimary = false,
       isSpecial = false,
       isSpacer = false;

  const _KeySpec.icon(
    this.icon, {
    this.action = _KeyAction.none,
    this.flex = 1,
    this.isPrimary = false,
    this.isSpecial = false,
  }) : label = null,
       isSpacer = false;

  const _KeySpec.smallInset()
    : label = null,
      icon = null,
      action = _KeyAction.none,
      flex = 1,
      isPrimary = false,
      isSpecial = false,
      isSpacer = true;

  final String? label;
  final IconData? icon;
  final _KeyAction action;
  final int flex;
  final bool isPrimary;
  final bool isSpecial;
  final bool isSpacer;
}
