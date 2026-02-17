import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/presentation/shared/widgets/form_text_field.dart';
import 'package:simplelog/presentation/shared/widgets/uppercase_text_formatter.dart';
import 'package:simplelog/state/providers/airport_data_controller_provider.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

class AirportEditScreen extends ConsumerStatefulWidget {
  const AirportEditScreen({
    super.key,
    required this.item,
    this.isCreate = false,
  });

  final Airport item;
  final bool isCreate;

  @override
  ConsumerState<AirportEditScreen> createState() => _AirportEditScreenState();
}

class _AirportEditScreenState extends ConsumerState<AirportEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _icaoController;
  late final TextEditingController _iataController;
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _icaoController =
        TextEditingController(text: widget.isCreate ? '' : item.icao);
    _iataController = TextEditingController(
      text: widget.isCreate ? '' : (item.iata ?? ''),
    );
    _nameController = TextEditingController(
      text: widget.isCreate ? '' : (item.name ?? ''),
    );
    _cityController = TextEditingController(
      text: widget.isCreate ? '' : (item.city ?? ''),
    );
    _countryController = TextEditingController(
      text: widget.isCreate ? '' : (item.country ?? ''),
    );
    _latitudeController = TextEditingController(
      text: widget.isCreate ? '' : item.latitude.toString(),
    );
    _longitudeController = TextEditingController(
      text: widget.isCreate ? '' : item.longitude.toString(),
    );
    _isFavorite = widget.isCreate ? false : item.isFavorite;
  }

  @override
  void dispose() {
    _icaoController.dispose();
    _iataController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  double _doubleOrFallback(String value, double fallback) {
    final parsed = double.tryParse(value);
    return parsed ?? fallback;
  }

  void _applyUppercaseDefaults() {
    if (_icaoController.text.isNotEmpty) {
      _icaoController.text = _icaoController.text.toUpperCase();
    }
    if (_iataController.text.isNotEmpty) {
      _iataController.text = _iataController.text.toUpperCase();
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    _applyUppercaseDefaults();
    final icao = _icaoController.text.trim();
    final iata = _iataController.text.trim();
    final name = _nameController.text.trim();
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();
    final latitude = _doubleOrFallback(_latitudeController.text.trim(), 0);
    final longitude = _doubleOrFallback(_longitudeController.text.trim(), 0);

    final controller = ref.read(airportDataControllerProvider.notifier);
    ValidationResult validation;

    if (widget.isCreate) {
      final companion = AirportsCompanion.insert(
        icao: icao,
        iata: iata.isEmpty ? const Value(null) : Value(iata),
        name: name.isEmpty ? const Value(null) : Value(name),
        city: city.isEmpty ? const Value(null) : Value(city),
        country: country.isEmpty ? const Value(null) : Value(country),
        latitude: latitude,
        longitude: longitude,
        isFavorite: _isFavorite,
        isLocked: false,
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
        icao: icao,
        iata: iata.isEmpty ? const Value(null) : Value(iata),
        name: name.isEmpty ? const Value(null) : Value(name),
        city: city.isEmpty ? const Value(null) : Value(city),
        country: country.isEmpty ? const Value(null) : Value(country),
        latitude: latitude,
        longitude: longitude,
        isFavorite: _isFavorite,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCreate ? l10n.createAirportTitle : l10n.editAirportTitle,
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
              controller: _icaoController,
              label: l10n.fieldIcao,
              inputFormatters: [
                const UpperCaseTextFormatter(),
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.codeRequired;
                }
                if (value.trim().length != 4) {
                  return l10n.icaoLengthError;
                }
                return null;
              },
            ),
            FormTextField(
              controller: _iataController,
              label: l10n.fieldIata,
              inputFormatters: [
                const UpperCaseTextFormatter(),
                LengthLimitingTextInputFormatter(3),
              ],
            ),
            FormTextField(
              controller: _nameController,
              label: l10n.fieldName,
            ),
            FormTextField(
              controller: _cityController,
              label: l10n.fieldCity,
            ),
            FormTextField(
              controller: _countryController,
              label: l10n.fieldCountry,
            ),
            FormTextField(
              controller: _latitudeController,
              label: l10n.fieldLatitude,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^-?\d*\.?\d*'),
                ),
              ],
            ),
            FormTextField(
              controller: _longitudeController,
              label: l10n.fieldLongitude,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^-?\d*\.?\d*'),
                ),
              ],
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
