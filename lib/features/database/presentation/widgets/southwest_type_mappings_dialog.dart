import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/dropdown_input_field.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/features/aircraft_types/application/providers/aircraft_types_feature_providers.dart';
import 'package:simplelog/features/aircraft_types/presentation/aircraft_type_edit_screen.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Dialog used to resolve Southwest raw aircraft type mappings before import.
class SouthwestTypeMappingsDialog extends ConsumerStatefulWidget {
  /// Creates the dialog.
  const SouthwestTypeMappingsDialog({
    required this.fileName,
    required this.rawTypeCodes,
    required this.rawTypeAircraftRegistrations,
    required this.initialMappings,
    super.key,
  });

  /// Name of file being imported.
  final String fileName;

  /// Unique raw type designators extracted from the source file.
  final List<String> rawTypeCodes;

  /// Aircraft registrations grouped by raw type for rows to be created.
  final Map<String, List<String>> rawTypeAircraftRegistrations;

  /// Initial mapping values loaded from persisted settings.
  final Map<String, String> initialMappings;

  /// Opens the dialog and returns resolved mappings, or `null` on cancel.
  static Future<Map<String, String>?> show(
    BuildContext context, {
    required String fileName,
    required List<String> rawTypeCodes,
    required Map<String, List<String>> rawTypeAircraftRegistrations,
    required Map<String, String> initialMappings,
  }) {
    final screen = SouthwestTypeMappingsDialog(
      fileName: fileName,
      rawTypeCodes: rawTypeCodes,
      rawTypeAircraftRegistrations: rawTypeAircraftRegistrations,
      initialMappings: initialMappings,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return AppNavigator.pushMaterial<Map<String, String>>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => screen,
    );
  }

  @override
  ConsumerState<SouthwestTypeMappingsDialog> createState() =>
      _SouthwestTypeMappingsDialogState();
}

