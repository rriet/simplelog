// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SimpleLog';

  @override
  String get homeTitle => 'SimpleLog';

  @override
  String get addAction => 'Add';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get screenMenu => 'Screens';

  @override
  String get screenLogbook => 'Logbook';

  @override
  String get logbookFilterAction => 'Filters';

  @override
  String get logbookFilterTitle => 'Filters';

  @override
  String get logbookFilterFromDate => 'From date';

  @override
  String get logbookFilterToDate => 'To date';

  @override
  String get logbookFilterRange => 'Date range';

  @override
  String get logbookFilterApply => 'Apply filters';

  @override
  String get logbookFilterPresetCustom => 'Custom';

  @override
  String get logbookFilterPresetSinceFirstFlight => 'Since first flight';

  @override
  String get logbookFilterPresetLast7Days => 'Last 7 days';

  @override
  String get logbookFilterPresetLast14Days => 'Last 14 days';

  @override
  String get logbookFilterPresetLast21Days => 'Last 21 days';

  @override
  String get logbookFilterPresetLast28Days => 'Last 28 days';

  @override
  String get logbookFilterPresetLast365Days => 'Last 365 days';

  @override
  String get logbookFilterPresetLastMonth => 'Last month';

  @override
  String get logbookFilterPresetLastYear => 'Last year';

  @override
  String get logbookFilterPresetCurrentMonth => 'Current month';

  @override
  String get logbookFilterPresetCurrentYear => 'Current year';

  @override
  String get logbookFilterEventTypes => 'Event types';

  @override
  String get logbookFilterAdvanced => 'Advanced filters (coming soon)';

  @override
  String get logbookEventFlight => 'Flight';

  @override
  String get logbookEventSimulator => 'Simulator training';

  @override
  String get logbookEventDuty => 'Duty period';

  @override
  String get logbookEventDutyStart => 'Duty start';

  @override
  String get logbookEventDutyEnd => 'Duty end';

  @override
  String get logbookEventPositioning => 'Positioning';

  @override
  String get logbookEventUnknown => 'Event';

  @override
  String get screenAircraft => 'Aircraft';

  @override
  String get screenAircraftTypes => 'Aircraft Types';

  @override
  String get screenAirports => 'Airports';

  @override
  String get screenCrew => 'Crew';

  @override
  String get screenReports => 'Reports';

  @override
  String get screenDatabase => 'Database';

  @override
  String get screenSettings => 'Settings';

  @override
  String get searchAircraft => 'Search aircraft';

  @override
  String get searchCrew => 'Search crew';

  @override
  String get searchAirports => 'Search airports';

  @override
  String get searchAircraftTypes => 'Search aircraft types';

  @override
  String get emptyResults => 'No results found';

  @override
  String get lockAction => 'Lock';

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get confirmDeleteTitle => 'Confirm delete';

  @override
  String confirmDeleteAircraftType(String code) {
    return 'Delete aircraft type $code?';
  }

  @override
  String confirmDeleteAircraft(String registration) {
    return 'Delete aircraft $registration?';
  }

  @override
  String confirmDeleteCrew(String name) {
    return 'Delete crew member $name?';
  }

  @override
  String confirmDeleteAirport(String icao) {
    return 'Delete airport $icao?';
  }

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDeveloper => 'Developer';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get editAircraftTypeTitle => 'Edit aircraft type';

  @override
  String get createAircraftTypeTitle => 'Add aircraft type';

  @override
  String get editAircraftTitle => 'Edit aircraft';

  @override
  String get createAircraftTitle => 'Add aircraft';

  @override
  String get editCrewTitle => 'Edit crew';

  @override
  String get createCrewTitle => 'Add crew';

  @override
  String get editAirportTitle => 'Edit airport';

  @override
  String get createAirportTitle => 'Add airport';

  @override
  String get saveAction => 'Save';

  @override
  String get okAction => 'OK';

  @override
  String get validationErrorTitle => 'Validation error';

  @override
  String get validationErrorGeneric => 'Please check the form and try again.';

  @override
  String get codeRequired => 'Code is required';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get codeDuplicateTitle => 'Duplicate code';

  @override
  String codeDuplicateMessage(String code) {
    return 'Code $code already exists.';
  }

  @override
  String get deleteBlockedTitle => 'Delete blocked';

  @override
  String deleteBlockedAircraftType(int count) {
    return 'This aircraft type is used by $count aircraft and can\'t be deleted.';
  }

  @override
  String get fieldCode => 'Code';

  @override
  String get fieldRegistration => 'Registration';

  @override
  String get fieldAircraftType => 'Aircraft type';

  @override
  String get fieldFamily => 'Family';

  @override
  String get fieldLongName => 'Type Name';

  @override
  String get fieldManufacturer => 'Manufacturer';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldEngineType => 'Engine type';

  @override
  String get fieldMtow => 'MTOW';

  @override
  String get fieldEngineCount => 'Engine count';

  @override
  String get fieldMultiPilot => 'Multi-pilot';

  @override
  String get fieldComplex => 'Complex';

  @override
  String get fieldEfis => 'EFIS';

  @override
  String get fieldHighPerformance => 'High performance';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldPicture => 'Picture';

  @override
  String get pictureHint => 'Click to add/edit photo';

  @override
  String get photoCamera => 'Camera';

  @override
  String get photoLibrary => 'Photo Library';

  @override
  String get removePicture => 'Remove photo';

  @override
  String get cropPhotoTitle => 'Edit photo';

  @override
  String get fieldIsSelf => 'Self';

  @override
  String get fieldIsFavorite => 'Favorite';

  @override
  String get fieldIsSimulator => 'Simulator';

  @override
  String get fieldIcao => 'ICAO';

  @override
  String get fieldIata => 'IATA';

  @override
  String get fieldCity => 'City';

  @override
  String get fieldCountry => 'Country';

  @override
  String get fieldLatitude => 'Latitude';

  @override
  String get fieldLongitude => 'Longitude';

  @override
  String get aircraftTypeRequired => 'Select an aircraft type';

  @override
  String get registrationDuplicateTitle => 'Duplicate registration';

  @override
  String registrationDuplicateMessage(String registration) {
    return 'Registration $registration already exists.';
  }

  @override
  String get nameDuplicateTitle => 'Duplicate name';

  @override
  String nameDuplicateMessage(String name) {
    return 'Name $name already exists.';
  }

  @override
  String get icaoLengthError => 'ICAO must be 4 characters';

  @override
  String get icaoDuplicateTitle => 'Duplicate ICAO';

  @override
  String icaoDuplicateMessage(String icao) {
    return 'ICAO $icao already exists.';
  }

  @override
  String get callNumber => 'Call number';

  @override
  String get textNumber => 'Text message';

  @override
  String get copyNumber => 'Copy number';

  @override
  String get sendEmail => 'Send email';

  @override
  String get copyEmail => 'Copy email';

  @override
  String get seedTestData => 'Seed test data';

  @override
  String get seedDataDone => 'Test data inserted';

  @override
  String get databaseSyncTitle => 'Local sync';

  @override
  String get databaseSyncStartLocal => 'Start Local Sync';

  @override
  String get databaseSyncFoundTitle => 'Available devices';

  @override
  String get databaseSyncSearching => 'Searching for devices on Wi‑Fi...';

  @override
  String get databaseSyncSendAction => 'Send to device';

  @override
  String get databaseSyncPullAction => 'Pull from device';

  @override
  String get databaseSyncConfirmTitle => 'Confirm overwrite';

  @override
  String databaseSyncConfirmMessage(String device) {
    return '⚠️ This will replace all data on $device.';
  }

  @override
  String get databaseSyncConfirmAction => 'Confirm';

  @override
  String databaseSyncConnected(String device) {
    return 'Connected: $device';
  }

  @override
  String get databaseSyncWaiting => 'Waiting for transfer...';

  @override
  String get databaseSyncSchemaMismatchTitle => 'Database version mismatch';

  @override
  String databaseSyncSchemaMismatchMessage(Object local, Object remote) {
    return 'Cannot sync because the database versions differ. This device uses v$local and the other device uses v$remote. Update both apps and try again.';
  }

  @override
  String get databaseSyncCopyDebug => 'Copy debug info';

  @override
  String get databaseSyncCopied => 'Debug info copied';

  @override
  String get databaseSyncLocalServer => 'Local server';

  @override
  String get databaseSyncTestServer => 'Test local server';

  @override
  String get databaseSyncSessionInfo =>
      'Start a session on one device and join from another.';

  @override
  String get databaseSyncStartSession => 'Start session';

  @override
  String get databaseSyncStopSession => 'Stop session';

  @override
  String get databaseSyncJoinSession => 'Connect device';

  @override
  String get databaseSyncHosting => 'Hosting session';

  @override
  String get databaseSyncEnterAddress => 'Enter address';

  @override
  String get databaseSyncAddressHint =>
      'simplelog://sync?host=192.168.1.10&port=49200';

  @override
  String get databaseSyncConnectedLabel => 'Connected to';

  @override
  String get databaseSyncNotConnected => 'Not connected';

  @override
  String get databaseSyncConnectHint =>
      'To send from this device, connect to the other device first.';

  @override
  String get databaseSyncSend => 'Send database';

  @override
  String get databaseSyncEnterLastTwo => 'Enter last two IP groups';

  @override
  String get databaseSyncOctet3 => 'Third group';

  @override
  String get databaseSyncOctet4 => 'Fourth group';

  @override
  String databaseSyncInstruction(String prefix, String octet3, String octet4) {
    return 'On the other device, enter only the last two numbers: $octet3.$octet4 (prefix $prefix, port 54742).';
  }

  @override
  String get databaseSyncSuccess => 'Sync complete';

  @override
  String get databaseSyncInvalidSession => 'Unable to connect to that session.';

  @override
  String get databaseSyncNoNetwork => 'No local network IP found.';

  @override
  String get databaseSyncScanQr => 'Scan QR code';

  @override
  String get databaseSyncDisconnected => 'Disconnected from the other device.';

  @override
  String get databaseSyncStopWarning =>
      'Stopping will disconnect other devices. Continue?';

  @override
  String get reportsTabOverview => 'Overview';

  @override
  String get reportsTabFlights => 'Flights';

  @override
  String get reportsTabTotals => 'Totals';

  @override
  String get reportsTabAnalyses => 'Analyses';

  @override
  String get reportsTabReports => 'Reports';

  @override
  String get reportsTabFilters => 'Filters';

  @override
  String get reportsEntryGeneric => 'Entry';

  @override
  String reportsDeleteEntryConfirm(String label) {
    return 'Delete $label?';
  }

  @override
  String get reportsDeleteDutyConfirm => 'Delete this duty entry?';

  @override
  String get reportsNoPreviousFlightFound => 'No previous flight found.';

  @override
  String get logbookFabReturnFlight => 'Return Flight';

  @override
  String get logbookFabNextFlight => 'Next Flight';

  @override
  String get reportsStartBeforeEndError =>
      'Start date must be before end date.';

  @override
  String reportsSavedQuery(String name) {
    return 'Saved query \"$name\".';
  }

  @override
  String get reportsPdfPreparing => 'Preparing PDF...';

  @override
  String get reportsPdfGenerating => 'Generating PDF...';

  @override
  String get reportsPdfSaving => 'Saving PDF...';

  @override
  String get reportsPdfDone => 'Done.';

  @override
  String reportsPdfExported(String path) {
    return 'PDF exported to: $path';
  }

  @override
  String reportsPdfFailed(String error) {
    return 'Failed to generate PDF: $error';
  }

  @override
  String get reportsNoTemplateAvailable => 'No template available.';

  @override
  String get reportsSavePdfDialogTitle => 'Save PDF';

  @override
  String get reportsChooseExportFolderTitle => 'Choose export folder';

  @override
  String get reportsCancelled => 'Cancelled';

  @override
  String get reportsAnalyzeByLabel => 'Analyze by';

  @override
  String get reportsOrderByLabel => 'Order by';

  @override
  String get reportsAnalyzeByAircraft => 'By Aircraft';

  @override
  String get reportsAnalyzeByType => 'By Type';

  @override
  String get reportsAnalyzeByFamily => 'By Family';

  @override
  String get reportsAnalyzeByYear => 'By Year';

  @override
  String get reportsAnalyzeByMonth => 'By Month';

  @override
  String get reportsOrderByGreater => 'Greater';

  @override
  String get reportsOrderByNatural => 'Natural';

  @override
  String get reportsShowMap => 'Show Map';

  @override
  String get reportsShowPath => 'Show Path';

  @override
  String get reportsIncludeHoursBefore => 'Include hours before';

  @override
  String get reportsPageSizeLabel => 'Page Size';

  @override
  String get reportsXmlTemplateLabel => 'XML Template';

  @override
  String get reportsGeneratingShort => 'Generating...';

  @override
  String get reportsGeneratePdf => 'Generate PDF';

  @override
  String get reportsDatePresetLastMonthRolling => 'Last month (rolling)';

  @override
  String get reportsUnknown => 'Unknown';

  @override
  String get reportsUnknownType => 'Unknown type';

  @override
  String get reportsUnknownFamily => 'Unknown family';

  @override
  String reportsFiltersSummary(int count, String from, String to) {
    return '$count filters • $from UTC - $to UTC';
  }

  @override
  String get reportsEventSimShort => 'Sim';

  @override
  String get reportsPreviousExperienceLabel => 'Previous experience';

  @override
  String get reportsInclude => 'Include';

  @override
  String get reportsExclude => 'Exclude';

  @override
  String get reportsMatchModeLabel => 'Match mode';

  @override
  String get reportsMatchAll => 'All';

  @override
  String get reportsMatchAny => 'Any';

  @override
  String get reportsAddFilter => 'Add Filter';

  @override
  String reportsFilterChipLabel(String field, String operator, String value) {
    return '$field · $operator · $value';
  }

  @override
  String get reportsSavedQueriesLabel => 'Saved queries';

  @override
  String get reportsSaveQuery => 'Save Query';

  @override
  String reportsDeleteSavedQuery(String name) {
    return 'Delete: $name';
  }

  @override
  String get reportsDeleteSavedLabel => 'Delete Saved';

  @override
  String get reportsMetricIfrApproaches => 'IFR Approaches';

  @override
  String get reportsMetricTakeoffDay => 'Takeoff Day';

  @override
  String get reportsMetricTakeoffNight => 'Takeoff Night';

  @override
  String get reportsMetricLandingDay => 'Landing Day';

  @override
  String get reportsMetricLandingNight => 'Landing Night';

  @override
  String get reportsMetricTotalBlock => 'Total Block';

  @override
  String get reportsMetricPic => 'PIC';

  @override
  String get reportsMetricPicus => 'PICUS';

  @override
  String get reportsMetricSic => 'SIC';

  @override
  String get reportsMetricDual => 'Dual';

  @override
  String get reportsMetricInstructor => 'Instructor';

  @override
  String get reportsMetricNight => 'Night';

  @override
  String get reportsMetricIfr => 'IFR';

  @override
  String get reportsMetricInstrument => 'Instrument';

  @override
  String get reportsMetricCrossCountry => 'Cross-Country';

  @override
  String get reportsMetricSimulator => 'Simulator';

  @override
  String get reportsMetricDuty => 'Duty';

  @override
  String get reportsMetricDistanceNm => 'Distance NM';

  @override
  String reportsFlightCount(String count) {
    return 'Flight count: $count';
  }

  @override
  String get reportsNoDataForQuery => 'No data for selected query.';

  @override
  String get reportsMetricLandings => 'Landings';

  @override
  String reportsFirstFlightAt(String date) {
    return 'First flight $date UTC';
  }

  @override
  String reportsLastFlightAt(String date) {
    return 'Last flight $date UTC';
  }

  @override
  String get reportsFieldNameLabel => 'Field name';

  @override
  String get reportsConditionLabel => 'Condition';

  @override
  String get reportsValueLabel => 'Value';

  @override
  String get reportsFlightsAndSimulatorTitle => 'Flights & Simulator';

  @override
  String reportsEntriesCount(int count) {
    return '$count entries';
  }

  @override
  String get reportsNoFlightsInPeriod => 'No flights/sim in selected period.';

  @override
  String get reportsFlightMapTitle => 'Flight Map';

  @override
  String get reportsHideLines => 'Hide lines';

  @override
  String get reportsShowLines => 'Show lines';

  @override
  String get reportsDone => 'Done';

  @override
  String get reportsNoCoordinatesAvailable => 'No coordinates available.';

  @override
  String reportsAirportsCount(int count) {
    return 'Airports: $count';
  }

  @override
  String get reportsFilterFieldDepartureIcao => 'Departure ICAO';

  @override
  String get reportsFilterFieldDepartureIata => 'Departure IATA';

  @override
  String get reportsFilterFieldDepartureName => 'Departure Name';

  @override
  String get reportsFilterFieldDepartureCity => 'Departure City';

  @override
  String get reportsFilterFieldDepartureCountry => 'Departure Country';

  @override
  String get reportsFilterFieldArrivalIcao => 'Arrival ICAO';

  @override
  String get reportsFilterFieldArrivalIata => 'Arrival IATA';

  @override
  String get reportsFilterFieldArrivalName => 'Arrival Name';

  @override
  String get reportsFilterFieldArrivalCity => 'Arrival City';

  @override
  String get reportsFilterFieldArrivalCountry => 'Arrival Country';

  @override
  String get reportsFilterFieldAircraftRegistration => 'Aircraft Registration';

  @override
  String get reportsFilterFieldAircraftTypeCode => 'Aircraft Type Code';

  @override
  String get reportsFilterFieldAircraftTypeFamily => 'Aircraft Type Family';

  @override
  String get reportsFilterFieldAircraftTypeName => 'Aircraft Type Name';

  @override
  String get reportsFilterFieldPilotName => 'Pilot Name';

  @override
  String get reportsFilterFieldPilotOnBoard => 'Pilot On Board';

  @override
  String get reportsFilterFieldPilotPic => 'Pilot PIC';

  @override
  String get reportsFilterFieldPilotSic => 'Pilot SIC';

  @override
  String get reportsFilterFieldPilotTrainee => 'Pilot Trainee';

  @override
  String get reportsFilterFieldApproachType => 'Approach Type';

  @override
  String get reportsFilterFieldRemarks => 'Remarks';

  @override
  String get reportsFilterFieldNotes => 'Notes';

  @override
  String get reportsFilterFieldBlockTime => 'Block Time';

  @override
  String get reportsFilterFieldFlightTime => 'Flight Time';

  @override
  String get reportsFilterFieldTotalTime => 'Total Time';

  @override
  String get reportsFilterFieldNightTime => 'Night Time';

  @override
  String get reportsFilterFieldIfrTime => 'IFR Time';

  @override
  String get reportsFilterFieldInstrumentTime => 'Instrument Time';

  @override
  String get reportsFilterFieldSimInstrumentTime => 'Sim Instrument Time';

  @override
  String get reportsFilterFieldPicTime => 'PIC Time';

  @override
  String get reportsFilterFieldPicusTime => 'PICUS Time';

  @override
  String get reportsFilterFieldSicTime => 'SIC Time';

  @override
  String get reportsFilterFieldDualTime => 'Dual Time';

  @override
  String get reportsFilterFieldInstructorTime => 'Instructor Time';

  @override
  String get reportsFilterFieldCrossCountryTime => 'Cross-Country Time';

  @override
  String get reportsFilterFieldCustom1Time => 'Custom 1 Time';

  @override
  String get reportsFilterFieldCustom2Time => 'Custom 2 Time';

  @override
  String get reportsFilterFieldCustom3Time => 'Custom 3 Time';

  @override
  String get reportsFilterFieldCustom4Time => 'Custom 4 Time';

  @override
  String get reportsFilterFieldDistanceNm => 'Distance NM';

  @override
  String get reportsFilterFieldTakeoffs => 'Takeoffs';

  @override
  String get reportsFilterFieldTakeoffsDay => 'Takeoffs Day';

  @override
  String get reportsFilterFieldTakeoffsNight => 'Takeoffs Night';

  @override
  String get reportsFilterFieldLandings => 'Landings';

  @override
  String get reportsFilterFieldLandingsDay => 'Landings Day';

  @override
  String get reportsFilterFieldLandingsNight => 'Landings Night';

  @override
  String get reportsFilterFieldIfrApproaches => 'IFR Approaches';

  @override
  String get reportsFilterFieldMultiPilot => 'Multi Pilot';

  @override
  String get reportsFilterFieldSimulator => 'Simulator';

  @override
  String get reportsFilterOperatorContains => 'Contains';

  @override
  String get reportsFilterOperatorDoesNotContain => 'Does not contain';

  @override
  String get reportsFilterOperatorStartsWith => 'Starts With';

  @override
  String get reportsFilterOperatorDoesNotStartWith => 'Does not start with';

  @override
  String get reportsFilterOperatorEndsWith => 'Ends With';

  @override
  String get reportsFilterOperatorDoesNotEndWith => 'Does not end with';

  @override
  String get reportsFilterOperatorIs => 'Is';

  @override
  String get reportsFilterOperatorIsNot => 'Is not';

  @override
  String get reportsFilterOperatorGreaterThan => 'Greater than';

  @override
  String get reportsFilterOperatorLessThan => 'Less than';

  @override
  String get reportsFilterOperatorEquals => 'Equals';

  @override
  String get reportsFilterOperatorIsTrue => 'Is True';

  @override
  String get reportsFilterOperatorIsFalse => 'Is False';

  @override
  String get languageLatvian => 'Latvian';

  @override
  String get reportsAnalyzeByAirport => 'By Airport';

  @override
  String get reportsAnalyzeByPilot => 'By Pilot';

  @override
  String get reportsUnknownAirport => 'Unknown airport';

  @override
  String get reportsUnknownPilot => 'Unknown pilot';

  @override
  String get reportsOrderByHours => 'Hours';

  @override
  String get reportsOrderByLandings => 'Landings';

  @override
  String get reportsOrderByTakeoff => 'TakeOff';

  @override
  String get reportsOrderByOperations => 'Operations';

  @override
  String get reportsMetricTakeoff => 'TakeOff';

  @override
  String get reportsMetricOperations => 'Operations';

  @override
  String get aircraftFiltersTitle => 'Aircraft filters';

  @override
  String get crewFiltersTitle => 'Crew filters';

  @override
  String get airportFiltersTitle => 'Airport filters';

  @override
  String get searchByLabel => 'Search by';

  @override
  String get orderByLabel => 'Order by';

  @override
  String get optionAll => 'All';

  @override
  String get searchFieldType => 'Type';

  @override
  String get applyAction => 'Apply';

  @override
  String get fieldTakeoffs => 'Takeoffs';

  @override
  String get fieldLandings => 'Landings';

  @override
  String get fieldVisits => 'Visits';

  @override
  String get airportShowOnlyVisited => 'Show only visited airports';

  @override
  String get airportSearchIcaoOrIata => 'ICAO or IATA';

  @override
  String get summaryFirstFlight => 'First flight';

  @override
  String get summaryLastFlight => 'Last flight';

  @override
  String get summaryTotalTime => 'Total time';

  @override
  String get summaryTotalPic => 'PIC total';

  @override
  String get notAvailableShort => '-';

  @override
  String get fieldCrew => 'Crew';

  @override
  String get addCrewTitle => 'Add crew';

  @override
  String get selectCrewTitle => 'Select crew';

  @override
  String get crewPositionLabel => 'Position';

  @override
  String get crewPositionPic => 'PIC';

  @override
  String get crewPositionPicus => 'PICUS';

  @override
  String get crewPositionSic => 'SIC';

  @override
  String get crewPositionTrainee => 'Trainee';

  @override
  String get crewPositionInstructor => 'Instructor';

  @override
  String get crewPositionObserver => 'Observer';

  @override
  String get crewPositionRelief => 'Relief';

  @override
  String get crewPositionReliefCaptain => 'Relief Captain';

  @override
  String get crewPositionReliefFirstOfficer => 'Relief First Officer';

  @override
  String get crewPositionCabinSenior => 'Cabin Senior';

  @override
  String get crewPositionCabinCrew => 'Cabin Crew';

  @override
  String get crewPositionOther => 'Other';

  @override
  String get crewPositionUnknown => 'Unknown';

  @override
  String get searchRegistration => 'Search registration';

  @override
  String get searchType => 'Search type';

  @override
  String get searchFamily => 'Search family';

  @override
  String get searchNotes => 'Search notes';

  @override
  String get searchName => 'Search name';

  @override
  String get searchCity => 'Search city';

  @override
  String get searchCountry => 'Search country';

  @override
  String get searchIcao => 'Search ICAO';

  @override
  String get searchIata => 'Search IATA';

  @override
  String get searchIcaoIata => 'Search ICAO/IATA';

  @override
  String get createSimulatorTitle => 'Add simulator';

  @override
  String get mapTitle => 'Map';

  @override
  String get aircraftEmptyResults => 'No aircraft found';

  @override
  String get crewEmptyResults => 'No crew found';

  @override
  String get crewLoadError => 'Error loading crew';

  @override
  String get airportEmptyResults => 'No airports found';

  @override
  String get airportLoadError => 'Error loading airports';

  @override
  String get errorLabel => 'Error';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardNoActiveRules => 'No active rules configured.';

  @override
  String get dashboardRuleTotals => 'Rule totals';

  @override
  String get dashboardNoData => 'No data.';

  @override
  String get dashboardEventsInCalculation => 'Events in calculation';

  @override
  String get dashboardNoEventsInWindow => 'No events in this window.';

  @override
  String get dashboardFlightsLabel => 'Flights';

  @override
  String get dashboardBlockLabel => 'Block';

  @override
  String get dashboardFlightLabel => 'Flight';

  @override
  String get dashboardNightLabel => 'Night';

  @override
  String get dashboardIfrLabel => 'IFR';

  @override
  String get dashboardInstrumentLabel => 'Instrument';

  @override
  String get dashboardDutyLabel => 'Duty';

  @override
  String get dashboardLandingsLabel => 'Landings';

  @override
  String get dashboardSetupTitle => 'Dashboard setup';

  @override
  String get dashboardAddRule => 'Add rule';

  @override
  String get dashboardNoRulesConfigured => 'No rules configured.';

  @override
  String get dashboardEditRuleTitle => 'Edit rule';

  @override
  String get dashboardCreateRuleTitle => 'Create rule';

  @override
  String get dashboardRuleNameLabel => 'Rule name';

  @override
  String get dashboardMetricLabel => 'Metric';

  @override
  String get dashboardRuleTypeLabel => 'Rule type';

  @override
  String get dashboardWindowTypeLabel => 'Window type';

  @override
  String get dashboardStartReferenceLabel => 'Start reference';

  @override
  String get dashboardWindowValueLabel => 'Window value';

  @override
  String get dashboardLimitValueLabel => 'Limit value';

  @override
  String get dashboardUnitLabel => 'Unit';

  @override
  String get dashboardWarnYellowBeforeLabel => 'Warn yellow before';

  @override
  String get dashboardWarnRedBeforeLabel => 'Warn red before';

  @override
  String get dashboardCreateAction => 'Create';

  @override
  String get dashboardTakeoffLabel => 'Takeoff';

  @override
  String get dashboardTakeoffDayLabel => 'Takeoff day';

  @override
  String get dashboardTakeoffNightLabel => 'Takeoff night';

  @override
  String get dashboardLandingsDayLabel => 'Landings day';

  @override
  String get dashboardLandingsNightLabel => 'Landings night';

  @override
  String get dashboardInstrumentApproachesLabel => 'Instrument approaches';

  @override
  String get dashboardPicTimeLabel => 'PIC time';

  @override
  String get dashboardSicTimeLabel => 'SIC time';

  @override
  String get dashboardPicusTimeLabel => 'PICUS time';

  @override
  String get dashboardDualTimeLabel => 'Dual time';

  @override
  String get dashboardInstructorTimeLabel => 'Instructor time';

  @override
  String get dashboardCrossCountryLabel => 'Cross country';

  @override
  String get dashboardMinimumLabel => 'Minimum';

  @override
  String get dashboardMaximumLabel => 'Maximum';

  @override
  String get dashboardHoursUnit => 'hours';

  @override
  String get dashboardMinutesUnit => 'minutes';

  @override
  String get dashboardDaysUnit => 'days';

  @override
  String get dashboardWeeksUnit => 'weeks';

  @override
  String get dashboardMonthsUnit => 'months';

  @override
  String get dashboardYearsUnit => 'years';

  @override
  String get dashboardCountUnit => 'count';

  @override
  String get dashboardCalendarMonthsLabel => 'Calendar months';

  @override
  String get dashboardCalendarYearsLabel => 'Calendar years';

  @override
  String get dashboardCalendarDaysLabel => 'Calendar days';

  @override
  String get dashboardCalendarQuarterLabel => 'Calendar quarter';

  @override
  String get dashboardSameTimeNowLabel => 'Same time (now)';

  @override
  String get dashboardMidnightLocalLabel => 'Midnight local';

  @override
  String get dashboardMidnightUtcLabel => 'Midnight UTC';

  @override
  String get dashboardRemainingSuffix => 'remaining';

  @override
  String get dashboardOverLimitSuffix => 'over limit';

  @override
  String get dashboardAboveMinimumSuffix => 'above minimum';

  @override
  String get dashboardBelowMinimumSuffix => 'below minimum';

  @override
  String get dashboardMinimumShortLabel => 'Min';

  @override
  String get dashboardMaximumShortLabel => 'Max';

  @override
  String get dashboardSameTimeLabel => 'Same time';

  @override
  String get checkFactoringRulesTitle => 'Check factoring rules';

  @override
  String get continueSavingQuestion => 'Continue saving?';

  @override
  String get reviewAction => 'Review';

  @override
  String get saveAnywayAction => 'Save anyway';

  @override
  String get createFlightTitle => 'New Flight';

  @override
  String get editFlightTitle => 'Edit Flight';

  @override
  String get calculateAction => 'Calculate';

  @override
  String get nextAction => 'Next';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldPilotFunction => 'Pilot Function';

  @override
  String get chocksOffRequiredToCalculate =>
      'Chocks OFF is required to calculate.';

  @override
  String get chocksOnRequiredToCalculate =>
      'Chocks ON is required to calculate.';

  @override
  String get clearAction => 'Clear';

  @override
  String get fieldRemarks => 'Remarks';

  @override
  String get noCrewAssigned => 'No crew assigned';

  @override
  String get removeAction => 'Remove';

  @override
  String get eventInfoTitle => 'Event info';

  @override
  String get clearDatabaseTitle => 'Clear database';

  @override
  String get clearDatabaseMessage =>
      'This will delete all data and recreate empty tables.';

  @override
  String get aboutTagline => 'Pilot Logbook • Made by a Pilot, for Pilots';

  @override
  String get aboutWhyTitle => 'Why SimpleLog';

  @override
  String get aboutStoryText =>
      'SimpleLog was born in the cockpit: built by a real airline pilot who got fed up with scribbling on paper like it\'s 1976.\n\nThis app replaces my previous Java logbook software, which I developed and used for many years as an airline pilot. The rewrite brings mobile support, modern UI, and easier data portability while preserving the core focus on quick, accurate entries in real operations.\n\nJust punch in takeoff, landing, airports and times -> smash Calculate -> watch how fast totals and breakdowns get calculated automatically -> save and done.\n\nNo nonsense, no subscriptions, no server drama. Your flights stay yours, stored locally, synced on local network.\n\nOpen source. Free forever. Fly. Log. Repeat.\nIf it saves you time, a coffee keeps the lights on.';

  @override
  String get aboutGithubTitle => 'Open Source on GitHub';

  @override
  String get aboutGithubDocsText =>
      'Documentation • Tutorials • Sync setup • Desktop builds • Bug tracker • Future features';

  @override
  String get aboutTapProject => 'Tap here to visit the project page ->';

  @override
  String get aboutRepoAddress => 'github.com/rriet/simplelog';

  @override
  String get aboutSupportTitle => 'Support SimpleLog';

  @override
  String get aboutSupportBodyText =>
      'SimpleLog will always remain free and open source.\n\nOngoing costs include Apple and Google developer accounts, test devices, and countless hours improving the app based on real pilot feedback.\n\nIf SimpleLog saves you time in the cockpit or makes your logbook life easier, any support is deeply appreciated.';

  @override
  String get aboutSupportFooterText =>
      '-> The GitHub page has full documentation, tutorials, sync guides, desktop builds, and ways to support the project.';

  @override
  String get aboutTechStack => 'Flutter • Riverpod • Drift';

  @override
  String get aboutLicenseText => 'GNU GPLv3 License';

  @override
  String get databaseSyncSubtitle => 'Connect two devices on the same network.';

  @override
  String get logtenReviewHelpText =>
      'Fix the value for each invalid field, or ignore the full source line.';

  @override
  String get logtenReviewSimulatorSelectedHelp =>
      'Simulator selected: airport fields are not required.';

  @override
  String get qatarMissingAirportsMessage =>
      'Create the missing airports before continuing the Qatar Airways import.';

  @override
  String get qatarMissingAircraftMessage =>
      'Create the missing simulator aircraft before continuing the Qatar Airways import.';

  @override
  String get logbookUnlockEndorsedEntryTitle => 'Unlock endorsed entry?';

  @override
  String get logbookUnlockEndorsementWarning =>
      'If you unlock this entry, signature and endorsement information will be deleted. Continue?';

  @override
  String get logbookUnlockAction => 'Unlock';

  @override
  String get endorsementLockWarning =>
      'Once saved with an endorsement signature, this entry is locked and cannot be edited unless the signature is removed.';

  @override
  String get endorsementMismatchWarning =>
      'Warning: flight information does not match the original endorsed flight record.';

  @override
  String get reportsMapSectionSubtitle =>
      'Preview the filtered routes and path overlay.';

  @override
  String get reportsPdfSectionSubtitle =>
      'Select template and export the report PDF.';

  @override
  String get settingsCalculationPilotProfileSubtitle =>
      'Pilot identity and signature preferences.';

  @override
  String get previousExperienceEntriesSubtitle =>
      'Edit, add, or remove previous experience records.';

  @override
  String get timeFieldsIntro =>
      'Control visible time columns and custom labels.';

  @override
  String get timeFieldsVisibleSubtitle =>
      'Choose which columns are shown in forms and lists.';

  @override
  String get timeFieldsCustomLabelsSubtitle =>
      'Rename custom fields used across the app.';
}
