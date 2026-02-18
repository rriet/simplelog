import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/features/airports/application/providers/airports_feature_providers.dart';
import 'package:simplelog/features/airports/presentation/airport_edit_screen.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_picker_dialog.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/presentation/shared/widgets/time_input_field.dart';
import 'package:simplelog/state/providers/database_provider.dart';

class PositioningEditScreen extends ConsumerStatefulWidget {
  const PositioningEditScreen({
    super.key,
    this.positioningId,
  });

  final int? positioningId;

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

  @override
  void initState() {
    super.initState();
    _departureTimeController.text = TimeInputField.formatMinutes(
      _departure.hour * 60 + _departure.minute,
    );
    _arrivalTimeController.text = '';
    _timeController.text = TimeInputField.formatMinutes(0);
    _loadExisting();
  }

  @override
  void dispose() {
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (widget.isCreate) {
      setState(() => _loading = false);
      return;
    }
    final useCases = ref.read(logbookUseCasesProvider);
    final loaded = await useCases.loadPositioningEditData(widget.positioningId!);
    if (!mounted) return;
    if (loaded == null) {
      setState(() => _loading = false);
      return;
    }
    _positioning = loaded.positioning;
    _departure = loaded.departureLine?.eventDateTime ?? DateTime.now();
    _departureAirportId = loaded.positioning.departurePlaceId;
    _arrivalAirportId = loaded.positioning.arrivalPlaceId;
    _arrival = loaded.positioning.arrivalDateTime;
    _departureTimeController.text = TimeInputField.formatMinutes(
      _departure.hour * 60 + _departure.minute,
    );
    _arrivalTimeController.text = _arrival == null
        ? ''
        : TimeInputField.formatMinutes(_arrival!.hour * 60 + _arrival!.minute);
    _notesController.text = loaded.positioning.notes;
    _timeController.text =
        TimeInputField.formatMinutes(loaded.positioning.timeTotalMinutes);
    setState(() => _loading = false);
  }

  int _calculatedMinutes() {
    if (_arrival == null) return 0;
    return _arrival!.difference(_departure).inMinutes.clamp(0, 24 * 60 * 10);
  }

  void _updateTimeIfAuto() {
    if (_timeEdited) return;
    _timeController.text = TimeInputField.formatMinutes(_calculatedMinutes());
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departure,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
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

  Future<void> _pickDepartureAirport() async {
    final selected = await AirportPickerDialog.show(
      context,
      title: 'Select departure airport',
    );
    if (selected == null || !mounted) return;
    setState(() => _departureAirportId = selected.id);
  }

  Future<void> _pickArrivalAirport() async {
    final selected = await AirportPickerDialog.show(
      context,
      title: 'Select arrival airport',
    );
    if (selected == null || !mounted) return;
    setState(() => _arrivalAirportId = selected.id);
  }

  Future<void> _createAirportAndSelect({required bool asDeparture}) async {
    final placeholder = Airport(
      id: kPlaceholderId,
      icao: '',
      iata: null,
      name: null,
      city: null,
      country: null,
      latitude: 0,
      longitude: 0,
      isFavorite: false,
      isLocked: false,
    );
    final result = await _showStandardFormDialog<dynamic>(
      context,
      AirportEditScreen(
        item: placeholder,
        isCreate: true,
      ),
    );

    if (!mounted) return;
    final id = result is int ? result : null;
    if (id == null) return;
    final db = ref.read(databaseProvider);
    final created =
        await (db.select(db.airports)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (!mounted || created == null) return;
    setState(() {
      if (asDeparture) {
        _departureAirportId = created.id;
      } else {
        _arrivalAirportId = created.id;
      }
    });
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
      _updateTimeIfAuto();
    });
  }

  void _clearArrivalTime() {
    setState(() {
      _arrival = null;
      _arrivalTimeController.text = '';
      _updateTimeIfAuto();
    });
  }

