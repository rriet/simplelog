import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/debug/edit_screen_lifecycle_logger.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/app_message_dialog.dart';
import 'package:simplelog/core/presentation/widgets/inputs/dropdown_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/number_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/text_input_field.dart';
import 'package:simplelog/core/presentation/widgets/keyboard/uppercase_text_formatter.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/features/aircraft/application/providers/aircraft_feature_providers.dart';
import 'package:simplelog/features/aircraft_types/application/providers/aircraft_types_feature_providers.dart';
import 'package:simplelog/features/aircraft_types/presentation/aircraft_type_edit_screen.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

/// Create/edit screen for aircraft rows.
class AircraftEditScreen extends ConsumerStatefulWidget {
  /// Creates the aircraft edit screen.
  const AircraftEditScreen({
    required this.item,
    super.key,
    this.isCreate = false,
    this.initialIsSimulator,
    this.initialRegistration = '',
    this.initialAircraftTypeId,
  });

  /// Initial aircraft value.
  final Aircraft item;

  /// Whether screen is in create mode.
  final bool isCreate;

  /// Optional simulator-mode default for create flow.
  final bool? initialIsSimulator;

  /// Optional default registration used only in create mode.
  final String initialRegistration;

  /// Optional default aircraft type used only in create mode.
  final int? initialAircraftTypeId;

  @override
  ConsumerState<AircraftEditScreen> createState() => _AircraftEditScreenState();
}

