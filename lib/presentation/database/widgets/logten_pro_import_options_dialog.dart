import 'package:flutter/material.dart';
import 'package:simplelog/data/import/logten_pro_import_models.dart';
import 'package:simplelog/data/import/logten_pro_tsv_inspector.dart';

/// Configuration dialog shown before importing a LogTen Pro export.
class LogTenProImportOptionsDialog extends StatefulWidget {
  /// Creates the dialog.
  const LogTenProImportOptionsDialog({
    required this.fileName,
    required this.inspection,
    required this.initial,
    super.key,
  });

  /// Picked file name.
  final String fileName;

  /// Extracted TSV metadata.
  final LogTenProTsvInspection inspection;

  /// Initial import options.
  final LogTenImportOptions initial;

  /// Opens the dialog and returns selected options.
  static Future<LogTenImportOptions?> show(
    BuildContext context, {
    required String fileName,
    required LogTenProTsvInspection inspection,
    required LogTenImportOptions initial,
  }) {
    return showDialog<LogTenImportOptions>(
      context: context,
      builder: (context) => LogTenProImportOptionsDialog(
        fileName: fileName,
        inspection: inspection,
        initial: initial,
      ),
    );
  }

  @override
  State<LogTenProImportOptionsDialog> createState() =>
      _LogTenProImportOptionsDialogState();
}

class _LogTenProImportOptionsDialogState
    extends State<LogTenProImportOptionsDialog> {
  late final Map<String, LogTenFieldAssociation> _assignments;
  late int _timezoneOffsetMinutes;

  @override
  void initState() {
    super.initState();
    _assignments = Map<String, LogTenFieldAssociation>.from(
      widget.initial.assignments,
    );
    _timezoneOffsetMinutes = widget.initial.timezoneOffsetMinutes;
  }

  void _submit() {
    Navigator.of(context).pop(
      LogTenImportOptions(
        assignments: Map<String, LogTenFieldAssociation>.from(_assignments),
        timezoneOffsetMinutes: _timezoneOffsetMinutes,
        valueOverrides: widget.initial.valueOverrides,
        ignoredLines: widget.initial.ignoredLines,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timezoneOptions = _buildTimezoneOptions();
    return Dialog(
      child: SizedBox(
        width: 1100,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Import LogTen Pro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('File: ${widget.fileName}'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Source Column',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Association',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 520,
                        child: ListView.builder(
                          itemCount: widget.inspection.columns.length,
                          itemBuilder: (context, index) {
                            final column = widget.inspection.columns[index];
                            final value =
                                _assignments[column] ??
                                LogTenFieldAssociation.ignore;
                            return Container(
                              color: index.isEven
                                  ? Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.35)
                                  : null,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      column,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child:
                                        DropdownButtonFormField<
                                          LogTenFieldAssociation
                                        >(
                                          initialValue: value,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          items: [
                                            for (final option
                                                in LogTenFieldAssociation
                                                    .values)
                                              DropdownMenuItem(
                                                value: option,
                                                child: Text(option.label),
                                              ),
                                          ],
                                          onChanged: (selection) {
                                            if (selection == null) return;
                                            setState(() {
                                              _assignments[column] = selection;
                                            });
                                          },
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    const Text('Timezone'),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<int>(
                        initialValue: _timezoneOffsetMinutes,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          for (final option in timezoneOptions)
                            DropdownMenuItem(
                              value: option.offsetMinutes,
                              child: Text(option.label),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _timezoneOffsetMinutes = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 24),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submit,
                      child: const Text('Import'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<LogTenTimezoneOption> _buildTimezoneOptions() {
  return [
    for (var offset = -12; offset <= 14; offset += 1)
      LogTenTimezoneOption(
        label: offset == 0
            ? 'UTC (Zulu)'
            : 'UTC${offset > 0 ? '+' : '-'}'
                  '${offset.abs().toString().padLeft(2, '0')}:00',
        offsetMinutes: offset * 60,
      ),
  ];
}
