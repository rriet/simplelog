import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_lv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('lv'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SimpleLog'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'SimpleLog'**
  String get homeTitle;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @screenMenu.
  ///
  /// In en, this message translates to:
  /// **'Screens'**
  String get screenMenu;

  /// No description provided for @screenLogbook.
  ///
  /// In en, this message translates to:
  /// **'Logbook'**
  String get screenLogbook;

  /// No description provided for @logbookFilterAction.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get logbookFilterAction;

  /// No description provided for @logbookFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get logbookFilterTitle;

  /// No description provided for @logbookFilterFromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get logbookFilterFromDate;

  /// No description provided for @logbookFilterToDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get logbookFilterToDate;

  /// No description provided for @logbookFilterRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get logbookFilterRange;

  /// No description provided for @logbookFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get logbookFilterApply;

  /// No description provided for @logbookFilterPresetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get logbookFilterPresetCustom;

  /// No description provided for @logbookFilterPresetSinceFirstFlight.
  ///
  /// In en, this message translates to:
  /// **'Since first flight'**
  String get logbookFilterPresetSinceFirstFlight;

  /// No description provided for @logbookFilterPresetLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get logbookFilterPresetLast7Days;

  /// No description provided for @logbookFilterPresetLast14Days.
  ///
  /// In en, this message translates to:
  /// **'Last 14 days'**
  String get logbookFilterPresetLast14Days;

  /// No description provided for @logbookFilterPresetLast21Days.
  ///
  /// In en, this message translates to:
  /// **'Last 21 days'**
  String get logbookFilterPresetLast21Days;

  /// No description provided for @logbookFilterPresetLast28Days.
  ///
  /// In en, this message translates to:
  /// **'Last 28 days'**
  String get logbookFilterPresetLast28Days;

  /// No description provided for @logbookFilterPresetLast365Days.
  ///
  /// In en, this message translates to:
  /// **'Last 365 days'**
  String get logbookFilterPresetLast365Days;

  /// No description provided for @logbookFilterPresetLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get logbookFilterPresetLastMonth;

  /// No description provided for @logbookFilterPresetLastYear.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get logbookFilterPresetLastYear;

  /// No description provided for @logbookFilterPresetCurrentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current month'**
  String get logbookFilterPresetCurrentMonth;

  /// No description provided for @logbookFilterPresetCurrentYear.
  ///
  /// In en, this message translates to:
  /// **'Current year'**
  String get logbookFilterPresetCurrentYear;

  /// No description provided for @logbookFilterEventTypes.
  ///
  /// In en, this message translates to:
  /// **'Event types'**
  String get logbookFilterEventTypes;

  /// No description provided for @logbookFilterAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters (coming soon)'**
  String get logbookFilterAdvanced;

  /// No description provided for @logbookEventFlight.
  ///
  /// In en, this message translates to:
  /// **'Flight'**
  String get logbookEventFlight;

  /// No description provided for @logbookEventSimulator.
  ///
  /// In en, this message translates to:
  /// **'Simulator training'**
  String get logbookEventSimulator;

  /// No description provided for @logbookEventDuty.
  ///
  /// In en, this message translates to:
  /// **'Duty period'**
  String get logbookEventDuty;

  /// No description provided for @logbookEventDutyStart.
  ///
  /// In en, this message translates to:
  /// **'Duty start'**
  String get logbookEventDutyStart;

  /// No description provided for @logbookEventDutyEnd.
  ///
  /// In en, this message translates to:
  /// **'Duty end'**
  String get logbookEventDutyEnd;

  /// No description provided for @logbookEventPositioning.
  ///
  /// In en, this message translates to:
  /// **'Positioning'**
  String get logbookEventPositioning;

  /// No description provided for @logbookEventUnknown.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get logbookEventUnknown;

  /// No description provided for @screenAircraft.
  ///
  /// In en, this message translates to:
  /// **'Aircraft'**
  String get screenAircraft;

  /// No description provided for @screenAircraftTypes.
  ///
  /// In en, this message translates to:
  /// **'Aircraft Types'**
  String get screenAircraftTypes;

  /// No description provided for @screenAirports.
  ///
  /// In en, this message translates to:
  /// **'Airports'**
  String get screenAirports;

  /// No description provided for @screenCrew.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get screenCrew;

  /// No description provided for @screenReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get screenReports;

  /// No description provided for @screenDatabase.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get screenDatabase;

  /// No description provided for @screenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get screenSettings;

  /// No description provided for @searchAircraft.
  ///
  /// In en, this message translates to:
  /// **'Search aircraft'**
  String get searchAircraft;

  /// No description provided for @searchCrew.
  ///
  /// In en, this message translates to:
  /// **'Search crew'**
  String get searchCrew;

  /// No description provided for @searchAirports.
  ///
  /// In en, this message translates to:
  /// **'Search airports'**
  String get searchAirports;

  /// No description provided for @searchAircraftTypes.
  ///
  /// In en, this message translates to:
  /// **'Search aircraft types'**
  String get searchAircraftTypes;

  /// No description provided for @emptyResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get emptyResults;

  /// No description provided for @lockAction.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lockAction;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteAircraftType.
  ///
  /// In en, this message translates to:
  /// **'Delete aircraft type {code}?'**
  String confirmDeleteAircraftType(String code);

  /// No description provided for @confirmDeleteAircraft.
  ///
  /// In en, this message translates to:
  /// **'Delete aircraft {registration}?'**
  String confirmDeleteAircraft(String registration);

  /// No description provided for @confirmDeleteCrew.
  ///
  /// In en, this message translates to:
  /// **'Delete crew member {name}?'**
  String confirmDeleteCrew(String name);

  /// No description provided for @confirmDeleteAirport.
  ///
  /// In en, this message translates to:
  /// **'Delete airport {icao}?'**
  String confirmDeleteAirport(String icao);

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsDeveloper;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @editAircraftTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit aircraft type'**
  String get editAircraftTypeTitle;

  /// No description provided for @createAircraftTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add aircraft type'**
  String get createAircraftTypeTitle;

  /// No description provided for @editAircraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit aircraft'**
  String get editAircraftTitle;

  /// No description provided for @createAircraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Add aircraft'**
  String get createAircraftTitle;

  /// No description provided for @editCrewTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit crew'**
  String get editCrewTitle;

  /// No description provided for @createCrewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add crew'**
  String get createCrewTitle;

  /// No description provided for @editAirportTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit airport'**
  String get editAirportTitle;

  /// No description provided for @createAirportTitle.
  ///
  /// In en, this message translates to:
  /// **'Add airport'**
  String get createAirportTitle;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @okAction.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okAction;

  /// No description provided for @validationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get validationErrorTitle;

  /// No description provided for @validationErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Please check the form and try again.'**
  String get validationErrorGeneric;

  /// No description provided for @codeRequired.
  ///
  /// In en, this message translates to:
  /// **'Code is required'**
  String get codeRequired;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @codeDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate code'**
  String get codeDuplicateTitle;

  /// No description provided for @codeDuplicateMessage.
  ///
  /// In en, this message translates to:
  /// **'Code {code} already exists.'**
  String codeDuplicateMessage(String code);

  /// No description provided for @deleteBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete blocked'**
  String get deleteBlockedTitle;

  /// No description provided for @deleteBlockedAircraftType.
  ///
  /// In en, this message translates to:
  /// **'This aircraft type is used by {count} aircraft and can\'t be deleted.'**
  String deleteBlockedAircraftType(int count);

  /// No description provided for @fieldCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get fieldCode;

  /// No description provided for @fieldRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get fieldRegistration;

  /// No description provided for @fieldAircraftType.
  ///
  /// In en, this message translates to:
  /// **'Aircraft type'**
  String get fieldAircraftType;

  /// No description provided for @fieldFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get fieldFamily;

  /// No description provided for @fieldLongName.
  ///
  /// In en, this message translates to:
  /// **'Type Name'**
  String get fieldLongName;

  /// No description provided for @fieldManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get fieldManufacturer;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @fieldEngineType.
  ///
  /// In en, this message translates to:
  /// **'Engine type'**
  String get fieldEngineType;

  /// No description provided for @fieldMtow.
  ///
  /// In en, this message translates to:
  /// **'MTOW'**
  String get fieldMtow;

  /// No description provided for @fieldEngineCount.
  ///
  /// In en, this message translates to:
  /// **'Engine count'**
  String get fieldEngineCount;

  /// No description provided for @fieldMultiPilot.
  ///
  /// In en, this message translates to:
  /// **'Multi-pilot'**
  String get fieldMultiPilot;

  /// No description provided for @fieldComplex.
  ///
  /// In en, this message translates to:
  /// **'Complex'**
  String get fieldComplex;

  /// No description provided for @fieldEfis.
  ///
  /// In en, this message translates to:
  /// **'EFIS'**
  String get fieldEfis;

  /// No description provided for @fieldHighPerformance.
  ///
  /// In en, this message translates to:
  /// **'High performance'**
  String get fieldHighPerformance;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @fieldPicture.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get fieldPicture;

  /// No description provided for @pictureHint.
  ///
  /// In en, this message translates to:
  /// **'Click to add/edit photo'**
  String get pictureHint;

  /// No description provided for @photoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get photoCamera;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get photoLibrary;

  /// No description provided for @removePicture.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePicture;

  /// No description provided for @cropPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit photo'**
  String get cropPhotoTitle;

  /// No description provided for @fieldIsSelf.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get fieldIsSelf;

  /// No description provided for @fieldIsFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get fieldIsFavorite;

  /// No description provided for @fieldIsSimulator.
  ///
  /// In en, this message translates to:
  /// **'Simulator'**
  String get fieldIsSimulator;

  /// No description provided for @fieldIcao.
  ///
  /// In en, this message translates to:
  /// **'ICAO'**
  String get fieldIcao;

  /// No description provided for @fieldIata.
  ///
  /// In en, this message translates to:
  /// **'IATA'**
  String get fieldIata;

  /// No description provided for @fieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get fieldCity;

  /// No description provided for @fieldCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get fieldCountry;

  /// No description provided for @fieldLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get fieldLatitude;

  /// No description provided for @fieldLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get fieldLongitude;

  /// No description provided for @aircraftTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select an aircraft type'**
  String get aircraftTypeRequired;

  /// No description provided for @registrationDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate registration'**
  String get registrationDuplicateTitle;

  /// No description provided for @registrationDuplicateMessage.
  ///
  /// In en, this message translates to:
  /// **'Registration {registration} already exists.'**
  String registrationDuplicateMessage(String registration);

  /// No description provided for @nameDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate name'**
  String get nameDuplicateTitle;

  /// No description provided for @nameDuplicateMessage.
  ///
  /// In en, this message translates to:
  /// **'Name {name} already exists.'**
  String nameDuplicateMessage(String name);

  /// No description provided for @icaoLengthError.
  ///
  /// In en, this message translates to:
  /// **'ICAO must be 4 characters'**
  String get icaoLengthError;

  /// No description provided for @icaoDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate ICAO'**
  String get icaoDuplicateTitle;

  /// No description provided for @icaoDuplicateMessage.
  ///
  /// In en, this message translates to:
  /// **'ICAO {icao} already exists.'**
  String icaoDuplicateMessage(String icao);

  /// No description provided for @callNumber.
  ///
  /// In en, this message translates to:
  /// **'Call number'**
  String get callNumber;

  /// No description provided for @textNumber.
  ///
  /// In en, this message translates to:
  /// **'Text message'**
  String get textNumber;

  /// No description provided for @copyNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy number'**
  String get copyNumber;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get sendEmail;

  /// No description provided for @copyEmail.
  ///
  /// In en, this message translates to:
  /// **'Copy email'**
  String get copyEmail;

  /// No description provided for @seedTestData.
  ///
  /// In en, this message translates to:
  /// **'Seed test data'**
  String get seedTestData;

  /// No description provided for @seedDataDone.
  ///
  /// In en, this message translates to:
  /// **'Test data inserted'**
  String get seedDataDone;

  /// No description provided for @databaseSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Local sync'**
  String get databaseSyncTitle;

  /// No description provided for @databaseSyncStartLocal.
  ///
  /// In en, this message translates to:
  /// **'Start Local Sync'**
  String get databaseSyncStartLocal;

  /// No description provided for @databaseSyncFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Available devices'**
  String get databaseSyncFoundTitle;

  /// No description provided for @databaseSyncSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching for devices on Wi‑Fi...'**
  String get databaseSyncSearching;

  /// No description provided for @databaseSyncSendAction.
  ///
  /// In en, this message translates to:
  /// **'Send to device'**
  String get databaseSyncSendAction;

  /// No description provided for @databaseSyncPullAction.
  ///
  /// In en, this message translates to:
  /// **'Pull from device'**
  String get databaseSyncPullAction;

  /// No description provided for @databaseSyncConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm overwrite'**
  String get databaseSyncConfirmTitle;

  /// No description provided for @databaseSyncConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'⚠️ This will replace all data on {device}.'**
  String databaseSyncConfirmMessage(String device);

  /// No description provided for @databaseSyncConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get databaseSyncConfirmAction;

  /// No description provided for @databaseSyncConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected: {device}'**
  String databaseSyncConnected(String device);

  /// No description provided for @databaseSyncWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for transfer...'**
  String get databaseSyncWaiting;

  /// No description provided for @databaseSyncSchemaMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Database version mismatch'**
  String get databaseSyncSchemaMismatchTitle;

  /// No description provided for @databaseSyncSchemaMismatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot sync because the database versions differ. This device uses v{local} and the other device uses v{remote}. Update both apps and try again.'**
  String databaseSyncSchemaMismatchMessage(Object local, Object remote);

  /// No description provided for @databaseSyncCopyDebug.
  ///
  /// In en, this message translates to:
  /// **'Copy debug info'**
  String get databaseSyncCopyDebug;

  /// No description provided for @databaseSyncCopied.
  ///
  /// In en, this message translates to:
  /// **'Debug info copied'**
  String get databaseSyncCopied;

  /// No description provided for @databaseSyncLocalServer.
  ///
  /// In en, this message translates to:
  /// **'Local server'**
  String get databaseSyncLocalServer;

  /// No description provided for @databaseSyncTestServer.
  ///
  /// In en, this message translates to:
  /// **'Test local server'**
  String get databaseSyncTestServer;

  /// No description provided for @databaseSyncSessionInfo.
  ///
  /// In en, this message translates to:
  /// **'Start a session on one device and join from another.'**
  String get databaseSyncSessionInfo;

  /// No description provided for @databaseSyncStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get databaseSyncStartSession;

  /// No description provided for @databaseSyncStopSession.
  ///
  /// In en, this message translates to:
  /// **'Stop session'**
  String get databaseSyncStopSession;

  /// No description provided for @databaseSyncJoinSession.
  ///
  /// In en, this message translates to:
  /// **'Connect device'**
  String get databaseSyncJoinSession;

  /// No description provided for @databaseSyncHosting.
  ///
  /// In en, this message translates to:
  /// **'Hosting session'**
  String get databaseSyncHosting;

  /// No description provided for @databaseSyncEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get databaseSyncEnterAddress;

  /// No description provided for @databaseSyncAddressHint.
  ///
  /// In en, this message translates to:
  /// **'simplelog://sync?host=192.168.1.10&port=49200'**
  String get databaseSyncAddressHint;

  /// No description provided for @databaseSyncConnectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Connected to'**
  String get databaseSyncConnectedLabel;

  /// No description provided for @databaseSyncNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get databaseSyncNotConnected;

  /// No description provided for @databaseSyncConnectHint.
  ///
  /// In en, this message translates to:
  /// **'To send from this device, connect to the other device first.'**
  String get databaseSyncConnectHint;

  /// No description provided for @databaseSyncSend.
  ///
  /// In en, this message translates to:
  /// **'Send database'**
  String get databaseSyncSend;

  /// No description provided for @databaseSyncEnterLastTwo.
  ///
  /// In en, this message translates to:
  /// **'Enter last two IP groups'**
  String get databaseSyncEnterLastTwo;

  /// No description provided for @databaseSyncOctet3.
  ///
  /// In en, this message translates to:
  /// **'Third group'**
  String get databaseSyncOctet3;

  /// No description provided for @databaseSyncOctet4.
  ///
  /// In en, this message translates to:
  /// **'Fourth group'**
  String get databaseSyncOctet4;

  /// No description provided for @databaseSyncInstruction.
  ///
  /// In en, this message translates to:
  /// **'On the other device, enter only the last two numbers: {octet3}.{octet4} (prefix {prefix}, port 54742).'**
  String databaseSyncInstruction(String prefix, String octet3, String octet4);

  /// No description provided for @databaseSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get databaseSyncSuccess;

  /// No description provided for @databaseSyncInvalidSession.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to that session.'**
  String get databaseSyncInvalidSession;

  /// No description provided for @databaseSyncNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No local network IP found.'**
  String get databaseSyncNoNetwork;

  /// No description provided for @databaseSyncScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get databaseSyncScanQr;

  /// No description provided for @databaseSyncDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from the other device.'**
  String get databaseSyncDisconnected;

  /// No description provided for @databaseSyncStopWarning.
  ///
  /// In en, this message translates to:
  /// **'Stopping will disconnect other devices. Continue?'**
  String get databaseSyncStopWarning;

  /// No description provided for @reportsTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get reportsTabOverview;

  /// No description provided for @reportsTabFlights.
  ///
  /// In en, this message translates to:
  /// **'Flights'**
  String get reportsTabFlights;

  /// No description provided for @reportsTabTotals.
  ///
  /// In en, this message translates to:
  /// **'Totals'**
  String get reportsTabTotals;

  /// No description provided for @reportsTabAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Analyses'**
  String get reportsTabAnalyses;

  /// No description provided for @reportsTabReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTabReports;

  /// No description provided for @reportsTabFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get reportsTabFilters;

  /// No description provided for @reportsEntryGeneric.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get reportsEntryGeneric;

  /// No description provided for @reportsDeleteEntryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {label}?'**
  String reportsDeleteEntryConfirm(String label);

  /// No description provided for @reportsDeleteDutyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this duty entry?'**
  String get reportsDeleteDutyConfirm;

  /// No description provided for @reportsNoPreviousFlightFound.
  ///
  /// In en, this message translates to:
  /// **'No previous flight found.'**
  String get reportsNoPreviousFlightFound;

  /// No description provided for @logbookFabReturnFlight.
  ///
  /// In en, this message translates to:
  /// **'Return Flight'**
  String get logbookFabReturnFlight;

  /// No description provided for @logbookFabNextFlight.
  ///
  /// In en, this message translates to:
  /// **'Next Flight'**
  String get logbookFabNextFlight;

  /// No description provided for @reportsStartBeforeEndError.
  ///
  /// In en, this message translates to:
  /// **'Start date must be before end date.'**
  String get reportsStartBeforeEndError;

  /// No description provided for @reportsSavedQuery.
  ///
  /// In en, this message translates to:
  /// **'Saved query \"{name}\".'**
  String reportsSavedQuery(String name);

  /// No description provided for @reportsPdfPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing PDF...'**
  String get reportsPdfPreparing;

  /// No description provided for @reportsPdfGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get reportsPdfGenerating;

  /// No description provided for @reportsPdfSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving PDF...'**
  String get reportsPdfSaving;

  /// No description provided for @reportsPdfDone.
  ///
  /// In en, this message translates to:
  /// **'Done.'**
  String get reportsPdfDone;

  /// No description provided for @reportsPdfExported.
  ///
  /// In en, this message translates to:
  /// **'PDF exported to: {path}'**
  String reportsPdfExported(String path);

  /// No description provided for @reportsPdfFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate PDF: {error}'**
  String reportsPdfFailed(String error);

  /// No description provided for @reportsNoTemplateAvailable.
  ///
  /// In en, this message translates to:
  /// **'No template available.'**
  String get reportsNoTemplateAvailable;

  /// No description provided for @reportsSavePdfDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save PDF'**
  String get reportsSavePdfDialogTitle;

  /// No description provided for @reportsChooseExportFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose export folder'**
  String get reportsChooseExportFolderTitle;

  /// No description provided for @reportsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get reportsCancelled;

  /// No description provided for @reportsAnalyzeByLabel.
  ///
  /// In en, this message translates to:
  /// **'Analyze by'**
  String get reportsAnalyzeByLabel;

  /// No description provided for @reportsOrderByLabel.
  ///
  /// In en, this message translates to:
  /// **'Order by'**
  String get reportsOrderByLabel;

  /// No description provided for @reportsAnalyzeByAircraft.
  ///
  /// In en, this message translates to:
  /// **'By Aircraft'**
  String get reportsAnalyzeByAircraft;

  /// No description provided for @reportsAnalyzeByType.
  ///
  /// In en, this message translates to:
  /// **'By Type'**
  String get reportsAnalyzeByType;

  /// No description provided for @reportsAnalyzeByFamily.
  ///
  /// In en, this message translates to:
  /// **'By Family'**
  String get reportsAnalyzeByFamily;

  /// No description provided for @reportsAnalyzeByYear.
  ///
  /// In en, this message translates to:
  /// **'By Year'**
  String get reportsAnalyzeByYear;

  /// No description provided for @reportsAnalyzeByMonth.
  ///
  /// In en, this message translates to:
  /// **'By Month'**
  String get reportsAnalyzeByMonth;

  /// No description provided for @reportsOrderByGreater.
  ///
  /// In en, this message translates to:
  /// **'Greater'**
  String get reportsOrderByGreater;

  /// No description provided for @reportsOrderByNatural.
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get reportsOrderByNatural;

  /// No description provided for @reportsShowMap.
  ///
  /// In en, this message translates to:
  /// **'Show Map'**
  String get reportsShowMap;

  /// No description provided for @reportsShowPath.
  ///
  /// In en, this message translates to:
  /// **'Show Path'**
  String get reportsShowPath;

  /// No description provided for @reportsIncludeHoursBefore.
  ///
  /// In en, this message translates to:
  /// **'Include hours before'**
  String get reportsIncludeHoursBefore;

  /// No description provided for @reportsPageSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Page Size'**
  String get reportsPageSizeLabel;

  /// No description provided for @reportsXmlTemplateLabel.
  ///
  /// In en, this message translates to:
  /// **'XML Template'**
  String get reportsXmlTemplateLabel;

  /// No description provided for @reportsGeneratingShort.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get reportsGeneratingShort;

  /// No description provided for @reportsGeneratePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get reportsGeneratePdf;

  /// No description provided for @reportsDatePresetLastMonthRolling.
  ///
  /// In en, this message translates to:
  /// **'Last month (rolling)'**
  String get reportsDatePresetLastMonthRolling;

  /// No description provided for @reportsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get reportsUnknown;

  /// No description provided for @reportsUnknownType.
  ///
  /// In en, this message translates to:
  /// **'Unknown type'**
  String get reportsUnknownType;

  /// No description provided for @reportsUnknownFamily.
  ///
  /// In en, this message translates to:
  /// **'Unknown family'**
  String get reportsUnknownFamily;

  /// No description provided for @reportsFiltersSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} filters • {from} UTC - {to} UTC'**
  String reportsFiltersSummary(int count, String from, String to);

  /// No description provided for @reportsEventSimShort.
  ///
  /// In en, this message translates to:
  /// **'Sim'**
  String get reportsEventSimShort;

  /// No description provided for @reportsPreviousExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous experience'**
  String get reportsPreviousExperienceLabel;

  /// No description provided for @reportsInclude.
  ///
  /// In en, this message translates to:
  /// **'Include'**
  String get reportsInclude;

  /// No description provided for @reportsExclude.
  ///
  /// In en, this message translates to:
  /// **'Exclude'**
  String get reportsExclude;

  /// No description provided for @reportsMatchModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Match mode'**
  String get reportsMatchModeLabel;

  /// No description provided for @reportsMatchAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reportsMatchAll;

  /// No description provided for @reportsMatchAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get reportsMatchAny;

  /// No description provided for @reportsAddFilter.
  ///
  /// In en, this message translates to:
  /// **'Add Filter'**
  String get reportsAddFilter;

  /// No description provided for @reportsFilterChipLabel.
  ///
  /// In en, this message translates to:
  /// **'{field} · {operator} · {value}'**
  String reportsFilterChipLabel(String field, String operator, String value);

  /// No description provided for @reportsSavedQueriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved queries'**
  String get reportsSavedQueriesLabel;

  /// No description provided for @reportsSaveQuery.
  ///
  /// In en, this message translates to:
  /// **'Save Query'**
  String get reportsSaveQuery;

  /// No description provided for @reportsDeleteSavedQuery.
  ///
  /// In en, this message translates to:
  /// **'Delete: {name}'**
  String reportsDeleteSavedQuery(String name);

  /// No description provided for @reportsDeleteSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete Saved'**
  String get reportsDeleteSavedLabel;

  /// No description provided for @reportsMetricIfrApproaches.
  ///
  /// In en, this message translates to:
  /// **'IFR Approaches'**
  String get reportsMetricIfrApproaches;

  /// No description provided for @reportsMetricTakeoffDay.
  ///
  /// In en, this message translates to:
  /// **'Takeoff Day'**
  String get reportsMetricTakeoffDay;

  /// No description provided for @reportsMetricTakeoffNight.
  ///
  /// In en, this message translates to:
  /// **'Takeoff Night'**
  String get reportsMetricTakeoffNight;

  /// No description provided for @reportsMetricLandingDay.
  ///
  /// In en, this message translates to:
  /// **'Landing Day'**
  String get reportsMetricLandingDay;

  /// No description provided for @reportsMetricLandingNight.
  ///
  /// In en, this message translates to:
  /// **'Landing Night'**
  String get reportsMetricLandingNight;

  /// No description provided for @reportsMetricTotalBlock.
  ///
  /// In en, this message translates to:
  /// **'Total Block'**
  String get reportsMetricTotalBlock;

  /// No description provided for @reportsMetricPic.
  ///
  /// In en, this message translates to:
  /// **'PIC'**
  String get reportsMetricPic;

  /// No description provided for @reportsMetricPicus.
  ///
  /// In en, this message translates to:
  /// **'PICUS'**
  String get reportsMetricPicus;

  /// No description provided for @reportsMetricSic.
  ///
  /// In en, this message translates to:
  /// **'SIC'**
  String get reportsMetricSic;

  /// No description provided for @reportsMetricDual.
  ///
  /// In en, this message translates to:
  /// **'Dual'**
  String get reportsMetricDual;

  /// No description provided for @reportsMetricInstructor.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get reportsMetricInstructor;

  /// No description provided for @reportsMetricNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get reportsMetricNight;

  /// No description provided for @reportsMetricIfr.
  ///
  /// In en, this message translates to:
  /// **'IFR'**
  String get reportsMetricIfr;

  /// No description provided for @reportsMetricInstrument.
  ///
  /// In en, this message translates to:
  /// **'Instrument'**
  String get reportsMetricInstrument;

  /// No description provided for @reportsMetricCrossCountry.
  ///
  /// In en, this message translates to:
  /// **'Cross-Country'**
  String get reportsMetricCrossCountry;

  /// No description provided for @reportsMetricSimulator.
  ///
  /// In en, this message translates to:
  /// **'Simulator'**
  String get reportsMetricSimulator;

  /// No description provided for @reportsMetricDuty.
  ///
  /// In en, this message translates to:
  /// **'Duty'**
  String get reportsMetricDuty;

  /// No description provided for @reportsMetricDistanceNm.
  ///
  /// In en, this message translates to:
  /// **'Distance NM'**
  String get reportsMetricDistanceNm;

  /// No description provided for @reportsFlightCount.
  ///
  /// In en, this message translates to:
  /// **'Flight count: {count}'**
  String reportsFlightCount(String count);

  /// No description provided for @reportsNoDataForQuery.
  ///
  /// In en, this message translates to:
  /// **'No data for selected query.'**
  String get reportsNoDataForQuery;

  /// No description provided for @reportsMetricLandings.
  ///
  /// In en, this message translates to:
  /// **'Landings'**
  String get reportsMetricLandings;

  /// No description provided for @reportsFirstFlightAt.
  ///
  /// In en, this message translates to:
  /// **'First flight {date} UTC'**
  String reportsFirstFlightAt(String date);

  /// No description provided for @reportsLastFlightAt.
  ///
  /// In en, this message translates to:
  /// **'Last flight {date} UTC'**
  String reportsLastFlightAt(String date);

  /// No description provided for @reportsFieldNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Field name'**
  String get reportsFieldNameLabel;

  /// No description provided for @reportsConditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get reportsConditionLabel;

  /// No description provided for @reportsValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get reportsValueLabel;

  /// No description provided for @reportsFlightsAndSimulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Flights & Simulator'**
  String get reportsFlightsAndSimulatorTitle;

  /// No description provided for @reportsEntriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String reportsEntriesCount(int count);

  /// No description provided for @reportsNoFlightsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No flights/sim in selected period.'**
  String get reportsNoFlightsInPeriod;

  /// No description provided for @reportsFlightMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Flight Map'**
  String get reportsFlightMapTitle;

  /// No description provided for @reportsHideLines.
  ///
  /// In en, this message translates to:
  /// **'Hide lines'**
  String get reportsHideLines;

  /// No description provided for @reportsShowLines.
  ///
  /// In en, this message translates to:
  /// **'Show lines'**
  String get reportsShowLines;

  /// No description provided for @reportsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get reportsDone;

  /// No description provided for @reportsNoCoordinatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No coordinates available.'**
  String get reportsNoCoordinatesAvailable;

  /// No description provided for @reportsAirportsCount.
  ///
  /// In en, this message translates to:
  /// **'Airports: {count}'**
  String reportsAirportsCount(int count);

  /// No description provided for @reportsFilterFieldDepartureIcao.
  ///
  /// In en, this message translates to:
  /// **'Departure ICAO'**
  String get reportsFilterFieldDepartureIcao;

  /// No description provided for @reportsFilterFieldDepartureIata.
  ///
  /// In en, this message translates to:
  /// **'Departure IATA'**
  String get reportsFilterFieldDepartureIata;

  /// No description provided for @reportsFilterFieldDepartureName.
  ///
  /// In en, this message translates to:
  /// **'Departure Name'**
  String get reportsFilterFieldDepartureName;

  /// No description provided for @reportsFilterFieldDepartureCity.
  ///
  /// In en, this message translates to:
  /// **'Departure City'**
  String get reportsFilterFieldDepartureCity;

  /// No description provided for @reportsFilterFieldDepartureCountry.
  ///
  /// In en, this message translates to:
  /// **'Departure Country'**
  String get reportsFilterFieldDepartureCountry;

  /// No description provided for @reportsFilterFieldArrivalIcao.
  ///
  /// In en, this message translates to:
  /// **'Arrival ICAO'**
  String get reportsFilterFieldArrivalIcao;

  /// No description provided for @reportsFilterFieldArrivalIata.
  ///
  /// In en, this message translates to:
  /// **'Arrival IATA'**
  String get reportsFilterFieldArrivalIata;

  /// No description provided for @reportsFilterFieldArrivalName.
  ///
  /// In en, this message translates to:
  /// **'Arrival Name'**
  String get reportsFilterFieldArrivalName;

  /// No description provided for @reportsFilterFieldArrivalCity.
  ///
  /// In en, this message translates to:
  /// **'Arrival City'**
  String get reportsFilterFieldArrivalCity;

  /// No description provided for @reportsFilterFieldArrivalCountry.
  ///
  /// In en, this message translates to:
  /// **'Arrival Country'**
  String get reportsFilterFieldArrivalCountry;

  /// No description provided for @reportsFilterFieldAircraftRegistration.
  ///
  /// In en, this message translates to:
  /// **'Aircraft Registration'**
  String get reportsFilterFieldAircraftRegistration;

  /// No description provided for @reportsFilterFieldAircraftTypeCode.
  ///
  /// In en, this message translates to:
  /// **'Aircraft Type Code'**
  String get reportsFilterFieldAircraftTypeCode;

  /// No description provided for @reportsFilterFieldAircraftTypeFamily.
  ///
  /// In en, this message translates to:
  /// **'Aircraft Type Family'**
  String get reportsFilterFieldAircraftTypeFamily;

  /// No description provided for @reportsFilterFieldAircraftTypeName.
  ///
  /// In en, this message translates to:
  /// **'Aircraft Type Name'**
  String get reportsFilterFieldAircraftTypeName;

  /// No description provided for @reportsFilterFieldPilotName.
  ///
  /// In en, this message translates to:
  /// **'Pilot Name'**
  String get reportsFilterFieldPilotName;

  /// No description provided for @reportsFilterFieldPilotOnBoard.
  ///
  /// In en, this message translates to:
  /// **'Pilot On Board'**
  String get reportsFilterFieldPilotOnBoard;

  /// No description provided for @reportsFilterFieldPilotPic.
  ///
  /// In en, this message translates to:
  /// **'Pilot PIC'**
  String get reportsFilterFieldPilotPic;

  /// No description provided for @reportsFilterFieldPilotSic.
  ///
  /// In en, this message translates to:
  /// **'Pilot SIC'**
  String get reportsFilterFieldPilotSic;

  /// No description provided for @reportsFilterFieldPilotTrainee.
  ///
  /// In en, this message translates to:
  /// **'Pilot Trainee'**
  String get reportsFilterFieldPilotTrainee;

  /// No description provided for @reportsFilterFieldApproachType.
  ///
  /// In en, this message translates to:
  /// **'Approach Type'**
  String get reportsFilterFieldApproachType;

  /// No description provided for @reportsFilterFieldRemarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get reportsFilterFieldRemarks;

  /// No description provided for @reportsFilterFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get reportsFilterFieldNotes;

  /// No description provided for @reportsFilterFieldBlockTime.
  ///
  /// In en, this message translates to:
  /// **'Block Time'**
  String get reportsFilterFieldBlockTime;

  /// No description provided for @reportsFilterFieldFlightTime.
  ///
  /// In en, this message translates to:
  /// **'Flight Time'**
  String get reportsFilterFieldFlightTime;

  /// No description provided for @reportsFilterFieldTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get reportsFilterFieldTotalTime;

  /// No description provided for @reportsFilterFieldNightTime.
  ///
  /// In en, this message translates to:
  /// **'Night Time'**
  String get reportsFilterFieldNightTime;

  /// No description provided for @reportsFilterFieldIfrTime.
  ///
  /// In en, this message translates to:
  /// **'IFR Time'**
  String get reportsFilterFieldIfrTime;

  /// No description provided for @reportsFilterFieldInstrumentTime.
  ///
  /// In en, this message translates to:
  /// **'Instrument Time'**
  String get reportsFilterFieldInstrumentTime;

  /// No description provided for @reportsFilterFieldSimInstrumentTime.
  ///
  /// In en, this message translates to:
  /// **'Sim Instrument Time'**
  String get reportsFilterFieldSimInstrumentTime;

  /// No description provided for @reportsFilterFieldPicTime.
  ///
  /// In en, this message translates to:
  /// **'PIC Time'**
  String get reportsFilterFieldPicTime;

  /// No description provided for @reportsFilterFieldPicusTime.
  ///
  /// In en, this message translates to:
  /// **'PICUS Time'**
  String get reportsFilterFieldPicusTime;

  /// No description provided for @reportsFilterFieldSicTime.
  ///
  /// In en, this message translates to:
  /// **'SIC Time'**
  String get reportsFilterFieldSicTime;

  /// No description provided for @reportsFilterFieldDualTime.
  ///
  /// In en, this message translates to:
  /// **'Dual Time'**
  String get reportsFilterFieldDualTime;

  /// No description provided for @reportsFilterFieldInstructorTime.
  ///
  /// In en, this message translates to:
  /// **'Instructor Time'**
  String get reportsFilterFieldInstructorTime;

  /// No description provided for @reportsFilterFieldCrossCountryTime.
  ///
  /// In en, this message translates to:
  /// **'Cross-Country Time'**
  String get reportsFilterFieldCrossCountryTime;

  /// No description provided for @reportsFilterFieldCustom1Time.
  ///
  /// In en, this message translates to:
  /// **'Custom 1 Time'**
  String get reportsFilterFieldCustom1Time;

  /// No description provided for @reportsFilterFieldCustom2Time.
  ///
  /// In en, this message translates to:
  /// **'Custom 2 Time'**
  String get reportsFilterFieldCustom2Time;

  /// No description provided for @reportsFilterFieldCustom3Time.
  ///
  /// In en, this message translates to:
  /// **'Custom 3 Time'**
  String get reportsFilterFieldCustom3Time;

  /// No description provided for @reportsFilterFieldCustom4Time.
  ///
  /// In en, this message translates to:
  /// **'Custom 4 Time'**
  String get reportsFilterFieldCustom4Time;

  /// No description provided for @reportsFilterFieldDistanceNm.
  ///
  /// In en, this message translates to:
  /// **'Distance NM'**
  String get reportsFilterFieldDistanceNm;

  /// No description provided for @reportsFilterFieldTakeoffs.
  ///
  /// In en, this message translates to:
  /// **'Takeoffs'**
  String get reportsFilterFieldTakeoffs;

  /// No description provided for @reportsFilterFieldTakeoffsDay.
  ///
  /// In en, this message translates to:
  /// **'Takeoffs Day'**
  String get reportsFilterFieldTakeoffsDay;

  /// No description provided for @reportsFilterFieldTakeoffsNight.
  ///
  /// In en, this message translates to:
  /// **'Takeoffs Night'**
  String get reportsFilterFieldTakeoffsNight;

  /// No description provided for @reportsFilterFieldLandings.
  ///
  /// In en, this message translates to:
  /// **'Landings'**
  String get reportsFilterFieldLandings;

  /// No description provided for @reportsFilterFieldLandingsDay.
  ///
  /// In en, this message translates to:
  /// **'Landings Day'**
  String get reportsFilterFieldLandingsDay;

  /// No description provided for @reportsFilterFieldLandingsNight.
  ///
  /// In en, this message translates to:
  /// **'Landings Night'**
  String get reportsFilterFieldLandingsNight;

  /// No description provided for @reportsFilterFieldIfrApproaches.
  ///
  /// In en, this message translates to:
  /// **'IFR Approaches'**
  String get reportsFilterFieldIfrApproaches;

  /// No description provided for @reportsFilterFieldMultiPilot.
  ///
  /// In en, this message translates to:
  /// **'Multi Pilot'**
  String get reportsFilterFieldMultiPilot;

  /// No description provided for @reportsFilterFieldSimulator.
  ///
  /// In en, this message translates to:
  /// **'Simulator'**
  String get reportsFilterFieldSimulator;

  /// No description provided for @reportsFilterOperatorContains.
  ///
  /// In en, this message translates to:
  /// **'Contains'**
  String get reportsFilterOperatorContains;

  /// No description provided for @reportsFilterOperatorDoesNotContain.
  ///
  /// In en, this message translates to:
  /// **'Does not contain'**
  String get reportsFilterOperatorDoesNotContain;

  /// No description provided for @reportsFilterOperatorStartsWith.
  ///
  /// In en, this message translates to:
  /// **'Starts With'**
  String get reportsFilterOperatorStartsWith;

  /// No description provided for @reportsFilterOperatorDoesNotStartWith.
  ///
  /// In en, this message translates to:
  /// **'Does not start with'**
  String get reportsFilterOperatorDoesNotStartWith;

  /// No description provided for @reportsFilterOperatorEndsWith.
  ///
  /// In en, this message translates to:
  /// **'Ends With'**
  String get reportsFilterOperatorEndsWith;

  /// No description provided for @reportsFilterOperatorDoesNotEndWith.
  ///
  /// In en, this message translates to:
  /// **'Does not end with'**
  String get reportsFilterOperatorDoesNotEndWith;

  /// No description provided for @reportsFilterOperatorIs.
  ///
  /// In en, this message translates to:
  /// **'Is'**
  String get reportsFilterOperatorIs;

  /// No description provided for @reportsFilterOperatorIsNot.
  ///
  /// In en, this message translates to:
  /// **'Is not'**
  String get reportsFilterOperatorIsNot;

  /// No description provided for @reportsFilterOperatorGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'Greater than'**
  String get reportsFilterOperatorGreaterThan;

  /// No description provided for @reportsFilterOperatorLessThan.
  ///
  /// In en, this message translates to:
  /// **'Less than'**
  String get reportsFilterOperatorLessThan;

  /// No description provided for @reportsFilterOperatorEquals.
  ///
  /// In en, this message translates to:
  /// **'Equals'**
  String get reportsFilterOperatorEquals;

  /// No description provided for @reportsFilterOperatorIsTrue.
  ///
  /// In en, this message translates to:
  /// **'Is True'**
  String get reportsFilterOperatorIsTrue;

  /// No description provided for @reportsFilterOperatorIsFalse.
  ///
  /// In en, this message translates to:
  /// **'Is False'**
  String get reportsFilterOperatorIsFalse;

  /// No description provided for @languageLatvian.
  ///
  /// In en, this message translates to:
  /// **'Latvian'**
  String get languageLatvian;

  /// No description provided for @reportsAnalyzeByAirport.
  ///
  /// In en, this message translates to:
  /// **'By Airport'**
  String get reportsAnalyzeByAirport;

  /// No description provided for @reportsAnalyzeByPilot.
  ///
  /// In en, this message translates to:
  /// **'By Pilot'**
  String get reportsAnalyzeByPilot;

  /// No description provided for @reportsUnknownAirport.
  ///
  /// In en, this message translates to:
  /// **'Unknown airport'**
  String get reportsUnknownAirport;

  /// No description provided for @reportsUnknownPilot.
  ///
  /// In en, this message translates to:
  /// **'Unknown pilot'**
  String get reportsUnknownPilot;

  /// No description provided for @reportsOrderByHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get reportsOrderByHours;

  /// No description provided for @reportsOrderByLandings.
  ///
  /// In en, this message translates to:
  /// **'Landings'**
  String get reportsOrderByLandings;

  /// No description provided for @reportsOrderByTakeoff.
  ///
  /// In en, this message translates to:
  /// **'TakeOff'**
  String get reportsOrderByTakeoff;

  /// No description provided for @reportsOrderByOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get reportsOrderByOperations;

  /// No description provided for @reportsMetricTakeoff.
  ///
  /// In en, this message translates to:
  /// **'TakeOff'**
  String get reportsMetricTakeoff;

  /// No description provided for @reportsMetricOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get reportsMetricOperations;

  /// No description provided for @aircraftFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Aircraft filters'**
  String get aircraftFiltersTitle;

  /// No description provided for @crewFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Crew filters'**
  String get crewFiltersTitle;

  /// No description provided for @airportFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Airport filters'**
  String get airportFiltersTitle;

  /// No description provided for @searchByLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by'**
  String get searchByLabel;

  /// No description provided for @orderByLabel.
  ///
  /// In en, this message translates to:
  /// **'Order by'**
  String get orderByLabel;

  /// No description provided for @optionAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get optionAll;

  /// No description provided for @searchFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get searchFieldType;

  /// No description provided for @applyAction.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyAction;

  /// No description provided for @fieldTakeoffs.
  ///
  /// In en, this message translates to:
  /// **'Takeoffs'**
  String get fieldTakeoffs;

  /// No description provided for @fieldLandings.
  ///
  /// In en, this message translates to:
  /// **'Landings'**
  String get fieldLandings;

  /// No description provided for @fieldVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get fieldVisits;

  /// No description provided for @airportShowOnlyVisited.
  ///
  /// In en, this message translates to:
  /// **'Show only visited airports'**
  String get airportShowOnlyVisited;

  /// No description provided for @airportSearchIcaoOrIata.
  ///
  /// In en, this message translates to:
  /// **'ICAO or IATA'**
  String get airportSearchIcaoOrIata;

  /// No description provided for @summaryFirstFlight.
  ///
  /// In en, this message translates to:
  /// **'First flight'**
  String get summaryFirstFlight;

  /// No description provided for @summaryLastFlight.
  ///
  /// In en, this message translates to:
  /// **'Last flight'**
  String get summaryLastFlight;

  /// No description provided for @summaryTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get summaryTotalTime;

  /// No description provided for @summaryTotalPic.
  ///
  /// In en, this message translates to:
  /// **'PIC total'**
  String get summaryTotalPic;

  /// No description provided for @notAvailableShort.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get notAvailableShort;

  /// No description provided for @fieldCrew.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get fieldCrew;

  /// No description provided for @addCrewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add crew'**
  String get addCrewTitle;

  /// No description provided for @selectCrewTitle.
  ///
  /// In en, this message translates to:
  /// **'Select crew'**
  String get selectCrewTitle;

  /// No description provided for @crewPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get crewPositionLabel;

  /// No description provided for @crewPositionPic.
  ///
  /// In en, this message translates to:
  /// **'PIC'**
  String get crewPositionPic;

  /// No description provided for @crewPositionPicus.
  ///
  /// In en, this message translates to:
  /// **'PICUS'**
  String get crewPositionPicus;

  /// No description provided for @crewPositionSic.
  ///
  /// In en, this message translates to:
  /// **'SIC'**
  String get crewPositionSic;

  /// No description provided for @crewPositionTrainee.
  ///
  /// In en, this message translates to:
  /// **'Trainee'**
  String get crewPositionTrainee;

  /// No description provided for @crewPositionInstructor.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get crewPositionInstructor;

  /// No description provided for @crewPositionObserver.
  ///
  /// In en, this message translates to:
  /// **'Observer'**
  String get crewPositionObserver;

  /// No description provided for @crewPositionRelief.
  ///
  /// In en, this message translates to:
  /// **'Relief'**
  String get crewPositionRelief;

  /// No description provided for @crewPositionReliefCaptain.
  ///
  /// In en, this message translates to:
  /// **'Relief Captain'**
  String get crewPositionReliefCaptain;

  /// No description provided for @crewPositionReliefFirstOfficer.
  ///
  /// In en, this message translates to:
  /// **'Relief First Officer'**
  String get crewPositionReliefFirstOfficer;

  /// No description provided for @crewPositionCabinSenior.
  ///
  /// In en, this message translates to:
  /// **'Cabin Senior'**
  String get crewPositionCabinSenior;

  /// No description provided for @crewPositionCabinCrew.
  ///
  /// In en, this message translates to:
  /// **'Cabin Crew'**
  String get crewPositionCabinCrew;

  /// No description provided for @crewPositionOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get crewPositionOther;

  /// No description provided for @crewPositionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get crewPositionUnknown;

  /// No description provided for @searchRegistration.
  ///
  /// In en, this message translates to:
  /// **'Search registration'**
  String get searchRegistration;

  /// No description provided for @searchType.
  ///
  /// In en, this message translates to:
  /// **'Search type'**
  String get searchType;

  /// No description provided for @searchFamily.
  ///
  /// In en, this message translates to:
  /// **'Search family'**
  String get searchFamily;

  /// No description provided for @searchNotes.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get searchNotes;

  /// No description provided for @searchName.
  ///
  /// In en, this message translates to:
  /// **'Search name'**
  String get searchName;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search city'**
  String get searchCity;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountry;

  /// No description provided for @searchIcao.
  ///
  /// In en, this message translates to:
  /// **'Search ICAO'**
  String get searchIcao;

  /// No description provided for @searchIata.
  ///
  /// In en, this message translates to:
  /// **'Search IATA'**
  String get searchIata;

  /// No description provided for @searchIcaoIata.
  ///
  /// In en, this message translates to:
  /// **'Search ICAO/IATA'**
  String get searchIcaoIata;

  /// No description provided for @createSimulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Add simulator'**
  String get createSimulatorTitle;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @aircraftEmptyResults.
  ///
  /// In en, this message translates to:
  /// **'No aircraft found'**
  String get aircraftEmptyResults;

  /// No description provided for @crewEmptyResults.
  ///
  /// In en, this message translates to:
  /// **'No crew found'**
  String get crewEmptyResults;

  /// No description provided for @crewLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading crew'**
  String get crewLoadError;

  /// No description provided for @airportEmptyResults.
  ///
  /// In en, this message translates to:
  /// **'No airports found'**
  String get airportEmptyResults;

  /// No description provided for @airportLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading airports'**
  String get airportLoadError;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardNoActiveRules.
  ///
  /// In en, this message translates to:
  /// **'No active rules configured.'**
  String get dashboardNoActiveRules;

  /// No description provided for @dashboardRuleTotals.
  ///
  /// In en, this message translates to:
  /// **'Rule totals'**
  String get dashboardRuleTotals;

  /// No description provided for @dashboardNoData.
  ///
  /// In en, this message translates to:
  /// **'No data.'**
  String get dashboardNoData;

  /// No description provided for @dashboardEventsInCalculation.
  ///
  /// In en, this message translates to:
  /// **'Events in calculation'**
  String get dashboardEventsInCalculation;

  /// No description provided for @dashboardNoEventsInWindow.
  ///
  /// In en, this message translates to:
  /// **'No events in this window.'**
  String get dashboardNoEventsInWindow;

  /// No description provided for @dashboardFlightsLabel.
  ///
  /// In en, this message translates to:
  /// **'Flights'**
  String get dashboardFlightsLabel;

  /// No description provided for @dashboardBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get dashboardBlockLabel;

  /// No description provided for @dashboardFlightLabel.
  ///
  /// In en, this message translates to:
  /// **'Flight'**
  String get dashboardFlightLabel;

  /// No description provided for @dashboardNightLabel.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get dashboardNightLabel;

  /// No description provided for @dashboardIfrLabel.
  ///
  /// In en, this message translates to:
  /// **'IFR'**
  String get dashboardIfrLabel;

  /// No description provided for @dashboardInstrumentLabel.
  ///
  /// In en, this message translates to:
  /// **'Instrument'**
  String get dashboardInstrumentLabel;

  /// No description provided for @dashboardDutyLabel.
  ///
  /// In en, this message translates to:
  /// **'Duty'**
  String get dashboardDutyLabel;

  /// No description provided for @dashboardLandingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Landings'**
  String get dashboardLandingsLabel;

  /// No description provided for @dashboardSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard setup'**
  String get dashboardSetupTitle;

  /// No description provided for @dashboardAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get dashboardAddRule;

  /// No description provided for @dashboardNoRulesConfigured.
  ///
  /// In en, this message translates to:
  /// **'No rules configured.'**
  String get dashboardNoRulesConfigured;

  /// No description provided for @dashboardEditRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit rule'**
  String get dashboardEditRuleTitle;

  /// No description provided for @dashboardCreateRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Create rule'**
  String get dashboardCreateRuleTitle;

  /// No description provided for @dashboardRuleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Rule name'**
  String get dashboardRuleNameLabel;

  /// No description provided for @dashboardMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get dashboardMetricLabel;

  /// No description provided for @dashboardRuleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Rule type'**
  String get dashboardRuleTypeLabel;

  /// No description provided for @dashboardWindowTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Window type'**
  String get dashboardWindowTypeLabel;

  /// No description provided for @dashboardStartReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Start reference'**
  String get dashboardStartReferenceLabel;

  /// No description provided for @dashboardWindowValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Window value'**
  String get dashboardWindowValueLabel;

  /// No description provided for @dashboardLimitValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit value'**
  String get dashboardLimitValueLabel;

  /// No description provided for @dashboardUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get dashboardUnitLabel;

  /// No description provided for @dashboardWarnYellowBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Warn yellow before'**
  String get dashboardWarnYellowBeforeLabel;

  /// No description provided for @dashboardWarnRedBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Warn red before'**
  String get dashboardWarnRedBeforeLabel;

  /// No description provided for @dashboardCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get dashboardCreateAction;

  /// No description provided for @dashboardTakeoffLabel.
  ///
  /// In en, this message translates to:
  /// **'Takeoff'**
  String get dashboardTakeoffLabel;

  /// No description provided for @dashboardTakeoffDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Takeoff day'**
  String get dashboardTakeoffDayLabel;

  /// No description provided for @dashboardTakeoffNightLabel.
  ///
  /// In en, this message translates to:
  /// **'Takeoff night'**
  String get dashboardTakeoffNightLabel;

  /// No description provided for @dashboardLandingsDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Landings day'**
  String get dashboardLandingsDayLabel;

  /// No description provided for @dashboardLandingsNightLabel.
  ///
  /// In en, this message translates to:
  /// **'Landings night'**
  String get dashboardLandingsNightLabel;

  /// No description provided for @dashboardInstrumentApproachesLabel.
  ///
  /// In en, this message translates to:
  /// **'Instrument approaches'**
  String get dashboardInstrumentApproachesLabel;

  /// No description provided for @dashboardPicTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'PIC time'**
  String get dashboardPicTimeLabel;

  /// No description provided for @dashboardSicTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'SIC time'**
  String get dashboardSicTimeLabel;

  /// No description provided for @dashboardPicusTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'PICUS time'**
  String get dashboardPicusTimeLabel;

  /// No description provided for @dashboardDualTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dual time'**
  String get dashboardDualTimeLabel;

  /// No description provided for @dashboardInstructorTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructor time'**
  String get dashboardInstructorTimeLabel;

  /// No description provided for @dashboardCrossCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Cross country'**
  String get dashboardCrossCountryLabel;

  /// No description provided for @dashboardMinimumLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get dashboardMinimumLabel;

  /// No description provided for @dashboardMaximumLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get dashboardMaximumLabel;

  /// No description provided for @dashboardHoursUnit.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get dashboardHoursUnit;

  /// No description provided for @dashboardMinutesUnit.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get dashboardMinutesUnit;

  /// No description provided for @dashboardDaysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get dashboardDaysUnit;

  /// No description provided for @dashboardWeeksUnit.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get dashboardWeeksUnit;

  /// No description provided for @dashboardMonthsUnit.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get dashboardMonthsUnit;

  /// No description provided for @dashboardYearsUnit.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get dashboardYearsUnit;

  /// No description provided for @dashboardCountUnit.
  ///
  /// In en, this message translates to:
  /// **'count'**
  String get dashboardCountUnit;

  /// No description provided for @dashboardCalendarMonthsLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar months'**
  String get dashboardCalendarMonthsLabel;

  /// No description provided for @dashboardCalendarYearsLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar years'**
  String get dashboardCalendarYearsLabel;

  /// No description provided for @dashboardCalendarDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar days'**
  String get dashboardCalendarDaysLabel;

  /// No description provided for @dashboardCalendarQuarterLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar quarter'**
  String get dashboardCalendarQuarterLabel;

  /// No description provided for @dashboardSameTimeNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Same time (now)'**
  String get dashboardSameTimeNowLabel;

  /// No description provided for @dashboardMidnightLocalLabel.
  ///
  /// In en, this message translates to:
  /// **'Midnight local'**
  String get dashboardMidnightLocalLabel;

  /// No description provided for @dashboardMidnightUtcLabel.
  ///
  /// In en, this message translates to:
  /// **'Midnight UTC'**
  String get dashboardMidnightUtcLabel;

  /// No description provided for @dashboardRemainingSuffix.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get dashboardRemainingSuffix;

  /// No description provided for @dashboardOverLimitSuffix.
  ///
  /// In en, this message translates to:
  /// **'over limit'**
  String get dashboardOverLimitSuffix;

  /// No description provided for @dashboardAboveMinimumSuffix.
  ///
  /// In en, this message translates to:
  /// **'above minimum'**
  String get dashboardAboveMinimumSuffix;

  /// No description provided for @dashboardBelowMinimumSuffix.
  ///
  /// In en, this message translates to:
  /// **'below minimum'**
  String get dashboardBelowMinimumSuffix;

  /// No description provided for @dashboardMinimumShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get dashboardMinimumShortLabel;

  /// No description provided for @dashboardMaximumShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get dashboardMaximumShortLabel;

  /// No description provided for @dashboardSameTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Same time'**
  String get dashboardSameTimeLabel;

  /// No description provided for @checkFactoringRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Check factoring rules'**
  String get checkFactoringRulesTitle;

  /// No description provided for @continueSavingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Continue saving?'**
  String get continueSavingQuestion;

  /// No description provided for @reviewAction.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewAction;

  /// No description provided for @saveAnywayAction.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get saveAnywayAction;

  /// No description provided for @createFlightTitle.
  ///
  /// In en, this message translates to:
  /// **'New Flight'**
  String get createFlightTitle;

  /// No description provided for @editFlightTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Flight'**
  String get editFlightTitle;

  /// No description provided for @calculateAction.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculateAction;

  /// No description provided for @nextAction.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextAction;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// No description provided for @fieldPilotFunction.
  ///
  /// In en, this message translates to:
  /// **'Pilot Function'**
  String get fieldPilotFunction;

  /// No description provided for @chocksOffRequiredToCalculate.
  ///
  /// In en, this message translates to:
  /// **'Chocks OFF is required to calculate.'**
  String get chocksOffRequiredToCalculate;

  /// No description provided for @chocksOnRequiredToCalculate.
  ///
  /// In en, this message translates to:
  /// **'Chocks ON is required to calculate.'**
  String get chocksOnRequiredToCalculate;

  /// No description provided for @clearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAction;

  /// No description provided for @fieldRemarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get fieldRemarks;

  /// No description provided for @noCrewAssigned.
  ///
  /// In en, this message translates to:
  /// **'No crew assigned'**
  String get noCrewAssigned;

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @eventInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Event info'**
  String get eventInfoTitle;

  /// No description provided for @clearDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear database'**
  String get clearDatabaseTitle;

  /// No description provided for @clearDatabaseMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete all data and recreate empty tables.'**
  String get clearDatabaseMessage;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Pilot Logbook • Made by a Pilot, for Pilots'**
  String get aboutTagline;

  /// No description provided for @aboutWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why SimpleLog'**
  String get aboutWhyTitle;

  /// No description provided for @aboutStoryText.
  ///
  /// In en, this message translates to:
  /// **'SimpleLog was born in the cockpit: built by a real airline pilot who got fed up with scribbling on paper like it\'s 1976.\n\nThis app replaces my previous Java logbook software, which I developed and used for many years as an airline pilot. The rewrite brings mobile support, modern UI, and easier data portability while preserving the core focus on quick, accurate entries in real operations.\n\nJust punch in takeoff, landing, airports and times -> smash Calculate -> watch how fast totals and breakdowns get calculated automatically -> save and done.\n\nNo nonsense, no subscriptions, no server drama. Your flights stay yours, stored locally, synced on local network.\n\nOpen source. Free forever. Fly. Log. Repeat.\nIf it saves you time, a coffee keeps the lights on.'**
  String get aboutStoryText;

  /// No description provided for @aboutGithubTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Source on GitHub'**
  String get aboutGithubTitle;

  /// No description provided for @aboutGithubDocsText.
  ///
  /// In en, this message translates to:
  /// **'Documentation • Tutorials • Sync setup • Desktop builds • Bug tracker • Future features'**
  String get aboutGithubDocsText;

  /// No description provided for @aboutTapProject.
  ///
  /// In en, this message translates to:
  /// **'Tap here to visit the project page ->'**
  String get aboutTapProject;

  /// No description provided for @aboutRepoAddress.
  ///
  /// In en, this message translates to:
  /// **'github.com/rriet/simplelog'**
  String get aboutRepoAddress;

  /// No description provided for @aboutSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support SimpleLog'**
  String get aboutSupportTitle;

  /// No description provided for @aboutSupportBodyText.
  ///
  /// In en, this message translates to:
  /// **'SimpleLog will always remain free and open source.\n\nOngoing costs include Apple and Google developer accounts, test devices, and countless hours improving the app based on real pilot feedback.\n\nIf SimpleLog saves you time in the cockpit or makes your logbook life easier, any support is deeply appreciated.'**
  String get aboutSupportBodyText;

  /// No description provided for @aboutSupportFooterText.
  ///
  /// In en, this message translates to:
  /// **'-> The GitHub page has full documentation, tutorials, sync guides, desktop builds, and ways to support the project.'**
  String get aboutSupportFooterText;

  /// No description provided for @aboutTechStack.
  ///
  /// In en, this message translates to:
  /// **'Flutter • Riverpod • Drift'**
  String get aboutTechStack;

  /// No description provided for @aboutLicenseText.
  ///
  /// In en, this message translates to:
  /// **'GNU GPLv3 License'**
  String get aboutLicenseText;

  /// No description provided for @databaseSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect two devices on the same network.'**
  String get databaseSyncSubtitle;

  /// No description provided for @logtenReviewHelpText.
  ///
  /// In en, this message translates to:
  /// **'Fix the value for each invalid field, or ignore the full source line.'**
  String get logtenReviewHelpText;

  /// No description provided for @logtenReviewSimulatorSelectedHelp.
  ///
  /// In en, this message translates to:
  /// **'Simulator selected: airport fields are not required.'**
  String get logtenReviewSimulatorSelectedHelp;

  /// No description provided for @qatarMissingAirportsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create the missing airports before continuing the Qatar Airways import.'**
  String get qatarMissingAirportsMessage;

  /// No description provided for @qatarMissingAircraftMessage.
  ///
  /// In en, this message translates to:
  /// **'Create the missing simulator aircraft before continuing the Qatar Airways import.'**
  String get qatarMissingAircraftMessage;

  /// No description provided for @logbookUnlockEndorsedEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock endorsed entry?'**
  String get logbookUnlockEndorsedEntryTitle;

  /// No description provided for @logbookUnlockEndorsementWarning.
  ///
  /// In en, this message translates to:
  /// **'If you unlock this entry, signature and endorsement information will be deleted. Continue?'**
  String get logbookUnlockEndorsementWarning;

  /// No description provided for @logbookUnlockAction.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get logbookUnlockAction;

  /// No description provided for @endorsementLockWarning.
  ///
  /// In en, this message translates to:
  /// **'Once saved with an endorsement signature, this entry is locked and cannot be edited unless the signature is removed.'**
  String get endorsementLockWarning;

  /// No description provided for @endorsementMismatchWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: flight information does not match the original endorsed flight record.'**
  String get endorsementMismatchWarning;

  /// No description provided for @reportsMapSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preview the filtered routes and path overlay.'**
  String get reportsMapSectionSubtitle;

  /// No description provided for @reportsPdfSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select template and export the report PDF.'**
  String get reportsPdfSectionSubtitle;

  /// No description provided for @settingsCalculationPilotProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pilot identity and signature preferences.'**
  String get settingsCalculationPilotProfileSubtitle;

  /// No description provided for @previousExperienceEntriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit, add, or remove previous experience records.'**
  String get previousExperienceEntriesSubtitle;

  /// No description provided for @timeFieldsIntro.
  ///
  /// In en, this message translates to:
  /// **'Control visible time columns and custom labels.'**
  String get timeFieldsIntro;

  /// No description provided for @timeFieldsVisibleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which columns are shown in forms and lists.'**
  String get timeFieldsVisibleSubtitle;

  /// No description provided for @timeFieldsCustomLabelsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rename custom fields used across the app.'**
  String get timeFieldsCustomLabelsSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'lv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'lv':
      return AppLocalizationsLv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
