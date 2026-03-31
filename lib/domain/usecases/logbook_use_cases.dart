import 'dart:typed_data';

import 'package:simplelog/core/date/db_date_time.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_info_item.dart';
import 'package:simplelog/data/models/duty_edit_data.dart';
import 'package:simplelog/data/models/flight_edit_data.dart';
import 'package:simplelog/data/models/flight_write_input.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/models/logbook_flight_summary.dart';
import 'package:simplelog/data/models/positioning_edit_data.dart';
import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';
import 'package:simplelog/data/models/simulator_edit_data.dart';
import 'package:simplelog/domain/repositories/logbook_repository_contract.dart';
import 'package:simplelog/domain/validation/flight_write_validator.dart';
import 'package:simplelog/domain/validation/validation_issue.dart';

/// Application-layer facade that orchestrates logbook operations.
///
/// It validates write inputs and delegates persistence/query work to
/// [LogbookRepositoryContract].
class LogbookUseCases {
  /// Creates use cases wired to [_repository].
  ///
  /// [flightWriteValidator] can be overridden in tests.
  LogbookUseCases(
    this._repository, {
    FlightWriteValidator flightWriteValidator = const FlightWriteValidator(),
  }) : _flightWriteValidator = flightWriteValidator;

  final LogbookRepositoryContract _repository;

  /// Validator used before creating/updating flights.
  final FlightWriteValidator _flightWriteValidator;

  /// Watches logbook entries that match [filters].
  Stream<List<LogbookEntry>> watchLogbook(LogbookFilters filters) {
    return _repository.watchLogbook(filters);
  }

  /// Fetches one paginated logbook slice for [filters].
  Future<List<LogbookEntry>> fetchLogbookPage(
    LogbookFilters filters, {
    required int limit,
    required int offset,
    Set<int>? includedFlightIds,
  }) {
    return _repository.fetchLogbookPage(
      filters,
      limit: limit,
      offset: offset,
      includedFlightIds: includedFlightIds,
    );
  }

  /// Returns earliest timeline date among stored entries, if any.
  Future<DateTime?> fetchFirstEventDate() => _repository.fetchFirstEventDate();

  /// Returns the entry attached to [timeLineId], or `null` if missing.
  Future<LogbookEntry?> fetchEntryByTimelineId(int timeLineId) =>
      _repository.fetchEntryByTimelineId(timeLineId);

  /// Finds a flight by primary key.
  Future<Flight?> findFlightById(int flightId) =>
      _repository.findFlightById(flightId);

  /// Loads all data required to edit a flight.
  Future<FlightEditData?> loadFlightEditData(int flightId) =>
      _repository.loadFlightEditData(flightId);

  /// Returns flight crew assignments for [flightId].
  Future<List<FlightCrewAssignment>> fetchFlightCrewAssignments(int flightId) =>
      _repository.fetchFlightCrewAssignments(flightId);

  /// Toggles lock state for the provided logbook [entry].
  Future<void> toggleEntryLock(LogbookEntry entry) =>
      _repository.toggleEntryLock(entry);

  /// Toggles lock state for a duty period by id.
  Future<void> toggleDutyLock(int dutyId) => _repository.toggleDutyLock(dutyId);

  /// Finds a duty period by id.
  Future<DutyPeriod?> findDutyById(int dutyId) =>
      _repository.findDutyById(dutyId);

  /// Loads all data required to edit a duty period.
  Future<DutyEditData?> loadDutyEditData(int dutyId) =>
      _repository.loadDutyEditData(dutyId);

  /// Finds a positioning entry by id.
  Future<Positioning?> findPositioningById(int positioningId) =>
      _repository.findPositioningById(positioningId);

  /// Loads all data required to edit a positioning entry.
  Future<PositioningEditData?> loadPositioningEditData(int positioningId) =>
      _repository.loadPositioningEditData(positioningId);

  /// Finds a simulator session by id.
  Future<SimulatorTraining?> findSimulatorTrainingById(int simulatorId) =>
      _repository.findSimulatorTrainingById(simulatorId);

  /// Loads all data required to edit a simulator session.
  Future<SimulatorEditData?> loadSimulatorEditData(int simulatorId) =>
      _repository.loadSimulatorEditData(simulatorId);

  /// Returns simulator crew assignments for [simulatorId].
  Future<List<SimulatorCrewAssignment>> fetchSimulatorCrewAssignments(
    int simulatorId,
  ) => _repository.fetchSimulatorCrewAssignments(simulatorId);

