import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/presentation/shared/widgets/form_dropdown_field.dart';
import 'package:simplelog/presentation/shared/widgets/form_text_field.dart';
import 'package:simplelog/presentation/shared/widgets/uppercase_text_formatter.dart';
import 'package:simplelog/state/providers/aircraft_type_repository_provider.dart';
import 'package:simplelog/state/providers/aircraft_type_data_controller_provider.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

class AircraftTypeEditScreen extends ConsumerStatefulWidget {
  const AircraftTypeEditScreen({
    super.key,
    required this.item,
    this.isCreate = false,
  });

  final AircraftType item;
  final bool isCreate;

  @override
  ConsumerState<AircraftTypeEditScreen> createState() =>
      _AircraftTypeEditScreenState();
}

class _AircraftTypeEditScreenState
    extends ConsumerState<AircraftTypeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _familyController;
  late final TextEditingController _longNameController;
  late final TextEditingController _manufacturerController;
  late final TextEditingController _mtowController;

  late AircraftCategory _category;
  late EngineType _engineType;
  late int _engineCount;
  late bool _multiPilot;
  late bool _complex;
  late bool _efis;
  late bool _highPerformance;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _codeController = TextEditingController(text: widget.isCreate ? '' : item.code);
    _familyController = TextEditingController(
      text: widget.isCreate ? '' : item.family,
    );
    _longNameController =
        TextEditingController(text: widget.isCreate ? '' : item.longName);
    _manufacturerController = TextEditingController(
      text: widget.isCreate ? '' : (item.manufacturer ?? ''),
    );
    _mtowController = TextEditingController(
      text: widget.isCreate ? '' : item.mtow.toString(),
    );
    _category = widget.isCreate ? AircraftCategory.landplane : item.category;
    _engineType = widget.isCreate ? EngineType.piston : item.engineType;
    _engineCount = widget.isCreate ? 1 : item.engineCount;
    _multiPilot = widget.isCreate ? false : item.multiPilot;
    _complex = widget.isCreate ? false : item.complex;
    _efis = widget.isCreate ? false : item.efis;
    _highPerformance = widget.isCreate ? false : item.highPerformance;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _familyController.dispose();
    _longNameController.dispose();
    _manufacturerController.dispose();
    _mtowController.dispose();
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

    final code = _codeController.text.trim().toUpperCase();
    final family = _familyController.text.trim();
    final controller = ref.read(aircraftTypeDataControllerProvider.notifier);
    ValidationResult validation;

    if (widget.isCreate) {
      final companion = AircraftTypesCompanion.insert(
        code: code,
        family: family,
        longName: _longNameController.text.trim(),
        manufacturer: _manufacturerController.text.trim().isEmpty
            ? const Value(null)
            : Value(_manufacturerController.text.trim()),
        category: _category,
        engineType: _engineType,
        mtow: _intOrFallback(_mtowController.text.trim(), 0),
        engineCount: _engineCount,
        multiPilot: _multiPilot,
        complex: _complex,
        efis: _efis,
        highPerformance: _highPerformance,
        isLocked: false,
      );
      validation = await controller.validateCreate(companion);
      if (!validation.isValid) {
        await _showValidationError(validation);
        return;
      }
      final id = await controller.create(companion);
      if (mounted) {
        Navigator.of(context).pop(id);
      }
      return;
    } else {
      final item = widget.item;
      final updated = item.copyWith(
        code: code,
        family: family,
        longName: _longNameController.text.trim(),
        manufacturer: _manufacturerController.text.trim().isEmpty
            ? const Value(null)
            : Value(_manufacturerController.text.trim()),
        category: _category,
        engineType: _engineType,
        mtow: _intOrFallback(_mtowController.text.trim(), item.mtow),
        engineCount: _engineCount,
        multiPilot: _multiPilot,
        complex: _complex,
        efis: _efis,
        highPerformance: _highPerformance,
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

  Stream<List<String>> _watchFamilies() {
    final repo = ref.read(aircraftTypeRepositoryProvider);
    return repo.watchFamilies();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = AircraftCategory.values
        .where((value) => value != AircraftCategory.unknown)
        .toList();
    final engineTypes = EngineType.values
        .where((value) => value != EngineType.unknown)
        .toList();
    final engineCounts = List.generate(9, (index) => index + 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCreate ? l10n.createAircraftTypeTitle : l10n.editAircraftTypeTitle,
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
              controller: _codeController,
              label: l10n.fieldCode,
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
            StreamBuilder<List<String>>(
              stream: _watchFamilies(),
              builder: (context, snapshot) {
                final families = {
                  if (_familyController.text.trim().isNotEmpty)
                    _familyController.text.trim(),
                  ...?snapshot.data,
                }.toList()
                  ..sort();

                return FormTextField(
                  controller: _familyController,
                  label: l10n.fieldFamily,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: families.isEmpty
                        ? null
                        : () async {
                            final selected = await showModalBottomSheet<String>(
                              context: context,
                              builder: (context) => SafeArea(
                                child: ListView(
                                  children: [
                                    for (final family in families)
                                      ListTile(
                                        title: Text(family),
                                        onTap: () =>
                                            Navigator.of(context).pop(family),
                                      ),
                                  ],
                                ),
                              ),
                            );

                            if (selected != null) {
                              _familyController.text = selected;
                            }
                          },
                  ),
                );
              },
            ),
            FormTextField(
              controller: _longNameController,
              label: l10n.fieldLongName,
            ),
            FormTextField(
              controller: _manufacturerController,
              label: l10n.fieldManufacturer,
            ),
            FormDropdownField<AircraftCategory>(
              label: l10n.fieldCategory,
              value: _category,
              items: categories,
              itemLabel: (value) => value.name,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            FormDropdownField<EngineType>(
              label: l10n.fieldEngineType,
              value: _engineType,
              items: engineTypes,
              itemLabel: (value) => value.name,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _engineType = value);
                }
              },
            ),
            FormTextField(
              controller: _mtowController,
              label: l10n.fieldMtow,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            FormDropdownField<int>(
              label: l10n.fieldEngineCount,
              value: _engineCount,
              items: engineCounts,
              itemLabel: (value) => value.toString(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _engineCount = value);
                }
              },
            ),
            SwitchListTile(
              title: Text(l10n.fieldMultiPilot),
              value: _multiPilot,
              onChanged: (value) => setState(() => _multiPilot = value),
            ),
            SwitchListTile(
              title: Text(l10n.fieldComplex),
              value: _complex,
              onChanged: (value) => setState(() => _complex = value),
            ),
            SwitchListTile(
              title: Text(l10n.fieldEfis),
              value: _efis,
              onChanged: (value) => setState(() => _efis = value),
            ),
            SwitchListTile(
              title: Text(l10n.fieldHighPerformance),
              value: _highPerformance,
              onChanged: (value) => setState(() => _highPerformance = value),
            ),
          ],
        ),
      ),
    );
  }
}
