import 'package:flutter/material.dart';

/// One row in a shared import field-mapping section.
class ImportFieldMappingRow<T> {
  /// Creates a mapping row.
  const ImportFieldMappingRow({
    required this.sourceLabel,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  /// Source column or field label.
  final String sourceLabel;

  /// Current mapped value.
  final T value;

  /// Available mapping options.
  final List<DropdownMenuItem<T>> items;

  /// Called when mapping changes.
  final ValueChanged<T> onChanged;
}

/// Reusable field-mapping section for import wizards.
class ImportFieldMappingSection<T> extends StatelessWidget {
  /// Creates a field-mapping section.
  const ImportFieldMappingSection({
    required this.sourceHeaderLabel,
    required this.mappingHeaderLabel,
    required this.rows,
    this.footer,
    this.dropdownSelectedLabelBuilder,
    super.key,
  });

  /// Header label for source column.
  final String sourceHeaderLabel;

  /// Header label for mapped field.
  final String mappingHeaderLabel;

  /// Mapping rows.
  final List<ImportFieldMappingRow<T>> rows;

  /// Optional footer below mapping rows.
  final Widget? footer;

  /// Optional selected-item label builder for dropdowns.
  final String Function(T value)? dropdownSelectedLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 760;
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (!isCompact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  _HeaderCell(label: sourceHeaderLabel),
                  const SizedBox(width: 16),
                  _HeaderCell(label: mappingHeaderLabel),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                return Container(
                  color: index.isEven
                      ? Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.35,
                        )
                      : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.sourceLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            _buildDropdown(row),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Text(
                                row.sourceLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDropdown(row)),
                          ],
                        ),
                );
              },
            ),
          ),
          if (footer != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: footer,
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(ImportFieldMappingRow<T> row) {
    return DropdownButtonFormField<T>(
      initialValue: row.value,
      isExpanded: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      selectedItemBuilder: dropdownSelectedLabelBuilder == null
          ? null
          : (context) => [
              for (final option in row.items)
                Text(
                  dropdownSelectedLabelBuilder!(option.value as T),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
      items: row.items,
      onChanged: (selection) {
        if (selection == null) {
          return;
        }
        row.onChanged(selection);
      },
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
