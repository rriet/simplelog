// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get appTitle => 'SimpleLog';

  @override
  String get homeTitle => 'SimpleLog';

  @override
  String get addAction => 'Pievienot';

  @override
  String get languageLabel => 'Valoda';

  @override
  String get languageSystem => 'Sistēma';

  @override
  String get languageEnglish => 'Angļu';

  @override
  String get languageSpanish => 'Spāņu';

  @override
  String get screenMenu => 'Ekrāni';

  @override
  String get screenLogbook => 'Lidojumu žurnāls';

  @override
  String get logbookFilterAction => 'Filtri';

  @override
  String get logbookFilterTitle => 'Filtri';

  @override
  String get logbookFilterFromDate => 'No datuma';

  @override
  String get logbookFilterToDate => 'Līdz datumam';

  @override
  String get logbookFilterRange => 'Datumu diapazons';

  @override
  String get logbookFilterApply => 'Lietot filtrus';

  @override
  String get logbookFilterPresetCustom => 'Pielāgots';

  @override
  String get logbookFilterPresetSinceFirstFlight => 'Kopš pirmā lidojuma';

  @override
  String get logbookFilterPresetLast7Days => 'Pēdējās 7 dienas';

  @override
  String get logbookFilterPresetLast14Days => 'Pēdējās 14 dienas';

  @override
  String get logbookFilterPresetLast21Days => 'Pēdējās 21 diena';

  @override
  String get logbookFilterPresetLast28Days => 'Pēdējās 28 dienas';

  @override
  String get logbookFilterPresetLast365Days => 'Pēdējās 365 dienas';

  @override
  String get logbookFilterPresetLastMonth => 'Pagājušais mēnesis';

  @override
  String get logbookFilterPresetLastYear => 'Pagājušais gads';

  @override
  String get logbookFilterPresetCurrentMonth => 'Šis mēnesis';

  @override
  String get logbookFilterPresetCurrentYear => 'Šis gads';

  @override
  String get logbookFilterEventTypes => 'Notikumu veidi';

  @override
  String get logbookFilterAdvanced => 'Papildu filtri (drīzumā)';

  @override
  String get logbookEventFlight => 'Lidojums';

  @override
  String get logbookEventSimulator => 'Simulatora treniņš';

  @override
  String get logbookEventDuty => 'Darba periods';

  @override
  String get logbookEventDutyStart => 'Darba sākums';

  @override
  String get logbookEventDutyEnd => 'Darba beigas';

  @override
  String get logbookEventPositioning => 'Pozicionēšana';

  @override
  String get logbookEventUnknown => 'Notikums';

  @override
  String get screenAircraft => 'Gaisa kuģi';

  @override
  String get screenAircraftTypes => 'Gaisa kuģu tipi';

  @override
  String get screenAirports => 'Lidostas';

  @override
  String get screenCrew => 'Apkalpe';

  @override
  String get screenReports => 'Atskaites';

  @override
  String get screenDatabase => 'Datu bāze';

  @override
  String get screenSettings => 'Iestatījumi';

  @override
  String get searchAircraft => 'Meklēt gaisa kuģi';

  @override
  String get searchCrew => 'Meklēt apkalpi';

  @override
  String get searchAirports => 'Meklēt lidostas';

  @override
  String get searchAircraftTypes => 'Meklēt gaisa kuģu tipus';

  @override
  String get emptyResults => 'Rezultāti nav atrasti';

  @override
  String get lockAction => 'Bloķēt';

  @override
  String get editAction => 'Rediģēt';

  @override
  String get deleteAction => 'Dzēst';

  @override
  String get cancelAction => 'Atcelt';

  @override
  String get confirmDeleteTitle => 'Apstiprināt dzēšanu';

  @override
  String confirmDeleteAircraftType(String code) {
    return 'Dzēst gaisa kuģa tipu $code?';
  }

  @override
  String confirmDeleteAircraft(String registration) {
    return 'Dzēst gaisa kuģi $registration?';
  }

  @override
  String confirmDeleteCrew(String name) {
    return 'Dzēst apkalpes locekli $name?';
  }

  @override
  String confirmDeleteAirport(String icao) {
    return 'Dzēst lidostu $icao?';
  }

  @override
  String get settingsAppearance => 'Izskats';

  @override
  String get settingsDeveloper => 'Izstrādātājs';

  @override
  String get themeSystem => 'Sekot sistēmai';

  @override
  String get themeLight => 'Gaišs';

  @override
  String get themeDark => 'Tumšs';

  @override
  String get editAircraftTypeTitle => 'Rediģēt gaisa kuģa tipu';

  @override
  String get createAircraftTypeTitle => 'Pievienot gaisa kuģa tipu';

  @override
  String get editAircraftTitle => 'Rediģēt gaisa kuģi';

  @override
  String get createAircraftTitle => 'Pievienot gaisa kuģi';

  @override
  String get editCrewTitle => 'Rediģēt apkalpi';

  @override
  String get createCrewTitle => 'Pievienot apkalpi';

  @override
  String get editAirportTitle => 'Rediģēt lidostu';

  @override
  String get createAirportTitle => 'Pievienot lidostu';

  @override
  String get saveAction => 'Saglabāt';

  @override
  String get okAction => 'Labi';

  @override
  String get validationErrorTitle => 'Validācijas kļūda';

  @override
  String get validationErrorGeneric =>
      'Lūdzu, pārbaudiet formu un mēģiniet vēlreiz.';

  @override
  String get codeRequired => 'Kods ir obligāts';

  @override
  String get nameRequired => 'Nosaukums ir obligāts';

  @override
  String get codeDuplicateTitle => 'Dublikāta kods';

  @override
  String codeDuplicateMessage(String code) {
    return 'Kods $code jau pastāv.';
  }

  @override
  String get deleteBlockedTitle => 'Dzēšana bloķēta';

  @override
  String deleteBlockedAircraftType(int count) {
    return 'Šo gaisa kuģa tipu izmanto $count gaisa kuģi un to nevar dzēst.';
  }

  @override
  String get fieldCode => 'Kods';

  @override
  String get fieldRegistration => 'Reģistrācija';

  @override
  String get fieldAircraftType => 'Gaisa kuģa tips';

  @override
  String get fieldFamily => 'Saime';

  @override
  String get fieldLongName => 'Tipa nosaukums';

  @override
  String get fieldManufacturer => 'Ražotājs';

  @override
  String get fieldCategory => 'Kategorija';

  @override
  String get fieldEngineType => 'Dzinēja tips';

  @override
  String get fieldMtow => 'MTOW';

  @override
  String get fieldEngineCount => 'Dzinēju skaits';

  @override
  String get fieldMultiPilot => 'Vairāku pilotu';

  @override
  String get fieldComplex => 'Sarežģīts';

  @override
  String get fieldEfis => 'EFIS';

  @override
  String get fieldHighPerformance => 'Augsta veiktspēja';

  @override
  String get fieldName => 'Vārds';

  @override
  String get fieldEmail => 'E-pasts';

  @override
  String get fieldPhone => 'Tālrunis';

  @override
  String get fieldNotes => 'Piezīmes';

  @override
  String get fieldPicture => 'Attēls';

  @override
  String get pictureHint => 'Noklikšķiniet, lai pievienotu/rediģētu foto';

  @override
  String get photoCamera => 'Kamera';

  @override
  String get photoLibrary => 'Foto bibliotēka';

  @override
  String get removePicture => 'Noņemt foto';

  @override
  String get cropPhotoTitle => 'Rediģēt foto';

  @override
  String get fieldIsSelf => 'Pats';

  @override
  String get fieldIsFavorite => 'Iecienītākais';

  @override
  String get fieldIsSimulator => 'Simulators';

  @override
  String get fieldIcao => 'ICAO';

  @override
  String get fieldIata => 'IATA';

  @override
  String get fieldCity => 'Pilsēta';

  @override
  String get fieldCountry => 'Valsts';

  @override
  String get fieldLatitude => 'Platums';

  @override
  String get fieldLongitude => 'Garums';

  @override
  String get aircraftTypeRequired => 'Izvēlieties gaisa kuģa tipu';

  @override
  String get registrationDuplicateTitle => 'Dublikāta reģistrācija';

  @override
  String registrationDuplicateMessage(String registration) {
    return 'Reģistrācija $registration jau pastāv.';
  }

  @override
  String get nameDuplicateTitle => 'Dublikāta nosaukums';

  @override
  String nameDuplicateMessage(String name) {
    return 'Nosaukums $name jau pastāv.';
  }

  @override
  String get icaoLengthError => 'ICAO jābūt 4 rakstzīmēm';

  @override
  String get icaoDuplicateTitle => 'Dublikāta ICAO';

  @override
  String icaoDuplicateMessage(String icao) {
    return 'ICAO $icao jau pastāv.';
  }

  @override
  String get callNumber => 'Zvanīt';

  @override
  String get textNumber => 'Īsziņa';

  @override
  String get copyNumber => 'Kopēt numuru';

  @override
  String get sendEmail => 'Sūtīt e-pastu';

  @override
  String get copyEmail => 'Kopēt e-pastu';

  @override
  String get seedTestData => 'Ielādēt testa datus';

  @override
  String get seedDataDone => 'Testa dati ievietoti';

  @override
  String get databaseSyncTitle => 'Lokālā sinhronizācija';

  @override
  String get databaseSyncStartLocal => 'Sākt lokālo sinhronizāciju';

  @override
  String get databaseSyncFoundTitle => 'Pieejamās ierīces';

  @override
  String get databaseSyncSearching => 'Meklē ierīces Wi‑Fi tīklā...';

  @override
  String get databaseSyncSendAction => 'Nosūtīt uz ierīci';

  @override
  String get databaseSyncPullAction => 'Ielādēt no ierīces';

  @override
  String get databaseSyncConfirmTitle => 'Apstiprināt pārrakstīšanu';

  @override
  String databaseSyncConfirmMessage(String device) {
    return '⚠️ Tas aizstās visus datus uz $device.';
  }

  @override
  String get databaseSyncConfirmAction => 'Apstiprināt';

  @override
  String databaseSyncConnected(String device) {
    return 'Savienots: $device';
  }

  @override
  String get databaseSyncWaiting => 'Gaida pārsūtīšanu...';

  @override
  String get databaseSyncSchemaMismatchTitle =>
      'Datu bāzes versiju neatbilstība';

  @override
  String databaseSyncSchemaMismatchMessage(Object local, Object remote) {
    return 'Nevar sinhronizēt, jo datu bāzes versijas atšķiras. Šī ierīce izmanto v$local un otra ierīce izmanto v$remote. Atjauniniet abas lietotnes un mēģiniet vēlreiz.';
  }

  @override
  String get databaseSyncCopyDebug => 'Kopēt atkļūdošanas informāciju';

  @override
  String get databaseSyncCopied => 'Atkļūdošanas informācija kopēta';

  @override
  String get databaseSyncLocalServer => 'Lokālais serveris';

  @override
  String get databaseSyncTestServer => 'Testēt lokālo serveri';

  @override
  String get databaseSyncSessionInfo =>
      'Sāciet sesiju vienā ierīcē un pievienojieties no citas.';

  @override
  String get databaseSyncStartSession => 'Sākt sesiju';

  @override
  String get databaseSyncStopSession => 'Apturēt sesiju';

  @override
  String get databaseSyncJoinSession => 'Savienot ierīci';

  @override
  String get databaseSyncHosting => 'Mitina sesiju';

  @override
  String get databaseSyncEnterAddress => 'Ievadiet adresi';

  @override
  String get databaseSyncAddressHint =>
      'simplelog://sync?host=192.168.1.10&port=49200';

  @override
  String get databaseSyncConnectedLabel => 'Savienots ar';

  @override
  String get databaseSyncNotConnected => 'Nav savienots';

  @override
  String get databaseSyncConnectHint =>
      'Lai nosūtītu no šīs ierīces, vispirms izveidojiet savienojumu ar otru ierīci.';

  @override
  String get databaseSyncSend => 'Nosūtīt datu bāzi';

  @override
  String get databaseSyncEnterLastTwo => 'Ievadiet pēdējās divas IP grupas';

  @override
  String get databaseSyncOctet3 => 'Trešā grupa';

  @override
  String get databaseSyncOctet4 => 'Ceturtā grupa';

  @override
  String databaseSyncInstruction(String prefix, String octet3, String octet4) {
    return 'Otrā ierīcē ievadiet tikai pēdējos divus skaitļus: $octet3.$octet4 (prefikss $prefix, ports 54742).';
  }

  @override
  String get databaseSyncSuccess => 'Sinhronizācija pabeigta';

  @override
  String get databaseSyncInvalidSession =>
      'Nevar izveidot savienojumu ar šo sesiju.';

  @override
  String get databaseSyncNoNetwork => 'Lokālā tīkla IP nav atrasts.';

  @override
  String get databaseSyncScanQr => 'Skenēt QR kodu';

  @override
  String get databaseSyncDisconnected => 'Atvienots no otras ierīces.';

  @override
  String get databaseSyncStopWarning =>
      'Apturēšana atvienotu citas ierīces. Turpināt?';

  @override
  String get reportsTabOverview => 'Pārskats';

  @override
  String get reportsTabFlights => 'Lidojumi';

  @override
  String get reportsTabTotals => 'Kopsummas';

  @override
  String get reportsTabAnalyses => 'Analīzes';

  @override
  String get reportsTabReports => 'Atskaites';

  @override
  String get reportsTabFilters => 'Filtri';

  @override
  String get reportsEntryGeneric => 'Ieraksts';

  @override
  String reportsDeleteEntryConfirm(String label) {
    return 'Dzēst $label?';
  }

  @override
  String get reportsDeleteDutyConfirm => 'Dzēst šo darba ierakstu?';

  @override
  String get reportsNoPreviousFlightFound =>
      'Iepriekšējais lidojums nav atrasts.';

  @override
  String get logbookFabReturnFlight => 'Atpakaļ lidojums';

  @override
  String get logbookFabNextFlight => 'Nākamais lidojums';

  @override
  String get reportsStartBeforeEndError =>
      'Sākuma datumam jābūt pirms beigu datuma.';

  @override
  String reportsSavedQuery(String name) {
    return 'Saglabāts vaicājums \"$name\".';
  }

  @override
  String get reportsPdfPreparing => 'Sagatavo PDF...';

  @override
  String get reportsPdfGenerating => 'Ģenerē PDF...';

  @override
  String get reportsPdfSaving => 'Saglabā PDF...';

  @override
  String get reportsPdfDone => 'Gatavs.';

  @override
  String reportsPdfExported(String path) {
    return 'PDF eksportēts uz: $path';
  }

  @override
  String reportsPdfFailed(String error) {
    return 'Neizdevās ģenerēt PDF: $error';
  }

  @override
  String get reportsNoTemplateAvailable => 'Nav pieejama veidne.';

  @override
  String get reportsSavePdfDialogTitle => 'Saglabāt PDF';

  @override
  String get reportsChooseExportFolderTitle => 'Izvēlieties eksporta mapi';

  @override
  String get reportsCancelled => 'Atcelts';

  @override
  String get reportsAnalyzeByLabel => 'Analizēt pēc';

  @override
  String get reportsOrderByLabel => 'Kārtot pēc';

  @override
  String get reportsAnalyzeByAircraft => 'Pēc gaisa kuģa';

  @override
  String get reportsAnalyzeByType => 'Pēc tipa';

  @override
  String get reportsAnalyzeByFamily => 'Pēc saimes';

  @override
  String get reportsAnalyzeByYear => 'Pēc gada';

  @override
  String get reportsAnalyzeByMonth => 'Pēc mēneša';

  @override
  String get reportsOrderByGreater => 'Lielāks';

  @override
  String get reportsOrderByNatural => 'Dabisks';

  @override
  String get reportsShowMap => 'Rādīt karti';

  @override
  String get reportsShowPath => 'Rādīt ceļu';

  @override
  String get reportsIncludeHoursBefore => 'Iekļaut stundas pirms';

  @override
  String get reportsPageSizeLabel => 'Lapas izmērs';

  @override
  String get reportsXmlTemplateLabel => 'XML veidne';

  @override
  String get reportsGeneratingShort => 'Ģenerē...';

  @override
  String get reportsGeneratePdf => 'Ģenerēt PDF';

  @override
  String get reportsDatePresetLastMonthRolling => 'Pēdējais mēnesis (ritošs)';

  @override
  String get reportsUnknown => 'Nezināms';

  @override
  String get reportsUnknownType => 'Nezināms tips';

  @override
  String get reportsUnknownFamily => 'Nezināma saime';

  @override
  String reportsFiltersSummary(int count, String from, String to) {
    return '$count filtri • $from UTC - $to UTC';
  }

  @override
  String get reportsEventSimShort => 'Sim';

  @override
  String get reportsPreviousExperienceLabel => 'Iepriekšējā pieredze';

  @override
  String get reportsInclude => 'Iekļaut';

  @override
  String get reportsExclude => 'Izslēgt';

  @override
  String get reportsMatchModeLabel => 'Atbilstības režīms';

  @override
  String get reportsMatchAll => 'Visi';

  @override
  String get reportsMatchAny => 'Jebkurš';

  @override
  String get reportsAddFilter => 'Pievienot filtru';

  @override
  String reportsFilterChipLabel(String field, String operator, String value) {
    return '$field · $operator · $value';
  }

  @override
  String get reportsSavedQueriesLabel => 'Saglabātie vaicājumi';

  @override
  String get reportsSaveQuery => 'Saglabāt vaicājumu';

  @override
  String reportsDeleteSavedQuery(String name) {
    return 'Dzēst: $name';
  }

  @override
  String get reportsDeleteSavedLabel => 'Dzēst saglabāto';

  @override
  String get reportsMetricIfrApproaches => 'IFR pietuves';

  @override
  String get reportsMetricTakeoffDay => 'Pacelšanās dienā';

  @override
  String get reportsMetricTakeoffNight => 'Pacelšanās naktī';

  @override
  String get reportsMetricLandingDay => 'Nolaišanās dienā';

  @override
  String get reportsMetricLandingNight => 'Nolaišanās naktī';

  @override
  String get reportsMetricTotalBlock => 'Kopējais bloks';

  @override
  String get reportsMetricPic => 'PIC';

  @override
  String get reportsMetricPicus => 'PICUS';

  @override
  String get reportsMetricSic => 'SIC';

  @override
  String get reportsMetricDual => 'Duāls';

  @override
  String get reportsMetricInstructor => 'Instruktors';

  @override
  String get reportsMetricNight => 'Nakts';

  @override
  String get reportsMetricIfr => 'IFR';

  @override
  String get reportsMetricInstrument => 'Instrumenti';

  @override
  String get reportsMetricCrossCountry => 'Šķērskompasā';

  @override
  String get reportsMetricSimulator => 'Simulators';

  @override
  String get reportsMetricDuty => 'Darbs';

  @override
  String get reportsMetricDistanceNm => 'Attālums NM';

  @override
  String reportsFlightCount(String count) {
    return 'Lidojumu skaits: $count';
  }

  @override
  String get reportsNoDataForQuery => 'Nav datu atlasītajam vaicājumam.';

  @override
  String get reportsMetricLandings => 'Nolaišanās';

  @override
  String reportsFirstFlightAt(String date) {
    return 'Pirmais lidojums $date UTC';
  }

  @override
  String reportsLastFlightAt(String date) {
    return 'Pēdējais lidojums $date UTC';
  }

  @override
  String get reportsFieldNameLabel => 'Lauka nosaukums';

  @override
  String get reportsConditionLabel => 'Nosacījums';

  @override
  String get reportsValueLabel => 'Vērtība';

  @override
  String get reportsFlightsAndSimulatorTitle => 'Lidojumi un simulators';

  @override
  String reportsEntriesCount(int count) {
    return '$count ieraksti';
  }

  @override
  String get reportsNoFlightsInPeriod => 'Nav lidojumu/sim atlasītajā periodā.';

  @override
  String get reportsFlightMapTitle => 'Lidojumu karte';

  @override
  String get reportsHideLines => 'Paslēpt līnijas';

  @override
  String get reportsShowLines => 'Rādīt līnijas';

  @override
  String get reportsDone => 'Gatavs';

  @override
  String get reportsNoCoordinatesAvailable => 'Koordinātas nav pieejamas.';

  @override
  String reportsAirportsCount(int count) {
    return 'Lidostas: $count';
  }

  @override
  String get reportsFilterFieldDepartureIcao => 'Izlidošanas ICAO';

  @override
  String get reportsFilterFieldDepartureIata => 'Izlidošanas IATA';

  @override
  String get reportsFilterFieldDepartureName => 'Izlidošanas nosaukums';

  @override
  String get reportsFilterFieldDepartureCity => 'Izlidošanas pilsēta';

  @override
  String get reportsFilterFieldDepartureCountry => 'Izlidošanas valsts';

  @override
  String get reportsFilterFieldArrivalIcao => 'Ielidošanas ICAO';

  @override
  String get reportsFilterFieldArrivalIata => 'Ielidošanas IATA';

  @override
  String get reportsFilterFieldArrivalName => 'Ielidošanas nosaukums';

  @override
  String get reportsFilterFieldArrivalCity => 'Ielidošanas pilsēta';

  @override
  String get reportsFilterFieldArrivalCountry => 'Ielidošanas valsts';

  @override
  String get reportsFilterFieldAircraftRegistration =>
      'Gaisa kuģa reģistrācija';

  @override
  String get reportsFilterFieldAircraftTypeCode => 'Gaisa kuģa tipa kods';

  @override
  String get reportsFilterFieldAircraftTypeFamily => 'Gaisa kuģa tipa saime';

  @override
  String get reportsFilterFieldAircraftTypeName => 'Gaisa kuģa tipa nosaukums';

  @override
  String get reportsFilterFieldPilotName => 'Pilota vārds';

  @override
  String get reportsFilterFieldPilotOnBoard => 'Pilots uz klāja';

  @override
  String get reportsFilterFieldPilotPic => 'Pilots PIC';

  @override
  String get reportsFilterFieldPilotSic => 'Pilots SIC';

  @override
  String get reportsFilterFieldPilotTrainee => 'Pilots praktikants';

  @override
  String get reportsFilterFieldApproachType => 'Pietuves tips';

  @override
  String get reportsFilterFieldRemarks => 'Piezīmes';

  @override
  String get reportsFilterFieldNotes => 'Piezīmes';

  @override
  String get reportsFilterFieldBlockTime => 'Bloka laiks';

  @override
  String get reportsFilterFieldFlightTime => 'Lidojuma laiks';

  @override
  String get reportsFilterFieldTotalTime => 'Kopējais laiks';

  @override
  String get reportsFilterFieldNightTime => 'Nakts laiks';

  @override
  String get reportsFilterFieldIfrTime => 'IFR laiks';

  @override
  String get reportsFilterFieldInstrumentTime => 'Instrumentu laiks';

  @override
  String get reportsFilterFieldSimInstrumentTime => 'Sim instrumentu laiks';

  @override
  String get reportsFilterFieldPicTime => 'PIC laiks';

  @override
  String get reportsFilterFieldPicusTime => 'PICUS laiks';

  @override
  String get reportsFilterFieldSicTime => 'SIC laiks';

  @override
  String get reportsFilterFieldDualTime => 'Duālais laiks';

  @override
  String get reportsFilterFieldInstructorTime => 'Instruktora laiks';

  @override
  String get reportsFilterFieldCrossCountryTime => 'Šķērskompasa laiks';

  @override
  String get reportsFilterFieldCustom1Time => 'Pielāgots 1 laiks';

  @override
  String get reportsFilterFieldCustom2Time => 'Pielāgots 2 laiks';

  @override
  String get reportsFilterFieldCustom3Time => 'Pielāgots 3 laiks';

  @override
  String get reportsFilterFieldCustom4Time => 'Pielāgots 4 laiks';

  @override
  String get reportsFilterFieldDistanceNm => 'Attālums NM';

  @override
  String get reportsFilterFieldTakeoffs => 'Pacelšanās';

  @override
  String get reportsFilterFieldTakeoffsDay => 'Pacelšanās dienā';

  @override
  String get reportsFilterFieldTakeoffsNight => 'Pacelšanās naktī';

  @override
  String get reportsFilterFieldLandings => 'Nolaišanās';

  @override
  String get reportsFilterFieldLandingsDay => 'Nolaišanās dienā';

  @override
  String get reportsFilterFieldLandingsNight => 'Nolaišanās naktī';

  @override
  String get reportsFilterFieldIfrApproaches => 'IFR pietuves';

  @override
  String get reportsFilterFieldMultiPilot => 'Vairāku pilotu';

  @override
  String get reportsFilterFieldSimulator => 'Simulators';

  @override
  String get reportsFilterOperatorContains => 'Satur';

  @override
  String get reportsFilterOperatorDoesNotContain => 'Nesatur';

  @override
  String get reportsFilterOperatorStartsWith => 'Sākas ar';

  @override
  String get reportsFilterOperatorDoesNotStartWith => 'Nesākas ar';

  @override
  String get reportsFilterOperatorEndsWith => 'Beidzas ar';

  @override
  String get reportsFilterOperatorDoesNotEndWith => 'Nebeidzas ar';

  @override
  String get reportsFilterOperatorIs => 'Ir';

  @override
  String get reportsFilterOperatorIsNot => 'Nav';

  @override
  String get reportsFilterOperatorGreaterThan => 'Lielāks par';

  @override
  String get reportsFilterOperatorLessThan => 'Mazāks par';

  @override
  String get reportsFilterOperatorEquals => 'Vienāds ar';

  @override
  String get reportsFilterOperatorIsTrue => 'Ir patiess';

  @override
  String get reportsFilterOperatorIsFalse => 'Ir nepatiess';

  @override
  String get languageLatvian => 'Latviešu';

  @override
  String get reportsAnalyzeByAirport => 'Pēc lidostas';

  @override
  String get reportsAnalyzeByPilot => 'Pēc pilota';

  @override
  String get reportsUnknownAirport => 'Nezināma lidosta';

  @override
  String get reportsUnknownPilot => 'Nezināms pilots';

  @override
  String get reportsOrderByHours => 'Stundas';

  @override
  String get reportsOrderByLandings => 'Nosēšanās';

  @override
  String get reportsOrderByTakeoff => 'Pacelšanās';

  @override
  String get reportsOrderByOperations => 'Operācijas';

  @override
  String get reportsMetricTakeoff => 'Pacelšanās';

  @override
  String get reportsMetricOperations => 'Operācijas';

  @override
  String get aircraftFiltersTitle => 'Lidaparātu filtri';

  @override
  String get crewFiltersTitle => 'Apkalpes filtri';

  @override
  String get airportFiltersTitle => 'Lidostu filtri';

  @override
  String get searchByLabel => 'Meklēt pēc';

  @override
  String get orderByLabel => 'Kārtot pēc';

  @override
  String get optionAll => 'Visi';

  @override
  String get searchFieldType => 'Tips';

  @override
  String get applyAction => 'Piemērot';

  @override
  String get fieldTakeoffs => 'Pacelšanās';

  @override
  String get fieldLandings => 'Nosēšanās';

  @override
  String get fieldVisits => 'Operācijas';

  @override
  String get airportShowOnlyVisited => 'Rādīt tikai apmeklētās lidostas';

  @override
  String get airportSearchIcaoOrIata => 'ICAO vai IATA';

  @override
  String get summaryFirstFlight => 'Pirmais lidojums';

  @override
  String get summaryLastFlight => 'Pēdējais lidojums';

  @override
  String get summaryTotalTime => 'Kopējais laiks';

  @override
  String get summaryTotalPic => 'PIC kopā';

  @override
  String get notAvailableShort => '-';

  @override
  String get fieldCrew => 'Apkalpe';

  @override
  String get addCrewTitle => 'Pievienot apkalpi';

  @override
  String get selectCrewTitle => 'Izvēlēties apkalpi';

  @override
  String get crewPositionLabel => 'Pozīcija';

  @override
  String get crewPositionPic => 'PIC';

  @override
  String get crewPositionPicus => 'PICUS';

  @override
  String get crewPositionSic => 'SIC';

  @override
  String get crewPositionTrainee => 'Praktikants';

  @override
  String get crewPositionInstructor => 'Instruktors';

  @override
  String get crewPositionObserver => 'Novērotājs';

  @override
  String get crewPositionRelief => 'Maiņas pilots';

  @override
  String get crewPositionReliefCaptain => 'Maiņas kapteinis';

  @override
  String get crewPositionReliefFirstOfficer => 'Maiņas otrais pilots';

  @override
  String get crewPositionCabinSenior => 'Vecākais kabīnē';

  @override
  String get crewPositionCabinCrew => 'Kabīnes apkalpe';

  @override
  String get crewPositionOther => 'Cits';

  @override
  String get crewPositionUnknown => 'Nezināms';

  @override
  String get searchRegistration => 'Meklēt reģistrāciju';

  @override
  String get searchType => 'Meklēt tipu';

  @override
  String get searchFamily => 'Meklēt saimi';

  @override
  String get searchNotes => 'Meklēt piezīmes';

  @override
  String get searchName => 'Meklēt nosaukumu';

  @override
  String get searchCity => 'Meklēt pilsētu';

  @override
  String get searchCountry => 'Meklēt valsti';

  @override
  String get searchIcao => 'Meklēt ICAO';

  @override
  String get searchIata => 'Meklēt IATA';

  @override
  String get searchIcaoIata => 'Meklēt ICAO/IATA';

  @override
  String get createSimulatorTitle => 'Pievienot simulatoru';

  @override
  String get mapTitle => 'Karte';

  @override
  String get aircraftEmptyResults => 'Lidaparāti nav atrasti';

  @override
  String get crewEmptyResults => 'Apkalpe nav atrasta';

  @override
  String get crewLoadError => 'Kļūda ielādējot apkalpi';

  @override
  String get airportEmptyResults => 'Lidostas nav atrastas';

  @override
  String get airportLoadError => 'Kļūda ielādējot lidostas';

  @override
  String get errorLabel => 'Kļūda';

  @override
  String get dashboardTitle => 'Panelis';

  @override
  String get dashboardNoActiveRules => 'Nav konfigurētu aktīvu noteikumu.';

  @override
  String get dashboardRuleTotals => 'Noteikuma kopsummas';

  @override
  String get dashboardNoData => 'Nav datu.';

  @override
  String get dashboardEventsInCalculation => 'Aprēķinā iekļautie notikumi';

  @override
  String get dashboardNoEventsInWindow => 'Šajā logā nav notikumu.';

  @override
  String get dashboardFlightsLabel => 'Lidojumi';

  @override
  String get dashboardBlockLabel => 'Bloka laiks';

  @override
  String get dashboardFlightLabel => 'Lidojuma laiks';

  @override
  String get dashboardNightLabel => 'Nakts';

  @override
  String get dashboardIfrLabel => 'IFR';

  @override
  String get dashboardInstrumentLabel => 'Instrumentālais';

  @override
  String get dashboardDutyLabel => 'Dežūra';

  @override
  String get dashboardLandingsLabel => 'Nosēšanās';

  @override
  String get dashboardSetupTitle => 'Paneļa iestatījumi';

  @override
  String get dashboardAddRule => 'Pievienot noteikumu';

  @override
  String get dashboardNoRulesConfigured => 'Nav konfigurētu noteikumu.';

  @override
  String get dashboardEditRuleTitle => 'Rediģēt noteikumu';

  @override
  String get dashboardCreateRuleTitle => 'Izveidot noteikumu';

  @override
  String get dashboardRuleNameLabel => 'Noteikuma nosaukums';

  @override
  String get dashboardMetricLabel => 'Metrika';

  @override
  String get dashboardRuleTypeLabel => 'Noteikuma veids';

  @override
  String get dashboardWindowTypeLabel => 'Loga tips';

  @override
  String get dashboardStartReferenceLabel => 'Sākuma atskaite';

  @override
  String get dashboardWindowValueLabel => 'Loga vērtība';

  @override
  String get dashboardLimitValueLabel => 'Limita vērtība';

  @override
  String get dashboardUnitLabel => 'Mērvienība';

  @override
  String get dashboardWarnYellowBeforeLabel => 'Dzeltenais brīdinājums pirms';

  @override
  String get dashboardWarnRedBeforeLabel => 'Sarkanais brīdinājums pirms';

  @override
  String get dashboardCreateAction => 'Izveidot';

  @override
  String get dashboardTakeoffLabel => 'Pacelšanās';

  @override
  String get dashboardTakeoffDayLabel => 'Pacelšanās dienā';

  @override
  String get dashboardTakeoffNightLabel => 'Pacelšanās naktī';

  @override
  String get dashboardLandingsDayLabel => 'Nosēšanās dienā';

  @override
  String get dashboardLandingsNightLabel => 'Nosēšanās naktī';

  @override
  String get dashboardInstrumentApproachesLabel => 'Instrumentālās pieejas';

  @override
  String get dashboardPicTimeLabel => 'PIC laiks';

  @override
  String get dashboardSicTimeLabel => 'SIC laiks';

  @override
  String get dashboardPicusTimeLabel => 'PICUS laiks';

  @override
  String get dashboardDualTimeLabel => 'Duālais laiks';

  @override
  String get dashboardInstructorTimeLabel => 'Instruktora laiks';

  @override
  String get dashboardCrossCountryLabel => 'Pārlidojums';

  @override
  String get dashboardMinimumLabel => 'Minimums';

  @override
  String get dashboardMaximumLabel => 'Maksimums';

  @override
  String get dashboardHoursUnit => 'stundas';

  @override
  String get dashboardMinutesUnit => 'minūtes';

  @override
  String get dashboardDaysUnit => 'dienas';

  @override
  String get dashboardWeeksUnit => 'nedēļas';

  @override
  String get dashboardMonthsUnit => 'mēneši';

  @override
  String get dashboardYearsUnit => 'gadi';

  @override
  String get dashboardCountUnit => 'skaits';

  @override
  String get dashboardCalendarMonthsLabel => 'Kalendārie mēneši';

  @override
  String get dashboardCalendarYearsLabel => 'Kalendārie gadi';

  @override
  String get dashboardCalendarDaysLabel => 'Kalendārās dienas';

  @override
  String get dashboardCalendarQuarterLabel => 'Kalendārais ceturksnis';

  @override
  String get dashboardSameTimeNowLabel => 'Tas pats laiks (tagad)';

  @override
  String get dashboardMidnightLocalLabel => 'Vietējā pusnakts';

  @override
  String get dashboardMidnightUtcLabel => 'UTC pusnakts';

  @override
  String get dashboardRemainingSuffix => 'atlikums';

  @override
  String get dashboardOverLimitSuffix => 'virs limita';

  @override
  String get dashboardAboveMinimumSuffix => 'virs minimuma';

  @override
  String get dashboardBelowMinimumSuffix => 'zem minimuma';

  @override
  String get dashboardMinimumShortLabel => 'Min';

  @override
  String get dashboardMaximumShortLabel => 'Maks';

  @override
  String get dashboardSameTimeLabel => 'Tas pats laiks';

  @override
  String get checkFactoringRulesTitle => 'Pārbaudīt aprēķina noteikumus';

  @override
  String get continueSavingQuestion => 'Turpināt saglabāšanu?';

  @override
  String get reviewAction => 'Pārskatīt';

  @override
  String get saveAnywayAction => 'Saglabāt tik un tā';

  @override
  String get createFlightTitle => 'Jauns lidojums';

  @override
  String get editFlightTitle => 'Rediģēt lidojumu';

  @override
  String get calculateAction => 'Aprēķināt';

  @override
  String get nextAction => 'Tālāk';

  @override
  String get fieldDate => 'Datums';

  @override
  String get fieldPilotFunction => 'Pilota funkcija';

  @override
  String get chocksOffRequiredToCalculate =>
      'Lai aprēķinātu, jānorāda Chocks OFF.';

  @override
  String get chocksOnRequiredToCalculate =>
      'Lai aprēķinātu, jānorāda Chocks ON.';

  @override
  String get clearAction => 'Notīrīt';

  @override
  String get fieldRemarks => 'Piezīmes';

  @override
  String get noCrewAssigned => 'Nav piešķirtas apkalpes';

  @override
  String get removeAction => 'Noņemt';

  @override
  String get eventInfoTitle => 'Notikuma informācija';

  @override
  String get clearDatabaseTitle => 'Notīrīt datubāzi';

  @override
  String get clearDatabaseMessage =>
      'Tas dzēsīs visus datus un izveidos tukšas tabulas no jauna.';

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