class _SouthwestTypeMappingsDialogState
    extends ConsumerState<SouthwestTypeMappingsDialog> {
  late final Map<String, String?> _selectedTypeCodesByRaw;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _selectedTypeCodesByRaw = <String, String?>{
      for (final raw in widget.rawTypeCodes)
        raw: _normalizeTypeCode(widget.initialMappings[raw] ?? ''),
    };
  }

  bool _isResolved(String rawTypeCode) {
    final selected = _normalizeTypeCode(_selectedTypeCodesByRaw[rawTypeCode]);
    return selected != null;
  }

  bool get _allResolved => widget.rawTypeCodes.every(_isResolved);

  void _setSelectedTypeCode(String rawTypeCode, String? selectedTypeCode) {
    setState(() {
      _selectedTypeCodesByRaw[rawTypeCode] = _normalizeTypeCode(
        selectedTypeCode,
      );
    });
  }

  Future<void> _createAircraftType(String rawTypeCode) async {
    const placeholder = AircraftType(
      id: kPlaceholderId,
      code: '',
      family: '',
      longName: '',
      category: AircraftCategory.landplane,
      engineType: EngineType.piston,
      mtow: 0,
      engineCount: 1,
      multiPilot: false,
      complex: false,
      efis: false,
      highPerformance: false,
      isLocked: false,
    );
    final createdTypeId = await _showCreateAircraftTypeDialog(placeholder);
    if (createdTypeId == null || !mounted) {
      return;
    }
    final db = ref.read(databaseProvider);
    final createdType = await (db.select(
      db.aircraftTypes,
    )..where((t) => t.id.equals(createdTypeId))).getSingleOrNull();
    if (createdType == null || !mounted) {
      return;
    }
    _setSelectedTypeCode(rawTypeCode, createdType.code);
  }

  Future<int?> _showCreateAircraftTypeDialog(AircraftType placeholder) {
    final useRoutePresentation =
        MediaQuery.of(context).size.width < 600 ||
        context.findAncestorWidgetOfExactType<Dialog>() != null;
    if (useRoutePresentation) {
      return AppNavigator.pushMaterial<int?>(
        context,
        (_) => AircraftTypeEditScreen(item: placeholder, isCreate: true),
      );
    }
    return showDialog<int?>(
      context: context,
      builder: (_) => AircraftTypeEditScreen(item: placeholder, isCreate: true),
    );
  }

  void _setAutoCreateMapping(String rawTypeCode) {
    final normalizedRaw = _normalizeTypeCode(rawTypeCode);
    _setSelectedTypeCode(rawTypeCode, normalizedRaw ?? 'UNKNOWN');
  }

  void _submit() {
    if (!_allResolved) {
      setState(() => _showValidationErrors = true);
      return;
    }
    final mappings = <String, String>{
      for (final rawTypeCode in widget.rawTypeCodes)
        rawTypeCode: _normalizeTypeCode(_selectedTypeCodesByRaw[rawTypeCode])!,
    };
    AppNavigator.pop(context, mappings);
  }

  String _rawTypeLabel(AppLocalizations l10n, String rawTypeCode) {
    return rawTypeCode.isEmpty
        ? l10n.southwestTypeMappingsEmptyRawTypeLabel
        : rawTypeCode;
  }

  String _aircraftUsagePreview(List<String> registrations) {
    const maxPreviewCount = 3;
    final preview = registrations.take(maxPreviewCount).toList(growable: false);
    final overflowCount = registrations.length - preview.length;
    if (overflowCount <= 0) {
      return preview.join(', ');
    }
    return '${preview.join(', ')}, +$overflowCount';
  }

  String _mappingQuickActionLabel(AppLocalizations l10n, String rawTypeCode) {
    if (rawTypeCode.isEmpty) {
      return l10n.southwestTypeMappingsUseUnknownAction;
    }
    return l10n.southwestTypeMappingsAutoCreateAction;
  }

  List<String> _aircraftRegistrationsForRawType(String rawTypeCode) {
    return widget.rawTypeAircraftRegistrations[rawTypeCode] ?? const <String>[];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controlsTheme = Theme.of(context).extension<AppFormControlsTheme>();
    final addButtonSize = controlsTheme?.pickerAddButtonSize ?? 40;
    final addIconSize = controlsTheme?.pickerAddIconSize ?? 20;
    final addBorderRadius = controlsTheme?.pickerAddBorderRadius ?? 8;
    final body = ref
        .watch(aircraftTypesProvider(''))
        .when(
          data: (rows) {
            final existingTypeCodes = rows
                .map((row) => row.code.trim().toUpperCase())
                .where((code) => code.isNotEmpty)
                .toSet();
            final selectedCodes = _selectedTypeCodesByRaw.values
                .map(_normalizeTypeCode)
                .whereType<String>()
                .toSet();
            final allDropdownCodes = <String>{
              ...existingTypeCodes,
              ...selectedCodes,
            }.toList()..sort();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.databaseFileLabel(widget.fileName)),
                  const SizedBox(height: 8),
                  Text(l10n.southwestTypeMappingsDialogMessage),
                  const SizedBox(height: 12),
                  for (final rawTypeCode in widget.rawTypeCodes) ...[
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.southwestTypeMappingsRawTypeValue(
                                _rawTypeLabel(l10n, rawTypeCode),
                              ),
                            ),
                            if (_aircraftRegistrationsForRawType(
                              rawTypeCode,
                            ).isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                l10n.southwestTypeMappingsAircraftUsageValue(
                                  _aircraftRegistrationsForRawType(
                                    rawTypeCode,
                                  ).length,
                                  _aircraftUsagePreview(
                                    _aircraftRegistrationsForRawType(
                                      rawTypeCode,
                                    ),
                                  ),
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: DropdownInputField<String>(
                                    label: l10n.fieldAircraftType,
                                    value: _normalizeTypeCode(
                                      _selectedTypeCodesByRaw[rawTypeCode],
                                    ),
                                    items: allDropdownCodes
                                        .map(
                                          (code) => DropdownMenuItem<String>(
                                            value: code,
                                            child: Text(code),
                                          ),
                                        )
                                        .toList(growable: false),
                                    onChanged: (value) => _setSelectedTypeCode(
                                      rawTypeCode,
                                      value,
                                    ),
                                    errorText:
                                        _showValidationErrors &&
                                            !_isResolved(rawTypeCode)
                                        ? l10n.aircraftTypeRequired
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: l10n.createAircraftTypeTitle,
                                  child: InkWell(
                                    onTap: () =>
                                        _createAircraftType(rawTypeCode),
                                    borderRadius: BorderRadius.circular(
                                      addBorderRadius,
                                    ),
                                    child: Container(
                                      width: addButtonSize,
                                      height: addButtonSize,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          addBorderRadius,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.add, size: addIconSize),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: rawTypeCode.isEmpty
                                      ? () => _setSelectedTypeCode(
                                          rawTypeCode,
                                          'UNKNOWN',
                                        )
                                      : () =>
                                            _setAutoCreateMapping(rawTypeCode),
                                  child: Text(
                                    _mappingQuickActionLabel(
                                      l10n,
                                      rawTypeCode,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(error.toString()),
          ),
        );

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.southwestTypeMappingsDialogTitle,
      popupMaxWidth: 760,
      actions: [
        TextButton(onPressed: _submit, child: Text(l10n.southwestImportAction)),
      ],
      contentView: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: body,
      ),
    );
  }
}

String? _normalizeTypeCode(String? value) {
  if (value == null) {
    return null;
  }
  final normalized = value.trim().toUpperCase();
  if (normalized.isEmpty) {
    return null;
  }
  return normalized;
}
