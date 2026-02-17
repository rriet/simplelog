import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  /// **'Follow system'**
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
      <String>['en', 'es'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