  String _dateLabel(DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('dd/MMM yyyy', locale).format(value);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_departureAirportId == null || _arrivalAirportId == null) {
      await _showError('Select departure and arrival airports.');
      return;
    }
    final arrival = _arrival;
    if (arrival != null && !arrival.isAfter(_departure)) {
      await _showError('Arrival time must be after departure time.');
      return;
    }
    if (arrival != null &&
        arrival.difference(_departure) > const Duration(hours: 24)) {
      await _showError('Arrival time cannot be more than 24 hours after departure.');
      return;
    }
    final parsed = TimeInputField.parseMinutes(_timeController.text);
    if (parsed == null || parsed <= 0) {
      await _showError('Enter a valid positioning time.');
      return;
    }

    final useCases = ref.read(logbookUseCasesProvider);
    if (widget.isCreate) {
      await useCases.createPositioning(
        departureAirportId: _departureAirportId!,
        arrivalAirportId: _arrivalAirportId!,
        departureDateTime: _departure,
        arrivalDateTime: arrival,
        totalMinutes: parsed,
        notes: _notesController.text.trim(),
      );
    } else {
      final item = _positioning;
      if (item == null) return;
      await useCases.updatePositioning(
        positioning: item,
        departureDateTime: _departure,
        arrivalDateTime: arrival,
        departureAirportId: _departureAirportId!,
        arrivalAirportId: _arrivalAirportId!,
        totalMinutes: parsed,
        notes: _notesController.text.trim(),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _showError(String message) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.validationErrorTitle),
        content: Text(message),
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
    final airportsAsync = ref.watch(
      airportsProvider(
        const AirportSearchParams(
          query: '',
          filters: AirportFilters(showOnlyVisited: false),
        ),
      ),
    );

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreate ? 'New Positioning' : 'Edit Positioning'),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(_dateLabel(_departure)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TimeInputField(
                    controller: _departureTimeController,
                    label: 'Departure Time',
                    maxHours: 23,
                    onChangedMinutes: _onDepartureTimeChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TimeInputField(
                    controller: _arrivalTimeController,
                    label: 'Arrival Time',
                    maxHours: 23,
                    onChangedMinutes: _onArrivalTimeChanged,
                    onCleared: _clearArrivalTime,
                    allowEmpty: true,
                  ),
                ),
                IconButton(
                  tooltip: 'Clear',
                  onPressed: _arrival == null ? null : _clearArrivalTime,
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TimeInputField(
                    controller: _timeController,
                    label: 'Total Time',
                    fallbackMinutes: _calculatedMinutes(),
                    onChangedMinutes: (_) => _timeEdited = true,
                    validator: (value) {
                      final parsed = TimeInputField.parseMinutes(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return l10n.validationErrorGeneric;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Use calculated time',
                  onPressed: _arrival == null
                      ? null
                      : () {
                          final calculated = _calculatedMinutes();
                          setState(() {
                            _timeController.text =
                                TimeInputField.formatMinutes(calculated);
                            _timeEdited = false;
                          });
                        },
                  icon: const Icon(Icons.calculate_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Departure Airport'),
                    subtitle: Text(
                      _airportLabelForId(_departureAirportId, airportsAsync),
                    ),
                    trailing: const Icon(Icons.search),
                    onTap: _pickDepartureAirport,
                  ),
                ),
                IconButton(
                  tooltip: 'Add airport',
                  onPressed: () => _createAirportAndSelect(asDeparture: true),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Arrival Airport'),
                    subtitle: Text(
                      _airportLabelForId(_arrivalAirportId, airportsAsync),
                    ),
                    trailing: const Icon(Icons.search),
                    onTap: _pickArrivalAirport,
                  ),
                ),
                IconButton(
                  tooltip: 'Add airport',
                  onPressed: () => _createAirportAndSelect(asDeparture: false),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              minLines: 3,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
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

  Future<T?> _showStandardFormDialog<T>(BuildContext context, Widget child) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    return showDialog<T>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: maxHeight,
          ),
          child: SizedBox(
            width: 520,
            child: child,
          ),
        ),
      ),
    );
  }

}
