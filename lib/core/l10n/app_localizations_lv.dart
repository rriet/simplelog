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
}
