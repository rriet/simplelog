import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

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

  /// No description provided for @menuVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {value}'**
  String menuVersionLabel(String value);

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

  /// No description provided for @batchWriteNavigationBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Wait for batch update to finish.'**
  String get batchWriteNavigationBlockedMessage;

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

  /// No description provided for @editSimulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit simulator'**
  String get editSimulatorTitle;

  /// No description provided for @createSimulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Add simulator'**
  String get createSimulatorTitle;

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

  /// No description provided for @icaoLengthError.
  ///
  /// In en, this message translates to:
  /// **'ICAO must be 4 characters'**
  String get icaoLengthError;

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

  /// No description provided for @databaseSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Transfer'**
  String get databaseSyncTitle;

  /// No description provided for @databaseSyncStartLocal.
  ///
  /// In en, this message translates to:
  /// **'Start local sync'**
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

  /// No description provided for @databaseSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get databaseSyncSuccess;

  /// No description provided for @databaseSyncDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from the other device.'**
  String get databaseSyncDisconnected;

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

  /// No description provided for @logbookFiltersHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get logbookFiltersHelpTitle;

  /// No description provided for @logbookFiltersHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Use From and To to define the date range for the logbook list and analysis tabs.\n\nOpen Filters to add advanced conditions.\n\nDisabled time fields remain visible in existing entries whenever they contain recorded values.'**
  String get logbookFiltersHelpBody;

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
  /// **'Aircraft'**
  String get reportsAnalyzeByAircraft;

  /// No description provided for @reportsAnalyzeByType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get reportsAnalyzeByType;

  /// No description provided for @reportsAnalyzeByFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get reportsAnalyzeByFamily;

  /// No description provided for @reportsAnalyzeByYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get reportsAnalyzeByYear;

  /// No description provided for @reportsAnalyzeByMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get reportsAnalyzeByMonth;

  /// No description provided for @reportsOrderByNatural.
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get reportsOrderByNatural;

  /// No description provided for @reportsShowMap.
  ///
  /// In en, this message translates to:
  /// **'Show map'**
  String get reportsShowMap;

  /// No description provided for @reportsShowPath.
  ///
  /// In en, this message translates to:
  /// **'Include path'**
  String get reportsShowPath;

  /// No description provided for @reportsIncludeHoursBefore.
  ///
  /// In en, this message translates to:
  /// **'Include hours before'**
  String get reportsIncludeHoursBefore;

  /// No description provided for @reportsXmlTemplateLabel.
  ///
  /// In en, this message translates to:
  /// **'Template'**
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

  /// No description provided for @reportsPreviousExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous experience'**
  String get reportsPreviousExperienceLabel;

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

  /// No description provided for @reportsFiltersHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get reportsFiltersHelpTitle;

  /// No description provided for @reportsFiltersHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Use this screen to narrow results by date range, event types, and custom filter conditions.\n\nSave stores the current setup as a Saved query. Select a saved query to reapply it later. Delete removes a saved query.\n\nMatch mode controls how multiple filter conditions are evaluated:\nAll: every condition must match.\nAny: at least one condition must match.'**
  String get reportsFiltersHelpBody;

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
  /// **'Save query'**
  String get reportsSaveQuery;

  /// No description provided for @reportsDeleteSavedQuery.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String reportsDeleteSavedQuery(String name);

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
  /// **'Block'**
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
  /// **'Flights: {count}'**
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
  /// **'First {date} UTC'**
  String reportsFirstFlightAt(String date);

  /// No description provided for @reportsLastFlightAt.
  ///
  /// In en, this message translates to:
  /// **'Last {date} UTC'**
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
  /// **'Flights & simulator'**
  String get reportsFlightsAndSimulatorTitle;

  /// No description provided for @reportsEntriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String reportsEntriesCount(int count);

  /// No description provided for @reportsNoFlightsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No flights or sim entries in this period.'**
  String get reportsNoFlightsInPeriod;

  /// No description provided for @reportsFlightMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Flight map'**
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
  /// **'Airport'**
  String get reportsAnalyzeByAirport;

  /// No description provided for @reportsUnknownAirport.
  ///
  /// In en, this message translates to:
  /// **'Unknown airport'**
  String get reportsUnknownAirport;

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
  /// **'Takeoff'**
  String get reportsOrderByTakeoff;

  /// No description provided for @reportsOrderByOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get reportsOrderByOperations;

  /// No description provided for @reportsMetricTakeoff.
  ///
  /// In en, this message translates to:
  /// **'Takeoff'**
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
  /// **'Setup'**
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

  /// No description provided for @databaseLocalTransferInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'How Local Transfer works'**
  String get databaseLocalTransferInfoTitle;

  /// No description provided for @databaseLocalTransferInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Local Transfer copies the entire database from the sending device to the receiving device.\nIt is not a two-way sync. All data on the receiving device will be completely overwritten with the data from the sending device.\n\nImportant note:\nLocal Transfer may not work on hotel, airport, or public Wi-Fi networks. These networks often isolate devices from each other for security reasons, which prevents direct communication between your devices.'**
  String get databaseLocalTransferInfoMessage;

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
  /// **'Show filtered flights on the map.'**
  String get reportsMapSectionSubtitle;

  /// No description provided for @reportsPdfSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a template and export a PDF report.'**
  String get reportsPdfSectionSubtitle;

  /// No description provided for @settingsCalculationPilotProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pilot identity and signature preferences.'**
  String get settingsCalculationPilotProfileSubtitle;

  /// No description provided for @settingsDefaultCrewFunctionTitle.
  ///
  /// In en, this message translates to:
  /// **'Default crew function'**
  String get settingsDefaultCrewFunctionTitle;

  /// No description provided for @settingsDefaultCrewFunctionHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Default crew function'**
  String get settingsDefaultCrewFunctionHelpTitle;

  /// No description provided for @settingsDefaultCrewFunctionHelpBody.
  ///
  /// In en, this message translates to:
  /// **'The Default Crew Function is applied when creating a new flight. It automatically assigns the \"Self\" crew member to the appropriate crew function.\n\nWhen importing crew data from a CSV file in which the crew function is not explicitly specified, the Default Crew Function is used as a fallback mechanism to ensure the \"Self\" crew member is correctly assigned.\n\nFor this functionality to operate correctly, exactly one crew member must be marked as \"Self\".'**
  String get settingsDefaultCrewFunctionHelpBody;

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

  /// No description provided for @autoUi001.
  ///
  /// In en, this message translates to:
  /// **'25.325399/-80.274803'**
  String get autoUi001;

  /// No description provided for @autoUi002.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get autoUi002;

  /// No description provided for @autoUi003.
  ///
  /// In en, this message translates to:
  /// **'Add Crew'**
  String get autoUi003;

  /// No description provided for @autoUi004.
  ///
  /// In en, this message translates to:
  /// **'Aircraft Type'**
  String get autoUi004;

  /// No description provided for @autoUi005.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get autoUi005;

  /// No description provided for @autoUi006.
  ///
  /// In en, this message translates to:
  /// **'Arrival Airport'**
  String get autoUi006;

  /// No description provided for @autoUi007.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get autoUi007;

  /// No description provided for @autoUi008.
  ///
  /// In en, this message translates to:
  /// **'Calculation Rules'**
  String get autoUi008;

  /// No description provided for @autoUi009.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get autoUi009;

  /// No description provided for @autoUi010.
  ///
  /// In en, this message translates to:
  /// **'Chocks OFF'**
  String get autoUi010;

  /// No description provided for @autoUi011.
  ///
  /// In en, this message translates to:
  /// **'Chocks ON'**
  String get autoUi011;

  /// No description provided for @autoUi012.
  ///
  /// In en, this message translates to:
  /// **'Clear signature'**
  String get autoUi012;

  /// No description provided for @autoUi013.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get autoUi013;

  /// No description provided for @autoUi014.
  ///
  /// In en, this message translates to:
  /// **'Could not open camera.'**
  String get autoUi014;

  /// No description provided for @autoUi015.
  ///
  /// In en, this message translates to:
  /// **'Could not select image file.'**
  String get autoUi015;

  /// No description provided for @autoUi016.
  ///
  /// In en, this message translates to:
  /// **'Crew home base airport'**
  String get autoUi016;

  /// No description provided for @autoUi017.
  ///
  /// In en, this message translates to:
  /// **'CrossCountry'**
  String get autoUi017;

  /// No description provided for @autoUi018.
  ///
  /// In en, this message translates to:
  /// **'Custom Time Labels'**
  String get autoUi018;

  /// No description provided for @autoUi019.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get autoUi019;

  /// No description provided for @autoUi020.
  ///
  /// In en, this message translates to:
  /// **'Departure Airport'**
  String get autoUi020;

  /// No description provided for @autoUi021.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get autoUi021;

  /// No description provided for @autoUi022.
  ///
  /// In en, this message translates to:
  /// **'Duty End'**
  String get autoUi022;

  /// No description provided for @autoUi023.
  ///
  /// In en, this message translates to:
  /// **'Duty Rules'**
  String get autoUi023;

  /// No description provided for @autoUi024.
  ///
  /// In en, this message translates to:
  /// **'Duty Start'**
  String get autoUi024;

  /// No description provided for @autoUi025.
  ///
  /// In en, this message translates to:
  /// **'Duty end time allowance'**
  String get autoUi025;

  /// No description provided for @autoUi026.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get autoUi026;

  /// No description provided for @autoUi027.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get autoUi027;

  /// No description provided for @autoUi028.
  ///
  /// In en, this message translates to:
  /// **'Endorsement'**
  String get autoUi028;

  /// No description provided for @autoUi029.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get autoUi029;

  /// No description provided for @autoUi030.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get autoUi030;

  /// No description provided for @autoUi031.
  ///
  /// In en, this message translates to:
  /// **'Factored Duty Time'**
  String get autoUi031;

  /// No description provided for @autoUi032.
  ///
  /// In en, this message translates to:
  /// **'First Flight'**
  String get autoUi032;

  /// No description provided for @autoUi033.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get autoUi033;

  /// No description provided for @autoUi034.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get autoUi034;

  /// No description provided for @autoUi035.
  ///
  /// In en, this message translates to:
  /// **'From Airport'**
  String get autoUi035;

  /// No description provided for @autoUi036.
  ///
  /// In en, this message translates to:
  /// **'Landing'**
  String get autoUi036;

  /// No description provided for @autoUi037.
  ///
  /// In en, this message translates to:
  /// **'Last Flight'**
  String get autoUi037;

  /// No description provided for @autoUi038.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get autoUi038;

  /// No description provided for @autoUi039.
  ///
  /// In en, this message translates to:
  /// **'Takeoff and landing Times'**
  String get autoUi039;

  /// No description provided for @autoUi040.
  ///
  /// In en, this message translates to:
  /// **'Manage prior totals by aircraft type.'**
  String get autoUi040;

  /// No description provided for @autoUi041.
  ///
  /// In en, this message translates to:
  /// **'Minimum rest time'**
  String get autoUi041;

  /// No description provided for @autoUi042.
  ///
  /// In en, this message translates to:
  /// **'N25°19.31/W080°16.29'**
  String get autoUi042;

  /// No description provided for @autoUi043.
  ///
  /// In en, this message translates to:
  /// **'No previous experience entries yet.'**
  String get autoUi043;

  /// No description provided for @autoUi044.
  ///
  /// In en, this message translates to:
  /// **'No signature'**
  String get autoUi044;

  /// No description provided for @autoUi046.
  ///
  /// In en, this message translates to:
  /// **'Previous Experience'**
  String get autoUi046;

  /// No description provided for @autoUi047.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get autoUi047;

  /// No description provided for @autoUi048.
  ///
  /// In en, this message translates to:
  /// **'Remove endorsement'**
  String get autoUi048;

  /// No description provided for @autoUi049.
  ///
  /// In en, this message translates to:
  /// **'Reporting time offbase'**
  String get autoUi049;

  /// No description provided for @autoUi050.
  ///
  /// In en, this message translates to:
  /// **'Reporting time on base'**
  String get autoUi050;

  /// No description provided for @autoUi051.
  ///
  /// In en, this message translates to:
  /// **'Save Labels'**
  String get autoUi051;

  /// No description provided for @autoUi052.
  ///
  /// In en, this message translates to:
  /// **'Session Time'**
  String get autoUi052;

  /// No description provided for @autoUi053.
  ///
  /// In en, this message translates to:
  /// **'Show endorsement'**
  String get autoUi053;

  /// No description provided for @autoUi054.
  ///
  /// In en, this message translates to:
  /// **'Sign'**
  String get autoUi054;

  /// No description provided for @autoUi055.
  ///
  /// In en, this message translates to:
  /// **'Sign on screen'**
  String get autoUi055;

  /// No description provided for @autoUi056.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get autoUi056;

  /// No description provided for @autoUi057.
  ///
  /// In en, this message translates to:
  /// **'Signature options'**
  String get autoUi057;

  /// No description provided for @autoUi059.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get autoUi059;

  /// No description provided for @autoUi060.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get autoUi060;

  /// No description provided for @autoUi061.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get autoUi061;

  /// No description provided for @autoUi062.
  ///
  /// In en, this message translates to:
  /// **'To Airport'**
  String get autoUi062;

  /// No description provided for @autoUi063.
  ///
  /// In en, this message translates to:
  /// **'Unable to load default position'**
  String get autoUi063;

  /// No description provided for @autoUi064.
  ///
  /// In en, this message translates to:
  /// **'Unable to load duty rules settings.'**
  String get autoUi064;

  /// No description provided for @autoUi065.
  ///
  /// In en, this message translates to:
  /// **'Unable to load option'**
  String get autoUi065;

  /// No description provided for @autoUi066.
  ///
  /// In en, this message translates to:
  /// **'Use calculated time'**
  String get autoUi066;

  /// No description provided for @autoUi067.
  ///
  /// In en, this message translates to:
  /// **'Visible Time Fields'**
  String get autoUi067;

  /// No description provided for @autoUi068.
  ///
  /// In en, this message translates to:
  /// **'→'**
  String get autoUi068;

  /// No description provided for @databaseBackupLogbookAction.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get databaseBackupLogbookAction;

  /// No description provided for @databaseBackupRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Back up or restore your data.'**
  String get databaseBackupRestoreSubtitle;

  /// No description provided for @databaseBackupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get databaseBackupRestoreTitle;

  /// No description provided for @databaseBackupRestoreInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get databaseBackupRestoreInfoTitle;

  /// No description provided for @databaseBackupRestoreInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Backup saves a full copy of your current database to a file.\nRestore replaces the current database with the selected backup file.\n\nImportant:\nRestore overwrites current data on this device.'**
  String get databaseBackupRestoreInfoMessage;

  /// No description provided for @databaseDangerZoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Irreversible actions.'**
  String get databaseDangerZoneSubtitle;

  /// No description provided for @databaseDangerZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get databaseDangerZoneTitle;

  /// No description provided for @databaseDumpTemporaryAction.
  ///
  /// In en, this message translates to:
  /// **'Export debug dump'**
  String get databaseDumpTemporaryAction;

  /// No description provided for @databaseExportCsvAction.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get databaseExportCsvAction;

  /// No description provided for @databaseExportFileAction.
  ///
  /// In en, this message translates to:
  /// **'Export file'**
  String get databaseExportFileAction;

  /// No description provided for @databaseImportExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import or export data files.'**
  String get databaseImportExportSubtitle;

  /// No description provided for @databaseImportExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import & Export'**
  String get databaseImportExportTitle;

  /// No description provided for @databaseImportExportInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Import & Export'**
  String get databaseImportExportInfoTitle;

  /// No description provided for @databaseImportExportInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Import reads supported files and writes their data into your logbook.\nFor database files, SimpleLog detects schema automatically:\n- Current SimpleLog backup schema restores (replaces current data).\n- Legacy SimpleLog schema imports into current format.\n\nExport lets you choose:\n- Export CSV: flights/simulators snapshot.\n- Backup logbook: full SQLite backup for restore.'**
  String get databaseImportExportInfoMessage;

  /// No description provided for @databaseImportFileAction.
  ///
  /// In en, this message translates to:
  /// **'Import file'**
  String get databaseImportFileAction;

  /// No description provided for @databaseImportSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Import summary'**
  String get databaseImportSummaryTitle;

  /// No description provided for @databaseImportingTitle.
  ///
  /// In en, this message translates to:
  /// **'Importing data'**
  String get databaseImportingTitle;

  /// No description provided for @databasePreparingLabel.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get databasePreparingLabel;

  /// No description provided for @databaseRestoreLogbookAction.
  ///
  /// In en, this message translates to:
  /// **'Restore logbook'**
  String get databaseRestoreLogbookAction;

  /// No description provided for @databaseSkippedLinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Skipped lines'**
  String get databaseSkippedLinesTitle;

  /// No description provided for @databaseToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get databaseToolsTitle;

  /// No description provided for @logtenAssociationHeader.
  ///
  /// In en, this message translates to:
  /// **'Mapped to'**
  String get logtenAssociationHeader;

  /// No description provided for @logtenContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get logtenContinueAction;

  /// No description provided for @logtenCorrectedValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Corrected value'**
  String get logtenCorrectedValueLabel;

  /// No description provided for @logtenCreateAirportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create airport'**
  String get logtenCreateAirportTooltip;

  /// No description provided for @logtenEntryTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Entry type'**
  String get logtenEntryTypeLabel;

  /// No description provided for @logtenFlightLabel.
  ///
  /// In en, this message translates to:
  /// **'Flight'**
  String get logtenFlightLabel;

  /// No description provided for @logtenIgnoreAllAction.
  ///
  /// In en, this message translates to:
  /// **'Ignore all'**
  String get logtenIgnoreAllAction;

  /// No description provided for @logtenIgnoreLineAction.
  ///
  /// In en, this message translates to:
  /// **'Ignore line'**
  String get logtenIgnoreLineAction;

  /// No description provided for @logtenImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get logtenImportAction;

  /// No description provided for @logtenImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import LogTen'**
  String get logtenImportTitle;

  /// No description provided for @logtenSelectAircraft.
  ///
  /// In en, this message translates to:
  /// **'Select aircraft'**
  String get logtenSelectAircraft;

  /// No description provided for @logtenCreateAircraftTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create aircraft'**
  String get logtenCreateAircraftTooltip;

  /// No description provided for @logtenNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get logtenNotSelected;

  /// No description provided for @logtenReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review LogTen'**
  String get logtenReviewTitle;

  /// No description provided for @logtenSelectAirportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select airport'**
  String get logtenSelectAirportTooltip;

  /// No description provided for @logtenSelectArrivalAirport.
  ///
  /// In en, this message translates to:
  /// **'Select arrival airport'**
  String get logtenSelectArrivalAirport;

  /// No description provided for @logtenSelectDepartureAirport.
  ///
  /// In en, this message translates to:
  /// **'Select departure airport'**
  String get logtenSelectDepartureAirport;

  /// No description provided for @logtenSelectedAirport.
  ///
  /// In en, this message translates to:
  /// **'Selected airport'**
  String get logtenSelectedAirport;

  /// No description provided for @logtenSimulatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Simulator'**
  String get logtenSimulatorLabel;

  /// No description provided for @logtenSourceColumnHeader.
  ///
  /// In en, this message translates to:
  /// **'Source column'**
  String get logtenSourceColumnHeader;

  /// No description provided for @logtenTimezoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get logtenTimezoneLabel;

  /// No description provided for @qatarContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get qatarContinueAction;

  /// No description provided for @qatarCreateAircraftAction.
  ///
  /// In en, this message translates to:
  /// **'Create aircraft'**
  String get qatarCreateAircraftAction;

  /// No description provided for @qatarCreateAirportAction.
  ///
  /// In en, this message translates to:
  /// **'Create airport'**
  String get qatarCreateAirportAction;

  /// No description provided for @qatarDefaultPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Default position'**
  String get qatarDefaultPositionLabel;

  /// No description provided for @qatarImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get qatarImportAction;

  /// No description provided for @qatarImportOptionsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Qatar options'**
  String get qatarImportOptionsHelpTitle;

  /// No description provided for @qatarImportOptionsHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Default position controls how the \"Self\" crew member is assigned during import.\n\nSIC: Self is imported as SIC. Names from the PIC column are imported as PIC crew members.\n\nPIC: Self is matched from PIC names using Pilot Name.\nPilot Name is required when Default position is PIC and must match the workbook text.\n- If only your name is present in PIC names, Self is imported as PIC.\n- If your name is missing, or appears together with other PIC names, Self is imported as Relief Captain and the other names are imported as PIC crew members.'**
  String get qatarImportOptionsHelpBody;

  /// No description provided for @qatarImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Qatar'**
  String get qatarImportTitle;

  /// No description provided for @qatarMissingAircraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing aircraft'**
  String get qatarMissingAircraftTitle;

  /// No description provided for @qatarMissingAirportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing airports'**
  String get qatarMissingAirportsTitle;

  /// No description provided for @qatarPilotNameAsWrittenLabel.
  ///
  /// In en, this message translates to:
  /// **'Pilot Name'**
  String get qatarPilotNameAsWrittenLabel;

  /// No description provided for @qatarPositionPic.
  ///
  /// In en, this message translates to:
  /// **'PIC'**
  String get qatarPositionPic;

  /// No description provided for @qatarPositionSic.
  ///
  /// In en, this message translates to:
  /// **'SIC'**
  String get qatarPositionSic;

  /// No description provided for @waderReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Wader import'**
  String get waderReviewTitle;

  /// No description provided for @waderReviewHelpText.
  ///
  /// In en, this message translates to:
  /// **'Fix invalid values before import, or ignore specific lines.'**
  String get waderReviewHelpText;

  /// No description provided for @waderReviewIgnoreAllAction.
  ///
  /// In en, this message translates to:
  /// **'Ignore all'**
  String get waderReviewIgnoreAllAction;

  /// No description provided for @waderReviewIgnoreLineAction.
  ///
  /// In en, this message translates to:
  /// **'Ignore line'**
  String get waderReviewIgnoreLineAction;

  /// No description provided for @waderReviewIncludeLineAction.
  ///
  /// In en, this message translates to:
  /// **'Include line'**
  String get waderReviewIncludeLineAction;

  /// No description provided for @waderReviewApplyAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get waderReviewApplyAction;

  /// No description provided for @waderReviewCorrectedValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Corrected value'**
  String get waderReviewCorrectedValueLabel;

  /// No description provided for @waderReviewSelectDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get waderReviewSelectDateHint;

  /// No description provided for @waderImportOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Wader'**
  String get waderImportOptionsTitle;

  /// No description provided for @waderImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get waderImportAction;

  /// No description provided for @waderImportRecalculationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recalculations'**
  String get waderImportRecalculationsTitle;

  /// No description provided for @waderRecalculateTotalTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Recalculate total time'**
  String get waderRecalculateTotalTimeLabel;

  /// No description provided for @waderImportOptionsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Wader options'**
  String get waderImportOptionsHelpTitle;

  /// No description provided for @waderImportOptionsHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Recalculate total time OFF: import uses the CSV total time as entered. Missing or invalid totals must be fixed, ignored, or resolved in review.\n\nRecalculate total time ON: import recalculates total from start/parking times for all eligible rows.'**
  String get waderImportOptionsHelpBody;

  /// No description provided for @waderTotalTimeResolutionLabel.
  ///
  /// In en, this message translates to:
  /// **'Missing total time resolution'**
  String get waderTotalTimeResolutionLabel;

  /// No description provided for @waderTotalTimeResolutionNone.
  ///
  /// In en, this message translates to:
  /// **'Fix manually'**
  String get waderTotalTimeResolutionNone;

  /// No description provided for @waderTotalTimeResolutionCalculateFromChocks.
  ///
  /// In en, this message translates to:
  /// **'Calculate from chocks'**
  String get waderTotalTimeResolutionCalculateFromChocks;

  /// No description provided for @waderTotalTimeResolutionUseBlock.
  ///
  /// In en, this message translates to:
  /// **'Use block value'**
  String get waderTotalTimeResolutionUseBlock;

  /// No description provided for @waderTotalTimeResolutionIgnoreLine.
  ///
  /// In en, this message translates to:
  /// **'Ignore line'**
  String get waderTotalTimeResolutionIgnoreLine;

  /// No description provided for @waderFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get waderFieldDate;

  /// No description provided for @waderFieldStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get waderFieldStartTime;

  /// No description provided for @waderFieldParkingTime.
  ///
  /// In en, this message translates to:
  /// **'Parking time'**
  String get waderFieldParkingTime;

  /// No description provided for @waderFieldDepartureAirport.
  ///
  /// In en, this message translates to:
  /// **'Departure airport'**
  String get waderFieldDepartureAirport;

  /// No description provided for @waderFieldArrivalAirport.
  ///
  /// In en, this message translates to:
  /// **'Arrival airport'**
  String get waderFieldArrivalAirport;

  /// No description provided for @waderFieldAircraftTail.
  ///
  /// In en, this message translates to:
  /// **'Aircraft tail'**
  String get waderFieldAircraftTail;

  /// No description provided for @waderFieldAircraftType.
  ///
  /// In en, this message translates to:
  /// **'Aircraft type'**
  String get waderFieldAircraftType;

  /// No description provided for @waderFieldTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get waderFieldTotalTime;

  /// No description provided for @waderFieldSimTraineeTime.
  ///
  /// In en, this message translates to:
  /// **'Simulator trainee time'**
  String get waderFieldSimTraineeTime;

  /// No description provided for @waderFieldSimTrainerTime.
  ///
  /// In en, this message translates to:
  /// **'Simulator trainer time'**
  String get waderFieldSimTrainerTime;

  /// No description provided for @reportsBatchChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch changes'**
  String get reportsBatchChangesTitle;

  /// No description provided for @reportsBatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit multiple entries at once'**
  String get reportsBatchSubtitle;

  /// No description provided for @reportsBatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch edit'**
  String get reportsBatchTitle;

  /// No description provided for @reportsBatchHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch edit (filtered entries)'**
  String get reportsBatchHelpTitle;

  /// No description provided for @reportsBatchHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Batch actions apply to entries in the current filtered result set.\n\nThe affected scope follows your current date range, event-type toggles, and active filter conditions.\n\nUse Check flights to preview issues before applying updates.'**
  String get reportsBatchHelpBody;

  /// No description provided for @reportsCalculateAction.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get reportsCalculateAction;

  /// No description provided for @reportsCalculateAll.
  ///
  /// In en, this message translates to:
  /// **'Calculate all'**
  String get reportsCalculateAll;

  /// No description provided for @reportsCalculateAllFlightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate all flights'**
  String get reportsCalculateAllFlightsTitle;

  /// No description provided for @reportsCalculateAllHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate all (filtered flights)'**
  String get reportsCalculateAllHelpTitle;

  /// No description provided for @reportsCalculateAllHelpBody.
  ///
  /// In en, this message translates to:
  /// **'This applies to all currently filtered flights.\n\nFor each field:\n- Don\'t change: keeps the current value.\n- Recalculate: sets the field from available flight data/rules.\n- Set Zero: sets the field to 0.\n\nField notes:\n- Block recalculates from chocks when timestamps are available.\n- IFR, Flight, Instructor, and Custom fields recalculate from Block.\n- Cross-country recalculates using the configured NM threshold.\n- Distance NM recalculates from departure/arrival coordinates.\n- Night, takeoffs, and landings recalculate from day/night calculations.'**
  String get reportsCalculateAllHelpBody;

  /// No description provided for @reportsCalculateDuty.
  ///
  /// In en, this message translates to:
  /// **'Calculate duty'**
  String get reportsCalculateDuty;

  /// No description provided for @reportsCalculateDutyConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate duty'**
  String get reportsCalculateDutyConfirmTitle;

  /// No description provided for @reportsCalculatingDutyPeriods.
  ///
  /// In en, this message translates to:
  /// **'Calculating duty periods...'**
  String get reportsCalculatingDutyPeriods;

  /// No description provided for @reportsCalculatingDutyShort.
  ///
  /// In en, this message translates to:
  /// **'Calculating duty...'**
  String get reportsCalculatingDutyShort;

  /// No description provided for @reportsCheckFlights.
  ///
  /// In en, this message translates to:
  /// **'Check flights'**
  String get reportsCheckFlights;

  /// No description provided for @reportsCheckingShort.
  ///
  /// In en, this message translates to:
  /// **'Checking flights...'**
  String get reportsCheckingShort;

  /// No description provided for @reportsChecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Check flights'**
  String get reportsChecksTitle;

  /// No description provided for @reportsClearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get reportsClearAction;

  /// No description provided for @reportsDeleteTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete template'**
  String get reportsDeleteTemplateTitle;

  /// No description provided for @reportsDownloadAction.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get reportsDownloadAction;

  /// No description provided for @reportsEditPilotProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit pilot profile'**
  String get reportsEditPilotProfile;

  /// No description provided for @reportsEditTemplates.
  ///
  /// In en, this message translates to:
  /// **'Edit templates'**
  String get reportsEditTemplates;

  /// No description provided for @reportsExportInteractiveMap.
  ///
  /// In en, this message translates to:
  /// **'Export map'**
  String get reportsExportInteractiveMap;

  /// No description provided for @reportsLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get reportsLock;

  /// No description provided for @reportsNoChangesApplied.
  ///
  /// In en, this message translates to:
  /// **'No changes applied.'**
  String get reportsNoChangesApplied;

  /// No description provided for @reportsNoFlightIssuesFound.
  ///
  /// In en, this message translates to:
  /// **'No flight issues found.'**
  String get reportsNoFlightIssuesFound;

  /// No description provided for @reportsOpenPdfAfterSaving.
  ///
  /// In en, this message translates to:
  /// **'Open PDF after saving'**
  String get reportsOpenPdfAfterSaving;

  /// No description provided for @reportsPdfGenerationTitle.
  ///
  /// In en, this message translates to:
  /// **'Print logbook'**
  String get reportsPdfGenerationTitle;

  /// No description provided for @reportsPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF options'**
  String get reportsPdfTitle;

  /// No description provided for @reportsPreparingBatchData.
  ///
  /// In en, this message translates to:
  /// **'Preparing batch data...'**
  String get reportsPreparingBatchData;

  /// No description provided for @reportsRunAction.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get reportsRunAction;

  /// No description provided for @reportsSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get reportsSelectAll;

  /// No description provided for @reportsSetCrew.
  ///
  /// In en, this message translates to:
  /// **'Set crew'**
  String get reportsSetCrew;

  /// No description provided for @reportsTabBatch.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get reportsTabBatch;

  /// No description provided for @reportsUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get reportsUnlock;

  /// No description provided for @reportsUploadJson.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get reportsUploadJson;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @settingsCalculationPilotProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Pilot Profile'**
  String get settingsCalculationPilotProfileTitle;

  /// No description provided for @settingsTabDatabase.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get settingsTabDatabase;

  /// No description provided for @settingsTabExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get settingsTabExperience;

  /// No description provided for @settingsTabGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsTabGeneral;

  /// No description provided for @settingsCalculationRulesHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculation Rules'**
  String get settingsCalculationRulesHelpTitle;

  /// No description provided for @settingsCalculationRulesHelpBody.
  ///
  /// In en, this message translates to:
  /// **'These rules control automatic flight-time calculations and apply when calculations are run for filtered flights.\n\nCross-country NM: Minimum distance (NM) required to count cross-country time.\n\nIFR %: Percent of block time used for IFR calculation.\nMinus: Time deducted before IFR percentage is applied.\nMinimum: Minimum IFR time to enforce after percentage/reduction.\n\nIRP3 Reduction: Time deducted before IRP3 percentage is applied.\nIRP3 %: Percent applied for IRP3 after reduction.\n\nIRP4 Reduction: Time deducted before IRP4 percentage is applied.\nIRP4 %: Percent applied for IRP4 after reduction.'**
  String get settingsCalculationRulesHelpBody;

  /// No description provided for @settingsCalculationRulesMinusLabel.
  ///
  /// In en, this message translates to:
  /// **'Minus'**
  String get settingsCalculationRulesMinusLabel;

  /// No description provided for @settingsCalculationRulesMinimumLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get settingsCalculationRulesMinimumLabel;

  /// No description provided for @settingsCalculationRulesIrp3ReductionLabel.
  ///
  /// In en, this message translates to:
  /// **'IRP3 Reduction'**
  String get settingsCalculationRulesIrp3ReductionLabel;

  /// No description provided for @settingsCalculationRulesIrp4ReductionLabel.
  ///
  /// In en, this message translates to:
  /// **'IRP4 Reduction'**
  String get settingsCalculationRulesIrp4ReductionLabel;

  /// No description provided for @settingsExperienceHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get settingsExperienceHelpTitle;

  /// No description provided for @settingsExperienceHelpBody.
  ///
  /// In en, this message translates to:
  /// **'This section allows you to manage previous experience totals by aircraft type.\nThese totals are automatically included in all relevant reports and calculations whenever previous experience is enabled in the system.'**
  String get settingsExperienceHelpBody;

  /// No description provided for @settingsPilotProfileHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Pilot Profile'**
  String get settingsPilotProfileHelpTitle;

  /// No description provided for @settingsPilotProfileHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Pilot Profile stores report identity and signature preferences.\n\nName, Address, and Licenses are used in generated reports.\nSignature is used where report templates include a signature field.\n\nUse Edit profile to update these values.'**
  String get settingsPilotProfileHelpBody;

  /// No description provided for @settingsPilotProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsPilotProfileNameLabel;

  /// No description provided for @settingsPilotProfileAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get settingsPilotProfileAddressLabel;

  /// No description provided for @settingsPilotProfileLicensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get settingsPilotProfileLicensesLabel;

  /// No description provided for @settingsPilotProfileNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingsPilotProfileNotSet;

  /// No description provided for @settingsTimeFieldsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Fields'**
  String get settingsTimeFieldsHelpTitle;

  /// No description provided for @settingsTimeFieldsHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Configure which time fields are displayed in the Add Flight form to match your logging requirements. Enabling a field includes it in new entries, while disabling it removes it from the form to reduce clutter and focus on relevant data.\n\nFields that are disabled will still be shown when they contain recorded time, ensuring all logged data remains visible and available for review or amendment.'**
  String get settingsTimeFieldsHelpBody;

  /// No description provided for @settingsDutyRulesHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Duty Rules'**
  String get settingsDutyRulesHelpTitle;

  /// No description provided for @settingsDutyRulesHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Duty rules are used when calculating duty periods.\n\nCrew home base airport: Airport used to determine on-base vs off-base reporting assumptions.\nReporting time on base: Minutes added before duty start when departure is from home base.\nReporting time offbase: Minutes added before duty start when away from home base.\nDuty end time allowance: Minutes added after the last operational event before duty ends.\nMinimum rest time: Minimum rest required between consecutive duty periods.'**
  String get settingsDutyRulesHelpBody;

  /// No description provided for @settingsTabTimeFields.
  ///
  /// In en, this message translates to:
  /// **'Time Fields'**
  String get settingsTabTimeFields;

  /// No description provided for @simplelogConflictResolutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Conflict resolution'**
  String get simplelogConflictResolutionTitle;

  /// No description provided for @simplelogCrossCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Cross-country time'**
  String get simplelogCrossCountryLabel;

  /// No description provided for @simplelogCrossCountryNmLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance threshold (NM)'**
  String get simplelogCrossCountryNmLabel;

  /// No description provided for @simplelogIfrPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'IFR %'**
  String get simplelogIfrPercentLabel;

  /// No description provided for @simplelogIfrTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'IFR time'**
  String get simplelogIfrTimeLabel;

  /// No description provided for @simplelogImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get simplelogImportAction;

  /// No description provided for @simplelogImportOptionsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Import SimpleLog options'**
  String get simplelogImportOptionsHelpTitle;

  /// No description provided for @simplelogImportOptionsHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Recalculate total time: recalculates Total Minutes from available departure/arrival data.\nIRP3 time: minutes deducted before IRP3 % is applied.\nIRP3 %: percentage applied after IRP3 deduction.\nIRP4 time: minutes deducted before IRP4 % is applied.\nIRP4 %: percentage applied after IRP4 deduction.\n\nNight time: recalculates night minutes from route and timestamps.\nTakeoffs and landings: recalculates day/night takeoff and landing distribution.\nCross-country time: recalculates cross-country minutes from distance.\nDistance threshold (NM): minimum distance required to count as cross-country.\n\nIFR time: recalculates IFR minutes.\nMinus: minutes subtracted before IFR % is applied.\nIFR %: percentage applied after subtraction.\nMinimum: minimum IFR minutes enforced after subtraction and percentage.\n\nOverwrite airport on conflict: updates existing airport records when imported values differ.\nOverwrite aircraft on conflict: updates existing aircraft records when imported values differ.\nOverwrite type on conflict: updates existing aircraft type records when imported values differ.'**
  String get simplelogImportOptionsHelpBody;

  /// No description provided for @simplelogImportOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import SimpleLog'**
  String get simplelogImportOptionsTitle;

  /// No description provided for @simplelogIrp3PercentLabel.
  ///
  /// In en, this message translates to:
  /// **'IRP3 %'**
  String get simplelogIrp3PercentLabel;

  /// No description provided for @simplelogIrp3TimeLabel.
  ///
  /// In en, this message translates to:
  /// **'IRP3 time'**
  String get simplelogIrp3TimeLabel;

  /// No description provided for @simplelogIrp4PercentLabel.
  ///
  /// In en, this message translates to:
  /// **'IRP4 %'**
  String get simplelogIrp4PercentLabel;

  /// No description provided for @simplelogIrp4TimeLabel.
  ///
  /// In en, this message translates to:
  /// **'IRP4 time'**
  String get simplelogIrp4TimeLabel;

  /// No description provided for @simplelogNightTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Night time'**
  String get simplelogNightTimeLabel;

  /// No description provided for @simplelogOverrideAircraftOnConflict.
  ///
  /// In en, this message translates to:
  /// **'Overwrite aircraft on conflict'**
  String get simplelogOverrideAircraftOnConflict;

  /// No description provided for @simplelogOverrideAircraftTypeOnConflict.
  ///
  /// In en, this message translates to:
  /// **'Overwrite type on conflict'**
  String get simplelogOverrideAircraftTypeOnConflict;

  /// No description provided for @simplelogOverrideAirportOnConflict.
  ///
  /// In en, this message translates to:
  /// **'Overwrite airport on conflict'**
  String get simplelogOverrideAirportOnConflict;

  /// No description provided for @simplelogRecalcTotalTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Recalculate total time'**
  String get simplelogRecalcTotalTimeLabel;

  /// No description provided for @simplelogRecalculationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recalculations'**
  String get simplelogRecalculationsTitle;

  /// No description provided for @simplelogTakeoffLandingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Takeoffs and landings'**
  String get simplelogTakeoffLandingsLabel;

  /// No description provided for @southwestAddCopilotStaffNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Add copilot staff number'**
  String get southwestAddCopilotStaffNumberLabel;

  /// No description provided for @southwestAddFlightNumberToNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Add flight number to notes'**
  String get southwestAddFlightNumberToNotesLabel;

  /// No description provided for @southwestCalculateCrossCountryTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Calculate cross-country'**
  String get southwestCalculateCrossCountryTimeLabel;

  /// No description provided for @southwestCalculateIfrTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Calculate IFR time'**
  String get southwestCalculateIfrTimeLabel;

  /// No description provided for @southwestCalculateNightTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Calculate night time'**
  String get southwestCalculateNightTimeLabel;

  /// No description provided for @southwestCrossCountryThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Cross-country threshold (NM)'**
  String get southwestCrossCountryThresholdLabel;

  /// No description provided for @southwestDefaultSelfPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Crew Function'**
  String get southwestDefaultSelfPositionLabel;

  /// No description provided for @southwestImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get southwestImportAction;

  /// No description provided for @southwestImportOptionsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Southwest options'**
  String get southwestImportOptionsHelpTitle;

  /// No description provided for @southwestImportOptionsHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Crew Function: sets your own role for imported Southwest flights (PIC or SIC).\n\nRecalculate block time: uses departure/arrival timestamps to compute block.\nCalculate night time: computes night minutes from departure/arrival and route.\nCalculate IFR time: computes IFR from block using IFR %, Minus, and Minimum.\nIFR %: percentage applied to block minutes.\nMinus: minutes subtracted before the percentage is applied.\nMinimum: minimum IFR minutes enforced after percentage/subtraction.\nCalculate cross-country: computes cross-country minutes from distance.\nCross-country threshold (NM): minimum distance required to count as cross-country.\n\nOverwrite existing data: updates matching flights already in the database.\nAdd copilot staff number: appends copilot staff number to notes when available.\nAdd flight number to notes: appends the Southwest flight number to notes.'**
  String get southwestImportOptionsHelpBody;

  /// No description provided for @southwestImportOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Southwest'**
  String get southwestImportOptionsTitle;

  /// No description provided for @southwestOverrideExistingDataLabel.
  ///
  /// In en, this message translates to:
  /// **'Overwrite existing data'**
  String get southwestOverrideExistingDataLabel;

  /// No description provided for @southwestRecalculateBlockTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Recalculate block time'**
  String get southwestRecalculateBlockTimeLabel;

  /// No description provided for @southwestPreflightMissingRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing required fields'**
  String get southwestPreflightMissingRequiredTitle;

  /// No description provided for @southwestPreflightMissingRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Missing required data:'**
  String get southwestPreflightMissingRequiredMessage;

  /// No description provided for @southwestPreflightMissingTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing aircraft type'**
  String get southwestPreflightMissingTypeTitle;

  /// No description provided for @southwestPreflightMissingTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose how to handle lines with missing aircraft type.'**
  String get southwestPreflightMissingTypeMessage;

  /// No description provided for @southwestPreflightMissingTypeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing aircraft type'**
  String get southwestPreflightMissingTypeInfoTitle;

  /// No description provided for @southwestPreflightMissingTypeInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Skip Lines will not import the listed lines.\n\nImport Anyway will import those lines and set aircraft type to UNKNOWN.'**
  String get southwestPreflightMissingTypeInfoMessage;

  /// No description provided for @southwestPreflightMissingTailTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing Tail Number'**
  String get southwestPreflightMissingTailTitle;

  /// No description provided for @southwestPreflightMissingTailMessage.
  ///
  /// In en, this message translates to:
  /// **'The following lines are missing Tail Number:'**
  String get southwestPreflightMissingTailMessage;

  /// No description provided for @southwestPreflightMissingTailInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing tail number'**
  String get southwestPreflightMissingTailInfoTitle;

  /// No description provided for @southwestPreflightMissingTailInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Skip Lines will not import the listed lines.\n\nImport Anyway will import those lines and create aircraft with tail number equal to the aircraft type.'**
  String get southwestPreflightMissingTailInfoMessage;

  /// No description provided for @southwestPreflightSkipLinesAction.
  ///
  /// In en, this message translates to:
  /// **'Skip Lines'**
  String get southwestPreflightSkipLinesAction;

  /// No description provided for @southwestPreflightImportAnywayAction.
  ///
  /// In en, this message translates to:
  /// **'Import Anyway'**
  String get southwestPreflightImportAnywayAction;

  /// No description provided for @southwestPreflightHowProceedLabel.
  ///
  /// In en, this message translates to:
  /// **'How would you like to proceed?'**
  String get southwestPreflightHowProceedLabel;

  /// No description provided for @southwestPreflightImportUnknownTypeAction.
  ///
  /// In en, this message translates to:
  /// **'Import with type UNKNOWN'**
  String get southwestPreflightImportUnknownTypeAction;

  /// No description provided for @southwestPreflightImportTailFromTypeAction.
  ///
  /// In en, this message translates to:
  /// **'Import anyway (tail = type)'**
  String get southwestPreflightImportTailFromTypeAction;

  /// No description provided for @southwestPreflightFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get southwestPreflightFieldDate;

  /// No description provided for @southwestPreflightFieldDepartureAirport.
  ///
  /// In en, this message translates to:
  /// **'Departure airport'**
  String get southwestPreflightFieldDepartureAirport;

  /// No description provided for @southwestPreflightFieldArrivalAirport.
  ///
  /// In en, this message translates to:
  /// **'Arrival airport'**
  String get southwestPreflightFieldArrivalAirport;

  /// No description provided for @southwestPreflightFieldDepartureTime.
  ///
  /// In en, this message translates to:
  /// **'Departure time'**
  String get southwestPreflightFieldDepartureTime;

  /// No description provided for @southwestPreflightFieldArrivalTime.
  ///
  /// In en, this message translates to:
  /// **'Arrival time'**
  String get southwestPreflightFieldArrivalTime;

  /// No description provided for @southwestPreflightMissingFieldsReason.
  ///
  /// In en, this message translates to:
  /// **'Missing: {fields}'**
  String southwestPreflightMissingFieldsReason(String fields);

  /// No description provided for @southwestPreflightMissingTypeReason.
  ///
  /// In en, this message translates to:
  /// **'Missing aircraft type.'**
  String get southwestPreflightMissingTypeReason;

  /// No description provided for @southwestPreflightMissingTailReason.
  ///
  /// In en, this message translates to:
  /// **'Missing aircraft tail. Aircraft type: {typeCode}.'**
  String southwestPreflightMissingTailReason(String typeCode);

  /// No description provided for @southwestPreflightUnknownTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get southwestPreflightUnknownTypeLabel;

  /// No description provided for @southwestTypeMappingsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Aircraft type mappings'**
  String get southwestTypeMappingsDialogTitle;

  /// No description provided for @southwestTypeMappingsDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Resolve aircraft types from this file before importing.'**
  String get southwestTypeMappingsDialogMessage;

  /// No description provided for @southwestTypeMappingsRawTypeValue.
  ///
  /// In en, this message translates to:
  /// **'Original type: {value}'**
  String southwestTypeMappingsRawTypeValue(String value);

  /// No description provided for @southwestTypeMappingsAircraftUsageValue.
  ///
  /// In en, this message translates to:
  /// **'Used by {count} aircraft: {registrations}'**
  String southwestTypeMappingsAircraftUsageValue(
    int count,
    String registrations,
  );

  /// No description provided for @southwestTypeMappingsEmptyRawTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get southwestTypeMappingsEmptyRawTypeLabel;

  /// No description provided for @southwestTypeMappingsAutoCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Auto-create from raw type'**
  String get southwestTypeMappingsAutoCreateAction;

  /// No description provided for @southwestTypeMappingsUseUnknownAction.
  ///
  /// In en, this message translates to:
  /// **'Use UNKNOWN'**
  String get southwestTypeMappingsUseUnknownAction;

  /// No description provided for @southwestTypeMappingsReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Review aircraft type mappings'**
  String get southwestTypeMappingsReviewAction;

  /// No description provided for @southwestTypeMappingsContinueWithoutReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Continue import'**
  String get southwestTypeMappingsContinueWithoutReviewAction;

  /// No description provided for @southwestTypeMappingsResolvedPrompt.
  ///
  /// In en, this message translates to:
  /// **'All aircraft types in this file are already mapped. You can continue or review mappings before import.'**
  String get southwestTypeMappingsResolvedPrompt;

  /// No description provided for @databaseAircraftLabel.
  ///
  /// In en, this message translates to:
  /// **'Aircraft: {count}'**
  String databaseAircraftLabel(int count);

  /// No description provided for @databaseAircraftTypesLabel.
  ///
  /// In en, this message translates to:
  /// **'Aircraft types: {count}'**
  String databaseAircraftTypesLabel(int count);

  /// No description provided for @databaseAirportsLabel.
  ///
  /// In en, this message translates to:
  /// **'Airports: {count}'**
  String databaseAirportsLabel(int count);

  /// No description provided for @databaseCrewLabel.
  ///
  /// In en, this message translates to:
  /// **'Crew: {count}'**
  String databaseCrewLabel(int count);

  /// No description provided for @databaseErrorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Errors: {count}'**
  String databaseErrorsLabel(int count);

  /// No description provided for @databaseFileLabel.
  ///
  /// In en, this message translates to:
  /// **'File: {fileName}'**
  String databaseFileLabel(String fileName);

  /// No description provided for @databaseFlightsLabel.
  ///
  /// In en, this message translates to:
  /// **'Flights: {count}'**
  String databaseFlightsLabel(int count);

  /// No description provided for @databaseImportProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Importing {processed} of {total}'**
  String databaseImportProgressLabel(int processed, int total);

  /// No description provided for @databaseLineIssueLabel.
  ///
  /// In en, this message translates to:
  /// **'Line {lineNumber}: {reason}'**
  String databaseLineIssueLabel(int lineNumber, String reason);

  /// No description provided for @databasePositioningsLabel.
  ///
  /// In en, this message translates to:
  /// **'Positionings: {count}'**
  String databasePositioningsLabel(int count);

  /// No description provided for @databaseRowsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rows: {count}'**
  String databaseRowsLabel(int count);

  /// No description provided for @databaseSimulatorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Simulators: {count}'**
  String databaseSimulatorsLabel(int count);

  /// No description provided for @databaseSkippedLabel.
  ///
  /// In en, this message translates to:
  /// **'Skipped: {count}'**
  String databaseSkippedLabel(int count);

  /// No description provided for @logtenLineLabel.
  ///
  /// In en, this message translates to:
  /// **'Line {lineNumber}'**
  String logtenLineLabel(int lineNumber);

  /// No description provided for @reportsBatchWarning.
  ///
  /// In en, this message translates to:
  /// **'This action will update {count} filtered entries.'**
  String reportsBatchWarning(int count);

  /// No description provided for @reportsCalculateDutyConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Recalculate duty periods for {count} flights?'**
  String reportsCalculateDutyConfirmBody(int count);

  /// No description provided for @reportsDeleteTemplateBody.
  ///
  /// In en, this message translates to:
  /// **'Delete template \"{templateName}\"?'**
  String reportsDeleteTemplateBody(String templateName);

  /// No description provided for @reportsIssueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} issues'**
  String reportsIssueCount(int count);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile and default rules to start logging faster.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingSkipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkipAction;

  /// No description provided for @onboardingNextAction.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNextAction;

  /// No description provided for @onboardingBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBackAction;

  /// No description provided for @onboardingFinishAction.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinishAction;

  /// No description provided for @onboardingPilotProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Pilot Profile'**
  String get onboardingPilotProfileTitle;

  /// No description provided for @onboardingPilotProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Add your profile details and signature for reports.'**
  String get onboardingPilotProfileBody;

  /// No description provided for @onboardingRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculation and Duty Rules'**
  String get onboardingRulesTitle;

  /// No description provided for @onboardingRulesBody.
  ///
  /// In en, this message translates to:
  /// **'Review calculation factors and duty rules before your first entries.'**
  String get onboardingRulesBody;

  /// No description provided for @onboardingFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get onboardingFieldsTitle;

  /// No description provided for @onboardingFieldsBody.
  ///
  /// In en, this message translates to:
  /// **'Choose which time fields are visible and rename custom fields.'**
  String get onboardingFieldsBody;

  /// No description provided for @newDutyTitle.
  ///
  /// In en, this message translates to:
  /// **'New Duty'**
  String get newDutyTitle;

  /// No description provided for @editDutyTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Duty'**
  String get editDutyTitle;

  /// No description provided for @newPositioningTitle.
  ///
  /// In en, this message translates to:
  /// **'New Positioning'**
  String get newPositioningTitle;

  /// No description provided for @editPositioningTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Positioning'**
  String get editPositioningTitle;

  /// No description provided for @newSimTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'New Sim Training'**
  String get newSimTrainingTitle;

  /// No description provided for @editSimTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Sim Training'**
  String get editSimTrainingTitle;

  /// No description provided for @aircraftRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Aircraft is required.'**
  String get aircraftRequiredError;

  /// No description provided for @fromAirportRequiredError.
  ///
  /// In en, this message translates to:
  /// **'From Airport is required.'**
  String get fromAirportRequiredError;

  /// No description provided for @toAirportRequiredError.
  ///
  /// In en, this message translates to:
  /// **'To Airport is required.'**
  String get toAirportRequiredError;

  /// No description provided for @reportsAllEntriesAlreadyLocked.
  ///
  /// In en, this message translates to:
  /// **'All filtered entries are already locked.'**
  String get reportsAllEntriesAlreadyLocked;

  /// No description provided for @reportsAllEntriesAlreadyUnlocked.
  ///
  /// In en, this message translates to:
  /// **'All filtered entries are already unlocked.'**
  String get reportsAllEntriesAlreadyUnlocked;

  /// No description provided for @reportsLockEntriesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock entries?'**
  String get reportsLockEntriesConfirmTitle;

  /// No description provided for @reportsUnlockEntriesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock entries?'**
  String get reportsUnlockEntriesConfirmTitle;

  /// No description provided for @reportsLockFilteredEntriesMessage.
  ///
  /// In en, this message translates to:
  /// **'This will lock {count} filtered entries.'**
  String reportsLockFilteredEntriesMessage(int count);

  /// No description provided for @reportsUnlockFilteredEntriesMessage.
  ///
  /// In en, this message translates to:
  /// **'This will unlock {count} filtered entries.'**
  String reportsUnlockFilteredEntriesMessage(int count);

  /// No description provided for @previousExperienceValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'Validation warnings'**
  String get previousExperienceValidationTitle;

  /// No description provided for @previousExperienceSaveAnywayPrompt.
  ///
  /// In en, this message translates to:
  /// **'Save anyway?'**
  String get previousExperienceSaveAnywayPrompt;

  /// No description provided for @previousExperienceReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get previousExperienceReviewAction;

  /// No description provided for @previousExperienceSaveAnywayAction.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get previousExperienceSaveAnywayAction;

  /// No description provided for @previousExperienceSelectAircraftType.
  ///
  /// In en, this message translates to:
  /// **'Select aircraft type.'**
  String get previousExperienceSelectAircraftType;

  /// No description provided for @previousExperienceFirstFlightRequired.
  ///
  /// In en, this message translates to:
  /// **'First Flight is required.'**
  String get previousExperienceFirstFlightRequired;

  /// No description provided for @previousExperienceLastFlightRequired.
  ///
  /// In en, this message translates to:
  /// **'Last Flight is required.'**
  String get previousExperienceLastFlightRequired;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
