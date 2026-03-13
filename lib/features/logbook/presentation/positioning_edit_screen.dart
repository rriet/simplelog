import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/date/db_date_time.dart';
import 'package:simplelog/core/debug/edit_screen_lifecycle_logger.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/clock_time_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/date_selector_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/picker_with_add_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/text_input_field.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/features/airports/application/providers/airports_feature_providers.dart';
import 'package:simplelog/features/airports/presentation/airport_edit_screen.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_picker_dialog.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_form_fields.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Screen used to create or edit positioning entries.
class PositioningEditScreen extends ConsumerStatefulWidget {
  /// Creates a positioning editor for an existing [positioningId] or new row.
  const PositioningEditScreen({super.key, this.positioningId});

  /// Existing positioning entry id when editing.
  final int? positioningId;

  /// True when this screen is creating a new positioning entry.
  bool get isCreate => positioningId == null;

  @override
  ConsumerState<PositioningEditScreen> createState() =>
      _PositioningEditScreenState();
}

class _PositioningEditScreenState extends ConsumerState<PositioningEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _departureTimeController = TextEditingController();
  final _arrivalTimeController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  bool _timeEdited = false;
  bool _loading = true;

  Positioning? _positioning;
  DateTime _departure = DateTime.now();
  DateTime? _arrival;
  int? _departureAirportId;
  int? _arrivalAirportId;
  String? _departureAirportErrorText;
  String? _arrivalAirportErrorText;
  String? _arrivalTimeErrorText;
  String? _totalTimeErrorText;

  void _setLoadingFalse() {
    setState(() => _loading = false);
  }

  void _applyPickedDate(DateTime picked) {
    setState(() {
      _departure = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _departure.hour,
        _departure.minute,
      );
      _updateTimeIfAuto();
    });
  }

  void _setDepartureAirportId(int id) {
    setState(() {
      _departureAirportId = id;
      _departureAirportErrorText = null;
    });
  }

  void _setArrivalAirportId(int id) {
    setState(() {
      _arrivalAirportId = id;
      _arrivalAirportErrorText = null;
    });
  }

  void _setCreatedAirport({
    required bool asDeparture,
    required Airport created,
  }) {
    setState(() {
      if (asDeparture) {
        _departureAirportId = created.id;
        _departureAirportErrorText = null;
      } else {
        _arrivalAirportId = created.id;
        _arrivalAirportErrorText = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    EditScreenLifecycleLogger.onInit(
      screen: 'PositioningEditScreen',
      state: this,
      details: <String, Object?>{
        'isCreate': widget.isCreate,
        'id': widget.positioningId,
      },
    );
    _departureTimeController.text = ClockTimeInputField.formatMinutesOfDay(
      _departure.hour * 60 + _departure.minute,
    );
    _arrivalTimeController.text = '';
    _timeController.text = HourInputField.formatHours(0);
    unawaited(_loadExisting());
  }

  @override
  void dispose() {
    EditScreenLifecycleLogger.onDispose(
      screen: 'PositioningEditScreen',
      state: this,
      details: <String, Object?>{
        'isCreate': widget.isCreate,
        'id': widget.positioningId,
      },
    );
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (widget.isCreate) {
      if (!mounted) return;
      _setLoadingFalse();
      return;
    }
    final useCases = ref.read(logbookUseCasesProvider);
    final loaded = await useCases.loadPositioningEditData(
      widget.positioningId!,
    );
    if (!mounted) return;
    if (loaded == null) {
      if (!mounted) return;
      _setLoadingFalse();
      return;
    }
    _positioning = loaded.positioning;
    _departure = loaded.departureLine == null
        ? DateTime.now()
        : DbDateTime.dbToUtc(loaded.departureLine!.eventDateTime);
    _departureAirportId = loaded.positioning.departurePlaceId;
    _arrivalAirportId = loaded.positioning.arrivalPlaceId;
    _arrival = DbDateTime.dbToUtcOrNull(loaded.positioning.arrivalDateTime);
    _departureTimeController.text = ClockTimeInputField.formatMinutesOfDay(
      _departure.hour * 60 + _departure.minute,
    );
    _arrivalTimeController.text = _arrival == null
        ? ''
        : ClockTimeInputField.formatMinutesOfDay(
            _arrival!.hour * 60 + _arrival!.minute,
          );
    _notesController.text = loaded.positioning.notes;
    _timeController.text = HourInputField.formatHours(
      loaded.positioning.timeTotalMinutes,
    );
    if (!mounted) return;
    _setLoadingFalse();
  }

  int _calculatedMinutes() {
    if (_arrival == null) return 0;
    return _arrival!.difference(_departure).inMinutes.clamp(0, 24 * 60 * 10);
  }

  void _updateTimeIfAuto() {
    if (_timeEdited) return;
    _timeController.text = HourInputField.formatHours(_calculatedMinutes());
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departure,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    if (!mounted) return;
    _applyPickedDate(picked);
  }

  Future<void> _pickDepartureAirport() async {
    final selected = await AirportPickerDialog.show(
      context,
      title: 'Select departure airport',
    );
    if (selected == null) return;
    if (!mounted) return;
    _setDepartureAirportId(selected.id);
  }

  Future<void> _pickArrivalAirport() async {
    final selected = await AirportPickerDialog.show(
      context,
      title: 'Select arrival airport',
    );
    if (selected == null) return;
    if (!mounted) return;
    _setArrivalAirportId(selected.id);
  }

  Future<void> _createAirportAndSelect({required bool asDeparture}) async {
    final useRoutePresentation =
        MediaQuery.of(context).size.width < 600 ||
        context.findAncestorWidgetOfExactType<Dialog>() != null;
    const placeholder = Airport(
      id: kPlaceholderId,
      icao: '',
      latitude: 0,
      longitude: 0,
      isFavorite: false,
      isLocked: false,
    );
    dynamic result;
    if (useRoutePresentation) {
      result = await AppNavigator.pushMaterial<dynamic>(
        context,
        (_) => const AirportEditScreen(item: placeholder, isCreate: true),
      );
    } else {
      result = await showDialog<dynamic>(
        context: context,
        builder: (_) =>
            const AirportEditScreen(item: placeholder, isCreate: true),
      );
    }

    if (!mounted) return;
    final id = result is int ? result : null;
    if (id == null) return;
    final db = ref.read(databaseProvider);
    final created = await (db.select(
      db.airports,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (!mounted || created == null) return;
    if (!mounted) return;
    _setCreatedAirport(asDeparture: asDeparture, created: created);
  }

  void _onDepartureTimeChanged(int minutes) {
    final hour = (minutes ~/ 60) % 24;
    final minute = minutes % 60;
    setState(() {
      _departure = DateTime(
        _departure.year,
        _departure.month,
        _departure.day,
        hour,
        minute,
      );
      _arrivalTimeErrorText = null;
      _updateTimeIfAuto();
    });
  }

  void _onArrivalTimeChanged(int minutes) {
    final hour = (minutes ~/ 60) % 24;
    final minute = minutes % 60;
    final departureDate = DateTime(
      _departure.year,
      _departure.month,
      _departure.day,
    );
    final departureMinutes = _departure.hour * 60 + _departure.minute;
    final isNextDay = minutes < departureMinutes;
    final arrivalDate = departureDate.add(Duration(days: isNextDay ? 1 : 0));
    setState(() {
      _arrival = DateTime(
        arrivalDate.year,
        arrivalDate.month,
        arrivalDate.day,
        hour,
        minute,
      );
      _arrivalTimeErrorText = null;
      _updateTimeIfAuto();
    });
  }

  void _clearArrivalTime() {
    setState(() {
      _arrival = null;
      _arrivalTimeController.text = '';
      _arrivalTimeErrorText = null;
      _updateTimeIfAuto();
    });
  }

  String _dateLabel(DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('dd/MMM yyyy', locale).format(value);
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    String? departureAirportErrorText;
    String? arrivalAirportErrorText;
    String? arrivalTimeErrorText;
    String? totalTimeErrorText;

    if (_departureAirportId == null || _arrivalAirportId == null) {
      departureAirportErrorText = _departureAirportId == null
          ? 'Select departure airport.'
          : null;
      arrivalAirportErrorText = _arrivalAirportId == null
          ? 'Select arrival airport.'
          : null;
    }
    final arrival = _arrival;
    if (arrival != null && !arrival.isAfter(_departure)) {
      arrivalTimeErrorText = 'Arrival time must be after departure time.';
    }
    if (arrival != null &&
        arrival.difference(_departure) > const Duration(hours: 24)) {
      arrivalTimeErrorText =
          'Arrival time cannot be more than 24 hours after departure.';
    }
    final parsed = HourInputField.parseHours(_timeController.text);
    if (parsed == null || parsed <= 0) {
      totalTimeErrorText = 'Enter a valid positioning time.';
    }

    setState(() {
      _departureAirportErrorText = departureAirportErrorText;
      _arrivalAirportErrorText = arrivalAirportErrorText;
      _arrivalTimeErrorText = arrivalTimeErrorText;
      _totalTimeErrorText = totalTimeErrorText;
    });

    if (!formValid ||
        departureAirportErrorText != null ||
        arrivalAirportErrorText != null ||
        arrivalTimeErrorText != null ||
        totalTimeErrorText != null) {
      return;
    }

    final useCases = ref.read(logbookUseCasesProvider);
    if (widget.isCreate) {
      await useCases.createPositioning(
        departureAirportId: _departureAirportId!,
        arrivalAirportId: _arrivalAirportId!,
        departureDateTime: DbDateTime.wallClockToDbUtc(_departure),
        arrivalDateTime: DbDateTime.wallClockToDbUtcOrNull(arrival),
        totalMinutes: parsed!,
        notes: _notesController.text.trim(),
      );
    } else {
      final item = _positioning;
      if (item == null) return;
      await useCases.updatePositioning(
        positioning: item,
        departureDateTime: DbDateTime.wallClockToDbUtc(_departure),
        arrivalDateTime: DbDateTime.wallClockToDbUtcOrNull(arrival),
        departureAirportId: _departureAirportId!,
        arrivalAirportId: _arrivalAirportId!,
        totalMinutes: parsed!,
        notes: _notesController.text.trim(),
      );
    }
    if (!mounted) return;
    AppNavigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final airportsAsync = ref.watch(
      airportsProvider(
        const AirportSearchParams(
          query: '',
          filters: AirportFilters(),
        ),
      ),
    );

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final form = Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DateSelectorInputField(
              label: 'Date',
              valueText: _dateLabel(_departure),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            TwoColumnFieldRow(
              left: ClockTimeInputField(
                controller: _departureTimeController,
                label: 'Departure Time',
                onChangedMinutes: _onDepartureTimeChanged,
              ),
              right: LabeledClockFieldWithClear(
                controller: _arrivalTimeController,
                label: 'Arrival Time',
                onChangedMinutes: _onArrivalTimeChanged,
                onCleared: _clearArrivalTime,
                errorText: _arrivalTimeErrorText,
                clearTooltip: 'Clear',
                clearEnabled: _arrival != null,
                onPressedClear: _clearArrivalTime,
              ),
            ),
            const SizedBox(height: 8),
            HourInputField(
              controller: _timeController,
              label: 'Total Time',
              fallbackMinutes: _calculatedMinutes(),
              onChangedMinutes: (_) {
                _timeEdited = true;
                if (_totalTimeErrorText != null) {
                  setState(() => _totalTimeErrorText = null);
                }
              },
              errorText: _totalTimeErrorText,
              suffixIcon: IconButton(
                tooltip: 'Use calculated time',
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
                onPressed: _arrival == null
                    ? null
                    : () {
                        final calculated = _calculatedMinutes();
                        setState(() {
                          _timeController.text = HourInputField.formatHours(
                            calculated,
                          );
                          _timeEdited = false;
                        });
                      },
                icon: const Icon(Icons.calculate_outlined),
              ),
              validator: (value) {
                final parsed = HourInputField.parseHours(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return l10n.validationErrorGeneric;
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            PickerWithAddInputField(
              label: 'Departure Airport',
              valueText: _airportLabelForId(_departureAirportId, airportsAsync),
              onTap: _pickDepartureAirport,
              onAdd: () => _createAirportAndSelect(asDeparture: true),
              addTooltip: 'Add airport',
              errorText: _departureAirportErrorText,
            ),
            const SizedBox(height: 8),
            PickerWithAddInputField(
              label: 'Arrival Airport',
              valueText: _airportLabelForId(_arrivalAirportId, airportsAsync),
              onTap: _pickArrivalAirport,
              onAdd: () => _createAirportAndSelect(asDeparture: false),
              addTooltip: 'Add airport',
              errorText: _arrivalAirportErrorText,
            ),
            const SizedBox(height: 8),
            TextInputField(
              controller: _notesController,
              label: 'Notes',
              minLines: 3,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );

    final title = widget.isCreate ? 'New Positioning' : 'Edit Positioning';
    return AdaptiveFormShell(
      onClose: () => unawaited(AppNavigator.maybePop(context)),
      longTitle: title,
      shortTitle: title,
      actions: [TextButton(onPressed: _save, child: Text(l10n.saveAction))],
      contentView: form,
    );
  }

  String _airportLabelForId(
    int? airportId,
    AsyncValue<List<AirportRow>> airportsAsync,
  ) {
    if (airportId == null) return 'Not selected';
    final list = airportsAsync.valueOrNull;
    if (list == null) return 'ID: $airportId';
    for (final row in list) {
      final airport = row.airport;
      if (airport.id != airportId) continue;
      final name = (airport.name ?? '').trim();
      return name.isEmpty ? airport.icao : '${airport.icao} - $name';
    }
    return 'ID: $airportId';
  }
}
