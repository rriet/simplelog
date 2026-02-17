import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/presentation/aircraft_types/aircraft_type_edit_screen.dart';
import 'package:simplelog/presentation/shared/widgets/form_dropdown_id_field.dart';
import 'package:simplelog/presentation/shared/widgets/form_text_field.dart';
import 'package:simplelog/presentation/shared/widgets/uppercase_text_formatter.dart';
import 'package:simplelog/state/providers/aircraft_type_repository_provider.dart';
import 'package:simplelog/state/providers/aircraft_data_controller_provider.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

class AircraftEditScreen extends ConsumerStatefulWidget {
  const AircraftEditScreen({
    super.key,
    required this.item,
    this.isCreate = false,
  });

  final Aircraft item;
  final bool isCreate;

  @override
  ConsumerState<AircraftEditScreen> createState() =>
      _AircraftEditScreenState();
}

class _AircraftEditScreenState extends ConsumerState<AircraftEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _registrationController;
  late final TextEditingController _mtowController;
  late final TextEditingController _notesController;
  int? _aircraftTypeId;
  late bool _isSimulator;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _registrationController = TextEditingController(
      text: widget.isCreate ? '' : item.registration,
    );
    _mtowController = TextEditingController(
      text: widget.isCreate ? '' : item.mtow.toString(),
    );
    _notesController = TextEditingController(
      text: widget.isCreate ? '' : (item.notes ?? ''),
    );
    _aircraftTypeId = widget.isCreate ? null : item.aircraftTypeId;
    _isSimulator = widget.isCreate ? false : item.isSimulator;
    _isFavorite = widget.isCreate ? false : item.isFavorite;
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _mtowController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int _intOrFallback(String value, int fallback) {
    final parsed = int.tryParse(value);
    return parsed ?? fallback;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final registration = _registrationController.text.trim().toUpperCase();
    if (_aircraftTypeId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.aircraftTypeRequired)),
        );
      }
      return;
    }

    final mtow = _intOrFallback(_mtowController.text.trim(), 0);
    final notes = _notesController.text.trim();

    final controller = ref.read(aircraftDataControllerProvider.notifier);
    ValidationResult validation;

    if (widget.isCreate) {
      final companion = AircraftsCompanion.insert(
        aircraftTypeId: _aircraftTypeId!,
        registration: registration,
        mtow: mtow,
        isSimulator: _isSimulator,
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
        aircraftTypeId: _aircraftTypeId!,
        registration: registration,
        mtow: mtow,
        isSimulator: _isSimulator,
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
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.validationErrorTitle),
        content: Text(validation.message ?? l10n.validationErrorGeneric),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
  }

  Future<void> _createAircraftType() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final placeholder = AircraftType(
      id: -1,
      code: '',
      family: '',
      longName: '',
      manufacturer: null,
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
          builder: (_) => AircraftTypeEditScreen(
            item: placeholder,
            isCreate: true,
          ),
        ),
      );
      if (newId != null) {
        setState(() => _aircraftTypeId = newId);
      }
      return;
    }

    final newId = await showDialog<int?>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 520,
          height: 640,
          child: AircraftTypeEditScreen(
            item: placeholder,
            isCreate: true,
          ),
        ),
      ),
    );
    if (newId != null) {
      setState(() => _aircraftTypeId = newId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final types = ref.watch(aircraftTypesProvider(''));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCreate ? l10n.createAircraftTitle : l10n.editAircraftTitle,
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.saveAction),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FormTextField(
              controller: _registrationController,
              label: l10n.fieldRegistration,
              inputFormatters: const [
                UpperCaseTextFormatter(),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.codeRequired;
                }
                return null;
              },
            ),
            types.when(
              data: (rows) {
                final options = rows
                    .map((row) => _TypeOption(row.id, row.code))
                    .toList();
                final safeValue = options.any((opt) => opt.id == _aircraftTypeId)
                    ? _aircraftTypeId
                    : null;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FormDropdownIdField<_TypeOption>(
                        label: l10n.fieldAircraftType,
                        value: safeValue,
                        items: options,
                        itemLabel: (value) => value.label,
                        itemValue: (value) => value.id,
                        onChanged: (value) =>
                            setState(() => _aircraftTypeId = value),
                        isRequired: true,
                        isDense: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: Center(
                        child: IconButton(
                          tooltip: l10n.createAircraftTypeTitle,
                          iconSize: 32,
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _createAircraftType,
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
            FormTextField(
              controller: _mtowController,
              label: l10n.fieldMtow,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            FormTextField(
              controller: _notesController,
              label: l10n.fieldNotes,
              maxLines: 4,
            ),
            SwitchListTile(
              title: Text(l10n.fieldIsSimulator),
              value: _isSimulator,
              onChanged: (value) => setState(() => _isSimulator = value),
            ),
            SwitchListTile(
              title: Text(l10n.fieldIsFavorite),
              value: _isFavorite,
              onChanged: (value) => setState(() => _isFavorite = value),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeOption {
  _TypeOption(this.id, this.label);

  final int id;
  final String label;
}

 
