import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simplelog/presentation/shared/widgets/alphanumeric_search_keyboard.dart';

class PickerSearchBar extends StatefulWidget {
  const PickerSearchBar({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.onSubmitted,
    this.onKeyEvent,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 0),
    this.useCustomKeyboard = false,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final KeyEventResult Function(FocusNode, KeyEvent)? onKeyEvent;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool useCustomKeyboard;

  @override
  State<PickerSearchBar> createState() => _PickerSearchBarState();
}

class _PickerSearchBarState extends State<PickerSearchBar> {
  late final FocusNode _internalFocusNode;
  OverlayEntry? _keyboardOverlay;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;
  bool get _isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    _effectiveFocusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant PickerSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      _effectiveFocusNode.addListener(_onFocusChanged);
    }
    if ((!widget.useCustomKeyboard || !_isIos) && _keyboardOverlay != null) {
      _hideKeyboardOverlay();
    }
  }

  @override
  void dispose() {
    _hideKeyboardOverlay();
    _effectiveFocusNode.removeListener(_onFocusChanged);
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (widget.useCustomKeyboard && _isIos && _effectiveFocusNode.hasFocus) {
      _showKeyboardOverlay();
    } else {
      _hideKeyboardOverlay();
    }
    if (mounted) setState(() {});
  }

  void _showKeyboardOverlay() {
    if (_keyboardOverlay != null) return;
    final overlay = Overlay.of(context, rootOverlay: true);
    _keyboardOverlay = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                bottom: false,
                child: Material(
                  color: Colors.transparent,
                  child: _BottomKeyboardPanel(
                    keyboard: AlphanumericSearchKeyboard(
                      onText: (value) => _insertText(value.toUpperCase()),
                      onBackspace: _backspace,
                      onSpace: () => _insertText(' '),
                      onEnter: () =>
                          widget.onSubmitted?.call(widget.controller.text),
                      onHide: () {
                        _effectiveFocusNode.unfocus();
                        _hideKeyboardOverlay();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_keyboardOverlay!);
  }

  void _hideKeyboardOverlay() {
    _keyboardOverlay?.remove();
    _keyboardOverlay = null;
  }

  void _insertText(String text) {
    final value = widget.controller.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    final safeStart = start.clamp(0, value.text.length);
    final safeEnd = end.clamp(0, value.text.length);
    final newText = value.text.replaceRange(safeStart, safeEnd, text);
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: safeStart + text.length),
    );
    widget.onChanged(newText);
  }

  void _backspace() {
    final value = widget.controller.value;
    final selection = value.selection;
    if (!selection.isValid) return;
    final start = selection.start;
    final end = selection.end;
    if (start != end) {
      final newText = value.text.replaceRange(start, end, '');
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start),
      );
      widget.onChanged(newText);
      return;
    }
    if (start <= 0) return;
    final newText = value.text.replaceRange(start - 1, start, '');
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start - 1),
    );
    widget.onChanged(newText);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        children: [
          Expanded(
            child: Focus(
              onKeyEvent: widget.onKeyEvent,
              child: TextField(
                controller: widget.controller,
                focusNode: _effectiveFocusNode,
                autofocus: widget.autofocus,
                readOnly: widget.useCustomKeyboard && _isIos,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: widget.label,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onTap: () => _effectiveFocusNode.requestFocus(),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
              ),
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 8),
            widget.trailing!,
          ],
        ],
      ),
    );
  }
}

class _BottomKeyboardPanel extends StatefulWidget {
  const _BottomKeyboardPanel({
    required this.keyboard,
  });

  final Widget keyboard;

  @override
  State<_BottomKeyboardPanel> createState() => _BottomKeyboardPanelState();
}

class _BottomKeyboardPanelState extends State<_BottomKeyboardPanel> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        padding: EdgeInsets.zero,
        child: widget.keyboard,
      ),
    );
  }
}
