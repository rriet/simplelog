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
  String get themeSystem => 'Follow system';

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
}
