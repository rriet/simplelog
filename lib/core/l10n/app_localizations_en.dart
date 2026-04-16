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
  String menuVersionLabel(String value) {
    return 'Version $value';
  }

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
  String get batchWriteNavigationBlockedMessage =>
      'Wait for batch update to finish.';

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
  String get editSimulatorTitle => 'Edit simulator';

  @override
  String get createSimulatorTitle => 'Add simulator';

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
  String get icaoLengthError => 'ICAO must be 4 characters';

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
  String get databaseSyncTitle => 'Local Transfer';

  @override
  String get databaseSyncStartLocal => 'Start local sync';

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
  String get databaseSyncSuccess => 'Sync complete';

  @override
  String get databaseSyncDisconnected => 'Disconnected from the other device.';

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
  String reportsPdfFailed(String error) {
    return 'Failed to generate PDF: $error';
  }

  @override
  String get reportsNoTemplateAvailable => 'No template available.';

  @override
  String get reportsSavePdfDialogTitle => 'Save PDF';

  @override
  String get reportsAnalyzeByLabel => 'Analyze by';

  @override
  String get reportsOrderByLabel => 'Order by';

  @override
  String get reportsAnalyzeByAircraft => 'Aircraft';

  @override
  String get reportsAnalyzeByType => 'Type';

  @override
  String get reportsAnalyzeByFamily => 'Family';

  @override
  String get reportsAnalyzeByYear => 'Year';

  @override
  String get reportsAnalyzeByMonth => 'Month';

  @override
  String get reportsOrderByNatural => 'Natural';

  @override
  String get reportsShowMap => 'Show map';

  @override
  String get reportsShowPath => 'Include path';

  @override
  String get reportsIncludeHoursBefore => 'Include hours before';

  @override
  String get reportsXmlTemplateLabel => 'Template';

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
  String get reportsPreviousExperienceLabel => 'Previous experience';

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
  String get reportsSaveQuery => 'Save query';

  @override
  String reportsDeleteSavedQuery(String name) {
    return 'Delete \"$name\"?';
  }

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
  String get reportsMetricCrossCountry => 'Cross-Country';

  @override
  String get reportsMetricSimulator => 'Simulator';

  @override
  String get reportsMetricDuty => 'Duty';

  @override
  String get reportsMetricDistanceNm => 'Distance NM';

  @override
  String reportsFlightCount(String count) {
    return 'Flights: $count';
  }

  @override
  String get reportsNoDataForQuery => 'No data for selected query.';

  @override
  String get reportsMetricLandings => 'Landings';

  @override
  String reportsFirstFlightAt(String date) {
    return 'First $date UTC';
  }

  @override
  String reportsLastFlightAt(String date) {
    return 'Last $date UTC';
  }

  @override
  String get reportsFieldNameLabel => 'Field name';

  @override
  String get reportsConditionLabel => 'Condition';

  @override
  String get reportsValueLabel => 'Value';

  @override
  String get reportsFlightsAndSimulatorTitle => 'Flights & simulator';

  @override
  String reportsEntriesCount(int count) {
    return '$count entries';
  }

  @override
  String get reportsNoFlightsInPeriod =>
      'No flights or sim entries in this period.';

  @override
  String get reportsFlightMapTitle => 'Flight map';

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
  String get reportsAnalyzeByAirport => 'Airport';

  @override
  String get reportsUnknownAirport => 'Unknown airport';

  @override
  String get reportsOrderByHours => 'Hours';

  @override
  String get reportsOrderByLandings => 'Landings';

  @override
  String get reportsOrderByTakeoff => 'Takeoff';

  @override
  String get reportsOrderByOperations => 'Operations';

  @override
  String get reportsMetricTakeoff => 'Takeoff';

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
  String get dashboardDutyLabel => 'Duty';

  @override
  String get dashboardLandingsLabel => 'Landings';

  @override
  String get dashboardSetupTitle => 'Setup';

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
  String get databaseLocalTransferInfoTitle => 'How Local Transfer works';

  @override
  String get databaseLocalTransferInfoMessage =>
      'Local Transfer copies the entire database from the sending device to the receiving device.\nIt is not a two-way sync. All data on the receiving device will be completely overwritten with the data from the sending device.\n\nImportant note:\nLocal Transfer may not work on hotel, airport, or public Wi-Fi networks. These networks often isolate devices from each other for security reasons, which prevents direct communication between your devices.';

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
  String get reportsMapSectionSubtitle => 'Show filtered flights on the map.';

  @override
  String get reportsPdfSectionSubtitle =>
      'Choose a template and export a PDF report.';

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

  @override
  String get autoUi001 => '25.325399/-80.274803';

  @override
  String get autoUi002 => 'About';

  @override
  String get autoUi003 => 'Add Crew';

  @override
  String get autoUi004 => 'Aircraft Type';

  @override
  String get autoUi005 => 'Arrival';

  @override
  String get autoUi006 => 'Arrival Airport';

  @override
  String get autoUi007 => 'Arrival Time';

  @override
  String get autoUi008 => 'Calculation Rules';

  @override
  String get autoUi009 => 'Certificate';

  @override
  String get autoUi010 => 'Chocks OFF';

  @override
  String get autoUi011 => 'Chocks ON';

  @override
  String get autoUi012 => 'Clear signature';

  @override
  String get autoUi013 => 'Close';

  @override
  String get autoUi014 => 'Could not open camera.';

  @override
  String get autoUi015 => 'Could not select image file.';

  @override
  String get autoUi016 => 'Crew home base airport';

  @override
  String get autoUi017 => 'CrossCountry';

  @override
  String get autoUi018 => 'Custom Time Labels';

  @override
  String get autoUi019 => 'Departure';

  @override
  String get autoUi020 => 'Departure Airport';

  @override
  String get autoUi021 => 'Departure Time';

  @override
  String get autoUi022 => 'Duty End';

  @override
  String get autoUi023 => 'Duty Rules';

  @override
  String get autoUi024 => 'Duty Start';

  @override
  String get autoUi025 => 'Duty end time allowance';

  @override
  String get autoUi026 => 'Edit profile';

  @override
  String get autoUi027 => 'End Time';

  @override
  String get autoUi028 => 'Endorsement';

  @override
  String get autoUi029 => 'Entries';

  @override
  String get autoUi030 => 'Expiry';

  @override
  String get autoUi031 => 'Factored Duty Time';

  @override
  String get autoUi032 => 'First Flight';

  @override
  String get autoUi033 => 'Format';

  @override
  String get autoUi034 => 'From';

  @override
  String get autoUi035 => 'From Airport';

  @override
  String get autoUi036 => 'Landing';

  @override
  String get autoUi037 => 'Last Flight';

  @override
  String get autoUi038 => 'Licenses';

  @override
  String get autoUi039 => 'Log takeoff and landing times';

  @override
  String get autoUi040 => 'Manage prior totals by aircraft type.';

  @override
  String get autoUi041 => 'Minimum rest time';

  @override
  String get autoUi042 => 'N25°19.31/W080°16.29';

  @override
  String get autoUi043 => 'No previous experience entries yet.';

  @override
  String get autoUi044 => 'No signature';

  @override
  String get autoUi046 => 'Previous Experience';

  @override
  String get autoUi047 => 'Profile';

  @override
  String get autoUi048 => 'Remove endorsement';

  @override
  String get autoUi049 => 'Reporting time offbase';

  @override
  String get autoUi050 => 'Reporting time on base';

  @override
  String get autoUi051 => 'Save Labels';

  @override
  String get autoUi052 => 'Session Time';

  @override
  String get autoUi053 => 'Show endorsement';

  @override
  String get autoUi054 => 'Sign';

  @override
  String get autoUi055 => 'Sign on screen';

  @override
  String get autoUi056 => 'Signature';

  @override
  String get autoUi057 => 'Signature options';

  @override
  String get autoUi059 => 'Start Time';

  @override
  String get autoUi060 => 'Times';

  @override
  String get autoUi061 => 'To';

  @override
  String get autoUi062 => 'To Airport';

  @override
  String get autoUi063 => 'Unable to load default position';

  @override
  String get autoUi064 => 'Unable to load duty rules settings.';

  @override
  String get autoUi065 => 'Unable to load option';

  @override
  String get autoUi066 => 'Use calculated time';

  @override
  String get autoUi067 => 'Visible Time Fields';

  @override
  String get autoUi068 => '→';

  @override
  String get databaseBackupLogbookAction => 'Backup logbook';

  @override
  String get databaseBackupRestoreSubtitle => 'Back up or restore your data.';

  @override
  String get databaseBackupRestoreTitle => 'Backup & Restore';

  @override
  String get databaseDangerZoneSubtitle => 'Irreversible actions.';

  @override
  String get databaseDangerZoneTitle => 'Danger zone';

  @override
  String get databaseDumpTemporaryAction => 'Export debug dump';

  @override
  String get databaseExportCsvAction => 'Export CSV';

  @override
  String get databaseImportExportSubtitle => 'Import or export data files.';

  @override
  String get databaseImportExportTitle => 'Import & Export';

  @override
  String get databaseImportFileAction => 'Import file';

  @override
  String get databaseImportSummaryTitle => 'Import summary';

  @override
  String get databaseImportingTitle => 'Importing data';

  @override
  String get databasePreparingLabel => 'Preparing...';

  @override
  String get databaseRestoreLogbookAction => 'Restore logbook';

  @override
  String get databaseSkippedLinesTitle => 'Skipped lines';

  @override
  String get databaseToolsTitle => 'Tools';

  @override
  String get logtenAssociationHeader => 'Mapped to';

  @override
  String get logtenContinueAction => 'Continue';

  @override
  String get logtenCorrectedValueLabel => 'Corrected value';

  @override
  String get logtenCreateAirportTooltip => 'Create airport';

  @override
  String get logtenEntryTypeLabel => 'Entry type';

  @override
  String get logtenFlightLabel => 'Flight';

  @override
  String get logtenIgnoreAllAction => 'Ignore all';

  @override
  String get logtenIgnoreLineAction => 'Ignore line';

  @override
  String get logtenImportAction => 'Import';

  @override
  String get logtenImportTitle => 'Import LogTen';

  @override
  String get logtenSelectAircraft => 'Select aircraft';

  @override
  String get logtenCreateAircraftTooltip => 'Create aircraft';

  @override
  String get logtenNotSelected => 'Not selected';

  @override
  String get logtenReviewTitle => 'Review LogTen';

  @override
  String get logtenSelectAirportTooltip => 'Select airport';

  @override
  String get logtenSelectArrivalAirport => 'Select arrival airport';

  @override
  String get logtenSelectDepartureAirport => 'Select departure airport';

  @override
  String get logtenSelectedAirport => 'Selected airport';

  @override
  String get logtenSimulatorLabel => 'Simulator';

  @override
  String get logtenSourceColumnHeader => 'Source column';

  @override
  String get logtenTimezoneLabel => 'Time zone';

  @override
  String get qatarContinueAction => 'Continue';

  @override
  String get qatarCreateAircraftAction => 'Create aircraft';

  @override
  String get qatarCreateAirportAction => 'Create airport';

  @override
  String get qatarDefaultPositionLabel => 'Default position';

  @override
  String get qatarImportAction => 'Import';

  @override
  String get qatarImportTitle => 'Import Qatar';

  @override
  String get qatarMissingAircraftTitle => 'Missing aircraft';

  @override
  String get qatarMissingAirportsTitle => 'Missing airports';

  @override
  String get qatarPilotNameAsWrittenLabel => 'Keep pilot name as-is';

  @override
  String get qatarPositionPic => 'PIC';

  @override
  String get qatarPositionSic => 'SIC';

  @override
  String get reportsBatchChangesTitle => 'Batch changes';

  @override
  String get reportsBatchSubtitle => 'Edit multiple entries at once';

  @override
  String get reportsBatchTitle => 'Batch edit';

  @override
  String get reportsCalculateAction => 'Calculate';

  @override
  String get reportsCalculateAll => 'Calculate all';

  @override
  String get reportsCalculateDuty => 'Calculate duty';

  @override
  String get reportsCalculateDutyConfirmTitle => 'Calculate duty';

  @override
  String get reportsCalculatingDutyPeriods => 'Calculating duty periods...';

  @override
  String get reportsCalculatingDutyShort => 'Calculating duty...';

  @override
  String get reportsCheckFlights => 'Check flights';

  @override
  String get reportsCheckingShort => 'Checking flights...';

  @override
  String get reportsChecksTitle => 'Check flights';

  @override
  String get reportsClearAction => 'Clear';

  @override
  String get reportsDeleteTemplateTitle => 'Delete template';

  @override
  String get reportsDownloadAction => 'Download';

  @override
  String get reportsEditPilotProfile => 'Edit pilot profile';

  @override
  String get reportsEditTemplates => 'Edit templates';

  @override
  String get reportsExportInteractiveMap => 'Export map';

  @override
  String get reportsLock => 'Lock';

  @override
  String get reportsNoChangesApplied => 'No changes applied.';

  @override
  String get reportsNoFlightIssuesFound => 'No flight issues found.';

  @override
  String get reportsOpenPdfAfterSaving => 'Open PDF after saving';

  @override
  String get reportsPdfGenerationTitle => 'Print logbook';

  @override
  String get reportsPdfTitle => 'PDF options';

  @override
  String get reportsPreparingBatchData => 'Preparing batch data...';

  @override
  String get reportsRunAction => 'Run';

  @override
  String get reportsSelectAll => 'Select all';

  @override
  String get reportsSetCrew => 'Set crew';

  @override
  String get reportsTabBatch => 'Batch';

  @override
  String get reportsUnlock => 'Unlock';

  @override
  String get reportsUploadJson => 'Upload';

  @override
  String get settingsAppearanceSubtitle => 'Appearance';

  @override
  String get settingsCalculationPilotProfileTitle => 'Pilot Profile';

  @override
  String get settingsTabDatabase => 'Database';

  @override
  String get settingsTabExperience => 'Experience';

  @override
  String get settingsTabGeneral => 'General';

  @override
  String get settingsTabTimeFields => 'Time Fields';

  @override
  String get simplelogConflictResolutionTitle => 'Conflict resolution';

  @override
  String get simplelogCrossCountryLabel => 'Cross-country time';

  @override
  String get simplelogCrossCountryNmLabel => 'Distance threshold (NM)';

  @override
  String get simplelogIfrPercentLabel => 'IFR %';

  @override
  String get simplelogIfrTimeLabel => 'IFR time';

  @override
  String get simplelogImportAction => 'Import';

  @override
  String get simplelogImportOptionsTitle => 'Import SimpleLog';

  @override
  String get simplelogIrp3PercentLabel => 'IRP3 %';

  @override
  String get simplelogIrp3TimeLabel => 'IRP3 time';

  @override
  String get simplelogIrp4PercentLabel => 'IRP4 %';

  @override
  String get simplelogIrp4TimeLabel => 'IRP4 time';

  @override
  String get simplelogNightTimeLabel => 'Night time';

  @override
  String get simplelogOverrideAircraftOnConflict =>
      'Overwrite aircraft on conflict';

  @override
  String get simplelogOverrideAircraftTypeOnConflict =>
      'Overwrite type on conflict';

  @override
  String get simplelogOverrideAirportOnConflict =>
      'Overwrite airport on conflict';

  @override
  String get simplelogRecalcTotalTimeLabel => 'Recalculate total time';

  @override
  String get simplelogRecalculationsTitle => 'Recalculations';

  @override
  String get simplelogTakeoffLandingsLabel => 'Takeoffs and landings';

  @override
  String get southwestAddCopilotStaffNumberLabel => 'Add copilot staff number';

  @override
  String get southwestAddFlightNumberToNotesLabel =>
      'Add flight number to notes';

  @override
  String get southwestCalculateCrossCountryTimeLabel =>
      'Calculate cross-country time';

  @override
  String get southwestCalculateIfrTimeLabel => 'Calculate IFR time';

  @override
  String get southwestCalculateNightTimeLabel => 'Calculate night time';

  @override
  String get southwestCrossCountryThresholdLabel =>
      'Cross-country threshold (NM)';

  @override
  String get southwestDefaultSelfPositionLabel => 'Default self position';

  @override
  String get southwestImportAction => 'Import';

  @override
  String get southwestImportOptionsTitle => 'Import Southwest';

  @override
  String get southwestOverrideExistingDataLabel => 'Overwrite existing data';

  @override
  String get southwestRecalculateBlockTimeLabel => 'Recalculate block time';

  @override
  String get southwestPreflightMissingRequiredTitle =>
      'Missing required fields';

  @override
  String get southwestPreflightMissingRequiredMessage =>
      'Missing required data:';

  @override
  String get southwestPreflightMissingTypeTitle => 'Missing aircraft type';

  @override
  String get southwestPreflightMissingTypeMessage =>
      'Choose how to handle lines with missing aircraft type.';

  @override
  String get southwestPreflightMissingTypeInfoTitle => 'Missing aircraft type';

  @override
  String get southwestPreflightMissingTypeInfoMessage =>
      'Skip Lines will not import the listed lines.\n\nImport Anyway will import those lines and set aircraft type to UNKNOWN.';

  @override
  String get southwestPreflightMissingTailTitle => 'Missing Tail Number';

  @override
  String get southwestPreflightMissingTailMessage =>
      'The following lines are missing Tail Number:';

  @override
  String get southwestPreflightMissingTailInfoTitle => 'Missing tail number';

  @override
  String get southwestPreflightMissingTailInfoMessage =>
      'Skip Lines will not import the listed lines.\n\nImport Anyway will import those lines and create aircraft with tail number equal to the aircraft type.';

  @override
  String get southwestPreflightSkipLinesAction => 'Skip Lines';

  @override
  String get southwestPreflightImportAnywayAction => 'Import Anyway';

  @override
  String get southwestPreflightHowProceedLabel =>
      'How would you like to proceed?';

  @override
  String get southwestPreflightImportUnknownTypeAction =>
      'Import with type UNKNOWN';

  @override
  String get southwestPreflightImportTailFromTypeAction =>
      'Import anyway (tail = type)';

  @override
  String get southwestPreflightFieldDate => 'Date';

  @override
  String get southwestPreflightFieldDepartureAirport => 'Departure airport';

  @override
  String get southwestPreflightFieldArrivalAirport => 'Arrival airport';

  @override
  String get southwestPreflightFieldDepartureTime => 'Departure time';

  @override
  String get southwestPreflightFieldArrivalTime => 'Arrival time';

  @override
  String southwestPreflightMissingFieldsReason(String fields) {
    return 'Missing: $fields';
  }

  @override
  String get southwestPreflightMissingTypeReason => 'Missing aircraft type.';

  @override
  String southwestPreflightMissingTailReason(String typeCode) {
    return 'Missing aircraft tail. Aircraft type: $typeCode.';
  }

  @override
  String get southwestPreflightUnknownTypeLabel => 'UNKNOWN';

  @override
  String databaseAircraftLabel(int count) {
    return 'Aircraft: $count';
  }

  @override
  String databaseAircraftTypesLabel(int count) {
    return 'Aircraft types: $count';
  }

  @override
  String databaseAirportsLabel(int count) {
    return 'Airports: $count';
  }

  @override
  String databaseCrewLabel(int count) {
    return 'Crew: $count';
  }

  @override
  String databaseErrorsLabel(int count) {
    return 'Errors: $count';
  }

  @override
  String databaseFileLabel(String fileName) {
    return 'File: $fileName';
  }

  @override
  String databaseFlightsLabel(int count) {
    return 'Flights: $count';
  }

  @override
  String databaseImportProgressLabel(int processed, int total) {
    return 'Importing $processed of $total';
  }

  @override
  String databaseLineIssueLabel(int lineNumber, String reason) {
    return 'Line $lineNumber: $reason';
  }

  @override
  String databasePositioningsLabel(int count) {
    return 'Positionings: $count';
  }

  @override
  String databaseRowsLabel(int count) {
    return 'Rows: $count';
  }

  @override
  String databaseSimulatorsLabel(int count) {
    return 'Simulators: $count';
  }

  @override
  String databaseSkippedLabel(int count) {
    return 'Skipped: $count';
  }

  @override
  String logtenLineLabel(int lineNumber) {
    return 'Line $lineNumber';
  }

  @override
  String reportsBatchWarning(int count) {
    return 'This action will update $count filtered flights.';
  }

  @override
  String reportsCalculateDutyConfirmBody(int count) {
    return 'Recalculate duty periods for $count flights?';
  }

  @override
  String reportsDeleteTemplateBody(String templateName) {
    return 'Delete template \"$templateName\"?';
  }

  @override
  String reportsIssueCount(int count) {
    return '$count issues';
  }

  @override
  String get onboardingWelcomeTitle => 'Welcome';

  @override
  String get onboardingWelcomeBody =>
      'Set up your profile and default rules to start logging faster.';

  @override
  String get onboardingSkipAction => 'Skip';

  @override
  String get onboardingNextAction => 'Next';

  @override
  String get onboardingBackAction => 'Back';

  @override
  String get onboardingFinishAction => 'Finish';

  @override
  String get onboardingPilotProfileTitle => 'Pilot Profile';

  @override
  String get onboardingPilotProfileBody =>
      'Add your profile details and signature for reports.';

  @override
  String get onboardingRulesTitle => 'Calculation and Duty Rules';

  @override
  String get onboardingRulesBody =>
      'Review calculation factors and duty rules before your first entries.';

  @override
  String get onboardingFieldsTitle => 'Fields';

  @override
  String get onboardingFieldsBody =>
      'Choose which time fields are visible and rename custom fields.';

  @override
  String get newDutyTitle => 'New Duty';

  @override
  String get editDutyTitle => 'Edit Duty';

  @override
  String get newPositioningTitle => 'New Positioning';

  @override
  String get editPositioningTitle => 'Edit Positioning';

  @override
  String get newSimTrainingTitle => 'New Sim Training';

  @override
  String get editSimTrainingTitle => 'Edit Sim Training';

  @override
  String get aircraftRequiredError => 'Aircraft is required.';

  @override
  String get fromAirportRequiredError => 'From Airport is required.';

  @override
  String get toAirportRequiredError => 'To Airport is required.';

  @override
  String get reportsAllEntriesAlreadyLocked =>
      'All filtered entries are already locked.';

  @override
  String get reportsAllEntriesAlreadyUnlocked =>
      'All filtered entries are already unlocked.';

  @override
  String get reportsLockEntriesConfirmTitle => 'Lock entries?';

  @override
  String get reportsUnlockEntriesConfirmTitle => 'Unlock entries?';

  @override
  String reportsLockFilteredEntriesMessage(int count) {
    return 'This will lock $count filtered entries.';
  }

  @override
  String reportsUnlockFilteredEntriesMessage(int count) {
    return 'This will unlock $count filtered entries.';
  }

  @override
  String get previousExperienceValidationTitle => 'Validation warnings';

  @override
  String get previousExperienceSaveAnywayPrompt => 'Save anyway?';

  @override
  String get previousExperienceReviewAction => 'Review';

  @override
  String get previousExperienceSaveAnywayAction => 'Save anyway';

  @override
  String get previousExperienceSelectAircraftType => 'Select aircraft type.';

  @override
  String get previousExperienceFirstFlightRequired =>
      'First Flight is required.';

  @override
  String get previousExperienceLastFlightRequired => 'Last Flight is required.';
}
