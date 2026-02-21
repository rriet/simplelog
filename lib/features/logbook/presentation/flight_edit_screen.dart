import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/date/db_date_time.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/flight/flight_calculations.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';
import 'package:simplelog/features/aircraft/application/providers/aircraft_feature_providers.dart';
import 'package:simplelog/features/aircraft/presentation/aircraft_edit_screen.dart';
import 'package:simplelog/features/aircraft/presentation/widgets/aircraft_picker_dialog.dart';
import 'package:simplelog/features/airports/application/providers/airports_feature_providers.dart';
import 'package:simplelog/features/airports/presentation/airport_edit_screen.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_picker_dialog.dart';
import 'package:simplelog/features/crew/application/providers/crew_feature_providers.dart';
import 'package:simplelog/features/crew/presentation/crew_edit_screen.dart';
import 'package:simplelog/features/crew/presentation/widgets/crew_picker_dialog.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/presentation/shared/widgets/time_input_field.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/custom_time_labels_provider.dart';
import 'package:simplelog/state/providers/flight_factoring_settings_provider.dart';
import 'package:simplelog/state/providers/flight_form_settings_provider.dart';
import 'package:simplelog/state/providers/flight_time_fields_visibility_provider.dart';
import 'package:simplelog/state/providers/simulator_default_crew_position_provider.dart';

class FlightEditScreen extends ConsumerStatefulWidget {
  const FlightEditScreen({super.key, this.flightId, this.prefill});

  final int? flightId;
  final FlightPrefill? prefill;

  bool get isCreate => flightId == null;

  @override
  ConsumerState<FlightEditScreen> createState() => _FlightEditScreenState();
}

class _FlightEditScreenState extends ConsumerState<FlightEditScreen> {
  final _remarksController = TextEditingController();
  final _notesController = TextEditingController();
  final _chocksOffTimeController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _takeOffTimeController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _landingTimeController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _chocksOnTimeController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _picController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _picusController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _sicController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _dualController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _instructorController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _ifrController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _instrumentController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _simInstrumentController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _nightController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _crossController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _custom1Controller = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _custom2Controller = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _custom3Controller = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _custom4Controller = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _flightController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _blockController = TextEditingController(
    text: TimeInputField.formatMinutes(0),
  );
  final _takeoffDayController = TextEditingController(text: '0');
  final _takeoffNightController = TextEditingController(text: '0');
  final _landingDayController = TextEditingController(text: '0');
  final _landingNightController = TextEditingController(text: '0');
  final _ifrApproachesController = TextEditingController(text: '0');
  final _approachTypeController = TextEditingController();
  final _distanceNmController = TextEditingController(text: '0');
  final _crewListController = ScrollController();
  final FocusNode _formFocusNode = FocusNode(skipTraversal: true);

  bool _loading = true;
  int _page = 0;

  Flight? _flight;
  DateTime _chocksOff = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  TimeOfDay? _takeOff;
  TimeOfDay? _landing;
  TimeOfDay? _chocksOn;

  int? _aircraftId;
  int? _fromAirportId;
  int? _toAirportId;
  String _pilotFunction = 'PF';
  int _timeTotalBlockMinutes = 0;
  final List<_CrewDraftRow> _crewRows = [];
  final Map<int, String> _airportLabelCache = {};
  final Map<int, String> _crewLabelCache = {};

  int _takeoffsDay = 0;
  int _takeoffsNight = 0;
  int _landingsDay = 0;
  int _landingsNight = 0;

  FlightFormTimeChecks _checks = const FlightFormTimeChecks();
  bool _logTakeoffLanding = true;
  int _lastCalculatedNightMinutes = 0;
  int _lastCalculatedFlightMinutes = 0;

