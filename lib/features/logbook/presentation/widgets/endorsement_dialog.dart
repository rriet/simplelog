import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/dialog_adaptive_presenter.dart';
import 'package:simplelog/core/presentation/widgets/display/square_outline_button.dart';
import 'package:simplelog/data/models/endorsement_data.dart';

/// Dialog to edit an entry endorsement and signature.
class EndorsementDialog extends StatefulWidget {
  /// Creates a dialog with an optional initial endorsement.
  const EndorsementDialog({super.key, this.initial});

  /// Initial endorsement value.
  final EndorsementData? initial;

  /// Shows the endorsement dialog.
  static Future<EndorsementData?> show(
    BuildContext context, {
    EndorsementData? initial,
  }) {
    if (isCompactDialogScreen(context)) {
      return AppNavigator.pushMaterial<EndorsementData>(
        context,
        (_) => EndorsementDialog(initial: initial),
      );
    }
    return showDialog<EndorsementData>(
      context: context,
      builder: (_) => EndorsementDialog(initial: initial),
    );
  }

  @override
  State<EndorsementDialog> createState() => _EndorsementDialogState();
}

class _EndorsementDialogState extends State<EndorsementDialog> {
  final _nameController = TextEditingController();
  final _certificateController = TextEditingController();
  final _typeController = TextEditingController();
  final _expiryController = TextEditingController();
  Uint8List? _signatureImage;