  /// Creates a duty period using UTC [start]/[end] and computed minutes.
  Future<void> createDuty({
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  }) {
    return _repository.createDuty(
      start: start,
      end: end,
      dutyMinutes: dutyMinutes,
      factoredMinutes: factoredMinutes,
    );
  }

  /// Updates an existing [duty] period with new timing values.
  Future<void> updateDuty({
    required DutyPeriod duty,
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  }) {
    return _repository.updateDuty(
      duty: duty,
      start: start,
      end: end,
      dutyMinutes: dutyMinutes,
      factoredMinutes: factoredMinutes,
    );
  }

  /// Creates a positioning leg.
  Future<void> createPositioning({
    required int departureAirportId,
    required int arrivalAirportId,
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int totalMinutes,
    required String notes,
  }) {
    return _repository.createPositioning(
      departureAirportId: departureAirportId,
      arrivalAirportId: arrivalAirportId,
      departureDateTime: departureDateTime,
      arrivalDateTime: arrivalDateTime,
      totalMinutes: totalMinutes,
      notes: notes,
    );
  }

  /// Updates an existing [positioning] leg.
  Future<void> updatePositioning({
    required Positioning positioning,
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int departureAirportId,
    required int arrivalAirportId,
    required int totalMinutes,
    required String notes,
  }) {
    return _repository.updatePositioning(
      positioning: positioning,
      departureDateTime: departureDateTime,
      arrivalDateTime: arrivalDateTime,
      departureAirportId: departureAirportId,
      arrivalAirportId: arrivalAirportId,
      totalMinutes: totalMinutes,
      notes: notes,
    );
  }

  /// Validates [input] without writing data.
  ValidationReport validateFlightWrite(FlightWriteInput input) {
    return _flightWriteValidator.validate(input);
  }

  /// Creates a flight if [input] passes validation.
  ///
  /// Returns validation warnings and errors in [WriteResult].
  Future<WriteResult<void>> createFlight({
    required FlightWriteInput input,
  }) async {
    final validation = _flightWriteValidator.validate(input);
    if (validation.hasErrors) {
      return WriteResult.failure(errors: validation.errors);
    }
    await _repository.createFlight(input: input);
    return WriteResult.success(warnings: validation.warnings);
  }

  /// Updates [flight] if [input] passes validation.
  ///
  /// Returns validation warnings and errors in [WriteResult].
  Future<WriteResult<void>> updateFlight({
    required Flight flight,
    required FlightWriteInput input,
  }) async {
    final validation = _flightWriteValidator.validate(input);
    if (validation.hasErrors) {
      return WriteResult.failure(errors: validation.errors);
    }
    await _repository.updateFlight(flight: flight, input: input);
    return WriteResult.success(warnings: validation.warnings);
  }

  /// Creates a simulator training record and optional endorsement payload.
  Future<void> createSimulatorTraining({
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
    String? endorsementData,
    Uint8List? endorsementSignatureImage,
  }) {
    return _repository.createSimulatorTraining(
      aircraftId: aircraftId,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      totalMinutes: totalMinutes,
      remarks: remarks,
      notes: notes,
      crewAssignments: crewAssignments,
      endorsementData: endorsementData,
      endorsementSignatureImage: endorsementSignatureImage,
    );
  }

  /// Updates [simulatorTraining] and related crew/endorsement data.
  Future<void> updateSimulatorTraining({
    required SimulatorTraining simulatorTraining,
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
    String? endorsementData,
    Uint8List? endorsementSignatureImage,
  }) {
    return _repository.updateSimulatorTraining(
      simulatorTraining: simulatorTraining,
      aircraftId: aircraftId,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      totalMinutes: totalMinutes,
      remarks: remarks,
      notes: notes,
      crewAssignments: crewAssignments,
      endorsementData: endorsementData,
      endorsementSignatureImage: endorsementSignatureImage,
    );
  }

  /// Verifies stored endorsement hash integrity for flight [flightId].
  Future<bool> verifyFlightEndorsementHash(int flightId) =>
      _repository.verifyFlightEndorsementHash(flightId);

  /// Verifies stored endorsement hash integrity for simulator [simulatorId].
  Future<bool> verifySimulatorEndorsementHash(int simulatorId) =>
      _repository.verifySimulatorEndorsementHash(simulatorId);

  /// Returns formatted crew labels for one flight.
  Future<List<String>> fetchFlightCrewLabels(int flightId) =>
      _repository.fetchFlightCrewLabels(flightId);