  DateTime get _chocksOffMinute => DateTime(
    _chocksOff.year,
    _chocksOff.month,
    _chocksOff.day,
    _chocksOff.hour,
    _chocksOff.minute,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _notesController.dispose();
    _chocksOffTimeController.dispose();
    _takeOffTimeController.dispose();
    _landingTimeController.dispose();
    _chocksOnTimeController.dispose();
    _picController.dispose();
    _picusController.dispose();
    _sicController.dispose();
    _dualController.dispose();
    _instructorController.dispose();
    _ifrController.dispose();
    _instrumentController.dispose();
    _simInstrumentController.dispose();
    _nightController.dispose();
    _crossController.dispose();
    _custom1Controller.dispose();
    _custom2Controller.dispose();
    _custom3Controller.dispose();
    _custom4Controller.dispose();
    _flightController.dispose();
    _blockController.dispose();
    _takeoffDayController.dispose();
    _takeoffNightController.dispose();
    _landingDayController.dispose();
    _landingNightController.dispose();
    _ifrApproachesController.dispose();
    _approachTypeController.dispose();
    _distanceNmController.dispose();
    _crewListController.dispose();
    _formFocusNode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final logTakeoffLanding = await ref.read(
      flightFormTakeoffLandingLogProvider.future,
    );
    final checks = await ref.read(flightFormTimeChecksProvider.future);
    _logTakeoffLanding = logTakeoffLanding;
    _checks = checks;
    if (widget.isCreate) {
      final prefill = widget.prefill;
      _applyChecksToControllers(
        totalMinutes: 0,
        calculatedNight: 0,
        calculatedFlight: 0,
      );
      _chocksOff =
          prefill?.chocksOff ??
          DateTime(_chocksOff.year, _chocksOff.month, _chocksOff.day);
      _aircraftId = prefill?.aircraftId;
      _fromAirportId = prefill?.fromAirportId;
      _toAirportId = prefill?.toAirportId;
      _takeOff = null;
      _landing = null;
      _chocksOn = null;
      _timeTotalBlockMinutes = 0;
      _chocksOffTimeController.text = prefill?.chocksOff == null
          ? ''
          : TimeInputField.formatMinutes(
              _chocksOff.hour * 60 + _chocksOff.minute,
            );
      _takeOffTimeController.text = '';
      _landingTimeController.text = '';
      _chocksOnTimeController.text = '';
      if (prefill != null && prefill.crewAssignments.isNotEmpty) {
        _crewRows
          ..clear()
          ..addAll(
            prefill.crewAssignments.map(
              (e) => _CrewDraftRow(crewId: e.crewId, position: e.position),
            ),
          );
      } else {
        await _insertDefaultSelfCrewIfAny();
      }
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }
    final useCases = ref.read(logbookUseCasesProvider);
    final loaded = await useCases.loadFlightEditData(widget.flightId!);
    if (!mounted || loaded == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final flight = loaded.flight;
    _flight = flight;
    _aircraftId = flight.aircraftId;
    _fromAirportId = flight.departureAirportId;
    _toAirportId = flight.arrivalAirportId;
    final totalTakeoffs = flight.takeOffsDays + flight.takeOffsNight;
    final totalLandings = flight.landingsDay + flight.landingsNight;
    _pilotFunction = _normalizePilotFunction(
      flight.pilotFunction,
      fallbackTakeoffs: totalTakeoffs,
      fallbackLandings: totalLandings,
    );
    _timeTotalBlockMinutes = flight.timeTotalBlockMinutes;
    _remarksController.text = flight.remarks;
    _notesController.text = flight.notes;
    _ifrApproachesController.text = '${flight.ifrApproaches}';
    _approachTypeController.text = _isPilotFunctionValue(flight.approachType)
        ? ''
        : flight.approachType;
    _distanceNmController.text = '${flight.distanceNM}';
    _takeoffsDay = flight.takeOffsDays;
    _takeoffsNight = flight.takeOffsNight;
    _landingsDay = flight.landingsDay;
    _landingsNight = flight.landingsNight;
    _takeoffDayController.text = '$_takeoffsDay';
    _takeoffNightController.text = '$_takeoffsNight';
    _landingDayController.text = '$_landingsDay';
    _landingNightController.text = '$_landingsNight';
    final dep = loaded.departureLine == null
        ? DateTime.now()
        : DbDateTime.dbToUtc(loaded.departureLine!.eventDateTime);
    _chocksOff = dep;
    _takeOff = _toTimeOfDayFromDb(flight.takeOffDateTime);
    _landing = _toTimeOfDayFromDb(flight.landingDateTime);
    _chocksOn = _toTimeOfDayFromDb(flight.arrivalDateTime);
    final unknownTimes =
        _chocksOff.hour == 0 && _chocksOff.minute == 0 && _chocksOn == null;
    _chocksOffTimeController.text = unknownTimes
        ? ''
        : TimeInputField.formatMinutes(
            _chocksOff.hour * 60 + _chocksOff.minute,
          );
    _takeOffTimeController.text = _takeOff == null
        ? ''
        : TimeInputField.formatMinutes(_takeOff!.hour * 60 + _takeOff!.minute);
    _landingTimeController.text = _landing == null
        ? ''
        : TimeInputField.formatMinutes(_landing!.hour * 60 + _landing!.minute);
    _chocksOnTimeController.text = _chocksOn == null
        ? ''
        : TimeInputField.formatMinutes(
            _chocksOn!.hour * 60 + _chocksOn!.minute,
          );
    _blockController.text = TimeInputField.formatMinutes(
      flight.timeBlockMinutes,
    );
    _picController.text = TimeInputField.formatMinutes(flight.timePICMinutes);
    _picusController.text = TimeInputField.formatMinutes(
      flight.timePICUSMinutes,
    );
    _sicController.text = TimeInputField.formatMinutes(flight.timeSICMinutes);
    _dualController.text = TimeInputField.formatMinutes(flight.timeDualMinutes);
    _instructorController.text = TimeInputField.formatMinutes(
      flight.timeInstructorMinutes,
    );
    _ifrController.text = TimeInputField.formatMinutes(flight.timeIFRMinutes);
    _instrumentController.text = TimeInputField.formatMinutes(
      flight.timeInstrumentMinutes,
    );
    _simInstrumentController.text = TimeInputField.formatMinutes(
      flight.timeSimulatedInstrumentMinutes,
    );
    _nightController.text = TimeInputField.formatMinutes(
      flight.timeNightMinutes,
    );
    _crossController.text = TimeInputField.formatMinutes(
      flight.timeCrossCountryMinutes,
    );
    _custom1Controller.text = TimeInputField.formatMinutes(
      flight.timeCustom1Minutes,
    );
    _custom2Controller.text = TimeInputField.formatMinutes(
      flight.timeCustom2Minutes,
    );
    _custom3Controller.text = TimeInputField.formatMinutes(
      flight.timeCustom3Minutes,
    );
    _custom4Controller.text = TimeInputField.formatMinutes(
      flight.timeCustom4Minutes,
    );
    _flightController.text = TimeInputField.formatMinutes(
      flight.timeFlightMinutes,
    );
    _lastCalculatedNightMinutes = flight.timeNightMinutes;
    _lastCalculatedFlightMinutes = flight.timeFlightMinutes;
    _crewRows
      ..clear()
      ..addAll(
        loaded.crewAssignments.map(
          (e) => _CrewDraftRow(crewId: e.crewId, position: e.position),
        ),
      );
    setState(() => _loading = false);
  }

  Future<void> _insertDefaultSelfCrewIfAny() async {
    if (!widget.isCreate || _crewRows.isNotEmpty) return;
    final db = ref.read(databaseProvider);
    final selfCrew =
        await (db.select(db.crew)
              ..where((t) => t.isSelf.equals(true))
              ..limit(1))
            .getSingleOrNull();
    if (!mounted || selfCrew == null) return;
    final defaultPosition = await ref.read(
      simulatorDefaultCrewPositionProvider.future,
    );
    if (!mounted) return;
    _crewRows.add(
      _CrewDraftRow(crewId: selfCrew.id, position: defaultPosition),
    );
  }

  Future<void> _pickFlightDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _chocksOff,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _chocksOff = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _chocksOff.hour,
        _chocksOff.minute,
      );
    });
  }

  void _onChocksOffTimeChanged(int totalMinutes) {
    final hour = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;
    setState(() {
      _chocksOff = DateTime(
        _chocksOff.year,
        _chocksOff.month,
        _chocksOff.day,
        hour,
        minute,
      );
    });
  }

  void _onTakeoffTimeChanged(int totalMinutes) {
    final hour = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;
    setState(() {
      _takeOff = TimeOfDay(hour: hour, minute: minute);
    });
  }

  void _onLandingTimeChanged(int totalMinutes) {
    final hour = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;
    setState(() {
      _landing = TimeOfDay(hour: hour, minute: minute);
    });
  }

  void _onChocksOnTimeChanged(int totalMinutes) {
    final hour = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;
    setState(() {
      _chocksOn = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _pickAircraft() async {
    _clearKeyboardFocus();
    final selected = await AircraftPickerDialog.show(
      context,
      title: 'Select aircraft',
      onlySimulators: false,
    );
    _clearKeyboardFocus();
    if (selected == null || !mounted) return;
    setState(() => _aircraftId = selected.id);
  }

  Future<void> _createAircraftAndSelect() async {
    final screenContext = context;
    final placeholder = Aircraft(
      id: kPlaceholderId,
      aircraftTypeId: 0,
      registration: '',
      mtow: null,
      isSimulator: false,
      isFavorite: false,
      isLocked: false,
      notes: null,
    );
    final result = await _showStandardFormDialog<dynamic>(
      screenContext,
      AircraftEditScreen(
        item: placeholder,
        isCreate: true,
        initialIsSimulator: false,
      ),
    );
    if (!mounted || result != true) return;
    final db = ref.read(databaseProvider);
    final created =
        await (db.select(db.aircrafts)
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingleOrNull();
    if (!mounted || created == null) return;
    setState(() => _aircraftId = created.id);
  }

  Future<void> _pickAirport({required bool isFrom}) async {
    _clearKeyboardFocus();
    final selected = await AirportPickerDialog.show(
      context,
      title: isFrom ? 'Select departure airport' : 'Select arrival airport',
    );
    _clearKeyboardFocus();
    if (selected == null || !mounted) return;
    final name = (selected.name ?? '').trim();
    _airportLabelCache[selected.id] = name.isEmpty
        ? selected.icao
        : '${selected.icao} - $name';
    setState(() {
      if (isFrom) {
        _fromAirportId = selected.id;
      } else {
        _toAirportId = selected.id;
      }
    });
  }

  Future<void> _createAirport({required bool isFrom}) async {
    final screenContext = context;
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
      screenContext,
      AirportEditScreen(item: placeholder, isCreate: true),
    );
    if (!mounted) return;
    final db = ref.read(databaseProvider);
    int? airportId = result is int ? result : null;
    if (airportId == null && result == true) {
      final created =
          await (db.select(db.airports)
                ..orderBy([(t) => OrderingTerm.desc(t.id)])
                ..limit(1))
              .getSingleOrNull();
      airportId = created?.id;
      if (created != null) {
        final name = (created.name ?? '').trim();
        _airportLabelCache[created.id] = name.isEmpty
            ? created.icao
            : '${created.icao} - $name';
      }
    } else if (airportId != null) {
      final existingId = airportId;
      final created = await (db.select(
        db.airports,
      )..where((t) => t.id.equals(existingId))).getSingleOrNull();
      if (created != null) {
        final name = (created.name ?? '').trim();
        _airportLabelCache[created.id] = name.isEmpty
            ? created.icao
            : '${created.icao} - $name';
      }
    }
    if (airportId == null) return;
    setState(() {
      if (isFrom) {
        _fromAirportId = airportId;
      } else {
        _toAirportId = airportId;
      }
    });
  }

  Future<void> _next() async {
    if (!_validateForSave()) return;
    final calc = await _calculate();
    if (calc != null) {
      _lastCalculatedNightMinutes = calc.nightMinutes;
      _lastCalculatedFlightMinutes = calc.flightMinutes;
      _distanceNmController.text = '${calc.distanceNm}';
    }
    if (!mounted) return;
    setState(() => _page = 1);
  }

  Future<void> _calculateAndNext() async {
    if (!_validateForCalculate()) return;
    final calc = await _calculate();
    if (calc == null || !mounted) return;
    _applyCalculation(calc);
    setState(() => _page = 1);
  }

  Future<void> _calculateInPlace() async {
    if (!_validateForCalculate()) return;
    final calc = await _calculate();
    if (calc == null || !mounted) return;
    setState(() => _applyCalculation(calc));
  }

  void _applyCalculation(_FlightCalcResult calc) {
    _takeoffsDay = calc.takeoffsDay;
    _takeoffsNight = calc.takeoffsNight;
    _landingsDay = calc.landingsDay;
    _landingsNight = calc.landingsNight;
    _takeoffDayController.text = '$_takeoffsDay';
    _takeoffNightController.text = '$_takeoffsNight';
    _landingDayController.text = '$_landingsDay';
    _landingNightController.text = '$_landingsNight';
    _lastCalculatedNightMinutes = calc.nightMinutes;
    _lastCalculatedFlightMinutes = calc.flightMinutes;
    _timeTotalBlockMinutes = calc.totalBlockMinutes;
    _blockController.text = TimeInputField.formatMinutes(calc.totalMinutes);
    _distanceNmController.text = '${calc.distanceNm}';
    _applyChecksToControllers(
      totalMinutes: calc.totalMinutes,
      calculatedNight: calc.nightMinutes,
      calculatedFlight: calc.flightMinutes,
    );
  }

  Future<_FlightCalcResult?> _calculate() async {
    final db = ref.read(databaseProvider);
    final from = await (db.select(
      db.airports,
    )..where((t) => t.id.equals(_fromAirportId!))).getSingleOrNull();
    final to = await (db.select(
      db.airports,
    )..where((t) => t.id.equals(_toAirportId!))).getSingleOrNull();
    if (from == null || to == null) return null;
    final dep = _chocksOffMinute;
    final arr = _resolveChocksOnDateTime();
    if (arr == null || !arr.isAfter(dep)) return null;
    final takeoffDateTime = _resolveTakeOffDateTime() ?? dep;
    final landingDateTime = _resolveLandingDateTime() ?? arr;
    final flightCalc = FlightCalculations(
      latDep: from.latitude,
      longDep: from.longitude,
      latArr: to.latitude,
      longArr: to.longitude,
      depTimeEpochSeconds: _wallClockAsUtcEpochSeconds(takeoffDateTime),
      arrTimeEpochSeconds: _wallClockAsUtcEpochSeconds(landingDateTime),
    );
    final totalBlockMinutes = arr.difference(dep).inMinutes.clamp(0, 24 * 60);
    final factoring = await ref.read(flightFactoringSettingsProvider.future);
    final totalMinutes = _applyPilotFunctionFactoring(
      totalBlockMinutes: totalBlockMinutes,
      pilotFunction: _pilotFunction,
      irp3Percent: factoring.irp3Percent,
      irp3SubtractMinutes: factoring.irp3SubtractMinutes,
      irp4Percent: factoring.irp4Percent,
      irp4SubtractMinutes: factoring.irp4SubtractMinutes,
    );
    final hasTakeoffAndLanding =
        _logTakeoffLanding && _takeOff != null && _landing != null;
    final flightMinutes = hasTakeoffAndLanding
        ? landingDateTime
              .difference(takeoffDateTime)
              .inMinutes
              .clamp(0, 24 * 60)
        : 0;
    final distanceNm = flightCalc.flightDistanceNm.round();
    var tkDay = 0;
    var tkNight = 0;
    var ldDay = 0;
    var ldNight = 0;
    final takeoffCount = switch (_pilotFunction) {
      'PF' || 'PF/PNF' => 1,
      _ => 0,
    };
    final landingCount = switch (_pilotFunction) {
      'PF' || 'PNF/PF' => 1,
      _ => 0,
    };
    if (takeoffCount > 0) {
      if (flightCalc.dayTakeOff) {
        tkDay = takeoffCount;
      } else {
        tkNight = takeoffCount;
      }
    }
    if (landingCount > 0) {
      if (flightCalc.dayLanding) {
        ldDay = landingCount;
      } else {
        ldNight = landingCount;
      }
    }
    return _FlightCalcResult(
      totalBlockMinutes: totalBlockMinutes,
      totalMinutes: totalMinutes,
      nightMinutes: flightCalc.nightTimeMinutes.clamp(0, totalMinutes),
      flightMinutes: flightMinutes,
      distanceNm: distanceNm,
      takeoffsDay: tkDay,
      takeoffsNight: tkNight,
      landingsDay: ldDay,
      landingsNight: ldNight,
    );
  }

  void _applyChecksToControllers({
    required int totalMinutes,
    required int calculatedNight,
    required int calculatedFlight,
  }) {
    _setControllerMinutes(_picController, _checks.pic ? totalMinutes : 0);
    _setControllerMinutes(_picusController, _checks.picus ? totalMinutes : 0);
    _setControllerMinutes(_sicController, _checks.sic ? totalMinutes : 0);
    _setControllerMinutes(_dualController, _checks.dual ? totalMinutes : 0);
    _setControllerMinutes(
      _instructorController,
      _checks.instructor ? totalMinutes : 0,
    );
    _setControllerMinutes(_ifrController, _checks.ifr ? totalMinutes : 0);
    _setControllerMinutes(
      _instrumentController,
      _checks.instrument ? totalMinutes : 0,
    );
    _setControllerMinutes(
      _simInstrumentController,
      _checks.simInstrument ? totalMinutes : 0,
    );
    _setControllerMinutes(
      _nightController,
      _checks.night ? calculatedNight : 0,
    );
    _setControllerMinutes(
      _crossController,
      _checks.crossCountry ? totalMinutes : 0,
    );
    _setControllerMinutes(
      _custom1Controller,
      _checks.custom1 ? totalMinutes : 0,
    );
    _setControllerMinutes(
      _custom2Controller,
      _checks.custom2 ? totalMinutes : 0,
    );
    _setControllerMinutes(
      _custom3Controller,
      _checks.custom3 ? totalMinutes : 0,
    );
    _setControllerMinutes(
      _custom4Controller,
      _checks.custom4 ? totalMinutes : 0,
    );
    _setControllerMinutes(
      _flightController,
      _checks.flight ? calculatedFlight : 0,
    );
  }

  void _setControllerMinutes(TextEditingController c, int minutes) {
    c.text = TimeInputField.formatMinutes(minutes);
  }

  bool _validateForSave() {
    if (!_syncClockTimesFromInput()) {
      return false;
    }
    if (!_canGoNext) {
      _showSnack('Select aircraft, departure airport, and arrival airport.');
      return false;
    }
    if (!_validateTimeSequence(requireChocksOn: false)) {
      return false;
    }
    return true;
  }

  bool _validateForCalculate() {
    if (!_syncClockTimesFromInput()) {
      return false;
    }
    if (!_canCalculate) {
      _showSnack('Select aircraft, departure/arrival airports, and Chocks On.');
      return false;
    }
    if (!_validateTimeSequence(requireChocksOn: true)) {
      return false;
    }
    return true;
  }

  bool _validateTimeSequence({required bool requireChocksOn}) {
    final chocksOn = _resolveChocksOnDateTime();
    if (requireChocksOn && chocksOn == null) {
      _showSnack('Select Chocks On time.');
      return false;
    }
    if (chocksOn != null && chocksOn.isBefore(_chocksOffMinute)) {
      _showSnack('Chocks On must be after or equal to Chocks Off.');
      return false;
    }
    if (_logTakeoffLanding) {
      final takeoff = _resolveTakeOffDateTime();
      final landing = _resolveLandingDateTime();
      if (takeoff != null && takeoff.isBefore(_chocksOffMinute)) {
        _showSnack('Takeoff must be after or equal to Chocks Off.');
        return false;
      }
      if (takeoff != null && landing != null && landing.isBefore(takeoff)) {
        _showSnack('Landing must be after or equal to Takeoff.');
        return false;
      }
      if (chocksOn != null && landing != null && landing.isAfter(chocksOn)) {
        _showSnack('Landing must be before or equal to Chocks On.');
        return false;
      }
    }
    return true;
  }

  bool _syncClockTimesFromInput() {
    final chocksOffMinutes = _parseClockMinutes(
      controller: _chocksOffTimeController,
      fieldLabel: 'Chocks OFF',
      allowEmpty: true,
    );
    if (chocksOffMinutes == null &&
        _chocksOffTimeController.text.trim().isNotEmpty) {
      return false;
    }
    final chocksOffValue = chocksOffMinutes ?? 0;
    _chocksOff = DateTime(
      _chocksOff.year,
      _chocksOff.month,
      _chocksOff.day,
      chocksOffValue ~/ 60,
      chocksOffValue % 60,
    );

    if (_logTakeoffLanding) {
      final takeoffMinutes = _parseClockMinutes(
        controller: _takeOffTimeController,
        fieldLabel: 'TakeOff',
        allowEmpty: true,
      );
      if (takeoffMinutes == null &&
          _takeOffTimeController.text.trim().isNotEmpty) {
        return false;
      }
      _takeOff = takeoffMinutes == null
          ? null
          : TimeOfDay(hour: takeoffMinutes ~/ 60, minute: takeoffMinutes % 60);

      final landingMinutes = _parseClockMinutes(
        controller: _landingTimeController,
        fieldLabel: 'Landing',
        allowEmpty: true,
      );
      if (landingMinutes == null &&
          _landingTimeController.text.trim().isNotEmpty) {
        return false;
      }
      _landing = landingMinutes == null
          ? null
          : TimeOfDay(hour: landingMinutes ~/ 60, minute: landingMinutes % 60);
    }

    final chocksOnMinutes = _parseClockMinutes(
      controller: _chocksOnTimeController,
      fieldLabel: 'Chocks ON',
      allowEmpty: true,
    );
    if (chocksOnMinutes == null &&
        _chocksOnTimeController.text.trim().isNotEmpty) {
      return false;
    }
    _chocksOn = chocksOnMinutes == null
        ? null
        : TimeOfDay(hour: chocksOnMinutes ~/ 60, minute: chocksOnMinutes % 60);
    return true;
  }

  int? _parseClockMinutes({
    required TextEditingController controller,
    required String fieldLabel,
    required bool allowEmpty,
  }) {
    final raw = controller.text.trim();
    if (allowEmpty && raw.isEmpty) return null;
    final minutes = TimeInputField.parseMinutes(raw, maxHours: 23);
    if (minutes == null) {
      _showSnack('$fieldLabel must be a valid time between 00:00 and 23:59.');
    }
    return minutes;
  }

  Future<void> _save() async {
    if (!_validateForSave()) return;
    final departure = _chocksOffMinute;
    final arrival = _resolveChocksOnDateTime();
    final takeoff = _logTakeoffLanding ? _resolveTakeOffDateTime() : null;
    final landing = _logTakeoffLanding ? _resolveLandingDateTime() : null;

    final block = TimeInputField.parseMinutes(_blockController.text) ?? 0;
    final totalBlock = arrival == null
        ? (_timeTotalBlockMinutes > 0 ? _timeTotalBlockMinutes : block)
        : arrival.difference(departure).inMinutes.clamp(0, 24 * 60);
    final pic = TimeInputField.parseMinutes(_picController.text) ?? 0;
    final picus = TimeInputField.parseMinutes(_picusController.text) ?? 0;
    final sic = TimeInputField.parseMinutes(_sicController.text) ?? 0;
    final dual = TimeInputField.parseMinutes(_dualController.text) ?? 0;
    final instructor =
        TimeInputField.parseMinutes(_instructorController.text) ?? 0;
    final selectedPrimaryRoles = [
      pic,
      picus,
      sic,
      dual,
      instructor,
    ].where((value) => value > 0).length;
    if (selectedPrimaryRoles > 1) {
      final continueSave = await _confirmMultiplePrimaryTimes();
      if (!continueSave) return;
    }
    final consistencyWarnings = <String>[];
    if (pic + picus + sic + dual + instructor != block) {
      consistencyWarnings.add(
        'PIC + PICUS + SIC + Dual + Instructor must equal Block time.',
      );
    }
    final ifr = TimeInputField.parseMinutes(_ifrController.text) ?? 0;
    final instrument =
        TimeInputField.parseMinutes(_instrumentController.text) ?? 0;
    final simInstrument =
        TimeInputField.parseMinutes(_simInstrumentController.text) ?? 0;
    final night = TimeInputField.parseMinutes(_nightController.text) ?? 0;
    final cross = TimeInputField.parseMinutes(_crossController.text) ?? 0;
    final custom1 = TimeInputField.parseMinutes(_custom1Controller.text) ?? 0;
    final custom2 = TimeInputField.parseMinutes(_custom2Controller.text) ?? 0;
    final custom3 = TimeInputField.parseMinutes(_custom3Controller.text) ?? 0;
    final custom4 = TimeInputField.parseMinutes(_custom4Controller.text) ?? 0;
    final flightTime =
        TimeInputField.parseMinutes(_flightController.text) ?? block;
    if (night > block) {
      consistencyWarnings.add('Night time is greater than Block time.');
    }
    if (cross > block) {
      consistencyWarnings.add('Cross-country time is greater than Block time.');
    }
    if (ifr > block) {
      consistencyWarnings.add('IFR time is greater than Block time.');
    }
    final ifrApproaches = _parseCount(_ifrApproachesController.text);
    final distanceNm = _parseCount(_distanceNmController.text);
    final approachType = _approachTypeController.text.trim();

    final crewAssignments = _crewRows
        .where((r) => r.crewId != null && r.position != null)
        .map(
          (r) => SimulatorCrewAssignmentInput(
            crewId: r.crewId!,
            position: r.position!,
          ),
        )
        .toList(growable: false);
    _takeoffsDay = _parseCount(_takeoffDayController.text);
    _takeoffsNight = _parseCount(_takeoffNightController.text);
    _landingsDay = _parseCount(_landingDayController.text);
    _landingsNight = _parseCount(_landingNightController.text);
    if (consistencyWarnings.isNotEmpty) {
      final continueSave = await _confirmRuleWarnings(consistencyWarnings);
      if (!continueSave) return;
    }

    final useCases = ref.read(logbookUseCasesProvider);
    if (widget.isCreate) {
      await useCases.createFlight(
        aircraftId: _aircraftId!,
        departureAirportId: _fromAirportId!,
        arrivalAirportId: _toAirportId!,
        departureDateTime: DbDateTime.wallClockToDbUtc(departure),
        takeOffDateTime: DbDateTime.wallClockToDbUtcOrNull(takeoff),
        landingDateTime: DbDateTime.wallClockToDbUtcOrNull(landing),
        arrivalDateTime: DbDateTime.wallClockToDbUtcOrNull(arrival),
        pilotFunction: _pilotFunction,
        ifrApproaches: ifrApproaches,
        approachType: approachType,
        takeOffsDays: _takeoffsDay,
        takeOffsNight: _takeoffsNight,
        landingsDay: _landingsDay,
        landingsNight: _landingsNight,
        timeBlockMinutes: block,
        timeTotalBlockMinutes: totalBlock,
        timeFlightMinutes: flightTime,
        timePICMinutes: pic,
        timePICUSMinutes: picus,
        timeSICMinutes: sic,
        timeDualMinutes: dual,
        timeInstructorMinutes: instructor,
        timeIFRMinutes: ifr,
        timeInstrumentMinutes: instrument,
        timeSimulatedInstrumentMinutes: simInstrument,
        timeNightMinutes: night,
        timeCrossCountryMinutes: cross,
        timeCustom1Minutes: custom1,
        timeCustom2Minutes: custom2,
        timeCustom3Minutes: custom3,
        timeCustom4Minutes: custom4,
        distanceNM: distanceNm,
        remarks: _remarksController.text.trim(),
        notes: _notesController.text.trim(),
        crewAssignments: crewAssignments,
      );
    } else {
      final flight = _flight;
      if (flight == null) return;
      await useCases.updateFlight(
        flight: flight,
        aircraftId: _aircraftId!,
        departureAirportId: _fromAirportId!,
        arrivalAirportId: _toAirportId!,
        departureDateTime: DbDateTime.wallClockToDbUtc(departure),
        takeOffDateTime: DbDateTime.wallClockToDbUtcOrNull(takeoff),
        landingDateTime: DbDateTime.wallClockToDbUtcOrNull(landing),
        arrivalDateTime: DbDateTime.wallClockToDbUtcOrNull(arrival),
        pilotFunction: _pilotFunction,
        ifrApproaches: ifrApproaches,
        approachType: approachType,
        takeOffsDays: _takeoffsDay,
        takeOffsNight: _takeoffsNight,
        landingsDay: _landingsDay,
        landingsNight: _landingsNight,
        timeBlockMinutes: block,
        timeTotalBlockMinutes: totalBlock,
        timeFlightMinutes: flightTime,
        timePICMinutes: pic,
        timePICUSMinutes: picus,
        timeSICMinutes: sic,
        timeDualMinutes: dual,
        timeInstructorMinutes: instructor,
        timeIFRMinutes: ifr,
        timeInstrumentMinutes: instrument,
        timeSimulatedInstrumentMinutes: simInstrument,
        timeNightMinutes: night,
        timeCrossCountryMinutes: cross,
        timeCustom1Minutes: custom1,
        timeCustom2Minutes: custom2,
        timeCustom3Minutes: custom3,
        timeCustom4Minutes: custom4,
        distanceNM: distanceNm,
        remarks: _remarksController.text.trim(),
        notes: _notesController.text.trim(),
        crewAssignments: crewAssignments,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<bool> _confirmMultiplePrimaryTimes() async {
    final decision = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check Time Entries'),
        content: const Text(
          'More than one of PIC, PICUS, SIC, Dual, Instructor has time greater than 0. Continue saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Review'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save anyway'),
          ),
        ],
      ),
    );
    return decision ?? false;
  }

  Future<bool> _confirmRuleWarnings(List<String> warnings) async {
    final decision = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check Factoring Rules'),
        content: Text('${warnings.join('\n')}\n\nContinue saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Review'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save anyway'),
          ),
        ],
      ),
    );
    return decision ?? false;
  }

  DateTime? _resolveChocksOnDateTime() {
    if (_chocksOn == null) return null;
    return _resolveDateTimeFromTime(
      _chocksOffMinute,
      _chocksOn!,
      allowNextDay: true,
    );
  }

  DateTime? _resolveTakeOffDateTime() {
    if (_takeOff == null) return null;
    return _resolveDateTimeFromTime(
      _chocksOffMinute,
      _takeOff!,
      allowNextDay: true,
    );
  }

  DateTime? _resolveLandingDateTime() {
    if (_landing == null) return null;
    final base = _resolveTakeOffDateTime() ?? _chocksOff;
    return _resolveDateTimeFromTime(base, _landing!, allowNextDay: true);
  }

  DateTime _resolveDateTimeFromTime(
    DateTime base,
    TimeOfDay time, {
    required bool allowNextDay,
  }) {
    final baseMinute = DateTime(
      base.year,
      base.month,
      base.day,
      base.hour,
      base.minute,
    );
    final sameDay = DateTime(
      base.year,
      base.month,
      base.day,
      time.hour,
      time.minute,
    );
    if (!allowNextDay) return sameDay;
    if (sameDay.isBefore(baseMinute)) {
      return sameDay.add(const Duration(days: 1));
    }
    return sameDay;
  }

  int _applyPilotFunctionFactoring({
    required int totalBlockMinutes,
    required String pilotFunction,
    required int irp3Percent,
    required int irp3SubtractMinutes,
    required int irp4Percent,
    required int irp4SubtractMinutes,
  }) {
    final normalized = pilotFunction.trim().toUpperCase();
    if (normalized != 'IRP 3' && normalized != 'IRP 4') {
      return totalBlockMinutes;
    }
    final percent = normalized == 'IRP 3' ? irp3Percent : irp4Percent;
    final subtract = normalized == 'IRP 3'
        ? irp3SubtractMinutes
        : irp4SubtractMinutes;
    var base = totalBlockMinutes - subtract;
    if (base < 0) base = 0;
    final clampedPercent = percent.clamp(0, 100);
    return ((base * clampedPercent) / 100).round();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearKeyboardFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (mounted) {
      FocusScope.of(context).requestFocus(_formFocusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canGoNext = _canGoNext;
    final canCalculate = _canCalculate;
    final customTimeLabels =
        ref.watch(customTimeLabelsProvider).valueOrNull ??
        const CustomTimeLabels();
    final timeFieldVisibility =
        ref.watch(flightTimeFieldsVisibilityProvider).valueOrNull ??
        const FlightTimeFieldsVisibility();
    final aircraftAsync = ref.watch(aircraftProvider(''));
    final airportsAsync = ref.watch(
      airportsProvider(
        const AirportSearchParams(
          query: '',
          filters: AirportFilters(showOnlyVisited: false),
        ),
      ),
    );
    final crewAsync = ref.watch(crewProvider(''));
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        leading: _page > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _page -= 1),
              )
            : null,
        title: Text(widget.isCreate ? 'New Flight' : 'Edit Flight'),
        actions: [
          if (_page == 0) ...[
            TextButton(
              onPressed: canCalculate ? _calculateAndNext : null,
              child: const Text('Calculate'),
            ),
            TextButton(
              onPressed: canGoNext ? _next : null,
              child: const Text('Next'),
            ),
          ] else ...[
            if (_page == 1) ...[
              TextButton(
                onPressed: canCalculate ? _calculateInPlace : null,
                child: const Text('Calculate'),
              ),
              TextButton(
                onPressed: _isFirstPageReady
                    ? () => setState(() => _page = 2)
                    : null,
                child: const Text('Next'),
              ),
            ] else
              TextButton(onPressed: _save, child: Text(l10n.saveAction)),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Focus(
            focusNode: _formFocusNode,
            child: Column(
              children: [
                if (_page == 0)
                  _buildPage1(aircraftAsync, airportsAsync, crewAsync, l10n)
                else if (_page == 1)
                  _buildPage2(l10n, customTimeLabels, timeFieldVisibility),
                if (_page == 2) _buildPage3(crewAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1(
    AsyncValue<List<AircraftRow>> aircraftAsync,
    AsyncValue<List<AirportRow>> airportsAsync,
    AsyncValue<List<CrewRow>> crewAsync,
    AppLocalizations l10n,
  ) {
    final locale = Localizations.localeOf(context).toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Date'),
          subtitle: Text(DateFormat('dd/MMM yyyy', locale).format(_chocksOff)),
          trailing: const Icon(Icons.calendar_today),
          onTap: _pickFlightDate,
        ),
        if (_logTakeoffLanding) ...[
          Row(
            children: [
              Expanded(
                child: TimeInputField(
                  controller: _chocksOffTimeController,
                  label: 'Chocks OFF',
                  maxHours: 23,
                  onChangedMinutes: _onChocksOffTimeChanged,
                  onCleared: () => setState(
                    () => _chocksOff = DateTime(
                      _chocksOff.year,
                      _chocksOff.month,
                      _chocksOff.day,
                    ),
                  ),
                  allowEmpty: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TimeInputField(
                  controller: _takeOffTimeController,
                  label: 'TakeOff',
                  maxHours: 23,
                  onChangedMinutes: _onTakeoffTimeChanged,
                  onCleared: () => setState(() => _takeOff = null),
                  allowEmpty: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TimeInputField(
                  controller: _landingTimeController,
                  label: 'Landing',
                  maxHours: 23,
                  onChangedMinutes: _onLandingTimeChanged,
                  onCleared: () => setState(() => _landing = null),
                  allowEmpty: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TimeInputField(
                  controller: _chocksOnTimeController,
                  label: 'Chocks ON',
                  maxHours: 23,
                  onChangedMinutes: _onChocksOnTimeChanged,
                  onCleared: () => setState(() => _chocksOn = null),
                  allowEmpty: true,
                ),
              ),
            ],
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: TimeInputField(
                  controller: _chocksOffTimeController,
                  label: 'Chocks OFF',
                  maxHours: 23,
                  onChangedMinutes: _onChocksOffTimeChanged,
                  onCleared: () => setState(
                    () => _chocksOff = DateTime(
                      _chocksOff.year,
                      _chocksOff.month,
                      _chocksOff.day,
                    ),
                  ),
                  allowEmpty: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TimeInputField(
                  controller: _chocksOnTimeController,
                  label: 'Chocks ON',
                  maxHours: 23,
                  onChangedMinutes: _onChocksOnTimeChanged,
                  onCleared: () => setState(() => _chocksOn = null),
                  allowEmpty: true,
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _pilotFunction,
          decoration: const InputDecoration(labelText: 'Pilot Function'),
          items: const [
            DropdownMenuItem(value: 'PF', child: Text('PF')),
            DropdownMenuItem(value: 'PNF', child: Text('PNF')),
            DropdownMenuItem(value: 'PF/PNF', child: Text('PF/PNF')),
            DropdownMenuItem(value: 'PNF/PF', child: Text('PNF/PF')),
            DropdownMenuItem(value: 'IRP 3', child: Text('IRP 3')),
            DropdownMenuItem(value: 'IRP 4', child: Text('IRP 4')),
          ],
          onChanged: (value) => setState(() => _pilotFunction = value ?? 'PF'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Aircraft'),
                subtitle: Text(_aircraftLabel(aircraftAsync)),
                trailing: const Icon(Icons.search),
                onTap: _pickAircraft,
              ),
            ),
            IconButton(
              onPressed: _createAircraftAndSelect,
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
                title: const Text('From Airport'),
                subtitle: Text(_airportLabel(_fromAirportId, airportsAsync)),
                trailing: const Icon(Icons.search),
                onTap: () => _pickAirport(isFrom: true),
              ),
            ),
            IconButton(
              onPressed: () => _createAirport(isFrom: true),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('To Airport'),
                subtitle: Text(_airportLabel(_toAirportId, airportsAsync)),
                trailing: const Icon(Icons.search),
                onTap: () => _pickAirport(isFrom: false),
              ),
            ),
            IconButton(
              onPressed: () => _createAirport(isFrom: false),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPage2(
    AppLocalizations l10n,
    CustomTimeLabels customTimeLabels,
    FlightTimeFieldsVisibility visibility,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _takeoffDayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Takeoff Day',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _takeoffNightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Takeoff Night',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _landingDayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Landing Day',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _landingNightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Landing Night',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ifrApproachesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'IFR Approaches',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _approachTypeController,
                decoration: const InputDecoration(
                  labelText: 'Approach Type',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        TimeInputField(controller: _blockController, label: 'Total Block'),
        const SizedBox(height: 8),
        if (_logTakeoffLanding)
          _timeCheckPair(
            leftLabel: 'Flight',
            leftController: _flightController,
            leftChecked: _checks.flight,
            leftEnabled: _takeOff != null && _landing != null,
            leftOnChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(flight: v),
              v,
              _flightController,
              checkedMinutes: _lastCalculatedFlightMinutes,
            ),
            rightLabel: 'Distance NM',
            right: TextFormField(
              controller: _distanceNmController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Distance NM',
                border: OutlineInputBorder(),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextFormField(
              controller: _distanceNmController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Distance NM',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        const SizedBox(height: 8),
        _buildTimeFieldsGrid([
          _TimeFieldConfig(
            label: 'PIC',
            controller: _picController,
            checked: _checks.pic,
            visible: _shouldShowTimeField(_picController, visibility.pic),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(pic: v),
              v,
              _picController,
            ),
          ),
          _TimeFieldConfig(
            label: 'PICUS',
            controller: _picusController,
            checked: _checks.picus,
            visible: _shouldShowTimeField(_picusController, visibility.picus),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(picus: v),
              v,
              _picusController,
            ),
          ),
          _TimeFieldConfig(
            label: 'SIC',
            controller: _sicController,
            checked: _checks.sic,
            visible: _shouldShowTimeField(_sicController, visibility.sic),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(sic: v),
              v,
              _sicController,
            ),
          ),
          _TimeFieldConfig(
            label: 'Dual',
            controller: _dualController,
            checked: _checks.dual,
            visible: _shouldShowTimeField(_dualController, visibility.dual),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(dual: v),
              v,
              _dualController,
            ),
          ),
          _TimeFieldConfig(
            label: 'Instructor',
            controller: _instructorController,
            checked: _checks.instructor,
            visible: _shouldShowTimeField(
              _instructorController,
              visibility.instructor,
            ),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(instructor: v),
              v,
              _instructorController,
            ),
          ),
          _TimeFieldConfig(
            label: 'IFR',
            controller: _ifrController,
            checked: _checks.ifr,
            visible: _shouldShowTimeField(_ifrController, visibility.ifr),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(ifr: v),
              v,
              _ifrController,
            ),
          ),
          _TimeFieldConfig(
            label: 'Instrument',
            controller: _instrumentController,
            checked: _checks.instrument,
            visible: _shouldShowTimeField(
              _instrumentController,
              visibility.instrument,
            ),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(instrument: v),
              v,
              _instrumentController,
            ),
          ),
          _TimeFieldConfig(
            label: 'Sim Instrument',
            controller: _simInstrumentController,
            checked: _checks.simInstrument,
            visible: _shouldShowTimeField(
              _simInstrumentController,
              visibility.simInstrument,
            ),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(simInstrument: v),
              v,
              _simInstrumentController,
            ),
          ),
          _TimeFieldConfig(
            label: 'Night',
            controller: _nightController,
            checked: _checks.night,
            visible: _shouldShowTimeField(_nightController, visibility.night),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(night: v),
              v,
              _nightController,
              checkedMinutes: _lastCalculatedNightMinutes,
            ),
          ),
          _TimeFieldConfig(
            label: 'CrossCountry',
            controller: _crossController,
            checked: _checks.crossCountry,
            visible: _shouldShowTimeField(
              _crossController,
              visibility.crossCountry,
            ),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(crossCountry: v),
              v,
              _crossController,
            ),
          ),
          _TimeFieldConfig(
            label: customTimeLabels.custom1,
            controller: _custom1Controller,
            checked: _checks.custom1,
            visible: _shouldShowTimeField(
              _custom1Controller,
              visibility.custom1,
            ),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(custom1: v),
              v,
              _custom1Controller,
            ),
          ),
          _TimeFieldConfig(
            label: customTimeLabels.custom2,
            controller: _custom2Controller,
            checked: _checks.custom2,
            visible: _shouldShowTimeField(
              _custom2Controller,
              visibility.custom2,
            ),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(custom2: v),
              v,
              _custom2Controller,
            ),
          ),
          _TimeFieldConfig(
            label: customTimeLabels.custom3,
            controller: _custom3Controller,
            checked: _checks.custom3,
            visible: _shouldShowTimeField(
              _custom3Controller,
              visibility.custom3,
            ),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(custom3: v),
              v,
              _custom3Controller,
            ),
          ),
          _TimeFieldConfig(
            label: customTimeLabels.custom4,
            controller: _custom4Controller,
            checked: _checks.custom4,
            visible: _shouldShowTimeField(
              _custom4Controller,
              visibility.custom4,
            ),
            onChanged: (v) => _updateChecksAndMaybeCopy(
              _checks.copyWith(custom4: v),
              v,
              _custom4Controller,
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildPage3(AsyncValue<List<CrewRow>> crewAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCrewList(crewAsync),
        const SizedBox(height: 8),
        TextFormField(
          controller: _remarksController,
          maxLines: 1,
          decoration: const InputDecoration(
            labelText: 'Remarks',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _timeCheckPair({
    required String leftLabel,
    required TextEditingController leftController,
    required bool leftChecked,
    required ValueChanged<bool> leftOnChanged,
    bool leftVisible = true,
    bool leftEnabled = true,
    String? rightLabel,
    TextEditingController? rightController,
    bool? rightChecked,
    ValueChanged<bool>? rightOnChanged,
    bool rightVisible = true,
    bool rightEnabled = true,
    Widget? right,
  }) {
    if (!leftVisible && !rightVisible) {
      return const SizedBox.shrink();
    }
    if (leftVisible && !rightVisible) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _timeCheckInput(
          label: leftLabel,
          controller: leftController,
          checked: leftChecked,
          onChanged: leftOnChanged,
          enabled: leftEnabled,
        ),
      );
    }
    if (!leftVisible && rightVisible) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child:
            right ??
            _timeCheckInput(
              label: rightLabel!,
              controller: rightController!,
              checked: rightChecked!,
              onChanged: rightOnChanged!,
              enabled: rightEnabled,
            ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: _timeCheckInput(
              label: leftLabel,
              controller: leftController,
              checked: leftChecked,
              onChanged: leftOnChanged,
              enabled: leftEnabled,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child:
                right ??
                _timeCheckInput(
                  label: rightLabel!,
                  controller: rightController!,
                  checked: rightChecked!,
                  onChanged: rightOnChanged!,
                  enabled: rightEnabled,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFieldsGrid(List<_TimeFieldConfig> fields) {
    final visible = fields.where((f) => f.visible).toList(growable: false);
    if (visible.isEmpty) return const SizedBox.shrink();
    final rows = <Widget>[];
    for (var i = 0; i < visible.length; i += 2) {
      final left = visible[i];
      final right = i + 1 < visible.length ? visible[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: _timeCheckInput(
                  label: left.label,
                  controller: left.controller,
                  checked: left.checked,
                  onChanged: left.onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: right == null
                    ? const SizedBox.shrink()
                    : _timeCheckInput(
                        label: right.label,
                        controller: right.controller,
                        checked: right.checked,
                        onChanged: right.onChanged,
                      ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  bool _shouldShowTimeField(TextEditingController controller, bool enabled) {
    if (enabled) return true;
    final minutes = TimeInputField.parseMinutes(controller.text) ?? 0;
    return minutes > 0;
  }

  Widget _timeCheckInput({
    required String label,
    required TextEditingController controller,
    required bool checked,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return TimeInputField(
      controller: controller,
      label: label,
      forceTextField: true,
      suffixIcon: Checkbox(
        value: checked,
        onChanged: enabled ? (v) => onChanged(v ?? false) : null,
      ),
    );
  }

  Future<void> _updateChecksAndMaybeCopy(
    FlightFormTimeChecks nextChecks,
    bool checked,
    TextEditingController target, {
    int? checkedMinutes,
  }) async {
    _checks = nextChecks;
    await ref.read(flightFormTimeChecksProvider.notifier).setValue(_checks);
    if (checked) {
      final minutes =
          checkedMinutes ??
          (TimeInputField.parseMinutes(_blockController.text) ?? 0);
      target.text = TimeInputField.formatMinutes(minutes);
    }
    if (!mounted) return;
    setState(() {});
  }

  int _parseCount(String raw) {
    final value = int.tryParse(raw.trim()) ?? 0;
    if (value < 0) return 0;
    return value;
  }

  int _wallClockAsUtcEpochSeconds(DateTime dt) {
    return DateTime.utc(
          dt.year,
          dt.month,
          dt.day,
          dt.hour,
          dt.minute,
          dt.second,
          dt.millisecond,
          dt.microsecond,
        ).millisecondsSinceEpoch ~/
        1000;
  }

  bool get _isFirstPageReady {
    if (_aircraftId == null || _fromAirportId == null || _toAirportId == null) {
      return false;
    }
    return true;
  }

  bool get _canGoNext => _isFirstPageReady;

  bool get _canCalculate => _canGoNext && _chocksOn != null;

  Widget _buildCrewList(AsyncValue<List<CrewRow>> crewAsync) {
    final crewItems = crewAsync.valueOrNull ?? const <CrewRow>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Crew',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final draft = await _showAddCrewDialog(crewItems);
                if (draft == null || !mounted) return;
                final duplicate = _crewRows.any(
                  (row) => row.crewId == draft.crewId,
                );
                if (duplicate) return;
                setState(() => _crewRows.add(draft));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Crew'),
            ),
          ],
        ),
        SizedBox(
          height: 170,
          child: Card(
            margin: EdgeInsets.zero,
            child: _crewRows.isEmpty
                ? const Center(child: Text('No crew assigned'))
                : Scrollbar(
                    controller: _crewListController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: _crewListController,
                      primary: false,
                      itemCount: _crewRows.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final row = _crewRows[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _crewLabel(row.crewId, crewItems),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  _positionLabel(row.position!),
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                visualDensity: VisualDensity.compact,
                                onPressed: () =>
                                    setState(() => _crewRows.removeAt(index)),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<_CrewDraftRow?> _showAddCrewDialog(List<CrewRow> crewItems) async {
    int? selectedCrewId = crewItems.isNotEmpty ? crewItems.first.id : null;
    CrewPosition selectedPosition = CrewPosition.other;
    return showDialog<_CrewDraftRow>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Add Crew'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Crew'),
                        subtitle: Text(_crewLabel(selectedCrewId, crewItems)),
                        trailing: const Icon(Icons.search),
                        onTap: () async {
                          final selected = await CrewPickerDialog.show(
                            dialogContext,
                            title: 'Select crew',
                          );
                          if (selected == null) return;
                          setLocalState(() => selectedCrewId = selected.id);
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: 'Create crew',
                      onPressed: () async {
                        final createdId = await _createCrewAndReturnId();
                        if (createdId == null) return;
                        setLocalState(() => selectedCrewId = createdId);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CrewPosition>(
                  initialValue: selectedPosition,
                  isExpanded: true,
                  items: _positionOptions
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(_positionLabel(p)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setLocalState(() => selectedPosition = value);
                  },
                  decoration: const InputDecoration(labelText: 'Position'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedCrewId == null
                  ? null
                  : () => Navigator.of(dialogContext).pop(
                      _CrewDraftRow(
                        crewId: selectedCrewId,
                        position: selectedPosition,
                      ),
                    ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _createCrewAndReturnId() async {
    final screenContext = context;
    final placeholder = CrewData(
      id: kPlaceholderId,
      name: '',
      email: null,
      notes: null,
      phone: null,
      picture: null,
      isSelf: false,
      isFavorite: false,
      isLocked: false,
    );
    final result = await _showStandardFormDialog<dynamic>(
      screenContext,
      CrewEditScreen(item: placeholder, isCreate: true),
    );
    if (!mounted || result != true) return null;
    final db = ref.read(databaseProvider);
    final created =
        await (db.select(db.crew)
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingleOrNull();
    if (!mounted || created == null) return null;
    _crewLabelCache[created.id] = created.name;
    return created.id;
  }

  TimeOfDay? _toTimeOfDayFromDb(DateTime? d) {
    if (d == null) return null;
    final local = DbDateTime.dbToUtc(d);
    return TimeOfDay(hour: local.hour, minute: local.minute);
  }

  Future<T?> _showStandardFormDialog<T>(BuildContext context, Widget child) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    return showDialog<T>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
          child: SizedBox(width: 520, child: child),
        ),
      ),
    );
  }

  String _aircraftLabel(AsyncValue<List<AircraftRow>> aircraftAsync) {
    if (_aircraftId == null) return 'Not selected';
    final rows = aircraftAsync.valueOrNull;
    if (rows == null) return 'ID: $_aircraftId';
    for (final row in rows) {
      if (row.id == _aircraftId) {
        final type = row.type?.code ?? row.type?.longName ?? '-';
        return '${row.registration} • $type';
      }
    }
    return 'ID: $_aircraftId';
  }

  String _airportLabel(int? id, AsyncValue<List<AirportRow>> airportsAsync) {
    if (id == null) return 'Not selected';
    final cached = _airportLabelCache[id];
    if (cached != null) return cached;
    final rows = airportsAsync.valueOrNull;
    if (rows == null) return 'ID: $id';
    for (final row in rows) {
      if (row.id == id) {
        final airport = row.airport;
        final name = (airport.name ?? '').trim();
        return name.isEmpty ? airport.icao : '${airport.icao} - $name';
      }
    }
    return 'ID: $id';
  }

  String _crewLabel(int? crewId, List<CrewRow> crewItems) {
    if (crewId == null) return 'Select crew';
    final cached = _crewLabelCache[crewId];
    if (cached != null) return cached;
    for (final row in crewItems) {
      if (row.id == crewId) return row.name;
    }
    return 'Crew #$crewId';
  }

  String _positionLabel(CrewPosition value) {
    switch (value) {
      case CrewPosition.pic:
        return 'PIC';
      case CrewPosition.sic:
        return 'SIC';
      case CrewPosition.instructor:
        return 'Instructor';
      case CrewPosition.observer:
        return 'Observer';
      case CrewPosition.relief:
        return 'Relief';
      case CrewPosition.reliefCaptain:
        return 'Relief Captain';
      case CrewPosition.reliefFirstOfficer:
        return 'Relief First Officer';
      case CrewPosition.cabinSenior:
        return 'Cabin Senior';
      case CrewPosition.cabinCrew:
        return 'Cabin Crew';
      case CrewPosition.other:
        return 'Other';
      case CrewPosition.unknown:
        return 'Unknown';
    }
  }

  static const List<CrewPosition> _positionOptions = [
    CrewPosition.pic,
    CrewPosition.sic,
    CrewPosition.instructor,
    CrewPosition.observer,
    CrewPosition.relief,
    CrewPosition.reliefCaptain,
    CrewPosition.reliefFirstOfficer,
    CrewPosition.cabinSenior,
    CrewPosition.cabinCrew,
    CrewPosition.other,
  ];

  String _pilotFunctionFromCounts(int takeoffs, int landings) {
    if (takeoffs > 0 && landings > 0) return 'PF';
    if (takeoffs == 0 && landings == 0) return 'PNF';
    if (takeoffs > 0 && landings == 0) return 'PF/PNF';
    if (takeoffs == 0 && landings > 0) return 'PNF/PF';
    return 'PNF';
  }

  bool _isPilotFunctionValue(String value) {
    final v = value.trim().toUpperCase();
    return v == 'PF' ||
        v == 'PNF' ||
        v == 'PF/PNF' ||
        v == 'PNF/PF' ||
        v == 'IRP 3' ||
        v == 'IRP 4';
  }

  String _normalizePilotFunction(
    String value, {
    required int fallbackTakeoffs,
    required int fallbackLandings,
  }) {
    final v = value.trim().toUpperCase();
    if (_isPilotFunctionValue(v)) return v;
    return _pilotFunctionFromCounts(fallbackTakeoffs, fallbackLandings);
  }
}

class _CrewDraftRow {
  _CrewDraftRow({this.crewId, this.position});

  int? crewId;
  CrewPosition? position;
}

class FlightPrefill {
  const FlightPrefill({
    this.aircraftId,
    this.fromAirportId,
    this.toAirportId,
    this.chocksOff,
    this.crewAssignments = const <SimulatorCrewAssignmentInput>[],
  });

  final int? aircraftId;
  final int? fromAirportId;
  final int? toAirportId;
  final DateTime? chocksOff;
  final List<SimulatorCrewAssignmentInput> crewAssignments;
}

class _TimeFieldConfig {
  const _TimeFieldConfig({
    required this.label,
    required this.controller,
    required this.checked,
    required this.onChanged,
    this.visible = true,
  });

  final String label;
  final TextEditingController controller;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final bool visible;
}

class _FlightCalcResult {
  const _FlightCalcResult({
    required this.totalBlockMinutes,
    required this.totalMinutes,
    required this.nightMinutes,
    required this.flightMinutes,
    required this.distanceNm,
    required this.takeoffsDay,
    required this.takeoffsNight,
    required this.landingsDay,
    required this.landingsNight,
  });

  final int totalBlockMinutes;
  final int totalMinutes;
  final int nightMinutes;
  final int flightMinutes;
  final int distanceNm;
  final int takeoffsDay;
  final int takeoffsNight;
  final int landingsDay;
  final int landingsNight;
}
