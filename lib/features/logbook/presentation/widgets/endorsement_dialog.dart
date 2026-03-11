import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final hasInitial = widget.initial != null && !widget.initial!.isEmpty;
    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      longTitle: 'Endorsement',
      shortTitle: 'Endorsement',
      popupMaxWidth: 760,
      actions: [
        TextButton(
          onPressed: _save,
          child: const Text('Save'),
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
              child: const Text(
                'Once saved with an endorsement signature, this entry '
                'is locked and cannot be edited unless the signature '
                'is removed.',
              ),
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
            Container(
              height: 130,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _signatureImage == null
                  ? const Center(child: Text('No signature'))
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
                  label: 'Sign on screen',
                  icon: Icons.gesture,
                  onPressed: _captureSignature,
                ),
                const SizedBox(width: 8),
                SquareOutlineButton(
                  label: 'Clear signature',
                  icon: Icons.delete_outline,
                  onPressed: _signatureImage == null
                      ? null
                      : () => setState(() => _signatureImage = null),
                ),
                if (hasInitial) ...[
                  const SizedBox(width: 8),
                  SquareOutlineButton(
                    label: 'Remove endorsement',
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
    setState(() {
      _expiryController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
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
    setState(() => _signatureImage = bytes);
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
  Size _canvasSize = const Size(520, 240);
  static const _strokeWidth = 3.5;

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
                  const Expanded(
                    child: Text(
                      'Sign on screen',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _save,
                    child: const Text('Save'),
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
                    _canvasSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (details) {
                          setState(() {
                            _strokes.add(<Offset>[details.localPosition]);
                          });
                        },
                        onPanUpdate: (details) {
                          if (_strokes.isEmpty) {
                            return;
                          }
                          setState(() {
                            _strokes.last.add(details.localPosition);
                          });
                        },
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _SignaturePainter(strokes: _strokes),
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
                  label: 'Clear',
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

  Future<Uint8List?> _exportSignaturePng() async {
    if (_strokes.isEmpty) return null;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in _strokes) {
      if (stroke.length < 2) {
        if (stroke.isNotEmpty) {
          canvas.drawCircle(
            stroke.first,
            _strokeWidth * 0.75,
            Paint()..color = Colors.black,
          );
        }
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      _canvasSize.width.round().clamp(1, 4096),
      _canvasSize.height.round().clamp(1, 4096),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }
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