  void _setExpiry(DateTime picked) {
    setState(() {
      _expiryController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  void _setSignature(Uint8List bytes) {
    setState(() => _signatureImage = bytes);
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial == null) return;
    _nameController.text = initial.name;
    _certificateController.text = initial.certificate;
    _typeController.text = initial.type;
    _expiryController.text = initial.expiry;
    _signatureImage = initial.signatureImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _certificateController.dispose();
    _typeController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasInitial = widget.initial != null && !widget.initial!.isEmpty;
    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: AppLocalizations.of(context)!.autoUi028,
      popupMaxWidth: 760,
      actions: [
        TextButton(
          onPressed: _save,
          child: Text(AppLocalizations.of(context)!.saveAction),
        ),
      ],
      contentView: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(l10n.endorsementLockWarning),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _certificateController,
              decoration: const InputDecoration(
                labelText: 'Certificate',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _expiryController,
              readOnly: true,
              onTap: _pickExpiry,
              decoration: InputDecoration(
                labelText: 'Expiry',
                suffixIcon: IconButton(
                  onPressed: _expiryController.text.trim().isEmpty
                      ? null
                      : () => setState(() => _expiryController.text = ''),
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SignaturePreviewPanel(
              height: 130,
              child: _signatureImage == null
                  ? Center(child: Text(AppLocalizations.of(context)!.autoUi044))
                  : Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.memory(
                        _signatureImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SquareOutlineButton(
                  label: AppLocalizations.of(context)!.autoUi055,
                  icon: Icons.gesture,
                  onPressed: _captureSignature,
                ),
                const SizedBox(width: 8),
                SquareOutlineButton(
                  label: AppLocalizations.of(context)!.autoUi012,
                  icon: Icons.delete_outline,
                  onPressed: _signatureImage == null
                      ? null
                      : () => setState(() => _signatureImage = null),
                ),
                if (hasInitial) ...[
                  const SizedBox(width: 8),
                  SquareOutlineButton(
                    label: AppLocalizations.of(context)!.autoUi048,
                    icon: Icons.remove_circle_outline,
                    onPressed: () => AppNavigator.pop(
                      context,
                      const EndorsementData(
                        name: '',
                        certificate: '',
                        expiry: '',
                        type: '',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickExpiry() async {
    final initialDate = _parseIsoDate(_expiryController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    if (!mounted) return;
    _setExpiry(picked);
  }

  DateTime? _parseIsoDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } on Object {
      return null;
    }
  }

  Future<void> _captureSignature() async {
    final bytes = await showDialog<Uint8List>(
      context: context,
      builder: (_) => const _SignaturePadDialog(),
    );
    if (bytes == null) return;
    if (!mounted) return;
    _setSignature(bytes);
  }

  void _save() {
    final result = EndorsementData(
      name: _nameController.text.trim(),
      certificate: _certificateController.text.trim(),
      expiry: _expiryController.text.trim(),
      type: _typeController.text.trim(),
      signatureImage: _signatureImage,
    );
    AppNavigator.pop(context, result);
  }
}

class _SignaturePadDialog extends StatefulWidget {
  const _SignaturePadDialog();

  @override
  State<_SignaturePadDialog> createState() => _SignaturePadDialogState();
}

class _SignaturePadDialogState extends State<_SignaturePadDialog> {
  final List<List<Offset>> _strokes = <List<Offset>>[];
  Size _canvasSize = const Size(600, 200);
  static const _strokeWidth = 3.5;
  static const _outputWidth = 1200;
  static const _outputHeight = 400;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 420),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.autoUi055,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _save,
                    child: Text(AppLocalizations.of(context)!.saveAction),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    var width = constraints.maxWidth;
                    var height = width / 3;
                    if (height > constraints.maxHeight) {
                      height = constraints.maxHeight;
                      width = height * 3;
                    }
                    _canvasSize = Size(width, height);
                    return Center(
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: _SignaturePreviewPanel(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (details) => _startStroke(
                              details.localPosition,
                            ),
                            onPanUpdate: (details) => _appendStroke(
                              details.localPosition,
                            ),
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: _SignaturePainter(strokes: _strokes),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SquareOutlineButton(
                  label: AppLocalizations.of(context)!.reportsClearAction,
                  icon: Icons.delete_outline,
                  onPressed: () => setState(_strokes.clear),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final bytes = await _exportSignaturePng();
    if (!mounted || bytes == null) {
      return;
    }
    AppNavigator.pop(context, bytes);
  }

  void _startStroke(Offset position) {
    setState(() {
      _strokes.add(<Offset>[position]);
    });
  }

  void _appendStroke(Offset position) {
    if (_strokes.isEmpty) {
      return;
    }
    setState(() {
      _strokes.last.add(position);
    });
  }

  Future<Uint8List?> _exportSignaturePng() async {
    if (_strokes.isEmpty) return null;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final scaleX = _outputWidth / _canvasSize.width;
    final scaleY = _outputHeight / _canvasSize.height;
    final strokeScale = (scaleX + scaleY) / 2;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = _strokeWidth * strokeScale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in _strokes) {
      if (stroke.length < 2) {
        if (stroke.isNotEmpty) {
          final point = Offset(
            stroke.first.dx * scaleX,
            stroke.first.dy * scaleY,
          );
          canvas.drawCircle(
            point,
            (_strokeWidth * strokeScale) * 0.75,
            Paint()..color = Colors.black,
          );
        }
        continue;
      }
      final first = stroke.first;
      final path = Path()..moveTo(first.dx * scaleX, first.dy * scaleY);
      for (var i = 1; i < stroke.length; i++) {
        final point = stroke[i];
        path.lineTo(point.dx * scaleX, point.dy * scaleY);
      }
      canvas.drawPath(path, paint);
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(_outputWidth, _outputHeight);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }
}

class _SignaturePreviewPanel extends StatelessWidget {
  const _SignaturePreviewPanel({
    required this.child,
    this.height,
  });

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: _signaturePreviewDecoration(context),
      child: child,
    );
  }
}

BoxDecoration _signaturePreviewDecoration(BuildContext context) {
  return BoxDecoration(
    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    borderRadius: BorderRadius.circular(8),
  );
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter({required this.strokes});

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = _SignaturePadDialogState._strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(
          stroke.first,
          _SignaturePadDialogState._strokeWidth * 0.75,
          Paint()..color = Colors.black,
        );
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}
