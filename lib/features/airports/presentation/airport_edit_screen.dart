import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/debug/edit_screen_lifecycle_logger.dart';
import 'package:simplelog/core/geo/coordinate_parser.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/app_message_dialog.dart';
import 'package:simplelog/core/presentation/widgets/inputs/dropdown_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/text_input_field.dart';
import 'package:simplelog/core/presentation/widgets/keyboard/uppercase_text_formatter.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/airports/application/providers/airports_feature_providers.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

/// Create/edit screen for airport rows.
class AirportEditScreen extends ConsumerStatefulWidget {
  /// Creates the airport edit screen.
  const AirportEditScreen({
    required this.item,
    super.key,
    this.isCreate = false,
    this.initialIcao = '',
    this.initialIata = '',
    this.initialName = '',
    this.initialCity = '',
    this.initialCountry = '',
  });

  /// Initial airport value.
  final Airport item;

  /// Whether screen is in create mode.
  final bool isCreate;

  /// Optional default ICAO used only in create mode.
  final String initialIcao;

  /// Optional default IATA used only in create mode.
  final String initialIata;

  /// Optional default name used only in create mode.
  final String initialName;

  /// Optional default city used only in create mode.
  final String initialCity;

  /// Optional default country used only in create mode.
  final String initialCountry;

  @override
  ConsumerState<AirportEditScreen> createState() => _AirportEditScreenState();
}

enum _CoordinateInputFormat { decimal, degMin }

