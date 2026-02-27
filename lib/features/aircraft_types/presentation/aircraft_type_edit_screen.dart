import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/features/aircraft_types/application/providers/aircraft_types_feature_providers.dart';
import 'package:simplelog/presentation/shared/widgets/app_message_dialog.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/dropdown_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/text_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/uppercase_text_formatter.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

/// Create/edit screen for aircraft type rows.
class AircraftTypeEditScreen extends ConsumerStatefulWidget {
  /// Creates the aircraft type edit screen.
  const AircraftTypeEditScreen({
    required this.item,
    super.key,
    this.isCreate = false,
  });

  /// Initial aircraft type value.
  final AircraftType item;
  /// Whether screen is in create mode.
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
    _codeController = TextEditingController(
      text: widget.isCreate ? '' : item.code,
    );
    _familyController = TextEditingController(
      text: widget.isCreate ? '' : item.family,
    );
    _longNameController = TextEditingController(
      text: widget.isCreate ? '' : item.longName,
    );
    _manufacturerController = TextEditingController(
      text: widget.isCreate ? '' : (item.manufacturer ?? ''),
    );
    _mtowController = TextEditingController(
      text: widget.isCreate ? '' : item.mtow.toString(),
    );
    _category = widget.isCreate ? AircraftCategory.landplane : item.category;
    _engineType = widget.isCreate ? EngineType.piston : item.engineType;
    _engineCount = widget.isCreate ? 1 : item.engineCount;
    _multiPilot = !widget.isCreate && item.multiPilot;
    _complex = !widget.isCreate && item.complex;
    _efis = !widget.isCreate && item.efis;
    _highPerformance = !widget.isCreate && item.highPerformance;
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
    await showAppMessageDialog(
      context,
      title: l10n.validationErrorTitle,
      message: validation.message ?? l10n.validationErrorGeneric,
      okLabel: l10n.okAction,
    );
  }

  Stream<List<String>> _watchFamilies() {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    return useCases.watchFamilies();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.isCreate
        ? l10n.createAircraftTypeTitle
        : l10n.editAircraftTypeTitle;
    final categories = AircraftCategory.values
        .where((value) => value != AircraftCategory.unknown)
        .toList();
    final engineTypes = EngineType.values
        .where((value) => value != EngineType.unknown)
        .toList();
    final engineCounts = List.generate(9, (index) => index + 1);
    final form = Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextInputField(
              controller: _codeController,
              label: l10n.fieldCode,
              inputFormatters: const [UpperCaseTextFormatter()],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.codeRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<String>>(
              stream: _watchFamilies(),
              builder: (context, snapshot) {
                final families = {
                  if (_familyController.text.trim().isNotEmpty)
                    _familyController.text.trim(),
                  ...?snapshot.data,
                }.toList()..sort();

                return TextInputField(
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
            const SizedBox(height: 8),
            TextInputField(
              controller: _longNameController,
              label: l10n.fieldLongName,
            ),
            const SizedBox(height: 8),
            TextInputField(
              controller: _manufacturerController,
              label: l10n.fieldManufacturer,
            ),
            const SizedBox(height: 8),
            DropdownInputField<AircraftCategory>(
              label: l10n.fieldCategory,
              value: _category,
              items: [
                for (final value in categories)
                  DropdownMenuItem(value: value, child: Text(value.name)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 8),
            DropdownInputField<EngineType>(
              label: l10n.fieldEngineType,
              value: _engineType,
              items: [
                for (final value in engineTypes)
                  DropdownMenuItem(value: value, child: Text(value.name)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _engineType = value);
                }
              },
            ),
            const SizedBox(height: 8),
            TextInputField(
              controller: _mtowController,
              label: l10n.fieldMtow,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 8),
            DropdownInputField<int>(
              label: l10n.fieldEngineCount,
              value: _engineCount,
              items: [
                for (final value in engineCounts)
                  DropdownMenuItem(value: value, child: Text(value.toString())),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _engineCount = value);
                }
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: const VisualDensity(vertical: -1),
              title: Text(l10n.fieldMultiPilot),
              value: _multiPilot,
              onChanged: (value) => setState(() => _multiPilot = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: const VisualDensity(vertical: -1),
              title: Text(l10n.fieldComplex),
              value: _complex,
              onChanged: (value) => setState(() => _complex = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: const VisualDensity(vertical: -1),
              title: Text(l10n.fieldEfis),
              value: _efis,
              onChanged: (value) => setState(() => _efis = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: const VisualDensity(vertical: -1),
              title: Text(l10n.fieldHighPerformance),
              value: _highPerformance,
              onChanged: (value) => setState(() => _highPerformance = value),
            ),
          ],
        ),
      ),
    );
    final isInDialog = context.findAncestorWidgetOfExactType<Dialog>() != null;

    if (isInDialog) {
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Text(title),
              trailing: TextButton(
                onPressed: _save,
                child: Text(l10n.saveAction),
              ),
            ),
            const Divider(height: 1),
            Flexible(child: form),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [TextButton(onPressed: _save, child: Text(l10n.saveAction))],
      ),
      body: form,
    );
  }
}
