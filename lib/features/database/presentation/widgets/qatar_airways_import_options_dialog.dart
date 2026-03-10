import 'package:flutter/material.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/text_input_field.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/import/qatar_airways_import_options.dart';
import 'package:simplelog/data/import/qatar_airways_workbook_inspector.dart';

/// Configuration dialog shown before importing a Qatar Airways workbook.
class QatarAirwaysImportOptionsDialog extends StatefulWidget {
  /// Creates the dialog.
  const QatarAirwaysImportOptionsDialog({
    required this.fileName,
    required this.inspection,
    required this.initial,
    super.key,
  });

  /// Picked workbook file name.
  final String fileName;

  /// Extracted worksheet metadata.
  final QatarAirwaysWorkbookInspection inspection;

  /// Initial values used to populate the controls.
  final QatarAirwaysImportOptions initial;

  /// Opens the dialog and returns selected options.
  static Future<QatarAirwaysImportOptions?> show(
    BuildContext context, {
    required String fileName,
    required QatarAirwaysWorkbookInspection inspection,
    required QatarAirwaysImportOptions initial,
  }) {
    final screen = QatarAirwaysImportOptionsDialog(
      fileName: fileName,
      inspection: inspection,
      initial: initial,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return Navigator.of(
        context,
        rootNavigator: true,
      ).push<QatarAirwaysImportOptions>(
        MaterialPageRoute(builder: (_) => screen),
      );
    }
    return showDialog<QatarAirwaysImportOptions>(
      context: context,
      builder: (_) => screen,
    );
  }

  @override
  State<QatarAirwaysImportOptionsDialog> createState() =>
      _QatarAirwaysImportOptionsDialogState();
}

class _QatarAirwaysImportOptionsDialogState
    extends State<QatarAirwaysImportOptionsDialog> {
  late CrewPosition _defaultPosition;
  late final TextEditingController _myNameController;

  @override
  void initState() {
    super.initState();
    _defaultPosition = widget.initial.defaultPosition;
    _myNameController = TextEditingController(text: widget.initial.myName);
  }

  @override
  void dispose() {
    _myNameController.dispose();
    super.dispose();
  }

  void _submit() {
    final myName = _myNameController.text.trim();
    if (_defaultPosition == CrewPosition.pic && myName.isEmpty) {
      return;
    }
    Navigator.of(context).pop(
      QatarAirwaysImportOptions(
        defaultPosition: _defaultPosition,
        myName: myName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showMyName = _defaultPosition == CrewPosition.pic;
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('File: ${widget.fileName}'),
          const SizedBox(height: 12),
          DropdownButtonFormField<CrewPosition>(
            initialValue: _defaultPosition,
            decoration: const InputDecoration(
              labelText: 'Default position',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: CrewPosition.pic,
                child: Text('PIC'),
              ),
              DropdownMenuItem(
                value: CrewPosition.sic,
                child: Text('SIC'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _defaultPosition = value);
              }
            },
          ),
          if (showMyName) ...[
            const SizedBox(height: 12),
            TextInputField(
              controller: _myNameController,
              label: 'Pilot name as written on file',
            ),
          ],
        ],
      ),
    );
    return AdaptiveFormShell(
      onClose: () => Navigator.of(context).pop(),
      longTitle: 'Import Qatar Airways',
      shortTitle: 'Import Qatar',
      actions: [
        TextButton(onPressed: _submit, child: const Text('Import')),
      ],
      contentView: body,
    );
  }
}
