import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/data/import/logten_pro_import_models.dart';
import 'package:simplelog/data/import/logten_pro_tsv_inspector.dart';
import 'package:simplelog/features/database/presentation/widgets/import_wizard/sections/import_field_mapping_section.dart';

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
    final screen = LogTenProImportOptionsDialog(
      fileName: fileName,
      inspection: inspection,
      initial: initial,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return AppNavigator.pushMaterial<LogTenImportOptions>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<LogTenImportOptions>(
      context: context,
      builder: (_) => screen,
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
    AppNavigator.pop(
      context,
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
    final l10n = AppLocalizations.of(context)!;
    final timezoneOptions = _buildTimezoneOptions();
    final mappingRows = widget.inspection.columns
        .map((column) {
          final value = _assignments[column] ?? LogTenFieldAssociation.ignore;
          return ImportFieldMappingRow<LogTenFieldAssociation>(
            sourceLabel: column,
            value: value,
            items: [
              for (final option in LogTenFieldAssociation.values)
                DropdownMenuItem(
                  value: option,
                  child: Text(option.label),
                ),
            ],
            onChanged: (selection) {
              setState(() {
                _assignments[column] = selection;
              });
            },
          );
        })
        .toList(growable: false);

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.databaseFileLabel(widget.fileName)),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ImportFieldMappingSection<LogTenFieldAssociation>(
              sourceHeaderLabel: l10n.logtenSourceColumnHeader,
              mappingHeaderLabel: l10n.logtenAssociationHeader,
              rows: mappingRows,
              dropdownSelectedLabelBuilder: (value) => value.label,
              footer: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(l10n.logtenTimezoneLabel),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width < 760
                        ? double.infinity
                        : 220,
                    child: DropdownButtonFormField<int>(
                      initialValue: _timezoneOffsetMinutes,
                      isExpanded: true,
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
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.logtenImportTitle,
      actions: [
        TextButton(onPressed: _submit, child: Text(l10n.logtenImportAction)),
      ],
      contentView: body,
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