class _AirportEditScreenState extends ConsumerState<AirportEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _icaoController;
  late final TextEditingController _iataController;
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late double _latitude;
  late double _longitude;
  late bool _isFavorite;

  void _setCoordinates(CoordinatePair value) {
    setState(() {
      _latitude = value.latitude;
      _longitude = value.longitude;
    });
  }

  @override
  void initState() {
    super.initState();
    EditScreenLifecycleLogger.onInit(
      screen: 'AirportEditScreen',
      state: this,
      details: <String, Object?>{
        'isCreate': widget.isCreate,
        'id': widget.item.id,
      },
    );
    final item = widget.item;
    _icaoController = TextEditingController(
      text: widget.isCreate ? widget.initialIcao : item.icao,
    );
    _iataController = TextEditingController(
      text: widget.isCreate ? widget.initialIata : (item.iata ?? ''),
    );
    _nameController = TextEditingController(
      text: widget.isCreate ? widget.initialName : (item.name ?? ''),
    );
    _cityController = TextEditingController(
      text: widget.isCreate ? widget.initialCity : (item.city ?? ''),
    );
    _countryController = TextEditingController(
      text: widget.isCreate ? widget.initialCountry : (item.country ?? ''),
    );
    _latitude = widget.isCreate ? 0 : item.latitude;
    _longitude = widget.isCreate ? 0 : item.longitude;
    _isFavorite = !widget.isCreate && item.isFavorite;
  }

  @override
  void dispose() {
    EditScreenLifecycleLogger.onDispose(
      screen: 'AirportEditScreen',
      state: this,
      details: <String, Object?>{
        'isCreate': widget.isCreate,
        'id': widget.item.id,
      },
    );
    _icaoController.dispose();
    _iataController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  String _formattedCoordinates() {
    return CoordinateParser.formatDegMinPair(_latitude, _longitude);
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
    final latitude = _latitude;
    final longitude = _longitude;

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
      final id = await controller.create(companion);
      if (mounted) {
        AppNavigator.pop(context, id ?? true);
      }
      return;
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
      AppNavigator.pop(context, true);
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

  Future<void> _editCoordinates() async {
    final result = await showDialog<CoordinatePair>(
      context: context,
      builder: (dialogContext) => _CoordinateEditDialog(
        latitude: _latitude,
        longitude: _longitude,
      ),
    );
    if (result == null) return;
    if (!mounted) return;
    _setCoordinates(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.isCreate
        ? l10n.createAirportTitle
        : l10n.editAirportTitle;
    final form = Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextInputField(
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
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextInputField(
                    controller: _iataController,
                    label: l10n.fieldIata,
                    inputFormatters: [
                      const UpperCaseTextFormatter(),
                      LengthLimitingTextInputFormatter(3),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextInputField(controller: _nameController, label: l10n.fieldName),
            const SizedBox(height: 8),
            TextInputField(controller: _cityController, label: l10n.fieldCity),
            const SizedBox(height: 8),
            TextInputField(
              controller: _countryController,
              label: l10n.fieldCountry,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _editCoordinates,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '${l10n.fieldLatitude} / ${l10n.fieldLongitude}',
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.edit),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
                child: Text(_formattedCoordinates()),
              ),
            ),
            const SizedBox(height: 8),
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
    return AdaptiveFormShell(
      onClose: () => AppNavigator.maybePop(context),
      longTitle: title,
      shortTitle: title,
      actions: [TextButton(onPressed: _save, child: Text(l10n.saveAction))],
      contentView: form,
    );
  }
}

class _CoordinateEditDialog extends StatefulWidget {
  const _CoordinateEditDialog({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  State<_CoordinateEditDialog> createState() => _CoordinateEditDialogState();
}

class _CoordinateEditDialogState extends State<_CoordinateEditDialog> {
  late final TextEditingController _latController;
  late final TextEditingController _lonController;
  _CoordinateInputFormat _selectedFormat = _CoordinateInputFormat.degMin;

  @override
  void initState() {
    super.initState();
    _latController = TextEditingController(
      text: _formatCoordinateInput(widget.latitude, true, _selectedFormat),
    );
    _lonController = TextEditingController(
      text: _formatCoordinateInput(widget.longitude, false, _selectedFormat),
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  String _formatCoordinateInput(
    double value,
    bool isLatitude,
    _CoordinateInputFormat format,
  ) {
    if (format == _CoordinateInputFormat.decimal) {
      return value.toStringAsFixed(6);
    }
    final pair = isLatitude
        ? CoordinateParser.formatDegMinPair(value, 0)
        : CoordinateParser.formatDegMinPair(0, value);
    return isLatitude ? pair.split('/').first : pair.split('/').last;
  }

  List<TextInputFormatter> _inputFormatters({required bool isLatitude}) {
    if (_selectedFormat == _CoordinateInputFormat.degMin) {
      return [
        _CoordinateDegMinMaskFormatter(isLatitude: isLatitude),
      ];
    }
    return [_CoordinateDecimalFormatter()];
  }

  Future<void> _saveCoordinatesFromControllers() async {
    final l10n = AppLocalizations.of(context)!;
    final lat = CoordinateParser.parseSingle(
      _latController.text,
      isLatitude: true,
    );
    final lon = CoordinateParser.parseSingle(
      _lonController.text,
      isLatitude: false,
    );
    if (lat == null || lon == null) {
      await showAppMessageDialog(
        context,
        title: l10n.validationErrorTitle,
        message: 'Invalid coordinates. Use decimal or degree-minute format.',
        okLabel: l10n.okAction,
        useRootNavigator: false,
      );
      return;
    }
    AppNavigator.pop(
      context,
      CoordinatePair(latitude: lat, longitude: lon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text('${l10n.fieldLatitude} / ${l10n.fieldLongitude}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownInputField<_CoordinateInputFormat>(
              label: 'Format',
              value: _selectedFormat,
              items: const [
                DropdownMenuItem(
                  value: _CoordinateInputFormat.decimal,
                  child: Text('25.325399/-80.274803'),
                ),
                DropdownMenuItem(
                  value: _CoordinateInputFormat.degMin,
                  child: Text('N25°19.31/W080°16.29'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedFormat = value;
                  _latController.text = _formatCoordinateInput(
                    widget.latitude,
                    true,
                    _selectedFormat,
                  );
                  _lonController.text = _formatCoordinateInput(
                    widget.longitude,
                    false,
                    _selectedFormat,
                  );
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    inputFormatters: _inputFormatters(isLatitude: true),
                    decoration: InputDecoration(
                      labelText: l10n.fieldLatitude,
                      border: const OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lonController,
                    inputFormatters: _inputFormatters(isLatitude: false),
                    decoration: InputDecoration(
                      labelText: l10n.fieldLongitude,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => AppNavigator.pop(context),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: _saveCoordinatesFromControllers,
          child: Text(l10n.saveAction),
        ),
      ],
    );
  }
}

class _CoordinateDegMinMaskFormatter extends TextInputFormatter {
  _CoordinateDegMinMaskFormatter({required this.isLatitude});

  final bool isLatitude;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    final allowed = upper.replaceAll(RegExp('[^0-9NSEW]'), '');
    if (allowed.isEmpty) {
      return TextEditingValue.empty;
    }

    final validDirections = isLatitude ? const {'N', 'S'} : const {'E', 'W'};
    final first = allowed[0];
    if (!validDirections.contains(first)) {
      return oldValue;
    }
    final prefix = first;
    final rest = allowed.substring(1).replaceAll(RegExp('[NSEW]'), '');

    final digitOnly = rest.replaceAll(RegExp('[^0-9]'), '');
    final degreeDigits = isLatitude ? 2 : 3;
    final maxDigits = degreeDigits + 4; // MMmm
    final trimmedDigits = digitOnly.substring(
      0,
      digitOnly.length.clamp(0, maxDigits),
    );

    final formatted = StringBuffer(prefix);
    if (trimmedDigits.length <= degreeDigits) {
      formatted.write(trimmedDigits);
    } else {
      final degrees = trimmedDigits.substring(0, degreeDigits);
      final minuteAndFraction = trimmedDigits.substring(degreeDigits);
      formatted
        ..write(degrees)
        ..write('°');
      if (minuteAndFraction.length <= 2) {
        formatted.write(minuteAndFraction);
      } else {
        final minute = minuteAndFraction.substring(0, 2);
        final fraction = minuteAndFraction.substring(2);
        formatted
          ..write(minute)
          ..write('.')
          ..write(fraction);
      }
    }

    final text = formatted.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _CoordinateDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    if (upper.isEmpty) return TextEditingValue.empty;

    final filtered = upper.replaceAll(RegExp(r'[^0-9+\-.]'), '');
    final buffer = StringBuffer();
    var hasSign = false;
    var hasDot = false;

    for (final char in filtered.split('')) {
      final isDigit = char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
      if (isDigit) {
        buffer.write(char);
        continue;
      }
      if ((char == '+' || char == '-') && !hasSign && buffer.isEmpty) {
        hasSign = true;
        buffer.write(char);
        continue;
      }
      if (char == '.' && !hasDot) {
        hasDot = true;
        buffer.write(char);
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
