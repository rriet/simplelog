import 'package:flutter/material.dart';
import 'package:simplelog/data/import/logten_pro_tsv_inspector.dart';

/// Temporary preview dialog for LogTen Pro tab-separated imports.
class LogTenProImportOptionsDialog extends StatelessWidget {
  /// Creates the dialog.
  const LogTenProImportOptionsDialog({
    required this.fileName,
    required this.inspection,
    super.key,
  });

  /// Picked file name.
  final String fileName;

  /// Extracted TSV metadata.
  final LogTenProTsvInspection inspection;

  /// Opens the dialog.
  static Future<void> show(
    BuildContext context, {
    required String fileName,
    required LogTenProTsvInspection inspection,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => LogTenProImportOptionsDialog(
        fileName: fileName,
        inspection: inspection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 640,
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('File: $fileName'),
                      const SizedBox(height: 16),
                      for (
                        var index = 0;
                        index < inspection.columns.length;
                        index++
                      )
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '${index + 1}. ${inspection.columns[index]}',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
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