class _AircraftEditScreenState extends ConsumerState<AircraftEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _registrationController;
  late final TextEditingController _mtowController;
  late final TextEditingController _notesController;
  int? _aircraftTypeId;
  late bool _isSimulatorMode;
  late bool _isFavorite;
  bool _showAircraftTypeError = false;

  @override
  void initState() {
    super.initState();
    EditScreenLifecycleLogger.onInit(
      screen: 'AircraftEditScreen',
      state: this,
      details: <String, Object?>{
        'isCreate': widget.isCreate,
        'id': widget.item.id,
      },
    );
    final item = widget.item;
    _registrationController = TextEditingController(
      text: widget.isCreate ? widget.initialRegistration : item.registration,
    );
    _mtowController = TextEditingController(
      text: widget.isCreate ? '' : _mtowText(item.mtow),
    );
    _notesController = TextEditingController(
      text: widget.isCreate ? '' : (item.notes ?? ''),
    );
    _aircraftTypeId = widget.isCreate
        ? widget.initialAircraftTypeId
        : item.aircraftTypeId;
    _isSimulatorMode = widget.isCreate
        ? (widget.initialIsSimulator ?? item.isSimulator)
        : item.isSimulator;
    _isFavorite = !widget.isCreate && item.isFavorite;
  }

  @override
  void dispose() {
    EditScreenLifecycleLogger.onDispose(
      screen: 'AircraftEditScreen',
      state: this,
      details: <String, Object?>{
        'isCreate': widget.isCreate,
        'id': widget.item.id,
      },
    );
    _registrationController.dispose();
    _mtowController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _mtowText(int? mtow) => mtow?.toString() ?? '';

  int? _parseOptionalInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  int _effectiveTypeMtow(List<AircraftTypeRow> rows) {
    final selectedId = _aircraftTypeId;
    if (selectedId == null) return 0;
    for (final row in rows) {
      if (row.id == selectedId) {
        return row.type.mtow;
      }
    }
    return 0;
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final hasAircraftType = _aircraftTypeId != null;
    setState(() => _showAircraftTypeError = !hasAircraftType);
    if (!formValid || !hasAircraftType) {
      return;
    }

    final registration = _registrationController.text.trim().toUpperCase();

    final mtow = _parseOptionalInt(_mtowController.text);
    final notes = _notesController.text.trim();

    final controller = ref.read(aircraftDataControllerProvider.notifier);
    ValidationResult validation;

    if (widget.isCreate) {
      final companion = AircraftsCompanion.insert(
        aircraftTypeId: _aircraftTypeId!,
        registration: registration,
        mtow: Value(mtow),
        isSimulator: _isSimulatorMode,
        isFavorite: _isFavorite,
        isLocked: false,
        notes: notes.isEmpty ? const Value(null) : Value(notes),
      );
      validation = await controller.validateCreate(companion);
      if (!validation.isValid) {
        await _showValidationError(validation);
        return;
      }
      await controller.create(companion);
    } else {
      final item = widget.item;
      final updated = item.copyWith(
        aircraftTypeId: _aircraftTypeId,
        registration: registration,
        mtow: Value(mtow),
        isSimulator: _isSimulatorMode,
        isFavorite: _isFavorite,
        notes: notes.isEmpty ? const Value(null) : Value(notes),
      );
      validation = await controller.validateUpdate(updated);
      if (!validation.isValid) {
        await _showValidationError(validation);
        return;
      }
      await controller.update(updated);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _showValidationError(ValidationResult validation) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showAppMessageDialog(
      context,
      title: l10n.validationErrorTitle,
      message: validation.message ?? l10n.validationErrorGeneric,
      okLabel: l10n.okAction,
    );
  }

  Future<void> _createAircraftType() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const placeholder = AircraftType(
      id: -1,
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

    if (isCompact) {
      final newId = await Navigator.of(context).push<int?>(
        MaterialPageRoute(
          builder: (_) =>
              const AircraftTypeEditScreen(item: placeholder, isCreate: true),
        ),
      );
      if (newId != null) {
        setState(() => _aircraftTypeId = newId);
      }
      return;
    }

    final newId = await showDialog<int?>(
      context: context,
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: size.height * 0.9,
            ),
            child: const AircraftTypeEditScreen(
              item: placeholder,
              isCreate: true,
            ),
          ),
        );
      },
    );
    if (newId != null) {
      setState(() => _aircraftTypeId = newId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controlsTheme = Theme.of(context).extension<AppFormControlsTheme>();
    final addButtonSize = controlsTheme?.pickerAddButtonSize ?? 40;
    final addIconSize = controlsTheme?.pickerAddIconSize ?? 20;
    final addBorderRadius = controlsTheme?.pickerAddBorderRadius ?? 8;
    final types = ref.watch(aircraftTypesProvider(''));
    final form = Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextInputField(
              controller: _registrationController,
              label: l10n.fieldRegistration,
              inputFormatters: const [UpperCaseTextFormatter()],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.codeRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            types.when(
              data: (rows) {
                final options = rows
                    .map((row) => _TypeOption(row.id, row.code))
                    .toList();
                final safeValue =
                    options.any((opt) => opt.id == _aircraftTypeId)
                    ? _aircraftTypeId
                    : null;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownInputField<int>(
                        label: l10n.fieldAircraftType,
                        value: safeValue,
                        items: options
                            .map(
                              (option) => DropdownMenuItem<int>(
                                value: option.id,
                                child: Text(option.label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) => setState(() {
                          _aircraftTypeId = value;
                          if (value != null) {
                            _showAircraftTypeError = false;
                          }
                        }),
                        errorText: _showAircraftTypeError && safeValue == null
                            ? l10n.aircraftTypeRequired
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: l10n.createAircraftTypeTitle,
                      child: InkWell(
                        onTap: _createAircraftType,
                        borderRadius: BorderRadius.circular(addBorderRadius),
                        child: Container(
                          width: addButtonSize,
                          height: addButtonSize,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
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
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(error.toString()),
              ),
            ),
            const SizedBox(height: 10),
            NumberInputField(
              controller: _mtowController,
              label: l10n.fieldMtow,
              allowEmpty: true,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: types.maybeWhen(
                data: (rows) {
                  if (_mtowController.text.trim().isNotEmpty) return null;
                  return _effectiveTypeMtow(rows).toString();
                },
                orElse: () =>
                    _mtowController.text.trim().isNotEmpty ? null : '0',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextInputField(
              controller: _notesController,
              label: l10n.fieldNotes,
              maxLines: 4,
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: const VisualDensity(vertical: -1),
              title: Text(l10n.fieldIsFavorite),
              value: _isFavorite,
              onChanged: (value) => setState(() => _isFavorite = value),
            ),
          ],
        ),
      ),
    );

    final title = widget.isCreate
        ? (_isSimulatorMode ? 'Add Simulator' : 'Add Aircraft')
        : (_isSimulatorMode ? 'Edit Simulator' : l10n.editAircraftTitle);
    return AdaptiveFormShell(
      onClose: () => Navigator.of(context).maybePop(),
      longTitle: title,
      shortTitle: title,
      actions: [TextButton(onPressed: _save, child: Text(l10n.saveAction))],
      contentView: form,
    );
  }
}

class _TypeOption {
  _TypeOption(this.id, this.label);

  final int id;
  final String label;
}