  /// Returns detailed crew rows for one flight.
  Future<List<CrewInfoItem>> fetchFlightCrewInfo(int flightId) =>
      _repository.fetchFlightCrewInfo(flightId);

  /// Returns formatted crew labels for one simulator session.
  Future<List<String>> fetchSimulatorCrewLabels(int simulatorId) =>
      _repository.fetchSimulatorCrewLabels(simulatorId);

  /// Returns detailed crew rows for one simulator session.
  Future<List<CrewInfoItem>> fetchSimulatorCrewInfo(int simulatorId) =>
      _repository.fetchSimulatorCrewInfo(simulatorId);

  /// Fetches all entries associated with airport [airportId].
  Future<List<LogbookEntry>> fetchEntriesForAirport(int airportId) =>
      _repository.fetchEntriesForAirport(airportId);

  /// Fetches a page of entries associated with airport [airportId].
  Future<List<LogbookEntry>> fetchEntriesForAirportPage(
    int airportId, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForAirportPage(
    airportId,
    limit: limit,
    offset: offset,
  );

  /// Returns aggregated flight totals for airport [airportId].
  Future<LogbookFlightSummary> fetchFlightSummaryForAirport(int airportId) =>
      _repository.fetchFlightSummaryForAirport(airportId);

  /// Fetches all entries associated with aircraft [aircraftId].
  Future<List<LogbookEntry>> fetchEntriesForAircraft(int aircraftId) =>
      _repository.fetchEntriesForAircraft(aircraftId);

  /// Fetches a page of entries associated with aircraft [aircraftId].
  Future<List<LogbookEntry>> fetchEntriesForAircraftPage(
    int aircraftId, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForAircraftPage(
    aircraftId,
    limit: limit,
    offset: offset,
  );

  /// Returns aggregated flight totals for aircraft [aircraftId].
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraft(int aircraftId) =>
      _repository.fetchFlightSummaryForAircraft(aircraftId);

  /// Fetches all entries associated with aircraft type [aircraftTypeId].
  Future<List<LogbookEntry>> fetchEntriesForAircraftType(int aircraftTypeId) =>
      _repository.fetchEntriesForAircraftType(aircraftTypeId);

  /// Fetches a page of entries for aircraft type [aircraftTypeId].
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypePage(
    int aircraftTypeId, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForAircraftTypePage(
    aircraftTypeId,
    limit: limit,
    offset: offset,
  );

  /// Returns aggregated flight totals for aircraft type [aircraftTypeId].
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftType(
    int aircraftTypeId,
  ) => _repository.fetchFlightSummaryForAircraftType(aircraftTypeId);

  /// Fetches a paged entry list for a family represented by [aircraftTypeIds].
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypeFamilyPage(
    List<int> aircraftTypeIds, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForAircraftTypeFamilyPage(
    aircraftTypeIds,
    limit: limit,
    offset: offset,
  );

  /// Returns aggregated totals for a family represented by [aircraftTypeIds].
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftTypeFamily(
    List<int> aircraftTypeIds,
  ) => _repository.fetchFlightSummaryForAircraftTypeFamily(aircraftTypeIds);

  /// Fetches all entries associated with crew member [crewId].
  Future<List<LogbookEntry>> fetchEntriesForCrew(int crewId) =>
      _repository.fetchEntriesForCrew(crewId);

  /// Fetches a paged list of entries associated with crew member [crewId].
  Future<List<LogbookEntry>> fetchEntriesForCrewPage(
    int crewId, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForCrewPage(
    crewId,
    limit: limit,
    offset: offset,
  );

  /// Returns aggregated flight totals for crew member [crewId].
  Future<LogbookFlightSummary> fetchFlightSummaryForCrew(int crewId) =>
      _repository.fetchFlightSummaryForCrew(crewId);

  /// Deletes the concrete record represented by [entry].
  Future<void> deleteEntry(LogbookEntry entry) =>
      _repository.deleteEntry(entry);

  /// Suggests duty start/end for creating a new duty from the latest event.
  ///
  /// The algorithm groups operational events (flight/positioning/simulator)
  /// by [DutyCalculationRules.minimumRestTimeMinutes] and returns the duty
  /// range for the latest contiguous block.
  Future<DutyCalculationSuggestion?> suggestDutyForLatestEvent({
    required DutyCalculationRules rules,
  }) async {
    final events = await _loadOperationalEvents();
    if (events.isEmpty) return null;
    final segments = _buildDutySegments(events: events, rules: rules);
    if (segments.isEmpty) return null;
    final latest = segments.last;
    return _buildDutySuggestion(segment: latest, rules: rules);
  }

  /// Calculates duty periods for filtered operational events and persists the
  /// result.
  ///
  /// For each filtered target event (flight/positioning/simulator), it
  /// computes the contiguous duty segment and then creates or updates one
  /// duty period per unique segment.
  Future<DutyBatchCalculationResult> calculateDutyForFlights({
    required Set<int> flightIds,
    required Set<int> nonFlightTimelineIds,
    required DutyCalculationRules rules,
  }) async {
    final targetCount = flightIds.length + nonFlightTimelineIds.length;
    if (targetCount == 0) {
      return const DutyBatchCalculationResult(
        created: 0,
        updated: 0,
        unchanged: 0,
        skippedLockedDuty: 0,
        skippedMissingTargetEvent: 0,
      );
    }

    final events = await _loadOperationalEvents();
    if (events.isEmpty) {
      return DutyBatchCalculationResult(
        created: 0,
        updated: 0,
        unchanged: 0,
        skippedLockedDuty: 0,
        skippedMissingTargetEvent: targetCount,
      );
    }

    final segments = _buildDutySegments(events: events, rules: rules);
    final segmentByFlightId = <int, _DutySegment>{};
    final segmentByTimelineId = <int, _DutySegment>{};
    for (final segment in segments) {
      for (final event in segment.events) {
        segmentByTimelineId[event.timelineId] = segment;
        final flightId = event.flightId;
        if (flightId != null && flightIds.contains(flightId)) {
          segmentByFlightId[flightId] = segment;
        }
      }
    }

    final uniqueSegments = <String, _DutySegment>{};
    for (final targetId in flightIds) {
      final segment = segmentByFlightId[targetId];
      if (segment != null) {
        uniqueSegments[_segmentKey(segment)] = segment;
      }
    }
    for (final targetId in nonFlightTimelineIds) {
      final segment = segmentByTimelineId[targetId];
      if (segment != null) {
        uniqueSegments[_segmentKey(segment)] = segment;
      }
    }

    var created = 0;
    var updated = 0;
    var unchanged = 0;
    var skippedLockedDuty = 0;
    var skippedMissingTargetEvent = 0;

    for (final targetId in flightIds) {
      if (!segmentByFlightId.containsKey(targetId)) {
        skippedMissingTargetEvent++;
      }
    }
    for (final targetId in nonFlightTimelineIds) {
      if (!segmentByTimelineId.containsKey(targetId)) {
        skippedMissingTargetEvent++;
      }
    }

    for (final segment in uniqueSegments.values) {
      final suggestion = _buildDutySuggestion(segment: segment, rules: rules);
      final exact = await _repository.findDutyByExactRange(
        start: suggestion.startUtc,
        end: suggestion.endUtc,
      );
      if (exact != null) {
        unchanged++;
        continue;
      }

      final covering = await _repository.findDutyCoveringTime(
        segment.lastEvent.endUtc,
      );
      if (covering != null) {
        if (covering.isLocked) {
          skippedLockedDuty++;
          continue;
        }
        await _repository.updateDuty(
          duty: covering,
          start: suggestion.startUtc,
          end: suggestion.endUtc,
          dutyMinutes: suggestion.dutyMinutes,
          factoredMinutes: suggestion.factoredMinutes,
        );
        updated++;
        continue;
      }

      await _repository.createDuty(
        start: suggestion.startUtc,
        end: suggestion.endUtc,
        dutyMinutes: suggestion.dutyMinutes,
        factoredMinutes: suggestion.factoredMinutes,
      );
      created++;
    }

    return DutyBatchCalculationResult(
      created: created,
      updated: updated,
      unchanged: unchanged,
      skippedLockedDuty: skippedLockedDuty,
      skippedMissingTargetEvent: skippedMissingTargetEvent,
    );
  }

  Future<List<_OperationalEvent>> _loadOperationalEvents() async {
    const pageSize = 500;
    var offset = 0;
    final events = <_OperationalEvent>[];
    while (true) {
      final page = await _repository.fetchLogbookPage(
        const LogbookFilters(
          types: {
            LogbookEventType.flight,
            LogbookEventType.positioning,
            LogbookEventType.simulatorTraining,
          },
        ),
        limit: pageSize,
        offset: offset,
      );
      if (page.isEmpty) break;
      for (final entry in page) {
        final event = _toOperationalEvent(entry);
        if (event != null) {
          events.add(event);
        }
      }
      if (page.length < pageSize) break;
      offset += page.length;
    }
    events.sort((a, b) {
      final startCompare = a.startUtc.compareTo(b.startUtc);
      if (startCompare != 0) return startCompare;
      return a.timelineId.compareTo(b.timelineId);
    });
    return events;
  }

  _OperationalEvent? _toOperationalEvent(LogbookEntry entry) {
    final timelineTime = DbDateTime.dbToUtc(entry.timeLine.eventDateTime);
    if (entry.flight case final flight?) {
      final fallbackMinutes = _maxInt(
        0,
        _maxInt(flight.timeBlockMinutes, flight.timeFlightMinutes),
      );
      final end = _normalizeEndTime(
        start: timelineTime,
        preferredEnd: DbDateTime.dbToUtcOrNull(
          flight.arrivalDateTime ??
              flight.landingDateTime ??
              flight.takeOffDateTime,
        ),
        fallbackMinutes: fallbackMinutes,
      );
      return _OperationalEvent(
        timelineId: entry.timeLine.id,
        kind: _OperationalEventKind.flight,
        startUtc: timelineTime,
        endUtc: end,
        startAirportId: flight.departureAirportId,
        endAirportId: flight.arrivalAirportId,
        flightId: flight.id,
      );
    }

    if (entry.positioning case final positioning?) {
      final end = _normalizeEndTime(
        start: timelineTime,
        preferredEnd: DbDateTime.dbToUtcOrNull(positioning.arrivalDateTime),
        fallbackMinutes: _maxInt(0, positioning.timeTotalMinutes),
      );
      return _OperationalEvent(
        timelineId: entry.timeLine.id,
        kind: _OperationalEventKind.positioning,
        startUtc: timelineTime,
        endUtc: end,
        startAirportId: positioning.departurePlaceId,
        endAirportId: positioning.arrivalPlaceId,
      );
    }

    if (entry.simulatorTraining case final simulator?) {
      final end = _normalizeEndTime(
        start: timelineTime,
        preferredEnd: DbDateTime.dbToUtcOrNull(simulator.endDateTime),
        fallbackMinutes: _maxInt(0, simulator.timeTotal),
      );
      return _OperationalEvent(
        timelineId: entry.timeLine.id,
        kind: _OperationalEventKind.simulator,
        startUtc: timelineTime,
        endUtc: end,
      );
    }

    return null;
  }

  DateTime _normalizeEndTime({
    required DateTime start,
    required DateTime? preferredEnd,
    required int fallbackMinutes,
  }) {
    final candidate =
        preferredEnd ?? start.add(Duration(minutes: fallbackMinutes));
    if (candidate.isBefore(start)) {
      return start.add(Duration(minutes: fallbackMinutes));
    }
    return candidate;
  }

  List<_DutySegment> _buildDutySegments({
    required List<_OperationalEvent> events,
    required DutyCalculationRules rules,
  }) {
    if (events.isEmpty) return const <_DutySegment>[];
    final minRest = _maxInt(0, rules.minimumRestTimeMinutes);
    final segments = <_DutySegment>[];
    var current = <_OperationalEvent>[events.first];
    for (var i = 1; i < events.length; i++) {
      final previous = events[i - 1];
      final next = events[i];
      final gapMinutes = next.startUtc.difference(previous.endUtc).inMinutes;
      if (gapMinutes < minRest) {
        current.add(next);
      } else {
        segments.add(
          _DutySegment(events: List<_OperationalEvent>.from(current)),
        );
        current = <_OperationalEvent>[next];
      }
    }
    segments.add(_DutySegment(events: List<_OperationalEvent>.from(current)));
    return segments;
  }

  DutyCalculationSuggestion _buildDutySuggestion({
    required _DutySegment segment,
    required DutyCalculationRules rules,
  }) {
    final first = segment.firstEvent;
    final last = segment.lastEvent;
    final startsWithSimulator = first.kind == _OperationalEventKind.simulator;

    final reportingOffsetMinutes = startsWithSimulator
        ? 0
        : _resolveReportingOffsetMinutes(
            firstAirportId: first.startAirportId,
            rules: rules,
          );
    final startUtc = first.startUtc.subtract(
      Duration(minutes: _maxInt(0, reportingOffsetMinutes)),
    );
    final endUtc = last.endUtc.add(
      Duration(minutes: _maxInt(0, rules.dutyEndTimeAllowanceMinutes)),
    );
    final normalizedEndUtc = endUtc.isBefore(startUtc) ? startUtc : endUtc;
    final dutyMinutes = _maxInt(
      0,
      normalizedEndUtc.difference(startUtc).inMinutes,
    );
    return DutyCalculationSuggestion(
      startUtc: startUtc,
      endUtc: normalizedEndUtc,
      dutyMinutes: dutyMinutes,
      factoredMinutes: dutyMinutes,
      startsWithSimulator: startsWithSimulator,
    );
  }

  int _resolveReportingOffsetMinutes({
    required int? firstAirportId,
    required DutyCalculationRules rules,
  }) {
    final baseAirportId = rules.crewHomeBaseAirportId;
    final onBase = baseAirportId != null && firstAirportId == baseAirportId;
    return onBase
        ? rules.reportingTimeOnBaseMinutes
        : rules.reportingTimeOffBaseMinutes;
  }

  String _segmentKey(_DutySegment segment) {
    return '${segment.firstEvent.startUtc.microsecondsSinceEpoch}|'
        '${segment.lastEvent.endUtc.microsecondsSinceEpoch}';
  }

  int _maxInt(int left, int right) {
    return left >= right ? left : right;
  }

  /// Deletes duty entry with id [dutyId].
  Future<void> deleteDutyById(int dutyId) => _repository.deleteDutyById(dutyId);
}

/// Input rules used to derive duty periods from timeline events.
class DutyCalculationRules {
  /// Creates duty calculation rules.
  const DutyCalculationRules({
    required this.reportingTimeOnBaseMinutes,
    required this.reportingTimeOffBaseMinutes,
    required this.dutyEndTimeAllowanceMinutes,
    required this.minimumRestTimeMinutes,
    this.crewHomeBaseAirportId,
  });

  /// Airport id for crew home base.
  final int? crewHomeBaseAirportId;

  /// Reporting time before an on-base event.
  final int reportingTimeOnBaseMinutes;

  /// Reporting time before an off-base event.
  final int reportingTimeOffBaseMinutes;

  /// Buffer after last event before duty ends.
  final int dutyEndTimeAllowanceMinutes;

  /// Minimum rest break separating two duties.
  final int minimumRestTimeMinutes;
}

/// Computed duty suggestion ready for UI prefill or persistence.
class DutyCalculationSuggestion {
  /// Creates a duty suggestion.
  const DutyCalculationSuggestion({
    required this.startUtc,
    required this.endUtc,
    required this.dutyMinutes,
    required this.factoredMinutes,
    required this.startsWithSimulator,
  });

  /// Suggested duty start.
  final DateTime startUtc;

  /// Suggested duty end.
  final DateTime endUtc;

  /// Suggested duty minutes.
  final int dutyMinutes;

  /// Suggested factored duty minutes.
  final int factoredMinutes;

  /// Whether the duty starts with a simulator event.
  final bool startsWithSimulator;
}

/// Result summary for batch duty calculation.
class DutyBatchCalculationResult {
  /// Creates a batch result summary.
  const DutyBatchCalculationResult({
    required this.created,
    required this.updated,
    required this.unchanged,
    required this.skippedLockedDuty,
    required this.skippedMissingTargetEvent,
  });

  /// Number of duty periods created.
  final int created;

  /// Number of duty periods updated.
  final int updated;

  /// Number of target segments already matching persisted duty periods.
  final int unchanged;

  /// Number of locked duty rows skipped.
  final int skippedLockedDuty;

  /// Number of targets skipped because no operational event was resolved.
  final int skippedMissingTargetEvent;
}

enum _OperationalEventKind { flight, positioning, simulator }

class _OperationalEvent {
  const _OperationalEvent({
    required this.timelineId,
    required this.kind,
    required this.startUtc,
    required this.endUtc,
    this.startAirportId,
    this.endAirportId,
    this.flightId,
  });

  final int timelineId;
  final _OperationalEventKind kind;
  final DateTime startUtc;
  final DateTime endUtc;
  final int? startAirportId;
  final int? endAirportId;
  final int? flightId;
}

class _DutySegment {
  const _DutySegment({required this.events});

  final List<_OperationalEvent> events;

  _OperationalEvent get firstEvent => events.first;
  _OperationalEvent get lastEvent => events.last;
}
